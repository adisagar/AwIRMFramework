/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Header.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/15/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Header : NSObject

@property (nonatomic, strong) NSData *headerSignature;
@property (nonatomic, strong) NSData *CLSID;
@property (nonatomic, assign, readonly) ushort minorVersion;
@property (nonatomic, assign, readonly) ushort majorVersion;
@property (nonatomic, assign, readonly) ushort byteOrder;
@property (nonatomic, assign, readonly) ushort sectorShift;
@property (nonatomic, assign, readonly) ushort miniSectorShift;
@property (nonatomic, assign, readonly) NSData *unUsed;
@property (nonatomic, assign) NSInteger directorySectorsNumber;
@property (nonatomic, assign) NSInteger FATSectorsNumber;
@property (nonatomic, assign) NSInteger firstDirectorySectorID;
@property (nonatomic, assign, readonly) NSUInteger unUsed2;
@property (nonatomic, assign) NSUInteger minSizeStandardStream;
@property (nonatomic, assign) NSInteger firstMiniFATSectorID;
@property (nonatomic, assign) NSUInteger miniFATSectorsNumber;
@property (nonatomic, assign) NSInteger firstDIFATSectorID;
@property (nonatomic, assign) NSUInteger DIFATSectorsNumber;
@property (nonatomic, assign) int *DIFAT;

- (id)init;
- (BOOL)readHeaderAndValidate:(NSInputStream *)fileInputStream error:(NSError *__autoreleasing*)error;

@end
