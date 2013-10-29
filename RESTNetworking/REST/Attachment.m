//
//  Attachment.m
//  TMSMobile
//
//  Created by Robert Walker on 8/9/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

#pragma mark Properties

@synthesize name = _name;
@synthesize fileData = _fileData;
@synthesize filename = _filename;
@synthesize contentType = _contentType;

#pragma mark - Factory constructors

+ (id)attachmentWithName:(NSString *)theName
                    data:(NSData *)theData
                filename:(NSString *)theFilename
             contentType:(NSString *)theContentType;
{
    return [[self alloc] initWithName:theName
                                  data:theData
                              filename:theFilename
                           contentType:theContentType];
}

#pragma mark - Initializers

- (id)initWithName:(NSString *)theName
              data:(NSData *)theData
          filename:(NSString *)theFilename
       contentType:(NSString *)theContentType
{
    self = [super init];
    if (self) {
        _name = theName;
        _fileData = theData;
        _filename = theFilename;
        _contentType = theContentType;
    }
    
    return self;
}

@end
