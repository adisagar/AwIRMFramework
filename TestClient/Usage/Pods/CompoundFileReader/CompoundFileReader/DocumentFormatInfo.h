/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DocumentFormatInfo.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RTFEnums.h"

typedef enum {
    DashStyleSolid = 0,
    DashStyleDash,
    DashStyleDot,
    DashStyleDashDot,
    DashStyleDashDotDot,
    DashStyleCustom
} DashStyle;

@interface DocumentFormatInfo : NSObject <NSCopying>

@property (nonatomic, strong) DocumentFormatInfo *parent;
@property (nonatomic, assign) BOOL readText;
@property (nonatomic, assign) BOOL leftBorder;
@property (nonatomic, assign) BOOL topBorder;
@property (nonatomic, assign) BOOL rightBorder;
@property (nonatomic, assign) BOOL bottomBorder;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) NSInteger borderWidth;
@property (nonatomic, assign) DashStyle dashStyle;
@property (nonatomic, assign) BOOL borderThickness;
@property (nonatomic, assign) NSInteger borderSpacing;
@property (nonatomic, assign) BOOL multiLine;
@property (nonatomic, assign) NSInteger standTabWidth;
@property (nonatomic, assign) NSInteger paragraphFirstLineIndent;
@property (nonatomic, assign) NSInteger leftIndent;
@property (nonatomic, assign) NSInteger spacing;
@property (nonatomic, assign) NSInteger lineSpacing;
@property (nonatomic, assign) BOOL multipleLineSpacing;
@property (nonatomic, assign) NSInteger spacingAfter;
@property (nonatomic, assign) NSInteger spacingBefore;
@property (nonatomic, assign) RtfAlignment rtfAlignment;
@property (nonatomic, assign) BOOL pageBreak;
@property (nonatomic, assign) NSInteger nativeLevel;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;
@property (nonatomic, assign) BOOL underLine;
@property (nonatomic, assign) BOOL strikeOut;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, assign) BOOL superScript;
@property (nonatomic, assign) BOOL subScript;
@property (nonatomic, assign) NSInteger listID;
@property (nonatomic, assign) BOOL noWrap;
@property (nonatomic, assign) NSAttributedString *attString;

- (void)resetText;
- (void)resetParagraph;
- (void)resetAll;

@end
