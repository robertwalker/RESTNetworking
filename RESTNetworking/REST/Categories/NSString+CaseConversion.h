//
//  NSString+CaseConversion.h
//  TMSMobile
//
//  Created by Robert Walker on 8/23/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_CaseConversion)

- (NSString *)camelize;
- (NSString *)camelizeWithFirstLetterCapitialized:(BOOL)capitializeFirstLetter;
- (NSString *)underscore;
- (NSString *)dasherize;
- (NSString *)decamelizeWithSeparator:(NSString *)theSeperator;
- (NSString *)humanize;

@end
