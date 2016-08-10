/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DirectoryEntry.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/19/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamHandle.h"

typedef enum
{
    NodeTypeInvalid = 0,
    NodeTypeStorage,
    NodeTypeStream,
    NodeTypeLockbytes,
    NodeTypeProperty,
    NodeTypeRoot
} NodeType;

typedef enum
{
    NodeColorRed = 0,
    NodeColorBlack
} NodeColor;

static uint32_t NOSTREAM = (int)0xFFFFFFFF;

@interface DirectoryEntry : NSObject

@property (nonatomic, assign) NSInteger sIdentifier;
@property (nonatomic, strong, readonly) NSData *entryNameData;
@property (nonatomic, assign) ushort nameLength;
@property (nonatomic, assign) NodeType nodeType;
@property (nonatomic, assign) NodeColor nodeColor;
@property (nonatomic, assign) uint32_t leftSibling;
@property (nonatomic, assign) uint32_t rightSibling;
@property (nonatomic, assign) uint32_t child;
@property (nonatomic, strong) NSUUID *uniqueID;
@property (nonatomic, assign) uint32_t stateBits;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSData *creationDateData;
@property (nonatomic, strong) NSData *modifiedDateData;
@property (nonatomic, assign) uint32_t startSectC;
@property (nonatomic, assign) long sizeOfEntry;

- (id)initWithNodeType:(NodeType)nodeType;
- (NSString *)getEntryName;
- (void)populateData:(StreamHandle *)fileStream;

@end
