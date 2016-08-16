/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  RtfObject.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "RtfObject.h"

@implementation RtfObject

- (void)dealloc
{
    _listName = nil;
    _listStyleName = nil;
    _fontName = nil;
    _levelText = nil;
}

- (id)init
{
    if (self = [super init]) {
        _listID = 0;
        _listTemplateID = 0;
        _listSimple = NO;
        _listHybrid = NO;
        _listName = nil;
        _listStyleName = nil;
        _levelStartAt = 1;
        _levelNfc = RtfLevelNumberTypeNone;
        _levelJC = 0;
        _levelFollow = 0;
        _fontName = nil;
        _levelText = nil;

    }
    return self;
}

@end
