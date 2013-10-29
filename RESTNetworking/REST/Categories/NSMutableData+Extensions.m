//
//  NSMutableData+Extensions.m
//  TMSMobile
//
//  Created by Robert Walker on 8/11/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import "NSMutableData+Extensions.h"


@implementation NSMutableData (NSMutableData_Extensions)

- (void)appendUTF8String:(NSString *)utf8String
{
    [self appendData:[utf8String dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
