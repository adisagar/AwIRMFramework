/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomObject.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomObject.h"

@implementation DomObject

- (void)dealloc
{
    _customAttributes = nil;
    _className = nil;
    _name = nil;
    _content = nil;
    _contentText = nil;
}

- (id)init
{
    if (self = [super init]) {
        _scaleX = 100;
        _scaleY = 100;
        _height = 0;
        _width = 0;
        _type = RtfObjectTypeEmb;
    }
    return self;
}

@end
