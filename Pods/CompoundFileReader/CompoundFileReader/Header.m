/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Header.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/15/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Header.h"
#import "Sector.h"
#import "StreamReader.h"
#import "CFileReaderError.h"

@interface Header ()
{
    int _difat[109];
}
@end

@implementation Header

- (void)dealloc
{
    _headerSignature = nil;
    _CLSID = nil;
    _DIFAT = nil;
}

- (id)init
{
    if (self = [super init]) {
        unsigned char start[8] = {0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1};
        _headerSignature = [NSData dataWithBytes:start length:8];
        _minorVersion = 0x003E;
        _majorVersion = 0x0003;
        _byteOrder = 0xFFFE;
        _sectorShift = 9;
        _miniSectorShift = 6;
        unsigned char unUsed[6] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
        _unUsed = [NSData dataWithBytes:unUsed length:6];
        _firstDirectorySectorID = ENDOFCHAIN;
        _unUsed2 = 0;
        _minSizeStandardStream = 4096;
        _firstMiniFATSectorID = 0xFFFFFFFE;
        _firstDIFATSectorID = ENDOFCHAIN;
        
        for (int i = 0 ; i < 109; i++) {
            _difat[i] = FREESECT;
        }
        _DIFAT = _difat;
    }
    return self;
}

- (BOOL)readHeaderAndValidate:(NSInputStream *)fileInputStream error:(NSError *__autoreleasing*)error
{
    StreamReader *stream = [[StreamReader alloc] initWithFileStream:fileInputStream];
    NSData *headerData = [stream readbytes:8];
    if (![self checkHeaderSignature:headerData]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:CFileReaderErrorDomain code:CFileReaderCorruptedHeaderErrorCode userInfo:@{@"Header Data": headerData}];
        }
        return NO;
    }
    
    _CLSID = [stream readbytes:16];
    _minorVersion = [stream read_UInt16];
    _majorVersion = [stream read_UInt16];
    
    if (![self checkMajorVersion:_majorVersion]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:CFileReaderErrorDomain code:CFileReaderUnsupportedVersionErrorCode userInfo:@{@"Version": @(_majorVersion)}];
        }
        return NO;
    }
    
    _byteOrder = [stream read_UInt16];
    _sectorShift = [stream read_UInt16];
    _miniSectorShift = [stream read_UInt16];
    _unUsed = [stream readbytes:6];
    _directorySectorsNumber = [stream read_Int32];
    _FATSectorsNumber = [stream read_Int32];
    _firstDirectorySectorID = [stream read_Int32];
    _unUsed2 = [stream read_UInt32];
    _minSizeStandardStream = [stream read_UInt32];
    _firstMiniFATSectorID = [stream read_Int32];
    _miniFATSectorsNumber = [stream read_UInt32];
    _firstDIFATSectorID = [stream read_Int32];
    _DIFATSectorsNumber = [stream read_UInt32];
    
    for (int i = 0 ; i < 109; i++) {
        _difat[i] = [stream read_UInt32];
    }
    _DIFAT = _difat;
    
    error = nil;
    return YES;
}

#pragma mark - Validation Handler

- (BOOL)checkHeaderSignature:(NSData *)headerSignature
{
    if (headerSignature && [headerSignature isEqualToData:_headerSignature]) {
        return YES;
    }
    return NO;
}

- (BOOL)checkMajorVersion:(ushort)majorVerion
{
    if (majorVerion != 3 && majorVerion != 4) {
        return NO;
    }
    _majorVersion = majorVerion;
    return YES;
}
@end
