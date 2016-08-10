/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Sector.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/17/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Sector.h"
#import "StreamReader.h"

const int FREESECT = (int)0xFFFFFFFF;
const int ENDOFCHAIN = (int)0xFFFFFFFE;
const int FATSECT = (int)0xFFFFFFFD;
const int DIFSECT = (int)0xFFFFFFFC;
int FILESIZE = (int)0xFFFFFFFF;

@interface Sector ()

@property (nonatomic, assign) BOOL isStreamed;
@property (nonatomic, strong) NSInputStream *fileInputStream;

@end

@implementation Sector

- (void)dealloc
{
    _fileInputStream = nil;
    _inputData = nil;
}

- (id)initWithFileStream:(NSInputStream *)fileStream andSize:(NSInteger)size;
{
    if (self = [super init]) {
        _sizeOfSector = size;
        _fileInputStream = fileStream;
        _identifier = -1;
    }
    return self;
}

- (BOOL)IsStreamed
{
    return (_fileInputStream != nil && self.sizeOfSector != MINISECTOR_SIZE) ? (self.identifier * self.sizeOfSector) + self.sizeOfSector < FILESIZE: false;
}

- (NSData *)getData
{
    if (self.inputData == nil || self.inputData.length == 0) {
        if ([self IsStreamed]) {
            [_fileInputStream setProperty:@(0) forKey:NSStreamFileCurrentOffsetKey];
            [_fileInputStream setProperty:@(((unsigned long)self.sizeOfSector + (unsigned long)self.identifier * (unsigned long)self.sizeOfSector)) forKey:NSStreamFileCurrentOffsetKey];
            
            uint8_t *inputBuf = malloc(sizeof(uint8_t) * self.sizeOfSector);
            [self.fileInputStream read:inputBuf maxLength:self.sizeOfSector];
            _inputData = [NSData dataWithBytes:inputBuf length:self.sizeOfSector];
            free(inputBuf);
        }
    }
    return self.inputData;
}

- (void)zeroData
{
    self.isDirtyFlag = YES;
}

@end
