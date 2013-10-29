//
//  NSManagedObject+RESTExtensions.m
//  TMSMobile
//
//  Created by Robert Walker on 7/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import "NSManagedObject+RESTExtensions.h"
#import "NSString+CaseConversion.h"

@implementation NSManagedObject (RESTExtensions)

+ (NSManagedObject *)findOrCreateEntityWithName:(NSString *)entityName
                                     identifier:(NSString *)idString
                                      inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSManagedObject *obj;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@", idString];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *array = [context executeFetchRequest:request error:&error];
    if ([array count] > 0) {
        // Return the found object
        obj = [array objectAtIndex:0];
    } else {
        // Create and return new instance
        obj = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                            inManagedObjectContext:context];
        [obj setValueWithString:idString forKey:@"uid"];
    }
    
    return obj;
}

- (void)takeValuesFromJSONDictionary:(NSDictionary *)jsonDict
{
    if (!jsonDict) {
        return;
    }
    
    NSArray *attributeNames = [[[self entity] attributesByName] allKeys];
    NSString *camelizedKey;
    for (NSString *key in [jsonDict allKeys]) {
        camelizedKey = [key camelize];
        id value = [jsonDict objectForKey:key];
        if (![key isEqualToString:@"id"] && value != [NSNull null] && [attributeNames containsObject:camelizedKey]) {
            [self setValueWithString:[value description] forKey:camelizedKey];
        }
    }
}

- (void)setValueWithString:(NSString *)strValue forKey:(NSString *)key
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];

    NSEntityDescription *entity = [self entity];
    NSAttributeDescription *attrDesc = [[entity attributesByName] objectForKey:key];
    NSString *str;
    switch ([attrDesc attributeType]) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
            [self setValue:[NSNumber numberWithInteger:[strValue integerValue]] forKey:key];
            break;
        case NSInteger64AttributeType:
            [self setValue:[NSNumber numberWithLongLong:[strValue longLongValue]] forKey:key];
            break;
        case NSFloatAttributeType:
            [self setValue:[NSNumber numberWithFloat:[strValue floatValue]] forKey:key];
            break;
        case NSDoubleAttributeType:
            [self setValue:[NSNumber numberWithDouble:[strValue doubleValue]] forKey:key];
            break;
        case NSBooleanAttributeType:
            [self setValue:(([strValue isEqualToString:@"true"])
                            ? [NSNumber numberWithBool:YES]
                            : [NSNumber numberWithBool:NO]) forKey:key];
            break;
        case NSDecimalAttributeType:
            [self setValue:[NSDecimalNumber decimalNumberWithString:strValue] forKey:key];
            break;
        case NSDateAttributeType:
            if ([strValue hasSuffix:@"Z"]) {
                str = [strValue stringByReplacingCharactersInRange:NSMakeRange([strValue length] - 1, 1)
                                                        withString:@"GMT+00:00"];
            }
            else if ([strValue length] > 19) {
                str = [strValue stringByReplacingCharactersInRange:NSMakeRange(19, 0)
                                                        withString:@"GMT"];
            } else {
                str = strValue;
            }
            [self setValue:[formatter dateFromString:str] forKey:key];
            break;
        default:
            [self setValue:strValue forKey:key];
            break;
    }
}

- (NSDictionary *)formDataRepresentation
{
    NSEntityDescription *entity = [self entity];
    NSDictionary *attributes = [entity attributesByName];
    return [self formDataRepresentationWithAttributeNames:[attributes allKeys]];
}

- (NSDictionary *)formDataRepresentationWithAttributeNames:(NSArray *)attributeNames
{
    NSMutableDictionary *formData = [NSMutableDictionary dictionary];
    
    NSEntityDescription *entity = [self entity];
    NSDictionary *attributes = [entity attributesByName];
    id objectValue;
    NSString *modelScope = [[entity name] underscore];
    NSString *scopedKey;
    NSString *valueString;
    NSAttributeDescription *attribute;
    for (NSString *attributeName in attributeNames) {
        attribute = [attributes objectForKey:attributeName];
        objectValue = [self valueForKey:attributeName];
        scopedKey = [NSString stringWithFormat:@"%@[%@]", modelScope, [attributeName underscore]];
        if (objectValue) {
            valueString = [self stringReqresentationOfValue:objectValue
                                                       type:[attribute attributeType]];
            [formData setObject:valueString forKey:scopedKey];
        }
    }
    return formData;
}

- (NSString *)stringReqresentationOfValue:(id)value type:(NSAttributeType)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:1];
    
    
    switch (type) {
        case NSFloatAttributeType:
        case NSDoubleAttributeType:
            return [numberFormatter stringFromNumber:value];
        case NSBooleanAttributeType:
            return ([value integerValue] == 0) ? @"false" : @"true";
        case NSDateAttributeType:
            return [dateFormatter stringFromDate:value];
        default:
            return [value description];
    }
}

@end
