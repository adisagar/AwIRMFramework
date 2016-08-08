/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomTableCell.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomTableCell.h"

@implementation DomTableCell

- (void)dealloc
{
    _format = nil;
    _overideCell = nil;
}

- (id)init
{
    if (self = [super init]) {
        _multiLine = YES;
        _format = [[DocumentFormatInfo alloc] init];
        _verticalAlignment = RtfVerticalAlignmentTop;
        _paddingBottom = NSIntegerMin;
        _paddingRight = NSIntegerMin;
        _paddingTop = NSIntegerMin;
        _paddingLeft = NSIntegerMin;
        _colSpan = 1;
        _rowSpan = 1;
        _height = 0;
        _width = 0;
        _left = 0;
        _format.borderWidth = 1;
    }
    return self;
}

@end
