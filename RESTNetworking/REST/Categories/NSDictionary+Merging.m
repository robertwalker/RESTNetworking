//
//  NSDictionary+Merging.m
//  TMSMobile
//
//  Created by Robert Walker on 9/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import "NSDictionary+Merging.h"


@implementation NSDictionary (NSDictionary_Merging)

- (NSDictionary *)dictionaryByMergingDictionary:(NSDictionary *)dictionary
{
    if (dictionary == nil || [dictionary count] == 0)
        return self;
    
    NSMutableDictionary *mergeDict = [NSMutableDictionary dictionaryWithDictionary:self];
    [mergeDict addEntriesFromDictionary:dictionary];
    return [mergeDict copy];
}

@end
