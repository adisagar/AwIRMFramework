/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Sector.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/17/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SectorTypeNormal = 0,
    SectorTypeMini,
    SectorTypeFAT,
    SectorTypeDIFAT,
    SectorTypeRangeLockSector,
    SectorTypeDirectory
} SectorType;

static int MINISECTOR_SIZE = 64;
extern const int FREESECT;
extern const int ENDOFCHAIN;
extern const int FATSECT;
extern const int DIFSECT;
extern int FILESIZE;

@interface Sector : NSObject

@property (nonatomic, assign) BOOL isDirtyFlag;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) SectorType sectorType;
@property (nonatomic, assign) NSInteger inputStreamLength;
@property (nonatomic, assign, readonly) NSInteger sizeOfSector;
@property (nonatomic, strong) NSData *inputData;

- (id)initWithFileStream:(NSInputStream *)fileStream andSize:(NSInteger)size;
- (NSData *)getData;
- (void)zeroData;

@end
