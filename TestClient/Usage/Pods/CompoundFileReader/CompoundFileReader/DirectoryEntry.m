/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DirectoryEntry.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/19/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DirectoryEntry.h"

@interface DirectoryEntry ()

@end

@implementation DirectoryEntry

- (void)dealloc
{
    _entryNameData = nil;
    _uniqueID = nil;
    _creationDateData = nil;
    _modifiedDateData = nil;
}

- (id)initWithNodeType:(NodeType)nodeType
{
    if (self = [super init]) {
        _nodeType = nodeType;
        _sIdentifier = -1;
        _entryNameData = [[NSData alloc] init];
        _nodeColor = NodeColorBlack;
        _leftSibling = NOSTREAM;
        _rightSibling = NOSTREAM;
        _child = NOSTREAM;
    }
    return self;
}

- (NSString *)getEntryName
{
    if (_entryNameData && _entryNameData.length > 0) {
        NSMutableData *data = [NSMutableData data];
        char emptyBytes[2] = {0x00, 0x00};
        for (int i = 0; i < _entryNameData.length; i += 2) {
            if ([[_entryNameData subdataWithRange:NSMakeRange(i, 2)] isEqualToData:[NSData dataWithBytes:emptyBytes length:2]]) {
                break;
            } else {
                [data appendData:[_entryNameData subdataWithRange:NSMakeRange(i, 2)]];
            }
        }
        return [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
    }
    return nil;
}

- (NSString *)name
{
    return [self getEntryName];
}

- (void)populateData:(StreamHandle *)fileStream
{
    StreamReader *stream = [[StreamReader alloc] initWithFileStream:fileStream];
    _entryNameData = [stream readbytes:64];
    self.nameLength = [stream read_UInt16];
    NSData *nodeTypeData = [stream readByte];
    Byte nodeTypeInt;
    [nodeTypeData getBytes:&nodeTypeInt length:nodeTypeData.length];
    self.nodeType = (NodeType)(nodeTypeInt);
    [stream readByte]; //Color
    self.leftSibling = [stream read_Int32];
    self.rightSibling = [stream read_Int32];
    self.child = [stream read_Int32];
    if (self.nodeType == NodeTypeInvalid) {
        self.leftSibling = NOSTREAM;
        self.rightSibling = NOSTREAM;
        self.child = NOSTREAM;
    }
    self.uniqueID = [[NSUUID alloc] initWithUUIDBytes:[stream readbytes:16].bytes];
    self.stateBits = [stream read_Int32];
    self.creationDateData = [stream readbytes:8];
    self.modifiedDateData = [stream readbytes:8];
    self.startSectC = [stream read_Int32];
    self.sizeOfEntry = [stream read_Int64];
}

@end
