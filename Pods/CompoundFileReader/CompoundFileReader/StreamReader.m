/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  StreamReader.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/21/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "StreamReader.h"
#import "StreamHandle.h"

@interface StreamReader ()

@property (nonatomic, strong) NSInputStream *fileInputStream;

@end

@implementation StreamReader

- (void)dealloc
{
    _fileInputStream = nil;
}

- (id)initWithFileStream:(NSInputStream *)fileInputStream
{
    if (self = [super init]) {
        _fileInputStream = fileInputStream;
    }
    return self;
}

- (NSData *)readByte
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = 1;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:1];
    return readData;
}

- (ushort)read_UInt16
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = 2;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:2];
    Byte *buffer = (unsigned char *)readData.bytes;
    return (ushort)(buffer[0] | (buffer[1] << 8));
}

- (int)read_Int32
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = 4;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:4];
    Byte *buffer = (unsigned char *)readData.bytes;
    return (int)(buffer[0] | (buffer[1] << 8) | (buffer[2] << 16) | (buffer[3] << 24));
}

- (uint)read_UInt32
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = 4;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:4];
    Byte *buffer = (unsigned char *)readData.bytes;
    return (uint)(buffer[0] | (buffer[1] << 8) | (buffer[2] << 16) | (buffer[3] << 24));
}

- (long)read_Int64
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = 8;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:8];
    Byte *buffer = (unsigned char *)readData.bytes;
    u_int64_t ls = (uint)(buffer[0] | (buffer[1] << 8) | (buffer[2] << 16) | (buffer[3] << 24));
    u_int64_t ms = (uint)((buffer[4]) | (buffer[5] << 8) | (buffer[6] << 16) | (buffer[7] << 24));
    return (long)((ms << 32) | ls);
}

- (u_long)read_UInt64
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = 8;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:8];
    Byte *buffer = (unsigned char *)readData.bytes;
    return (u_long)(buffer[0] | (buffer[1] << 8) | (buffer[2] << 16) | (buffer[3] << 24) | (buffer[4] << 32) | (buffer[5] << 40) | (buffer[6] << 48) | (buffer[7] << 56));
}

- (NSData *)readbytes:(NSUInteger)length
{
    NSMutableData *readData = [NSMutableData data];
    readData.length = length;
    [self.fileInputStream read:(uint8_t *)readData.mutableBytes maxLength:length];
    return readData;
}

@end
