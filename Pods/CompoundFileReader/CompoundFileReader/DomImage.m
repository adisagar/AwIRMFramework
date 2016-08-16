/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomImage.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomImage.h"

@implementation DomImage

- (void)dealloc
{
    _ID = nil;
    _data = nil;
    _base64Data = nil;
    _format = nil;
}

- (id)init
{
    if (self = [super init]) {
        _format = [[DocumentFormatInfo alloc] init];
        _scaleX = 100;
        _scaleY = 100;
        _picType = RtfPictureTypeJpegblip;
        _height = 0;
        _width = 0;
        _desiredHeight = 0;
        _desiredWidth = 0;
    }
    return self;
}

@end
