//
//  NSURLRequest+RESTExtensions.h
//  TMSMobile
//
//  Created by Robert Walker on 2/28/12.
//  Copyright (c) 2012 Bennett International Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (RESTExtensions)

#pragma mark - REST requests

+ (NSURLRequest *)GETRequestWithURL:(NSURL *)url;
+ (NSURLRequest *)POSTRequestWithURL:(NSURL *)url;
+ (NSURLRequest *)PUTRequestWithURL:(NSURL *)url;
+ (NSURLRequest *)DELETERequestWithURL:(NSURL *)url;

+ (NSURLRequest *)GETRequestWithURL:(NSURL *)url queryParams:(NSDictionary *)queryParams;
+ (NSURLRequest *)POSTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData;
+ (NSURLRequest *)PUTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData;
+ (NSURLRequest *)DELETERequestWithURL:(NSURL *)url queryParams:(NSDictionary *)queryParams;

#pragma mark - REST requests with attachments

+ (NSURLRequest *)POSTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData attachments:(NSArray *)attachments;
+ (NSURLRequest *)PUTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData attachments:(NSArray *)attachments;

#pragma mark - Class utility methods

+ (NSArray *)parseErrorsFromJSONResponseData:(NSData *)json;

@end
