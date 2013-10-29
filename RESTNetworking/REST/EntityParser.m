//
//  EntityParser.m
//  TMSMobile
//
//  Created by Robert Walker on 7/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import "EntityParser.h"
#import "NSString+CaseConversion.h"
#import "NSManagedObject+RESTExtensions.h"

@interface EntityParser ()

#pragma mark Properties

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *currentArrayName;
@property (strong, nonatomic) NSString *currentEntityName;
@property (strong, nonatomic) NSManagedObject *currentObject;
@property (strong, nonatomic) NSString *currentProperty;
@property (strong, nonatomic) NSMutableString *currentStringValue;

#pragma mark - Private methods

- (void)buildManagedObjectWithDictionary:(NSDictionary *)dict;
- (void)assignToDestinationEntity:(NSEntityDescription *)entity
                 relationshipName:(NSString *)relationshipName
                       identifier:(id)idValue;

@end

#pragma mark -

@implementation EntityParser
{
    NSUInteger objectCount;
}

#pragma mark Properties

@synthesize context = _context;
@synthesize currentArrayName = _currentArrayName;
@synthesize currentEntityName = _currentEntityName;
@synthesize currentObject = _currentObject;
@synthesize currentProperty = _currentProperty;
@synthesize currentStringValue = _currentStringValue;

#pragma mark - Object lifecycle

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)theContext
{
    self = [super init];
    if (self) {
        _context = theContext;
        objectCount = 0;
    }
    return self;
}

#pragma mark - Deserialization methods

// JSON
- (void)parseObjectForEntityNamed:(NSString *)entityName fromJSON:(NSData *)json
{
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    if (!dict) {
        return;
    }
    
    self.currentEntityName = [entityName copy];
    
    [self buildManagedObjectWithDictionary:dict];
}

- (NSUInteger)parseObjectsForEntityNamed:(NSString *)entityName fromJSON:(NSData *)json
{
    NSError *error;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
    if (!arr) {
        return 0;
    }
    
    self.currentEntityName = [entityName copy];
    
    for (NSDictionary *dict in arr) {
        [self buildManagedObjectWithDictionary:dict];
    }
    
    return [arr count];
}

// XML
- (void)parseObjectForEntityNamed:(NSString *)entityName fromXML:(NSData *)xml
{
    [self parseObjectsForEntityNamed:entityName fromXML:xml];
}

- (NSUInteger)parseObjectsForEntityNamed:(NSString *)entityName fromXML:(NSData *)xml
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xml];
    [xmlParser setDelegate:self];
    
    self.currentEntityName = [entityName copy];
    
    if (self.context) {
        [xmlParser parse];
    }
    
    return objectCount;
}

#pragma mark - Private methods

- (void)buildManagedObjectWithDictionary:(NSDictionary *)dict
{
    NSString *idString = [[dict objectForKey:@"id"] description];
    
    self.currentObject = [NSManagedObject findOrCreateEntityWithName:self.currentEntityName identifier:idString inContext:self.context];
    [self.currentObject takeValuesFromJSONDictionary:dict];
    
    // Setup two-one associations
    NSDictionary *relations = [[self.currentObject entity] relationshipsByName];
    NSRelationshipDescription *relation;
    NSString *foreignKeyAttributeName;
    id foreignKeyValue;
    for (NSString *relationName in [relations allKeys]) {
        relation = [relations objectForKey:relationName];
        if (![relation isToMany]) {
            foreignKeyAttributeName = [NSString stringWithFormat:@"%@Id", relationName];
            foreignKeyValue = [self.currentObject valueForKey:foreignKeyAttributeName];
            [self assignToDestinationEntity:[relation destinationEntity]
                           relationshipName:relationName
                                 identifier:foreignKeyValue];
        }
    }
}

- (void)assignToDestinationEntity:(NSEntityDescription *)entity
                 relationshipName:(NSString *)relationshipName
                       identifier:(id)idValue
{
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", idValue];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *array = [self.context executeFetchRequest:request error:&error];
    
    NSManagedObject *destinationObject;
    if ([array count] == 1) {
        destinationObject = (NSManagedObject *)[array objectAtIndex:0];
        [self.currentObject setValue:destinationObject forKey:relationshipName];
    }
}

#pragma mark - NSXMLParser delegate

- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSString *elementNameAsClass = [elementName camelizeWithFirstLetterCapitialized:YES];
    NSString *elementNameAsAttribute = ([elementName isEqualToString:@"id"]) ? @"uid" : [elementName camelize];
    
    // Clear any previously found characters
    self.currentStringValue = nil;
    
    // Begin object array
    if ([[attributeDict objectForKey:@"type"] isEqualToString:@"array"]) {
        self.currentArrayName = [elementName copy];
        return;
    }
    
    // Begin object
    if ([elementNameAsClass isEqualToString:self.currentEntityName] && [attributeDict count] == 0) {
        self.currentObject = [NSManagedObject findOrCreateEntityWithName:self.currentEntityName identifier:[attributeDict objectForKey:@"id"] inContext:self.context];
        return;
    }
    
    // Begin object attribute
    if ([elementNameAsAttribute isEqualToString:@"description"]) {
        elementNameAsAttribute = @"textDescription";
    }
    if ([[[[self.currentObject entity] attributesByName] allKeys] containsObject:elementNameAsAttribute]) {
        self.currentProperty = elementNameAsAttribute;
        return;
    }
}

- (void)parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string
{
    if (!self.currentStringValue) {
        self.currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.currentStringValue appendString:trimmed];
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *elementNameAsClass = [elementName camelizeWithFirstLetterCapitialized:YES];
    NSString *elementNameAsAttribute = ([elementName isEqualToString:@"id"]) ? @"uid" : [elementName camelize];
    
    // End object array
    if ([self.currentArrayName isEqualToString:elementName]) {
        self.currentArrayName = nil;
    }
    
    // End the object
    if ([elementNameAsClass isEqualToString:self.currentEntityName]) {
        objectCount++;
        self.currentObject = nil;
    }
    
    // The attribute name "description" can't be used since it is a reserved word.
    // Use "textDescription" in the Core Data objects instead.
    if ([elementNameAsAttribute isEqualToString:@"description"]) {
        elementNameAsAttribute = @"textDescription";
    }
    
    // End attribute element
    if ([elementNameAsAttribute isEqualToString:self.currentProperty]) {
        [self.currentObject setValueWithString:self.currentStringValue forKey:self.currentProperty];
        return;
    }
    
    // Cleanup memory
    self.currentStringValue = nil;
}

@end
