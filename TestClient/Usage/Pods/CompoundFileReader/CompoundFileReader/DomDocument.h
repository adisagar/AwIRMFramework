/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomDocument.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DomElement.h"
#import "ColorTable.h"
#import "FontTable.h"
#import "DocumentFormatInfo.h"
#import "DocumentInfo.h"
#import "ListOverrideTable.h"
#import "ListTable.h"

@interface DomDocument : DomElement

@property (nonatomic, copy) NSString *followingChars;
@property (nonatomic, copy) NSString *leadingChars;
@property (nonatomic, assign) NSStringEncoding runtimeEncoding;
@property (nonatomic, strong) ListTable *listTable;
@property (nonatomic, strong) FontTable *fontTable;
@property (nonatomic, strong) ColorTable *colorTable;
@property (nonatomic, strong) DocumentInfo *info;
@property (nonatomic, strong) ListOverrideTable *listOverrideTable;
@property (nonatomic, copy) NSString *generator;
@property (nonatomic, assign) NSInteger paperWidth;
@property (nonatomic, assign) NSInteger paperHeigth;
@property (nonatomic, assign) NSInteger leftMargin;
@property (nonatomic, assign) NSInteger topMargin;
@property (nonatomic, assign) NSInteger rightMargin;
@property (nonatomic, assign) NSInteger bottomMargin;
@property (nonatomic, assign) BOOL landScape;
@property (nonatomic, assign) NSInteger headerDistance;
@property (nonatomic, assign) NSInteger footerDistance;
@property (nonatomic, assign) NSInteger clientWidth;
@property (nonatomic, assign) BOOL changeTimesNewRoman;
@property (nonatomic, assign) NSInteger defaultRowHeight;
@property (nonatomic, copy) NSString *htmlContent;

- (void)loadRTFText:(NSString *)RTFText;

@end
