/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  MapiPropertyParser.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/26/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "MapiPropertyParser.h"
#import "Mapper.h"
#import "MappedObject.h"
#import "PropertyTag.h"
#import "Stream.h"

#define UNIX_EPOCH_SEC 11644473600

typedef enum
{
    PropTypeUnspecified = 0,
    PropTypeNull = 1,
    PropTypeInt16 = 2,
    PropTypeLong = 3,
    PropTypeDouble = 5,
    PropTypeBool = 11,
    PropTypeString8 = 30,
    PropTypeUnicode = 31,
    PropTypeSysTime = 64,
    PropTypeBinary = 258
} PropType;

@interface MapiPropertyParser ()

@property (nonatomic, strong) NSArray *namedProperties;
@property (nonatomic, strong) Storage *storage;

@end

@implementation MapiPropertyParser

- (void)dealloc
{
    _storage = nil;
    _namedProperties = nil;
}

- (id)initWithStorage:(Storage *)storage
{
    if (self = [super init]) {
        _storage = storage;
        Mapper *mapper = [[Mapper alloc] initWithRootStorage:_storage];
        _namedProperties = [mapper mappedObjects];
    }
    return self;
}

- (id)mapipropertyValueOfPropID:(NSString *)propID
{
    if (self.namedProperties) {
        NSString *mappedPropID = [self mappedStringOfString:propID];
        if (mappedPropID) {
            propID = mappedPropID;
        }
    }
    
    id propValue = [self dataFromStorageOrStreamWithPropID:propID];
    if (!propValue) {
        propValue = [self dataFromPropertyStreamDataWithPropId:propID];
    }
    return propValue;
}

- (id)dataFromStorageOrStreamWithPropID:(NSString *)propID
{
    NSArray *propKeys = [[[[self.storage streams] allObjects]
                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey != %@", [NSNull null]]] valueForKeyPath:@"propertyKey"];
    NSString *propTag;
    PropType propType = PropTypeUnspecified;
    
    for (NSString *propKey in propKeys) {
        if (![propKey hasPrefix:[NSString stringWithFormat:@"%@_%@", CFileReaderPropertyTagSubStgVersion, propID]]) {
            continue;
        }
        propTag = [[propKey substringFromIndex:12] substringToIndex:8];
        NSString *propTypeStr = [[propKey substringFromIndex:16] substringToIndex:4];
        NSScanner *scanner = [NSScanner scannerWithString:propTypeStr];
        [scanner scanHexInt:&propType];
    }
    
    if (!propTag) {
        return nil;
    }
    
    NSString *containerName = [NSString stringWithFormat:@"%@_%@", CFileReaderPropertyTagSubStgVersion, propTag];
    
    switch (propType) {
        case PropTypeUnspecified:
            return nil;
            break;
        case PropTypeString8:
            return [self stringFromStreamName:containerName andEncoding:NSUTF8StringEncoding];
            break;
        case PropTypeUnicode:
            return [self stringFromStreamName:containerName andEncoding:NSUTF16LittleEndianStringEncoding];
            break;
        case PropTypeBinary:
            return [self dataFromStreamName:containerName];
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)stringFromStreamName:(NSString *)streamName andEncoding:(NSStringEncoding)encoding
{
    Stream *stream = [[[[self.storage streams] allObjects]
                       filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey == %@", streamName]] objectAtIndex:0];
    NSString *value = [[NSString alloc] initWithData:[stream propertyData] encoding:encoding];
    return value;
}

- (NSData *)dataFromStreamName:(NSString *)streamName
{
    Stream *stream = [[[[self.storage streams] allObjects]
                       filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey == %@", streamName]] objectAtIndex:0];
    return [stream propertyData];
}

- (id)dataFromPropertyStreamDataWithPropId:(NSString *)propID
{
    NSData *propertyStreamData = [[[[[self.storage streams] allObjects]
                                    filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"propertyKey == %@", CFileReaderPropertyTagPropertyStream]] objectAtIndex:0] propertyData];
    
    NSInteger _propertyHeaderSize = 32;
    for (NSInteger i = _propertyHeaderSize; i < propertyStreamData.length; i += 16) {
        NSString *propTypeStr = [[NSString stringWithFormat:@"%@", [propertyStreamData subdataWithRange:NSMakeRange(i, 1)]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<->"]];
        NSScanner *scanner = [NSScanner scannerWithString:propTypeStr];
        unsigned int propType;
        [scanner scanHexInt:&propType];
        
        NSMutableData *propIdent = [[propertyStreamData subdataWithRange:NSMakeRange(i + 3, 1)] mutableCopy];
        [propIdent appendData:[propertyStreamData subdataWithRange:NSMakeRange(i + 2, 1)]];
        
        NSString *propIdentString = [[NSString stringWithFormat:@"%@", propIdent] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<->"]];
        
        if (![propID isEqualToString:propIdentString]) {
            continue;
        }
        
        switch (propType) {
            case PropTypeInt16:
                break;
            case PropTypeLong:
                break;
            case PropTypeDouble:
                break;
            case PropTypeBool:
                break;
            case PropTypeSysTime:
            {
                uint64_t time = [self getUInt64FromData:[propertyStreamData subdataWithRange:NSMakeRange(i + 8, 8)]];
                time *= 1.0e-7;
                time -= UNIX_EPOCH_SEC;
                NSDate *returnDate = [NSDate dateWithTimeIntervalSince1970:time];
                return returnDate;
            }
                break;
            default:
                break;
        }
    }
    return nil;
}

- (uint64_t)getUInt64FromData:(NSData *)data
{
    uint64_t retVal = 0;
    Byte *bytes = (unsigned char *)data.bytes;
    retVal = (retVal << 8) + bytes[7];
    retVal = (retVal << 8) + bytes[6];
    retVal = (retVal << 8) + bytes[5];
    retVal = (retVal << 8) + bytes[4];
    retVal = (retVal << 8) + bytes[3];
    retVal = (retVal << 8) + bytes[2];
    retVal = (retVal << 8) + bytes[1];
    retVal = (retVal << 8) + bytes[0];
    return retVal;
}

- (NSString *)mappedStringOfString:(NSString *)mappingString
{
    NSPredicate *mappingValuePredicate = [NSPredicate predicateWithFormat:@"entryORStringID == %@", mappingString];
    NSArray *filteredArray = [self.namedProperties filteredArrayUsingPredicate:mappingValuePredicate];
    
    if (filteredArray.count > 0) {
        return [[filteredArray objectAtIndex:0] propertyID];
    }
    return nil;
}

@end
