/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomImage.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DomElement.h"
#import "RTFEnums.h"
#import "DocumentFormatInfo.h"

@interface DomImage : DomElement

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSString *base64Data;
@property (nonatomic, assign) NSInteger scaleX;
@property (nonatomic, assign) NSInteger scaleY;
@property (nonatomic, assign) NSInteger desiredWidth;
@property (nonatomic, assign) NSInteger desiredHeight;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) RtfPictureType picType;
@property (nonatomic, strong) DocumentFormatInfo *format;

@end
