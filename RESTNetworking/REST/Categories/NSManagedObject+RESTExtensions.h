//
//  NSManagedObject+RESTExtensions.h
//  TMSMobile
//
//  Created by Robert Walker on 7/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (RESTExtensions)

+ (NSManagedObject *)findOrCreateEntityWithName:(NSString *)entityName
                                     identifier:(NSString *)idString
                                      inContext:(NSManagedObjectContext *)context;
- (void)takeValuesFromJSONDictionary:(NSDictionary *)jsonDict;
- (void)setValueWithString:(NSString *)strValue forKey:(NSString *)key;
- (NSDictionary *)formDataRepresentation;
- (NSDictionary *)formDataRepresentationWithAttributeNames:(NSArray *)attributeNames;
- (NSString *)stringReqresentationOfValue:(id)value type:(NSAttributeType)type;

@end
