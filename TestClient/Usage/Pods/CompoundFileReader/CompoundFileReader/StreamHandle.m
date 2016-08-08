/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  StreamHandle.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/17/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "StreamHandle.h"
#import "Sector.h"
#import <objc/runtime.h>

@interface StreamHandle ()

@property (nonatomic, assign) NSInteger sectorSize;
@property (nonatomic, strong) NSMutableArray *sectorChain;
@property (nonatomic, strong) NSInputStream *fileStream;

@end

@implementation StreamHandle

- (void)dealloc
{
    _sectorChain = nil;
    _fileStream = nil;
}

- (id)initWithFileStream:(NSInputStream *)fileStream andSectorChian:(NSArray *)sectorChain sectorSize:(NSInteger)sectorSize length:(long)length
{
    if (self = [super init]) {
        _fileStream = fileStream;
        _sectorChain = [[NSMutableArray alloc] initWithArray:sectorChain];
        _sectorSize = sectorSize;
        [self adjustLength:length];
    }
    return self;
}

- (void)adjustLength:(long)value
{
    self.length = value;
    
    long delta = value - ((long)self.sectorChain.count * (long)self.sectorSize);
    
    if (delta > 0)
    {
        // enlargment required
        int nSec = ceil(((double)delta / self.sectorSize));
        
        while (nSec > 0)
        {
            Sector *sector = [[Sector alloc] initWithFileStream:self.fileStream andSize:self.sectorSize];
            [self.sectorChain addObject:sector];
            nSec--;
        }
    }
}

- (void)seekToOffset:(long)offset origin:(SeekOrigin)origin
{
    switch (origin) {
        case SeekOriginBegin:
            _sectorPosition = offset;
            break;
        case SeekOriginCurrent:
            _sectorPosition += offset;
            break;
        case SeekOriginEnd:
            _sectorPosition = self.sectorSize - offset;
            break;
    }
    [self.fileStream setProperty:@(_sectorPosition) forKey:NSStreamFileCurrentOffsetKey];
    [self adjustLength:self.sectorPosition];
}

- (uint32_t)readInt32
{
    uint8_t *buffer = malloc(sizeof(uint8_t) * 4);
    memset(buffer, 0x00, 4);
    [self read:buffer maxLength:4];
    
    if (!buffer) {
        return -1;
    }
    uint32_t retVal = (((buffer[0] | (buffer[1] << 8)) | (buffer[2] << 16)) | (buffer[3] << 24));
    free(buffer);
    return retVal;
}

- (NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len
{
    int nRead = 0;
    int nToRead = 0;
    
    if (self.sectorChain != nil && self.sectorChain.count > 0)
    {
        // First sector
        int secIndex = (int)(self.sectorPosition / (long)self.sectorSize);
        
        // Bytes to read count is the min between request count
        // and sector border
        nToRead = MIN((int)([self.sectorChain[0] sizeOfSector] - (self.sectorPosition % self.sectorSize)),
                      (int)len);
        
        if (secIndex < self.sectorChain.count)
        {
            uint8_t *src = (uint8_t *)[self.sectorChain[secIndex] getData].bytes;
            memcpy(buffer, src + (int)(self.sectorPosition % self.sectorSize), nToRead);
        }
        
        nRead += nToRead;
        
        secIndex++;
        
        // Central sectors
        while (nRead < ((int)len - self.sectorSize))
        {
            nToRead = (int)self.sectorSize;
            
            uint8_t *src = (uint8_t *)[self.sectorChain[secIndex] getData].bytes;
            memcpy(buffer + nRead, src, nToRead);
            
            nRead += nToRead;
            secIndex++;
        }
        
        // Last sector
        nToRead = (int)len - nRead;
        
        if (nToRead != 0)
        {
            uint8_t *src = (uint8_t *)[self.sectorChain[secIndex] getData].bytes;
            memcpy(buffer + nRead, src, nToRead);
            nRead += nToRead;
        }
        
        _sectorPosition += nRead;
    }
    
    return nRead;
}

@end
