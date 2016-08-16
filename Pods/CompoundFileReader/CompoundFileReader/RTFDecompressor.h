/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//The following is implemented using http://msdn.microsoft.com/en-us/library/cc463890(v=exchg.80).aspx
//
//  RTFDecompressor.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/6/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTFDecompressor : NSObject

- (NSData *)decompressRTFData:(NSData *)inputData;

@end
