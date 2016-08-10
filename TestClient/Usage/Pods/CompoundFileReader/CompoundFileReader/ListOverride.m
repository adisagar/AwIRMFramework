/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ListOverride.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ListOverride.h"

@implementation ListOverride

- (id)init
{
    if (self = [super init]) {
        _listID = 0;
        _listOverrideCount = 0;
        _ID = 1;
    }
    return self;
}

@end
