/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Mapper.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/25/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Mapper.h"
#import "MappedObject.h"
#import "PropertyTag.h"
#import "Stream.h"

@interface Mapper ()

@property (nonatomic, strong) Storage *rootStorage;

@end

@implementation Mapper

- (void)dealloc
{
    _rootStorage = nil;
}

- (id)initWithRootStorage:(Storage *)rootStorage
{
    if (self = [super init]) {
        _rootStorage = rootStorage;
    }
    return self;
}

- (NSArray *)mappedObjects
{
    __block NSMutableArray *mappingValues = [NSMutableArray array];
    
    NSPredicate *namedPropertyPredicate = [NSPredicate predicateWithFormat:@"storageName == %@", CFileReaderPropertyTagNamedProperty];
    NSArray *filteredArray = [[[self.rootStorage storages] allObjects]
                              filteredArrayUsingPredicate:namedPropertyPredicate];
    
    if (filteredArray.count > 0) {
        Storage *namedStorage = self.rootStorage;
        [[namedStorage.streams allObjects] enumerateObjectsUsingBlock:^(Stream *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.propertyKey hasPrefix:CFileReaderPropertyTagSubStgVersion]) {
                NSString *propIDStr = [[obj.propertyKey substringFromIndex:12] substringToIndex:4];
                propIDStr = [propIDStr uppercaseString];
                NSScanner *hexScan = [NSScanner scannerWithString:propIDStr];
                unsigned int propID;
                [hexScan scanHexInt:&propID];
                if (propID >= 32768 && propID <= 65534) {
                    if (![mappingValues containsObject:propIDStr]) {
                        [mappingValues addObject:propIDStr];
                    }
                }
            }
        }];
        namedStorage = filteredArray[0];
        
        filteredArray = [[[self.rootStorage streams] allObjects]
                         filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey == %@", CFileReaderPropertyTagPropertyStream]];
        
        if (filteredArray.count > 0) {
            Stream *stream = [filteredArray objectAtIndex:0];
            NSData *propertyData = [stream propertyData];
            
            for (NSInteger i = 32; i < propertyData.length; i += 16) {
                
                NSMutableData *propIdent = [[propertyData subdataWithRange:NSMakeRange(i + 3, 1)] mutableCopy];
                [propIdent appendData:[propertyData subdataWithRange:NSMakeRange(i + 2, 1)]];
                
                NSString *propIdentString = [[NSString stringWithFormat:@"%@", propIdent] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<->"]];
                propIdentString = [propIdentString uppercaseString];
                
                NSScanner *hexScan = [NSScanner scannerWithString:propIdentString];
                unsigned int propID;
                [hexScan scanHexInt:&propID];
                
                if (propID >= 32768 && propID <= 65534) {
                    if (![mappingValues containsObject:propIdentString]) {
                        [mappingValues addObject:propIdentString];
                    }
                }
            }
            return [self obtainMappingFromArray:mappingValues andNamedStorage:namedStorage];
        }
        return nil;
    }
    return nil;
}

- (NSArray *)obtainMappingFromArray:(NSArray *)mappingValues andNamedStorage:(Storage *)namedStorage
{
    NSMutableArray *result = [NSMutableArray array];
    
    //Entry stream data...
    NSData *entryStreamData = nil;
    NSArray *filteredArray = [[[namedStorage streams] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey == %@",CFileReaderPropertyTagEntryStream]];
    if (filteredArray.count > 0) {
        entryStreamData = [[filteredArray objectAtIndex:0] propertyData];
    }
    
    //String stream data...
    NSData *stringStreamData = nil;
    filteredArray = [[[namedStorage streams] allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey == %@", CFileReaderPropertyTagStringStream]];
    if (filteredArray.count > 0) {
        stringStreamData = [[filteredArray objectAtIndex:0] propertyData];
    }
    
    if (entryStreamData && stringStreamData) {
        for (NSString *mappingVal in mappingValues) {
            NSScanner *hexScan = [NSScanner scannerWithString:mappingVal];
            unsigned int identVal;
            [hexScan scanHexInt:&identVal];
            
            NSInteger entryOffset = (identVal - 32768) * 8;
            NSString *entryIdentString;
            if (((unsigned char *)[[entryStreamData subdataWithRange:NSMakeRange(entryOffset + 1, 1)] bytes])[0] == 0) {
                NSData *data = [entryStreamData subdataWithRange:NSMakeRange(entryOffset, 1)];
                entryIdentString = [[NSString stringWithFormat:@"%@", data] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<->"]];
            } else {
                NSMutableData *data = [[entryStreamData subdataWithRange:NSMakeRange(entryOffset + 1, 1)] mutableCopy];
                [data appendData:[entryStreamData subdataWithRange:NSMakeRange(entryOffset, 1)]];
                entryIdentString = [[NSString stringWithFormat:@"%@", data] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<->"]];
            }
            
            NSData *typeData = [entryStreamData subdataWithRange:NSMakeRange(entryOffset + 4, 1)];
            NSString *type = [[NSString stringWithFormat:@"%@", typeData] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<->"]];
            
            if ([type isEqualToString:@"05"]) {
                hexScan = [NSScanner scannerWithString:entryIdentString];
                unsigned int stringOffset;
                [hexScan scanHexInt:&stringOffset];
                
                Byte *stringLenBytes = (Byte *)malloc(sizeof(Byte) * 4);
                
                [stringStreamData getBytes:stringLenBytes range:NSMakeRange(stringOffset, 4)];
                if (stringLenBytes) {
                    NSInteger stringLen = [self getIntFromBytes:stringLenBytes];
                    
                    stringOffset += 4;
                    
                    NSMutableString *str;
                    
                    for (NSInteger i = stringOffset; i < stringOffset + stringLen; i += 2) {
                        [str appendFormat:@"%@", [stringStreamData subdataWithRange:NSMakeRange(i, 1)]];
                    }
                    [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    [result addObject:[[MappedObject alloc] initWithPropertyID:mappingVal andEntryORStringID:[str uppercaseString]]];
                }
                free(stringLenBytes);
            } else {
                [result addObject:[[MappedObject alloc] initWithPropertyID:mappingVal andEntryORStringID:[entryIdentString uppercaseString]]];
            }
        }
    }
    return result;
}

- (int)getIntFromBytes:(Byte *)bytes
{
    int retVal = 0;
    retVal = (retVal << 8) + bytes[3];
    retVal = (retVal << 8) + bytes[2];
    retVal = (retVal << 8) + bytes[1];
    retVal = (retVal << 8) + bytes[0];
    return retVal;
}

@end
