//
//  Attachment.h
//  TMSMobile
//
//  Created by Robert Walker on 8/9/11.
//  Copyright 2011 Bennett International Group. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Attachment : NSObject

#pragma mark Properties

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSData *fileData;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSString *contentType;

#pragma mark - Factory constructors

+ (id)attachmentWithName:(NSString *)theName
                    data:(NSData *)theData
                filename:(NSString *)theFilename
             contentType:(NSString *)theContentType;

#pragma mark - Initializers

- (id)initWithName:(NSString *)theName
              data:(NSData *)theData
          filename:(NSString *)theFilename
       contentType:(NSString *)theContentType;

@end
