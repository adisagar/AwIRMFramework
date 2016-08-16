/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomTableRow.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomElement.h"
#import "DocumentFormatInfo.h"

@interface DomTableRow : DomElement

@property (nonatomic, strong) NSMutableArray *cellSettings;
@property (nonatomic, strong) DocumentFormatInfo *format;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) BOOL isLastRow;
@property (nonatomic, assign) BOOL header;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger paddingLeft;
@property (nonatomic, assign) NSInteger paddingTop;
@property (nonatomic, assign) NSInteger paddingRight;
@property (nonatomic, assign) NSInteger paddingBottom;
@property (nonatomic, assign) NSInteger width;

@end
