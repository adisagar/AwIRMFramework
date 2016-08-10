/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  MappedObject.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/25/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "MappedObject.h"

@implementation MappedObject

- (void)dealloc
{
    _propertyID = nil;
    _entryORStringID = nil;
}

- (id)initWithPropertyID:(NSString *)propID andEntryORStringID:(NSString *)entryORStringID
{
    if (self = [super init]) {
        _propertyID = propID;
        _entryORStringID = entryORStringID;
    }
    return self;
}

@end
