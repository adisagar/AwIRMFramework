/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomTableRow.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomTableRow.h"

@implementation DomTableRow

- (void)dealloc
{
    _cellSettings = nil;
    _format = nil;
}

- (id)init
{
    if (self = [super init]) {
        _width = 0;
        _paddingBottom = NSIntegerMin;
        _paddingRight = NSIntegerMin;
        _paddingTop = NSIntegerMin;
        _paddingLeft = NSIntegerMin;
        _height = 0;
        _header = NO;
        _isLastRow = NO;
        _level = 1;
        _format = [[DocumentFormatInfo alloc] init];
        _cellSettings = [NSMutableArray array];
    }
    return self;
}

@end
