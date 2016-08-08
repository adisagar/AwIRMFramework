/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */

/* The following is implemented as specified in http://www.openoffice.org/sc/compdocfileformat.pdf*/
//
//  CompoundFileReader.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/21/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
    MessageTypeUnknown = -1,
    MessageTypeNote = 0,
    MessageTypeAppointment,
    MessageTypeContact,
    MessageTypePost,
    MessageTypeActivity,
    MessageTypeTask
} MessageType;

@interface CompoundFileReader : NSObject

- (id)initWithFilePath:(NSString *)filePath;
- (BOOL)readFile:(NSError *__autoreleasing*)error;
- (NSString *)htmlToLoadData;
- (BOOL)hasAttachments;
- (NSArray *)attachments;

@end
