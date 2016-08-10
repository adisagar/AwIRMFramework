/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Message.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/18/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyTag.h"
#import "Storage.h"
#import "Stream.h"
#import "CompoundFileReader.h"

@interface Message : NSObject

- (id)initWithRootStorage:(Storage *)rootStorage;

@property (nonatomic, assign) MessageType type;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, copy) NSString *cc;
@property (nonatomic, copy) NSString *bcc;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, strong) NSDate *sentDateTime;
@property (nonatomic, copy) NSString *htmlBody;
@property (nonatomic, copy) NSString *meetingLocation;
@property (nonatomic, assign) BOOL hasAttachments;
@property (nonatomic, strong) NSMutableArray *attachments;
@property (nonatomic, strong) NSDate *meetingStartDateTime;
@property (nonatomic, strong) NSDate *meetingEndDateTime;

@end
