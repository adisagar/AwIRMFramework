/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  StreamHandle.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/17/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamReader.h"

typedef enum
{
    SeekOriginBegin = 0,
    SeekOriginCurrent,
    SeekOriginEnd
} SeekOrigin;

@interface StreamHandle : NSInputStream

@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign, readonly) long sectorPosition;

- (id)initWithFileStream:(NSInputStream *)fileStream andSectorChian:(NSArray *)sectorChain sectorSize:(NSInteger)sectorSize length:(long)length;

- (uint32_t)readInt32;
- (void)seekToOffset:(long)offset origin:(SeekOrigin)origin;

@end
