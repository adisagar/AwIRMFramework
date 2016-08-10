/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DocumentFormatInfo.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DocumentFormatInfo.h"
#import <CoreText/CoreText.h>

@interface DocumentFormatInfo ()

@end

@implementation DocumentFormatInfo

- (void)dealloc
{
    _parent = nil;
    _borderColor = nil;
    _font = nil;
    _fontName = nil;
    _textColor = nil;
    _backColor = nil;
    _link = nil;
    _attString = nil;
}

- (id)init
{
    if (self = [super init]) {
        _readText = YES;
        _noWrap = YES;
        _listID = -1;
        _link = nil;
        _backColor = [UIColor clearColor];
        _textColor = [UIColor blackColor];
        _hidden = NO;
        _strikeOut = NO;
        _underLine = NO;
        _italic = NO;
        _bold = NO;
        _fontSize = 12.0f;
        _fontName = @"Helevtica";
        _rtfAlignment = RtfAlignmentLeft;
        _spacingAfter = 0;
        _spacingBefore = 0;
        _multipleLineSpacing = NO;
        _lineSpacing = 0;
        _spacing = 0;
        _leftIndent = 0;
        _paragraphFirstLineIndent = 0;
        _pageBreak = NO;
        _standTabWidth = 100;
        _borderColor = [UIColor blackColor];
        _multiLine = NO;
        _borderSpacing = 0;
        _borderThickness = 0;
        _dashStyle = DashStyleSolid;
        _borderWidth = 0;
        _bottomBorder = NO;
        _rightBorder = NO;
        _topBorder = NO;
        _leftBorder = NO;
    }
    return self;
}

- (void)resetText
{
    _fontName = @"Helvetica";
    _bold = NO;
    _italic = NO;
    _underLine = NO;
    _strikeOut = NO;
    _textColor = [UIColor blackColor];
    _backColor = [UIColor clearColor];
    _subScript = NO;
    _superScript = NO;
    _multiLine = NO;
    _hidden = NO;
    _leftBorder = NO;
    _topBorder = NO;
    _rightBorder = NO;
    _bottomBorder = NO;
    _dashStyle = DashStyleSolid;
    _borderSpacing = 0;
    _borderThickness = NO;
    _borderColor = [UIColor blackColor];
}

- (void)resetParagraph
{
    _paragraphFirstLineIndent = 0;
    _rtfAlignment = RtfAlignmentLeft;
    _listID = -1;
    _leftIndent = 0;
    _lineSpacing = 0;
    _pageBreak = NO;
    _leftBorder = NO;
    _topBorder = NO;
    _rightBorder = NO;
    _bottomBorder = NO;
    _dashStyle = DashStyleSolid;
    _borderSpacing = 0;
    _borderThickness = 0;
    _borderColor = 0;
    _multipleLineSpacing = NO;
    _spacingBefore = 0;
    _spacingAfter = 0;
}

- (void)resetAll
{
    _paragraphFirstLineIndent = 0;
    _leftIndent = 0;
    _leftIndent = 0;
    _spacing = 0;
    _lineSpacing = 0;
    _multipleLineSpacing = false;
    _spacingBefore = 0;
    _spacingAfter = 0;
    _rtfAlignment = RtfAlignmentLeft;
    _fontName = @"Helvetica";
    _fontSize = 12;
    _bold = false;
    _italic = false;
    _underLine = false;
    _strikeOut = false;
    _textColor = [UIColor blackColor];
    _backColor = [UIColor clearColor];
    _link = nil;
    _subScript = false;
    _superScript = false;
    _listID = -1;
    _multiLine = true;
    _noWrap = true;
    _leftBorder = false;
    _topBorder = false;
    _rightBorder = false;
    _bottomBorder = false;
    _dashStyle = DashStyleSolid;
    _borderSpacing = 0;
    _borderThickness = false;
    _borderColor = [UIColor blackColor];
    _readText = true;
    _nativeLevel = 0;
    _hidden = false;
}

- (void)setFont:(UIFont *)font
{
    CTFontRef ctFontRef = (__bridge CTFontRef)font;
    _bold = (CTFontGetSymbolicTraits(ctFontRef) & kCTFontBoldTrait);
    _italic = (CTFontGetSymbolicTraits(ctFontRef) & kCTFontItalicTrait);
    _fontName = font.fontName;
    _fontSize = font.pointSize;
}

- (id)copyWithZone:(NSZone *)zone
{
    DocumentFormatInfo *documentFormatInfo = [[DocumentFormatInfo alloc] init];
    
    documentFormatInfo.parent = _parent;
    documentFormatInfo.readText = _readText;
    documentFormatInfo.leftBorder = _leftBorder;
    documentFormatInfo.topBorder = _topBorder;
    documentFormatInfo.rightBorder = _rightBorder;
    documentFormatInfo.bottomBorder = _bottomBorder;
    documentFormatInfo.borderColor = _borderColor;
    documentFormatInfo.borderWidth = _borderWidth;
    documentFormatInfo.dashStyle = _dashStyle;
    documentFormatInfo.borderThickness = _borderThickness;
    documentFormatInfo.borderSpacing = _borderSpacing;
    documentFormatInfo.multiLine = _multiLine;
    documentFormatInfo.standTabWidth = _standTabWidth;
    documentFormatInfo.paragraphFirstLineIndent = _paragraphFirstLineIndent;
    documentFormatInfo.leftIndent = _leftIndent;
    documentFormatInfo.spacing = _spacing;
    documentFormatInfo.lineSpacing = _lineSpacing;
    documentFormatInfo.multipleLineSpacing = _multipleLineSpacing;
    documentFormatInfo.spacingAfter = _spacingAfter;
    documentFormatInfo.spacingBefore =_spacingBefore;
    documentFormatInfo.rtfAlignment = _rtfAlignment;
    documentFormatInfo.pageBreak = _pageBreak;
    documentFormatInfo.nativeLevel = _nativeLevel;
    documentFormatInfo.font = _font;
    documentFormatInfo.fontName = _fontName;
    documentFormatInfo.fontSize = _fontSize;
    documentFormatInfo.bold = _bold;
    documentFormatInfo.italic = _italic;
    documentFormatInfo.underLine = _underLine;
    documentFormatInfo.strikeOut = _strikeOut;
    documentFormatInfo.hidden = _hidden;
    documentFormatInfo.textColor = _textColor;
    documentFormatInfo.backColor = _backColor;
    documentFormatInfo.link = _link;
    documentFormatInfo.superScript = _superScript;
    documentFormatInfo.subScript = _subScript;
    documentFormatInfo.listID = _listID;
    documentFormatInfo.noWrap = _noWrap;
    documentFormatInfo.attString = _attString;
    
    return documentFormatInfo;
}

@end
