/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ListTable.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/14/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RtfObject.h"

@interface ListTable : NSObject

- (RtfObject *)objectById:(NSInteger)ID;
- (void)addObject:(RtfObject *)rtfObject;

@end
