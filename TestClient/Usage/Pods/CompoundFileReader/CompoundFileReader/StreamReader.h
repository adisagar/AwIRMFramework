/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  StreamReader.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/21/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamReader : NSObject

- (id)initWithFileStream:(NSInputStream *)fileInputStream;

- (NSData *)readByte;
- (ushort)read_UInt16;
- (int)read_Int32;
- (uint)read_UInt32;
- (long)read_Int64;
- (u_long)read_UInt64;
- (NSData *)readbytes:(NSUInteger)length;

@end
