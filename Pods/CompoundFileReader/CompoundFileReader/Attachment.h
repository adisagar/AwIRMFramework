/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Attachment.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/18/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storage.h"
#import "Stream.h"

@interface Attachment : NSObject

@property (nonatomic, copy) NSString *fileMIMEType;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, assign) BOOL isInline;
@property (nonatomic, copy) NSString *contentID;

- (id)initWithStorage:(Storage *)storage;

@end
