//
//  RESTResource.h
//  TMSMobile
//
//  Created by Robert Walker on 9/29/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RESTResource <NSObject>

+ (NSURL *)collectionURL;
- (NSURL *)objectURLUsingParameters:(NSDictionary **)queryParameters;

@end
