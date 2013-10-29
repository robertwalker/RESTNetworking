//
//  NSURLRequest+RESTExtensions.m
//  TMSMobile
//
//  Created by Robert Walker on 2/28/12.
//  Copyright (c) 2012 Bennett International Group. All rights reserved.
//

#import "NSURLRequest+RESTExtensions.h"
#import "Attachment.h"
#import "NSMutableData+Extensions.h"

static NSString * const BOUNDARY_PREFIX = @"----WebKitFormBoundary";

@implementation NSURLRequest (RESTExtensions)

#pragma mark - Private utility methods

+ (NSString *)encodedStringValue:(NSString *)value
{
    NSString *stringValue = [value description];
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)stringValue, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    return result;
}

+ (NSString *)encodedValuesWithDictionary:(NSDictionary *)valueDictionary
{
    NSMutableArray *encodedValues = [NSMutableArray arrayWithCapacity:20];
    NSString *encodedKey;
    NSString *encodedValue;
    
    id value = nil;
    for (id key in [valueDictionary allKeys]) {
        value = [valueDictionary objectForKey:key];
        encodedKey = [self encodedStringValue:key];
        encodedValue = [self encodedStringValue:value];
        [encodedValues addObject:[[encodedKey stringByAppendingString:@"="]
                                  stringByAppendingString:encodedValue]];
    }
    
    return [encodedValues componentsJoinedByString:@"&"];
}

+ (NSString *)formDataBoundary
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
	NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuid);
	CFRelease(uuid);
    
    return [BOUNDARY_PREFIX stringByAppendingString:uuidString];
}

+ (NSData *)multipartBodyWithBoundary:(NSString *)boundary
                             formData:(NSDictionary *)formData
                          attachments:(NSArray *)attachments
{
    NSMutableData *body = [NSMutableData dataWithCapacity:1024];
    NSString *boundaryString = [NSString stringWithFormat:@"--%@\r\n", boundary];
	NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
	NSString *finalItemBoundary = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
    NSString *tempStr;
    
    // Begin boundary
    [body appendUTF8String:boundaryString];
    
    // Append form data parts
    NSString *value;
    NSUInteger i = 0;
    for (id key in [formData allKeys]) {
        value = [[formData objectForKey:key] description];
        tempStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value];
        [body appendUTF8String:tempStr];
        i++;
        if (i != [formData count] || [attachments count] > 0) {
            [body appendUTF8String:endItemBoundary];
        }
    }
    
    // Append attachments
    i = 0;
    for (Attachment *attachment in attachments) {
        tempStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", attachment.name, attachment.filename];
        tempStr = [tempStr stringByAppendingFormat:@"Content-Type: %@\r\n\r\n", attachment.contentType];
        [body appendUTF8String:tempStr];
        
        [body appendData:attachment.fileData];
        i++;
        
		// Only add the boundary if this is not the last item in the post body
		if (i != [attachments count]) {
            [body appendUTF8String:endItemBoundary];
		}
    }
    
    [body appendUTF8String:finalItemBoundary];
    
    return body;
}

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                       url:(NSURL *)url
                                  formData:(NSDictionary *)formData
                               attachments:(NSArray *)attachments
{
    // Create the request
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Add the REST virtual method to the form data
    NSMutableDictionary *dataWithRESTMethod = [NSMutableDictionary dictionaryWithObject:[method lowercaseString] forKey:@"_method"];
    
    // Set HTTP method
    [theRequest setHTTPMethod:@"POST"];
    
    // Merge in original formData
    if (formData) {
        [dataWithRESTMethod addEntriesFromDictionary:formData];
    }
    
    if (attachments) {
        // Generate multipart boundary string
        NSString *boundary = [self formDataBoundary];
        
        // Add multipart/formdata headers to request
        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        NSString *header = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, boundary];
        [theRequest addValue:header forHTTPHeaderField:@"Content-Type"];
        
        // Generate multipart body
        [theRequest setHTTPBody:[self multipartBodyWithBoundary:boundary formData:dataWithRESTMethod attachments:attachments]];
    }
    else {
        // Set encoded form data as request body
        [theRequest setHTTPBody:[[self encodedValuesWithDictionary:dataWithRESTMethod] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return theRequest;
}

#pragma mark - REST requests

+ (NSURLRequest *)GETRequestWithURL:(NSURL *)url
{
    return [self GETRequestWithURL:url queryParams:nil];
}

+ (NSURLRequest *)POSTRequestWithURL:(NSURL *)url
{
    return [self requestWithMethod:@"POST" url:url formData:nil attachments:nil];
}

+ (NSURLRequest *)PUTRequestWithURL:(NSURL *)url
{
    return [self requestWithMethod:@"PUT" url:url formData:nil attachments:nil];
}

+ (NSURLRequest *)DELETERequestWithURL:(NSURL *)url
{
    return [self requestWithMethod:@"DELETE" url:url formData:nil attachments:nil];
}

+ (NSURLRequest *)GETRequestWithURL:(NSURL *)url queryParams:(NSDictionary *)queryParams
{
    NSURL *fullURL;
    NSMutableString *urlBuilder;
    if (queryParams && ([queryParams count] > 0)) {
        urlBuilder = [NSMutableString stringWithString:[url absoluteString]];
        [urlBuilder appendString:@"?"];
        [urlBuilder appendString:[self encodedValuesWithDictionary:queryParams]];
        fullURL = [NSURL URLWithString:urlBuilder];
    } else {
        fullURL = url;
    }
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:fullURL];
    
    return theRequest;
}

+ (NSURLRequest *)POSTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData
{
    return [self requestWithMethod:@"POST" url:url formData:formData attachments:nil];
}

+ (NSURLRequest *)PUTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData
{
    return [self requestWithMethod:@"PUT" url:url formData:formData attachments:nil];
}

+ (NSURLRequest *)DELETERequestWithURL:(NSURL *)url queryParams:(NSDictionary *)queryParams
{
    return [self requestWithMethod:@"DELETE" url:url formData:queryParams attachments:nil];
}

#pragma mark - REST requests with attachments

+ (NSURLRequest *)POSTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData attachments:(NSArray *)attachments
{
    return [self requestWithMethod:@"POST" url:url formData:formData attachments:attachments];
}

+ (NSURLRequest *)PUTRequestWithURL:(NSURL *)url formData:(NSDictionary *)formData attachments:(NSArray *)attachments
{
    return [self requestWithMethod:@"PUT" url:url formData:formData attachments:attachments];
}

#pragma mark - Class utility methods

+ (NSArray *)parseErrorsFromJSONResponseData:(NSData *)json
{
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:10];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    id unprocessedErrors = [NSJSONSerialization JSONObjectWithData:json options:0 error:NULL];
    NSArray *components;
    if (unprocessedErrors) {
        for (NSString *error in unprocessedErrors) {
            components = [error componentsSeparatedByString:@" - "];
            [errors addObject:[components lastObject]];
        }
    }
    
    return [errors copy];
}

@end
