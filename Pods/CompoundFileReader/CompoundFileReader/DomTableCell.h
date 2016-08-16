/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomTableCell.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomElement.h"
#import "RTFEnums.h"
#import "DocumentFormatInfo.h"

@interface DomTableCell : DomElement

@property (nonatomic, assign) NSInteger rowSpan;
@property (nonatomic, assign) NSInteger colSpan;
@property (nonatomic, assign) NSInteger paddingLeft;
@property (nonatomic, assign) NSInteger runtimePaddingLeft;
@property (nonatomic, assign) NSInteger paddingTop;
@property (nonatomic, assign) NSInteger runtimePaddingTop;
@property (nonatomic, assign) NSInteger paddingRight;
@property (nonatomic, assign) NSInteger runtimePaddingRight;
@property (nonatomic, assign) NSInteger paddingBottom;
@property (nonatomic, assign) NSInteger runtimePaddingBottom;
@property (nonatomic, assign) RtfVerticalAlignment verticalAlignment;
@property (nonatomic, strong) DocumentFormatInfo *format;
@property (nonatomic, assign) BOOL multiLine;
@property (nonatomic, assign) NSInteger left;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) DomTableCell *overideCell;

@end
