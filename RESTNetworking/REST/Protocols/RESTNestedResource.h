//
//  RESTNestedResource.h
//  TMSMobile
//
//  Created by Robert Walker on 9/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResource.h"

@protocol RESTNestedResource <NSObject>

+ (NSURL *)collectionURLNestedIn:(id<RESTResource>)parent usingParameters:(NSDictionary **)queryParameters;
- (NSURL *)objectURLNestedIn:(id<RESTResource>)parent usingParameters:(NSDictionary **)queryParameters;

@optional
+ (NSURL *)collectionURLUsingParameters:(NSDictionary **)queryParameters;
- (NSURL *)objectURLUsingParameters:(NSDictionary **)queryParameters;

@end
