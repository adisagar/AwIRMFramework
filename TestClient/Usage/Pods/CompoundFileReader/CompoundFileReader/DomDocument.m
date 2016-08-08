/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomDocument.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomDocument.h"
#import "DocumentFormatInfo.h"
#import "ListOverride.h"
#import "RtfObject.h"
#import "AttributeList.h"
#import "Reader.h"
#import "TextConatiner.h"
#import "DomImage.h"
#import "DomText.h"
#import "DomHeader.h"
#import "DomFooter.h"
#import "DomObject.h"
#import "DomShape.h"
#import "DomShapeGroup.h"
#import "DomParagraph.h"
#import "DomField.h"
#import "DomBookmark.h"
#import "DomTableRow.h"
#import "DomTableCell.h"
#import "DomPageBreak.h"
#import "DomLineBreak.h"
#import "ElementContainer.h"
#import "RtfObject.h"

@interface DomDocument ()

@property (nonatomic, assign) NSInteger listTextFlag;
@property (nonatomic, assign) BOOL startContent;
@property (nonatomic, assign) NSInteger tokenCount;
@property (nonatomic, assign) NSStringEncoding associateFontCharset;
@property (nonatomic, assign) NSStringEncoding fontCharset;
@property (nonatomic, strong) DocumentFormatInfo *paragraphFormat;
@property (nonatomic, assign) NSStringEncoding defaultEncoding;

@end

@implementation DomDocument

- (void)dealloc
{
    _paragraphFormat = nil;
    _followingChars =  nil;
    _leadingChars = nil;
    _listTable = nil;
    _fontTable = nil;
    _colorTable = nil;
    _listOverrideTable = nil;
    _info = nil;
    _generator = nil;
    _htmlContent = nil;
}

- (id)init
{
    if (self = [super init]) {
        _defaultRowHeight = 400;
        _footerDistance = 720;
        _headerDistance = 720;
        _bottomMargin = 1440;
        _rightMargin = 1800;
        _topMargin = 1440;
        _leftMargin = 1800;
        _paperHeigth = 15800;
        _paperWidth = 12240;
        _info = [[DocumentInfo alloc] init];
        _listOverrideTable = [[ListOverrideTable alloc] init];
        _colorTable = [[ColorTable alloc] init];
        _fontTable = [[FontTable alloc] init];
        _changeTimesNewRoman = NO;
        self.ownerDocument = self;
        _defaultEncoding = NSUTF8StringEncoding;
        self.nativeLevel = -1;
    }
    return self;
}

- (NSInteger)clientWidth
{
    if (self.landScape) {
        return self.paperHeigth - self.leftMargin - self.rightMargin;
    }
    return self.paperWidth - self.leftMargin - self.rightMargin;
}

- (void)loadRTFText:(NSString *)RTFText
{
    _htmlContent = nil;
    [self.elementList removeAllObjects];
    _startContent = NO;
    Reader *reader = [[Reader alloc] initWithText:RTFText];
    DocumentFormatInfo *documentFormatInfo = [[DocumentFormatInfo alloc] init];
    self.paragraphFormat = nil;
    [self loadRTFReader:reader andDocumentFormatInfo:documentFormatInfo];
    
    //If couldn't find htmlContent load the rtf as htmlContent.
    if (!self.htmlContent) {
        self.htmlContent = [self htmlContentFromRTF];
    }
    self.ownerDocument = nil;
}

- (void)loadRTFReader:(Reader *)reader andDocumentFormatInfo:(DocumentFormatInfo *)parentFormat
{
    if (!reader) {
        return;
    }
    
    BOOL forBitPard = NO;
    DocumentFormatInfo *format;
    
    if (!self.paragraphFormat) {
        self.paragraphFormat = [[DocumentFormatInfo alloc] init];
    }
    
    if (!parentFormat) {
        format = [[DocumentFormatInfo alloc] init];
    } else {
        format = [parentFormat copy];
        format.nativeLevel = parentFormat.nativeLevel + 1;
    }
    
    TextConatiner *textContainer = [[TextConatiner alloc] initWithDomDocument:self];
    
    NSInteger levelBack = reader.level;
    
    while ([reader readToken]) {
        if (reader.tokenCount - self.tokenCount > 100) {
            self.tokenCount = reader.tokenCount;
        }
        
        if (self.startContent) {
            if ([textContainer acceptWithToken:reader.currentToken andWithReader:reader]) {
                textContainer.level = reader.level;
                continue;
            }
        }
        
        if (textContainer.hasContent) {
            if ([self applyTextWithTextContainer:textContainer withReader:reader andFormat:format]) {
                break;
            }
        }
    
        if (reader.tokenType == RtfTokenTypeGroupEnd) {
            NSArray *elements = [self getLastElementsbyCheckingLockState:YES];
            
            for (NSInteger count = 0; count < elements.count; count++) {
                
                id element = elements[count];
                if ([element nativeLevel] >= 0 && [element nativeLevel] > reader.level) {
                    
                    for (NSInteger count2 = count; count2 < elements.count; count2++) {
                        [elements[count2] setLocked:YES];
                    }
                    break;
                }
            }
            break;
        }
        
        if (reader.level < levelBack) {
            break;
        }
        
        if (reader.tokenType == RtfTokenTypeGroupStart) {
            [self loadRTFReader:reader andDocumentFormatInfo:format];
            if (reader.level < levelBack) {
                break;
            }
        }
        
        if (reader.tokenType == RtfTokenTypeControl
            || reader.tokenType == RtfTokenTypeKeyword
            || reader.tokenType == RtfTokenTypeExtKeyword) {
            
            if ([reader.keyWord isEqualToString:@"fromhtml"]) {
                [self readHTMLContent:reader];
                return;
            } else if ([reader.keyWord isEqualToString:@"listtable"]) {
                [self readListTable:reader];
                return;
            } else if ([reader.keyWord isEqualToString:@"listoverride"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"ansicpg"]) {
                self.defaultEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertWindowsCodepageToEncoding((UInt32)reader.parameter));
            } else if ([reader.keyWord isEqualToString:@"fonttbl"]) {
                [self readFontTable:reader];
            } else if ([reader.keyWord isEqualToString:@"listoverridetable"]) {
                [self readListOverrideTable:reader];
            } else if ([reader.keyWord isEqualToString:@"filetable"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"colortbl"]) {
                [self readColorTable:reader];
                return;
            } else if ([reader.keyWord isEqualToString:@"stylesheet"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"generator"]) {
                self.generator = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
            } else if ([reader.keyWord isEqualToString:@"info"]) {
                [self readDocumentInfo:reader];
                return;
            } else if ([reader.keyWord isEqualToString:@"headry"]) {
                if (reader.hasParam) {
                    self.headerDistance = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"footery"]) {
                if (reader.hasParam) {
                    self.footerDistance = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"header"]) {
                DomHeader *header = [[DomHeader alloc] init];
                header.style = RtfHeaderFooterStyleAllPages;
                [self appendChild:header];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                header.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"headerl"]) {
                DomHeader *headerl = [[DomHeader alloc] init];
                headerl.style = RtfHeaderFooterStyleLeftPages;
                [self appendChild:headerl];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                headerl.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"headerr"]) {
                DomHeader *headerr = [[DomHeader alloc] init];
                headerr.style = RtfHeaderFooterStyleRightPages;
                [self appendChild:headerr];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                headerr.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"headerf"]) {
                DomHeader *headerf = [[DomHeader alloc] init];
                headerf.style = RtfHeaderFooterStyleFirstPage;
                [self appendChild:headerf];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                headerf.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"footer"]) {
                DomFooter *footer = [[DomFooter alloc] init];
                footer.style = RtfHeaderFooterStyleAllPages;
                [self appendChild:footer];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                footer.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"footerl"]) {
                DomFooter *footerl = [[DomFooter alloc] init];
                footerl.style = RtfHeaderFooterStyleLeftPages;
                [self appendChild:footerl];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                footerl.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"footerr"]) {
                DomFooter *footerlr = [[DomFooter alloc] init];
                footerlr.style = RtfHeaderFooterStyleRightPages;
                [self appendChild:footerlr];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                footerlr.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"footerf"]) {
                DomFooter *footerlf = [[DomFooter alloc] init];
                footerlf.style = RtfHeaderFooterStyleFirstPage;
                [self appendChild:footerlf];
                [self loadRTFReader:reader andDocumentFormatInfo:parentFormat];
                footerlf.locked = YES;
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            } else if ([reader.keyWord isEqualToString:@"xmlns"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"nonesttables"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"paperw"]) {
                self.paperWidth = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"paperh"]) {
                self.paperHeigth = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"margl"]) {
                self.leftMargin = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"margr"]) {
                self.rightMargin = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"margb"]) {
                self.bottomMargin = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"margt"]) {
                self.topMargin = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"landscape"]) {
                self.landScape = YES;
            } else if ([reader.keyWord isEqualToString:@"fchars"]) {
                self.followingChars = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
            } else if ([reader.keyWord isEqualToString:@"lchars"]) {
                self.leadingChars = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
            } else if ([reader.keyWord isEqualToString:@"pnseclvl"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"pard"]) {
                self.startContent = YES;
                if (forBitPard) {
                    continue;
                }
                [self.paragraphFormat resetParagraph];
            } else if ([reader.keyWord isEqualToString:@"par"]) {
                self.startContent = YES;
                if (![self getLastElementWithElementType:NSStringFromClass([DomParagraph class])]) {
                    DomParagraph *paragraph = [[DomParagraph alloc] init];
                    paragraph.format = [self.paragraphFormat copy];
                    [self addContentElement:paragraph];
                    paragraph.locked = YES;
                } else {
                    [self completeParagraph];
                    DomParagraph *p = [[DomParagraph alloc] init];
                    [self addContentElement:p];
                }
                self.startContent = YES;
            } else if ([reader.keyWord isEqualToString:@"page"]) {
                self.startContent = YES;
                [self completeParagraph];
                [self addContentElement:[[DomPageBreak alloc] init]];
            } else if ([reader.keyWord isEqualToString:@"pagebb"]) {
                self.startContent = YES;
                self.paragraphFormat.pageBreak = YES;
            } else if ([reader.keyWord isEqualToString:@"ql"]) {
                self.startContent = YES;
                self.paragraphFormat.rtfAlignment = RtfAlignmentLeft;
            } else if ([reader.keyWord isEqualToString:@"qc"]) {
                self.startContent = YES;
                self.paragraphFormat.rtfAlignment = RtfAlignmentCenter;
            } else if ([reader.keyWord isEqualToString:@"qr"]) {
                self.startContent = YES;
                self.paragraphFormat.rtfAlignment = RtfAlignmentRight;
            } else if ([reader.keyWord isEqualToString:@"qj"]) {
                self.startContent = YES;
                self.paragraphFormat.rtfAlignment = RtfAlignmentJustify;
            } else if ([reader.keyWord isEqualToString:@"sl"]) {
                self.startContent = YES;
                if (reader.parameter >= 0) {
                    self.paragraphFormat.lineSpacing = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"slmult"]) {
                self.startContent = YES;
                self.paragraphFormat.multipleLineSpacing = (reader.parameter == 1);
            } else if ([reader.keyWord isEqualToString:@"sb"]) {
                self.startContent = YES;
                self.paragraphFormat.spacingBefore = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"sa"]) {
                self.startContent = YES;
                self.paragraphFormat.spacingAfter = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"fi"]) {
                self.startContent = YES;
                self.paragraphFormat.paragraphFirstLineIndent = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"brdrw"]) {
                self.startContent = YES;
                self.paragraphFormat.borderWidth = reader.parameter;
            } else if ([reader.keyWord isEqualToString:@"pn"]) {
                self.startContent = YES;
                self.paragraphFormat.listID = -1;
            } else if ([reader.keyWord isEqualToString:@"pnlvlbody"]) {
                self.startContent = YES;
            } else if ([reader.keyWord isEqualToString:@"pnlvlblt"]) {
                self.startContent = YES;
            } else if ([reader.keyWord isEqualToString:@"listtext"]) {
                self.startContent = YES;
                NSString *text = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                if (text) {
                    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    self.listTextFlag = [text hasPrefix:@"1"] ? 1 : 2;
                }
            } else if ([reader.keyWord isEqualToString:@"ls"]) {
                self.startContent = YES;
                self.paragraphFormat.listID = reader.parameter;
                self.listTextFlag = 0;
            } else if ([reader.keyWord isEqualToString:@"li"]) {
                self.startContent = YES;
                if (reader.hasParam) {
                    self.paragraphFormat.leftIndent = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"line"]) {
                self.startContent = YES;
                if ([format readText]) {
                    DomLineBreak *line = [[DomLineBreak alloc] init];
                    line.nativeLevel = reader.level;
                    [self addContentElement:line];
                }
            } else if ([reader.keyWord isEqualToString:@"plain"]) {
                self.startContent = YES;
                [format resetText];
            } else if ([reader.keyWord isEqualToString:@"f"]) {
                self.startContent = YES;
                if ([format readText]) {
                    NSString *fontName = [self.fontTable fontNameAtIndex:reader.parameter];
                    if (fontName) {
                        fontName = [fontName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    } else {
                        fontName = @"Microsoft Sans Serif";
                    }
                    
                    if (self.changeTimesNewRoman) {
                        if ([fontName isEqualToString:@"Times New Roman"]) {
                            fontName = @"Microsoft Sans Serif";
                        }
                    }
                    format.fontName = fontName;
                }
                self.fontCharset = [[self.fontTable fontAtIndex:reader.parameter] stringEncoding];
            } else if ([reader.keyWord isEqualToString:@"af"]) {
                self.associateFontCharset = [[self.fontTable fontAtIndex:reader.parameter] stringEncoding];
            } else if ([reader.keyWord isEqualToString:@"fs"]) {
                self.startContent = YES;
                if ([format readText]) {
                    if (reader.hasParam) {
                        format.fontSize = reader.parameter/2.0f;
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"cf"]) {
                self.startContent = YES;
                if ([format readText]) {
                    if (reader.hasParam) {
                        format.textColor = [self.colorTable colorAtIndex:reader.parameter andDefaultColor:[UIColor blackColor]];
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"cd"] || [reader.keyWord isEqualToString:@"chcbpat"]) {
                self.startContent = YES;
                if ([format readText]) {
                    if (reader.hasParam) {
                        format.backColor = [self.colorTable colorAtIndex:reader.parameter andDefaultColor:[UIColor clearColor]];
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"b"]) {
                self.startContent = YES;
                if ([format readText]) {
                    format.bold = (reader.hasParam == NO || reader.parameter != 0);
                }
            } else if ([reader.keyWord isEqualToString:@"v"]) {
                self.startContent = YES;
                if ([format readText]) {
                    if (reader.hasParam && reader.parameter == 0) {
                        format.hidden = NO;
                    } else {
                        format.hidden = YES;
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"highlight"]) {
                self.startContent = YES;
                if ([format readText]) {
                    if (reader.hasParam) {
                        format.backColor = [self.colorTable colorAtIndex:reader.parameter andDefaultColor:[UIColor clearColor]];
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"i"]) {
                self.startContent = YES;
                if ([format readText]) {
                    format.italic = (reader.hasParam == NO || reader.parameter != 0);
                }
            } else if ([reader.keyWord isEqualToString:@"ul"]) {
                self.startContent = YES;
                if ([format readText]) {
                    format.underLine = (reader.hasParam == NO || reader.parameter != 0);
                }
            } else if ([reader.keyWord isEqualToString:@"strike"]) {
                self.startContent = YES;
                if ([format readText]) {
                    format.strikeOut = (reader.hasParam == NO || reader.parameter != 0);
                }
            } else if ([reader.keyWord isEqualToString:@"sub"]) {
                self.startContent = YES;
                if ([format readText]) {
                    format.subScript = (reader.hasParam == NO || reader.parameter != 0);
                }
            } else if ([reader.keyWord isEqualToString:@"super"]) {
                self.startContent = YES;
                if ([format readText]) {
                    format.superScript = (reader.hasParam == NO || reader.parameter != 0);
                }
            } else if ([reader.keyWord isEqualToString:@"nosupersub"]) {
                self.startContent = YES;
                format.subScript = NO;
                format.superScript = NO;
            } else if ([reader.keyWord isEqualToString:@"brdrb"]) {
                self.startContent = YES;
                self.paragraphFormat.bottomBorder = YES;
            } else if ([reader.keyWord isEqualToString:@"brdrl"]) {
                self.startContent = YES;
                self.paragraphFormat.leftBorder = YES;
            } else if ([reader.keyWord isEqualToString:@"brdrr"]) {
                self.startContent = YES;
                self.paragraphFormat.rightBorder = YES;
            } else if ([reader.keyWord isEqualToString:@"brdrt"]) {
                self.startContent = YES;
                self.paragraphFormat.topBorder = YES;
            } else if ([reader.keyWord isEqualToString:@"brdrcf"]) {
                self.startContent = YES;
                DomElement *element = [self getLastElementWithElementType:NSStringFromClass([DomTableRow class]) andWithLockState:NO];
                if ([element isKindOfClass:[DomTableRow class]]) {
                    DomTableRow *row = (DomTableRow *)element;
                    if (row.cellSettings.count > 0) {
                        AttributeList *style = (AttributeList *)row.cellSettings[row.cellSettings.count - 1];
                        [style addAttributeWithName:reader.keyWord andValue:reader.parameter];
                    }
                } else {
                    self.paragraphFormat.borderColor = [self.colorTable colorAtIndex:reader.parameter andDefaultColor:[UIColor blackColor]];
                }
            } else if ([reader.keyWord isEqualToString:@"brdrs"]) {
                self.startContent = YES;
                self.paragraphFormat.borderThickness = NO;
                format.borderThickness = NO;
            } else if ([reader.keyWord isEqualToString:@"brdth"]) {
                self.startContent = YES;
                self.paragraphFormat.borderThickness = YES;
                format.borderThickness = YES;
            } else if ([reader.keyWord isEqualToString:@"brdrdot"]) {
                self.startContent = YES;
                self.paragraphFormat.dashStyle = DashStyleDashDot;
                format.dashStyle = DashStyleDashDot;
            } else if ([reader.keyWord isEqualToString:@"brdrdash"]) {
                self.startContent = YES;
                self.paragraphFormat.dashStyle = DashStyleDash;
                format.dashStyle = DashStyleDash;
            } else if ([reader.keyWord isEqualToString:@"brdrdashd"]) {
                self.startContent = YES;
                self.paragraphFormat.dashStyle = DashStyleDashDot;
                format.dashStyle = DashStyleDashDot;
            } else if ([reader.keyWord isEqualToString:@"brdrdashdd"]) {
                self.startContent = YES;
                self.paragraphFormat.dashStyle = DashStyleDashDotDot;
                format.dashStyle = DashStyleDashDotDot;
            } else if ([reader.keyWord isEqualToString:@"brdrnil"]) {
                self.startContent = YES;
                self.paragraphFormat.leftBorder = NO;
                self.paragraphFormat.topBorder = NO;
                self.paragraphFormat.rightBorder = NO;
                self.paragraphFormat.bottomBorder = NO;
                format.leftBorder = NO;
                format.topBorder = NO;
                format.rightBorder = NO;
                format.bottomBorder = NO;
            } else if ([reader.keyWord isEqualToString:@"brsp"]) {
                self.startContent = YES;
                if (reader.hasParam) {
                    self.paragraphFormat.borderSpacing = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"chbrdr"]) {
                self.startContent = YES;
                format.leftBorder = YES;
                format.topBorder = YES;
                format.rightBorder = YES;
                format.bottomBorder = YES;
            } else if ([reader.keyWord isEqualToString:@"bkmkstart"]) {
                self.startContent = YES;
                if ([format readText]) {
                    DomBookmark *bk = [[DomBookmark alloc] init];
                    bk.name = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                    bk.locked = YES;
                    [self addContentElement:bk];
                }
            } else if ([reader.keyWord isEqualToString:@"bkmkend"]) {
                forBitPard = YES;
                format.readText = NO;
            } else if ([reader.keyWord isEqualToString:@"field"]) {
                self.startContent = YES;
                [self readDomFieldFromReader:reader andFormat:format];
                return;
            } else if ([reader.keyWord isEqualToString:@"object"]) {
                self.startContent = YES;
                [self readDomObjectFromReader:reader andFormat:format];
                return;
            } else if ([reader.keyWord isEqualToString:@"nonshppict"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"pict"]) {
                self.startContent = YES;
                DomImage *image = [[DomImage alloc] init];
                image.nativeLevel = reader.level;
                [self addContentElement:image];
            } else if ([reader.keyWord isEqualToString:@"picscalex"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.scaleX = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"picscaley"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.scaleY = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"picwgoal"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.desiredWidth = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"pichgoal"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.desiredHeight = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"blipuid"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.ID = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                }
            } else if ([reader.keyWord isEqualToString:@"emfblip"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypeEmfblip;
                }
            } else if ([reader.keyWord isEqualToString:@"pngblip"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypePngblip;
                }
            } else if ([reader.keyWord isEqualToString:@"jpegblip"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypeJpegblip;
                }
            } else if ([reader.keyWord isEqualToString:@"macpict"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypeMacpict;
                }
            } else if ([reader.keyWord isEqualToString:@"pmmetafile"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypePmmetafile;
                }
            } else if ([reader.keyWord isEqualToString:@"wmetafile"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypeWmetafile;
                }
            } else if ([reader.keyWord isEqualToString:@"dibitmap"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypeDibitmap;
                }
            } else if ([reader.keyWord isEqualToString:@"wbitmap"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypeWbitmap;
                }
            } else if ([reader.keyWord isEqualToString:@"pngblip"]) {
                DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
                if (image) {
                    image.picType = RtfPictureTypePngblip;
                }
            } else if ([reader.keyWord isEqualToString:@"sp"]) {
                NSInteger level = 0;
                NSString *vName = nil;
                NSString *vValue = nil;
                
                while ([reader readToken]) {
                    if (reader.tokenType == RtfTokenTypeGroupStart) {
                        level++;
                    } else if (reader.tokenType == RtfTokenTypeGroupEnd) {
                        level--;
                        if (level < 0) {
                            break;
                        }
                    } else {
                        if ([reader.keyWord isEqualToString:@"sn"]) {
                            vName = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                        } else if ([reader.keyWord isEqualToString:@"sv"]) {
                            vValue = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                        }
                    }
                }
                
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                
                if (vName) {
                    if (shape) {
                        shape.extAttbs[vName] = vValue;
                    } else {
                        DomShapeGroup *g = (DomShapeGroup *)[self getLastElementWithElementType:NSStringFromClass([DomShapeGroup class])];
                        if (g) {
                            g.extAttbrs[vName] = vValue;
                        }
                    }
                }
             } else if ([reader.keyWord isEqualToString:@"shprslt"]) {
                [reader readToEndGround];
            } else if ([reader.keyWord isEqualToString:@"shp"]) {
                self.startContent = YES;
                DomShape *shape = [[DomShape alloc] init];
                shape.nativeLevel = reader.level;
                [self addContentElement:shape];
            } else if ([reader.keyWord isEqualToString:@"shpleft"]) {
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                if (shape) {
                    shape.left = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"shptop"]) {
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                if (shape) {
                    shape.top = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"shpright"]) {
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                if (shape) {
                    shape.width = reader.parameter - shape.left;
                }
            } else if ([reader.keyWord isEqualToString:@"shpbottom"]) {
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                if (shape) {
                    shape.height = reader.parameter - shape.top;
                }
            } else if ([reader.keyWord isEqualToString:@"shplid"]) {
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                if (shape) {
                    shape.ID = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"shpz"]) {
                DomShape *shape = (DomShape *)[self getLastElementWithElementType:NSStringFromClass([DomShape class])];
                if (shape) {
                    shape.zIndex = reader.parameter;
                }
            } else if ([reader.keyWord isEqualToString:@"shpgrp"]) {
                DomShapeGroup *shapeG = [[DomShapeGroup alloc] init];
                shapeG.nativeLevel = reader.level;
                [self addContentElement:shapeG];
            } else if ([reader.keyWord isEqualToString:@"intbl"]
                       || [reader.keyWord isEqualToString:@"trowd"]
                       || [reader.keyWord isEqualToString:@"itap"]) {
                self.startContent = YES;
                NSArray *es = [self getLastElementsbyCheckingLockState:YES];
                DomElement *lastUnlockElement = nil;
                DomElement *lastTableElement = nil;
                
                for (NSInteger count = es.count - 1; count >= 0; count--) {
                    DomElement *e = es[count];
                    if (!e.locked) {
                        if (!lastUnlockElement && !([e isKindOfClass:[DomParagraph class]])) {
                            lastUnlockElement = e;
                        }
                        if ([e isKindOfClass:[DomTableRow class]]
                            || [e isKindOfClass:[DomTableCell class]]) {
                            lastTableElement = e;
                        }
                        break;
                    }
                }
                
                if ([reader.keyWord isEqualToString:@"intbl"]) {
                    if (!lastTableElement) {
                        DomTableRow *row = [[DomTableRow alloc] init];
                        row.nativeLevel = reader.level;
                        if (lastUnlockElement) {
                            [lastUnlockElement appendChild:row];
                        }
                    }
                } else if ([reader.keyWord isEqualToString:@"trowd"]) {
                    DomTableRow *row;
                    if (!lastTableElement)
                    {
                        row = [[DomTableRow alloc] init];
                        row.nativeLevel = reader.level;
                        if (!lastUnlockElement)
                            [lastUnlockElement appendChild:row];
                    }
                    else
                    {
                        if ([lastTableElement isKindOfClass:[DomTableRow class]]) {
                            row = (DomTableRow *)lastTableElement;
                        } else {
                            row = (DomTableRow *)lastTableElement.parent;
                        }
                    }
                    [row.attributeList removeAllObjects];
                    [row.cellSettings removeAllObjects];
                    [self.paragraphFormat resetParagraph];
                } else if ([reader.keyWord isEqualToString:@"itap"]) {
                    // set nested level
                    
                    if (reader.parameter == 0)
                    {
                        // is the 0 level , belong to document , not to a table
                        //foreach (RTFDomElement element in es)
                        //{
                        //    if (element is RTFDomTableRow || element is RTFDomTableCell)
                        //    {
                        //        element.Locked = true;
                        //    }
                        //}
                    }
                    else
                    {
                        // in a row
                        DomTableRow *row;
                        if (!lastTableElement)
                        {
                            row = [[DomTableRow alloc] init];
                            row.nativeLevel = reader.level;
                            if (!lastUnlockElement)
                                [lastUnlockElement appendChild:row];
                        } else {
                            if ([lastTableElement isKindOfClass:[DomTableRow class]]) {
                                row = (DomTableRow *)lastTableElement;
                            } else {
                                row = (DomTableRow *)lastTableElement.parent;
                            }
                        }
                        
                        if (reader.parameter == row.level){
                        } else if (reader.parameter > row.level) {
                            // nested row
                            DomTableRow *newRow = [[DomTableRow alloc] init];
                            newRow.level = reader.parameter;
                            DomTableCell *parentCell = (DomTableCell *)[self getLastElementWithElementType:NSStringFromClass([DomTableCell class]) andWithLockState:NO];
                            if (!parentCell)
                                [self addContentElement:newRow];
                            else
                                [parentCell appendChild:newRow];
                        } else if (reader.parameter < row.level){
                            // exit nested row
                        }
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"row"]) {
                self.startContent = YES;
                NSArray *es = [self getLastElementsbyCheckingLockState:YES];
                for (NSInteger count = es.count - 1; count >= 0; count--) {
                    [es[count] setLocked:YES];
                    if ([es[count] isKindOfClass:[DomTableRow class]]) {
                        break;
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"nestrow"]) {
                self.startContent = YES;
                NSArray *es = [self getLastElementsbyCheckingLockState:YES];
                for (NSInteger count = es.count - 1; count >= 0; count--) {
                    [es[count] setLocked:YES];
                    if ([es[count] isKindOfClass:[DomTableRow class]]) {
                        break;
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"trrh"]
                       || [reader.keyWord isEqualToString:@"trautofit"]
                       || [reader.keyWord isEqualToString:@"irowband"]
                       || [reader.keyWord isEqualToString:@"trhdr"]
                       || [reader.keyWord isEqualToString:@"trkeep"]
                       || [reader.keyWord isEqualToString:@"trkeepfollow"]
                       || [reader.keyWord isEqualToString:@"trleft"]
                       || [reader.keyWord isEqualToString:@"trqc"]
                       || [reader.keyWord isEqualToString:@"trql"]
                       || [reader.keyWord isEqualToString:@"trqr"]
                       || [reader.keyWord isEqualToString:@"trcpbat"]
                       || [reader.keyWord isEqualToString:@"trcfpat"]
                       || [reader.keyWord isEqualToString:@"trpat"]
                       || [reader.keyWord isEqualToString:@"trshdng"]
                       || [reader.keyWord isEqualToString:@"trwWidth"]
                       || [reader.keyWord isEqualToString:@"trwWidthA"]
                       || [reader.keyWord isEqualToString:@"irow"]
                       || [reader.keyWord isEqualToString:@"trpaddb"]
                       || [reader.keyWord isEqualToString:@"trpaddl"]
                       || [reader.keyWord isEqualToString:@"trpaddr"]
                       || [reader.keyWord isEqualToString:@"trpaddt"]
                       || [reader.keyWord isEqualToString:@"trpaddfb"]
                       || [reader.keyWord isEqualToString:@"trpaddfl"]
                       || [reader.keyWord isEqualToString:@"trpaddfr"]
                       || [reader.keyWord isEqualToString:@"trpaddft"]
                       || [reader.keyWord isEqualToString:@"lastrow"]) {
                self.startContent = YES;
                DomTableRow *row = (DomTableRow *)[self getLastElementWithElementType:NSStringFromClass([DomTableRow class]) andWithLockState:YES];
                if (row) {
                    [row.attributeList addAttributeWithName:reader.keyWord andValue:reader.parameter];
                }
            } else if ([reader.keyWord isEqualToString:@"clvmgf"]
                       || [reader.keyWord isEqualToString:@"clvmrg"]
                       || [reader.keyWord isEqualToString:@"cellx"]
                       || [reader.keyWord isEqualToString:@"clvertalt"]
                       || [reader.keyWord isEqualToString:@"clvertalc"]
                       || [reader.keyWord isEqualToString:@"clvertalb"]
                       || [reader.keyWord isEqualToString:@"clnowrap"]
                       || [reader.keyWord isEqualToString:@"clcbpat"]
                       || [reader.keyWord isEqualToString:@"clcfpat"]
                       || [reader.keyWord isEqualToString:@"clpadl"]
                       || [reader.keyWord isEqualToString:@"clpadt"]
                       || [reader.keyWord isEqualToString:@"clpadr"]
                       || [reader.keyWord isEqualToString:@"clpadb"]
                       || [reader.keyWord isEqualToString:@"clbrdrl"]
                       || [reader.keyWord isEqualToString:@"clbrdrt"]
                       || [reader.keyWord isEqualToString:@"clbrdrr"]
                       || [reader.keyWord isEqualToString:@"clbrdrb"]
                       || [reader.keyWord isEqualToString:@"brdrtbl"]
                       || [reader.keyWord isEqualToString:@"brdrnone"] ) {
                self.startContent = YES;
                DomTableRow *row = (DomTableRow *)[self getLastElementWithElementType:NSStringFromClass([DomTableRow class]) andWithLockState:NO];
                AttributeList *style = nil;
                
                if (row.cellSettings.count > 0) {
                    style = (AttributeList *)row.cellSettings[row.cellSettings.count - 1];
                    if ([style containsAttributeByName:@"cellx"]) {
                        style = [[AttributeList alloc] init];
                        [row.cellSettings addObject:style];
                    }
                }
                
                if (!style) {
                    style = [[AttributeList alloc] init];
                    [row.cellSettings addObject:style];
                }
                
                [style addAttributeWithName:reader.keyWord andValue:reader.parameter];
            } else if ([reader.keyWord isEqualToString:@"cell"]) {
                self.startContent = YES;
                [self addContentElement:nil];
                [self completeParagraph];
                [self.paragraphFormat resetAll];
                [format resetAll];
                NSArray *es = [self getLastElementsbyCheckingLockState:YES];
                for (NSInteger count = es.count - 1; count >= 0; count--) {
                    if ([es[count] locked] == NO) {
                        [es[count] setLocked:YES];
                        if ([es[count] isKindOfClass:[DomTableCell class]]) {
                            break;
                        }
                    }
                }
            } else if ([reader.keyWord isEqualToString:@"nestcell"]) {
                self.startContent = YES;
                [self addContentElement:nil];
                [self completeParagraph];
                [self.paragraphFormat resetAll];
                [format resetAll];
                NSArray *es = [self getLastElementsbyCheckingLockState:YES];
                for (NSInteger count = es.count - 1; count >= 0; count--) {
                    if ([es[count] locked] == NO) {
                        [es[count] setLocked:YES];
                        if ([es[count] isKindOfClass:[DomTableCell class]]) {
                            ((DomTableCell *)es[count]).format = format;
                            break;
                        }
                    }
                }
            } else {
                if (reader.tokenType == RtfTokenTypeExtKeyword && reader.firstTokenInGroup) {
                    [reader readToEndGround];
                }
            }
        }
    }
    
    if (textContainer.hasContent) {
        [self applyTextWithTextContainer:textContainer withReader:reader andFormat:format];
    }
}

- (BOOL)applyTextWithTextContainer:(TextConatiner *)textContainer withReader:(Reader *)reader andFormat:(DocumentFormatInfo *)format
{
    if (textContainer.hasContent) {
        NSString *text = textContainer.text;
        [textContainer clear];
        DomImage *image = (DomImage *)[self getLastElementWithElementType:NSStringFromClass([DomImage class])];
        
        if (image && image.locked == NO) {
            image.data = [self hexToBytes:text];
            image.format = [format copy];
            image.width = (image.desiredWidth * image.scaleX) / 100;
            image.height = (image.desiredHeight * image.scaleY) / 100;
            image.locked = YES;
            if (reader.tokenType != RtfTokenTypeGroupEnd) {
                [reader readToEndGround];
            }
            return YES;
        }
        
        if (format.readText && self.startContent) {
            DomText *txt = [[DomText alloc] init];
            txt.nativeLevel = textContainer.level;
            txt.format = [format copy];
            if (txt.format.rtfAlignment == RtfAlignmentJustify)
                txt.format.rtfAlignment = RtfAlignmentLeft;
            txt.text = text;
            
            [self addContentElement:txt];
        }
    }
    return false;
}

- (DomElement *)getLastElementWithElementType:(NSString *)elementType
{
    NSArray *elements = [self getLastElementsbyCheckingLockState:YES];
    
    for (NSInteger count = elements.count - 1; count >= 0; count--) {
        if ([elements[count] isKindOfClass:NSClassFromString(elementType)]) {
            return elements[count];
        }
    }
    return nil;
}

- (DomElement *)getLastElementWithElementType:(NSString *)elementType andWithLockState:(BOOL)lockState
{
    NSArray *elements = [self getLastElementsbyCheckingLockState:YES];
    
    for (NSInteger count = elements.count - 1; count >= 0; count--) {
        if ([elements[count] isKindOfClass:NSClassFromString(elementType)]) {
            if ([elements[count] locked] == lockState) {
                return elements[count];
            }
        }
    }
    return nil;
}


- (NSArray *)getLastElementsbyCheckingLockState:(BOOL)checkLockState
{
    NSMutableArray *result = [NSMutableArray array];
    DomElement *element = self;
    while (element != nil) {
        if (checkLockState) {
            if (element.locked) {
                break;
            }
        }
        [result addObject:element];
        element = [element.elementList lastObject];
    }
    
    if (checkLockState) {
        for (NSInteger count = result.count - 1; count >= 0; count--) {
            if ([result[count] locked]) {
                [result removeObjectAtIndex:count];
            }
        }
    }
    
    return result;
}

- (NSData *)hexToBytes:(NSString *)hex
{
    const NSString *chars = @"0123456789abcdef";
    
    NSInteger value = 0;
    NSInteger charCount = 0;
    
    NSMutableData *data = [NSMutableData data];
    
    for (NSInteger count = 0; count < hex.length; count++) {
        char c = [hex characterAtIndex:count];
        c = tolower(c);
        NSInteger index = [chars rangeOfString:[NSString stringWithFormat:@"%c", c]].location;
        if (index >= 0) {
            charCount++;
            charCount++;
            value = value*16 + index;
            if (charCount > 0 && (charCount%2) == 0)
            {
                [data appendBytes:&value length:1];
                value = 0;
            }
        }
    }
    return data;
}

- (void)addContentElement:(DomElement *)newElement
{
    NSArray *elements = [self getLastElementsbyCheckingLockState:YES];
    DomElement *lastElement = nil;
    if (elements.count > 0) {
        lastElement = elements[elements.count - 1];
    }
    
    if ([lastElement isKindOfClass:[DomDocument class]]
        || [lastElement isKindOfClass:[DomHeader class]]
        || [lastElement isKindOfClass:[DomFooter class]]) {
        if ([newElement isKindOfClass:[DomText class]]
            || [newElement isKindOfClass:[DomImage class]]
            || [newElement isKindOfClass:[DomObject class]]
            || [newElement isKindOfClass:[DomShape class]]
            || [newElement isKindOfClass:[DomShapeGroup class]]) {
            
            DomParagraph *paragraph = [[DomParagraph alloc] init];
            
            if (lastElement.elementList.count > 0) {
                paragraph.isTemplateGenerated = YES;
            }
            
            if (self.paragraphFormat) {
                paragraph.format = self.paragraphFormat;
            }
            
            [lastElement appendChild:paragraph];
            
            [paragraph.elementList addObject:newElement];
            return;
        }
    }
    
    id element = elements[elements.count - 1];
    
    if (newElement && newElement.nativeLevel > 0) {
        
        for (NSInteger count = elements.count - 1; count >= 0; count--) {
            
            if ([elements[count] nativeLevel] == newElement.nativeLevel) {
                
                for (NSInteger count2 = count; count2 < elements.count; count2++) {
                    
                    id element2 = elements[count2];
                    if ([newElement isKindOfClass:[DomText class]]
                        || [newElement isKindOfClass:[DomImage class]]
                        || [newElement isKindOfClass:[DomObject class]]
                        || [newElement isKindOfClass:[DomShape class]]
                        || [newElement isKindOfClass:[DomShapeGroup class]]
                        || [newElement isKindOfClass:[DomField class]]
                        || [newElement isKindOfClass:[DomBookmark class]]) {
                        
                        if (newElement.nativeLevel == [element2 nativeLevel]) {
                            
                            if ([element2 isKindOfClass:[DomTableRow class]]
                                || [element2 isKindOfClass:[DomTableCell class]]
                                || [element2 isKindOfClass:[DomField class]]
                                || [element2 isKindOfClass:[DomParagraph class]]) {
                                continue;
                            }
                        }
                    }
                    
                    [elements[count2] setLocked:YES];
                }
                break;
            }
        }
    }
    
    for (NSInteger count = elements.count - 1; count >= 0; count--) {
        
        if ([elements[count] locked] == NO) {
            
            element = elements[count];
            
            if ([element isKindOfClass:[DomImage class]]) {
                [element setLocked:YES];
            } else {
                break;
            }
        }
    }
    
    if ([element isKindOfClass:[DomTableRow class]]) {
        
        DomTableCell *tableCell = [[DomTableCell alloc] init];
        tableCell.nativeLevel = [element nativeLevel];
        [element appendChild:tableCell];
        
        if ([newElement isKindOfClass:[DomTableRow class]]) {
            [tableCell.elementList addObject:newElement];
        } else {
            DomParagraph *cellParagraph = [[DomParagraph alloc] init];
            cellParagraph.format = [self.paragraphFormat copy];
            self.nativeLevel = tableCell.nativeLevel;
            
            [tableCell appendChild:cellParagraph];
            
            if (newElement) {
                [cellParagraph appendChild:newElement];
            }
        }
    } else {
        if (newElement) {
            if ([element isKindOfClass:[DomParagraph class]]
                && ([newElement isKindOfClass:[DomParagraph class]] ||
                    [newElement isKindOfClass:[DomTableRow class]])) {
                    [element setLocked:YES];
                    [[element parent] appendChild:newElement];
                } else {
                    [element appendChild:newElement];
                }
        }
    }
}

- (void)readHTMLContent:(Reader *)reader
{
    NSMutableString *stringBuilder = [NSMutableString string];
    BOOL htmlState = YES;
    
    while ([reader readToken]) {
        
        if ([reader.keyWord isEqualToString:@"htmlrtf"]) {
            if (reader.hasParam && reader.parameter == 0) {
                htmlState = NO;
            } else {
                htmlState = YES;
            }
        } else if ([reader.keyWord isEqualToString:@"htmltag"]) {
            if ([reader.innerReader peek] == ' ') {
                [reader.innerReader read];
            }
            
            NSString *text = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:YES];
            if (text) {
                [stringBuilder appendString:text];
            }
        } else {
            switch (reader.tokenType) {
                case RtfTokenTypeControl:
                    if ([reader.keyWord isEqualToString:@"'"] && !htmlState) {
                        [stringBuilder appendString:reader.currentToken.hex];
                    }
                    break;
                case RtfTokenTypeExtKeyword:
                case RtfTokenTypeKeyword:
                    if (!htmlState) {
                        if ([reader.keyWord isEqualToString:@"par"]) {
                            [stringBuilder appendString:@"\n"];
                        } else if ([reader.keyWord isEqualToString:@"line"]) {
                            [stringBuilder appendString:@"\n"];
                        } else if ([reader.keyWord isEqualToString:@"tab"]) {
                            [stringBuilder appendString:@"\t"];
                        } else if ([reader.keyWord isEqualToString:@"lquote"]) {
                            [stringBuilder appendString:@"&lsquo;"];
                        } else if ([reader.keyWord isEqualToString:@"rquote"]) {
                            [stringBuilder appendString:@"&rsquo;"];
                        } else if ([reader.keyWord isEqualToString:@"ldblquote"]) {
                            [stringBuilder appendString:@"&ldquo;"];
                        } else if ([reader.keyWord isEqualToString:@"rdblquote"]) {
                            [stringBuilder appendString:@"&rdquo;"];
                        } else if ([reader.keyWord isEqualToString:@"bullet"]) {
                            [stringBuilder appendString:@"&bull;"];
                        } else if ([reader.keyWord isEqualToString:@"endash"]) {
                            [stringBuilder appendString:@"&ndash;"];
                        } else if ([reader.keyWord isEqualToString:@"emdash"]) {
                            [stringBuilder appendString:@"&mdash;"];
                        } else if ([reader.keyWord isEqualToString:@"~"]) {
                            [stringBuilder appendString:@"&nbsp;"];
                        } else if ([reader.keyWord isEqualToString:@"_"]) {
                            [stringBuilder appendString:@"&shy;"];
                        }
                    }
                    break;
                case RtfTokenTypeText:
                    if (!htmlState) {
                        [stringBuilder appendString:reader.keyWord];
                    }
                    break;
                default:
                    break;
            }
        }
    }
    self.htmlContent = stringBuilder;
}

- (void)readListTable:(Reader *)reader
{
    self.listTable = [[ListTable alloc] init];
    
    while ([reader readToken]) {
        if (reader.tokenType == RtfTokenTypeGroupEnd) {
            break;
        }
        
        if (reader.tokenType == RtfTokenTypeGroupStart) {
            
            BOOL firstRead = YES;
            RtfObject *currentObj = nil;
            NSInteger level = reader.level;
            
            while ([reader readToken]) {
                if (reader.tokenType == RtfTokenTypeGroupEnd) {
                    if (reader.level < level) {
                        break;
                    }
                } else if (reader.tokenType == RtfTokenTypeGroupStart) {
                }
                
                if (firstRead) {
                    if (![reader.currentToken.key isEqualToString:@"list"]) {
                        [reader readToEndGround];
                        [reader readToken];
                        break;
                    }
                    currentObj = [[RtfObject alloc] init];
                    [self.listTable addObject:currentObj];
                    firstRead = NO;
                }
                
                if ([reader.currentToken.key isEqualToString:@"listtemplateid"]) {
                    currentObj.listTemplateID = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"listid"]) {
                    currentObj.listID = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"listhybrid"]) {
                    currentObj.listHybrid = YES;
                } else if ([reader.currentToken.key isEqualToString:@"levelfollow"]) {
                    currentObj.levelFollow = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"levelstartat"]) {
                    currentObj.levelStartAt = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"levelnfc"]) {
                    if (currentObj.levelNfc == RtfLevelNumberTypeNone) {
                        currentObj.levelNfc = (RtfLevelNumberType)reader.currentToken.param;
                    }
                } else if ([reader.currentToken.key isEqualToString:@"levelnfcn"]) {
                    if (currentObj.levelNfc == RtfLevelNumberTypeNone) {
                        currentObj.levelNfc = (RtfLevelNumberType)reader.currentToken.param;
                    }
                } else if ([reader.currentToken.key isEqualToString:@"leveljc"]) {
                    currentObj.levelJC = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"leveltext"]) {
                    if (!currentObj.levelText) {
                        NSString *text = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                        if (text && text.length > 2) {
                            NSInteger len = [text characterAtIndex:0];
                            len = MIN(len, text.length - 1);
                            text = [text substringWithRange:NSMakeRange(1, len)];
                        }
                        currentObj.levelText = text;
                    }
                } else if ([reader.currentToken.key isEqualToString:@"f"]) {
                    currentObj.fontName = [self.fontTable fontNameAtIndex:reader.currentToken.param];
                }
            }
        }
    }
}

- (NSString *)readInnerTextWithReader:(Reader *)reader token:(Token *)firstToken deeply:(BOOL)deeply breakMeetControlWord:(BOOL)breakMeetControlWord andHTMLMode:(BOOL)htmlMode
{
    NSInteger level = 0;
    TextConatiner *container = [[TextConatiner alloc] init];
    [container acceptWithToken:firstToken andWithReader:reader];
    
    while (YES) {
        
        RtfTokenType type = [reader peekTokenType];
        if (type == RtfTokenTypeEof) {
            break;
        }
        
        if (type == RtfTokenTypeGroupStart) {
            level++;
        } else if (type == RtfTokenTypeGroupEnd) {
            level--;
            if (level < 0) {
                break;
            }
        }
        
        [reader readToken];
        
        if (deeply || level == 0) {
            if (htmlMode && [reader.keyWord isEqualToString:@"par"]) {
                [container append:@"\n"];
                continue;
            }
            
            [container acceptWithToken:reader.currentToken andWithReader:reader];
            
            if (breakMeetControlWord) {
                break;
            }
        }
    }
    return container.text;
}

- (void)readFontTable:(Reader *)reader
{
    self.fontTable = nil;
    self.fontTable = [[FontTable alloc] init];
    while ([reader readToken]) {
        if (reader.tokenType == RtfTokenTypeGroupEnd) {
            break;
        }
        if (reader.tokenType == RtfTokenTypeGroupStart) {
            NSInteger index = -1;
            NSString *name = nil;
            NSStringEncoding charset = 1;
            BOOL nilFlag = YES;
            while ([reader readToken]) {
                if (reader.tokenType == RtfTokenTypeGroupEnd) {
                    break;
                }
                
                if (reader.tokenType == RtfTokenTypeGroupStart) {
                    [reader readToken];
                    [reader readToEndGround];
                    [reader readToken];
                } else if ([reader.keyWord isEqualToString:@"f"] && reader.hasParam) {
                    index = reader.parameter;
                } else if ([reader.keyWord isEqualToString:@"fnil"]) {
                    name = @"Microsoft Sans Serif";
                    nilFlag = YES;
                } else if ([reader.keyWord isEqualToString:@"fcharset"]) {
                    charset = CFStringConvertEncodingToNSStringEncoding(CFStringConvertWindowsCodepageToEncoding((UInt32)reader.parameter));
                } else if (reader.currentToken.isTextToken) {
                    name = [self readInnerTextWithReader:reader token:reader.currentToken deeply:NO breakMeetControlWord:NO andHTMLMode:NO];
                    if (name) {
                        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([name hasSuffix:@";"]) {
                            name = [name substringToIndex:(name.length - 1)];
                        }
                    }
                }
            }
            
            if (index >= 0 && name) {
                if ([name hasSuffix:@";"]) {
                    name = [name substringToIndex:(name.length - 1)];
                }
                name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (!name) {
                    name = @"Microsoft Sans Serif";
                }
                Font *font = [[Font alloc] init];
                font.index = index;
                font.fontName = name;
                font.stringEncoding = charset;
                font.nilFlag = nilFlag;
                
                [self.fontTable addFont:font];
            }
        }
    }
}

- (void)readListOverrideTable:(Reader *)reader
{
    while ([reader readToken]) {
        if (reader.tokenType == RtfTokenTypeGroupEnd) {
            break;
        }
        
        if (reader.tokenType == RtfTokenTypeGroupStart) {
            ListOverride *record = nil;
            
            while ([reader readToken]) {
                if (reader.tokenType == RtfTokenTypeGroupEnd) {
                    break;
                }
                
                if ([reader.currentToken.key isEqualToString:@"listoverride"]) {
                    record = [[ListOverride alloc] init];
                    [self.listOverrideTable addListOverrideObject:record];
                }
                
                if (!record) {
                    continue;
                }
                
                if ([reader.currentToken.key isEqualToString:@"listid"]) {
                    record.listID = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"listoverridecount"]) {
                    record.listOverrideCount = reader.currentToken.param;
                } else if ([reader.currentToken.key isEqualToString:@"ls"]) {
                    record.ID = reader.currentToken.param;
                }
            }
        }
    }
}

- (void)readColorTable:(Reader *)reader
{
    self.colorTable = nil;
    self.colorTable = [[ColorTable alloc] init];
    self.colorTable.checkValueExistWhenAdd = NO;
    NSInteger r = -1;
    NSInteger g = -1;
    NSInteger b = -1;
    
    while ([reader readToken]) {
        if (reader.tokenType == RtfTokenTypeGroupEnd) {
            break;
        }
        
        if ([reader.keyWord isEqualToString:@"red"]) {
            r = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"green"]) {
            g = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"blue"]) {
            b = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@";"]) {
            if (r >= 0 && g >= 0 && b >= 0) {
                UIColor *c = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
                [self.colorTable addColor:c];
                r = -1;
                g = -1;
                b = -1;
            }
        }
    }
    
    if (r >= 0 && g >= 0 && b >= 0) {
        UIColor *c = [UIColor colorWithRed:(r/255) green:(g/255) blue:(b/255) alpha:1.0];
        [self.colorTable addColor:c];
    }
}

- (void)readDocumentInfo:(Reader *)reader
{
    self.info = nil;
    self.info = [[DocumentInfo alloc] init];
    NSInteger level = 0;
    while ([reader readToken]) {
        if (reader.tokenType == RtfTokenTypeGroupStart) {
            level++;
        } else if (reader.tokenType == RtfTokenTypeGroupEnd) {
            level--;
            if (level < 0) {
                break;
            }
        } else {
            if ([reader.keyWord isEqualToString:@"creatim"]) {
                self.info.creationTime = [self readDateTime:reader];
                level--;
            } else if ([reader.keyWord isEqualToString:@"revtim"]) {
                self.info.revesionTime = [self readDateTime:reader];
                level--;
            } else if ([reader.keyWord isEqualToString:@"printim"]) {
                self.info.printTime = [self readDateTime:reader];
                level--;
            } else if ([reader.keyWord isEqualToString:@"buptim"]) {
                self.info.backUpTime = [self readDateTime:reader];
                level--;
            } else {
                if (reader.hasParam) {
                    self.info.infoStringDictionary[reader.keyWord] = [NSString stringWithFormat:@"%ld", (long)reader.parameter];
                } else {
                    self.info.infoStringDictionary[reader.keyWord] = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
                }
            }
        }
    }
}

- (NSDate *)readDateTime:(Reader *)reader
{
    NSInteger yr = 1900;
    NSInteger mo = 1;
    NSInteger dy = 1;
    NSInteger hr = 0;
    NSInteger min = 0;
    NSInteger sec = 0;
    while ([reader readToken])
    {
        if (reader.tokenType == RtfTokenTypeGroupEnd)
        {
            break;
        }
        
        if ([reader.keyWord isEqualToString:@"yr"]){
            yr = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"mo"]) {
            mo = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"dy"]) {
            dy = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"hr"]) {
            hr = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"min"]) {
            min = reader.parameter;
        } else if ([reader.keyWord isEqualToString:@"sec"]) {
            sec = reader.parameter;
        }
    }
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = yr;
    components.month = mo;
    components.day = dy;
    components.hour = hr;
    components.minute = min;
    components.second = sec;
    
    return components.date;
}

- (void)completeParagraph
{
    DomElement *lastElement = [[self getLastElementsbyCheckingLockState:YES] lastObject];
    while (lastElement) {
        if ([lastElement isKindOfClass:[DomParagraph class]]) {
            DomParagraph *p = (DomParagraph *)lastElement;
            p.locked = YES;
            if (self.paragraphFormat) {
                p.format = [self.paragraphFormat copy];
            } else {
                self.paragraphFormat = [[DocumentFormatInfo alloc] init];
            }
            break;
        }
        lastElement = lastElement.parent;
    }
}

- (void)readDomFieldFromReader:(Reader *)reader andFormat:(DocumentFormatInfo *)format
{
    DomField *field = [[DomField alloc] init];
    field.nativeLevel = reader.level;
    NSInteger levelBack = reader.level;
    
    while ([reader readToken]) {
        if (reader.level < levelBack) {
            break;
        }
        
        if (reader.tokenType == RtfTokenTypeGroupStart) {
        } else if (reader.tokenType == RtfTokenTypeGroupEnd) {
        } else {
            if ([reader.keyWord isEqualToString:@"flddirty"]) {
                field.method = RtfDomFieldMethodDirty;
            } else if ([reader.keyWord isEqualToString:@"fldedit"]) {
                field.method = RtfDomFieldMethodEdit;
            } else if ([reader.keyWord isEqualToString:@"fldlock"]) {
                field.method = RtfDomFieldMethodLock;
            } else if ([reader.keyWord isEqualToString:@"fldpriv"]) {
                field.method = RtfDomFieldMethodPriv;
            } else if ([reader.keyWord isEqualToString:@"fldrslt"]) {
                ElementContainer *result = [[ElementContainer alloc] init];
                result.name = @"fldrslt";
                [field appendChild:result];
                [self loadRTFReader:reader andDocumentFormatInfo:format];
                result.locked = YES;
            } else if ([reader.keyWord isEqualToString:@"fldinst"]) {
                ElementContainer *inst = [[ElementContainer alloc] init];
                inst.name = @"fldinst";
                [self loadRTFReader:reader andDocumentFormatInfo:format];
                inst.locked = YES;
                NSString *txt = [inst innerText];
                if (txt) {
                    NSInteger index = [txt rangeOfString:@"HYPERLINK"].location;
                    if (index >= 0) {
                        NSInteger index1 = [[txt substringFromIndex:index] rangeOfString:@"\""].location;
                        if (index1 > 0 && txt.length > index1 + 2) {
                            NSInteger index2 = [[txt substringFromIndex:(index1 + 2)] rangeOfString:@"\""].location;
                            if (index2 > index1) {
                                NSString *link = [txt substringWithRange:NSMakeRange(index1 + 1, index2 - index1 -1)];
                                if (format.parent) {
                                    if ([link hasPrefix:@"_Toc"]) {
                                        link = [NSString stringWithFormat:@"#%@", link];
                                        format.parent.link = link;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    field.locked = YES;
}

- (void)readDomObjectFromReader:(Reader *)reader andFormat:(DocumentFormatInfo *)format
{
    DomObject *domObject = [[DomObject alloc] init];
    domObject.nativeLevel = reader.level;
    [self addContentElement:domObject];
    
    NSInteger levelBack = reader.level;
    
    while ([reader readToken]) {
        if (reader.level < levelBack) {
            break;
        }
        
        if (reader.tokenType == RtfTokenTypeGroupStart || reader.tokenType == RtfTokenTypeGroupEnd) {
            continue;
        }
        
        if ((reader.level == domObject.nativeLevel + 1)
            && [reader.keyWord hasPrefix:@"attribute_"]) {
            domObject.customAttributes[reader.keyWord] = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
        }
        
        if ([reader.keyWord isEqualToString:@"objautlink"]) {
            
            domObject.type = RtfObjectTypeAutLink;
            
        } else if ([reader.keyWord isEqualToString:@"objclass"]) {
            
            domObject.className = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
            
        } else if ([reader.keyWord isEqualToString:@"objdata"]) {
            
            NSString *contentStr = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
            domObject.content = [self hexToBytes:contentStr];
            
        } else if ([reader.keyWord isEqualToString:@"objemb"]) {
            
            domObject.type = RtfObjectTypeEmb;
        
        } else if ([reader.keyWord isEqualToString:@"objh"]) {
            
            domObject.height = reader.parameter;
        
        } else if ([reader.keyWord isEqualToString:@"objhtml"]) {
            
            domObject.type = RtfObjectTypeHtml;
        
        } else if ([reader.keyWord isEqualToString:@"objicemb"]) {
            
            domObject.type = RtfObjectTypeIcemb;
        
        } else if ([reader.keyWord isEqualToString:@"objlink"]) {
            
            domObject.type = RtfObjectTypeLink;
        
        } else if ([reader.keyWord isEqualToString:@"objname"]) {
            
            domObject.name = [self readInnerTextWithReader:reader token:nil deeply:YES breakMeetControlWord:NO andHTMLMode:NO];
        
        } else if ([reader.keyWord isEqualToString:@"objocx"]) {
            
            domObject.type = RtfObjectTypeOcx;
            
        } else if ([reader.keyWord isEqualToString:@"objpub"]) {
            
            domObject.type = RtfObjectTypePub;
            
        } else if ([reader.keyWord isEqualToString:@"objsub"]) {
            
            domObject.type = RtfObjectTypeSub;
            
        } else if ([reader.keyWord isEqualToString:@"objtime"]) {
            
        } else if ([reader.keyWord isEqualToString:@"objw"]) {
            
            domObject.width = reader.parameter;
            
        } else if ([reader.keyWord isEqualToString:@"objscalex"]) {
            
            domObject.scaleX = reader.parameter;
            
        } else if ([reader.keyWord isEqualToString:@"objscaley"]) {
            
            domObject.scaleY = reader.parameter;
            
        } else if ([reader.keyWord isEqualToString:@"result"]) {
            
            ElementContainer *result = [[ElementContainer alloc] init];
            result.name = @"result";
            [domObject appendChild:result];
            [self loadRTFReader:reader andDocumentFormatInfo:format];
            result.locked = YES;
        }
    }
    domObject.locked = YES;
}

- (NSString *)htmlContentFromRTF
{
    NSMutableString *htmlString = [NSMutableString string];
    [htmlString appendString:@"<html><body><div>"];
    NSString *ulStr = @"<ul></ul>";
    
    for (DomElement *element in self.elementList) {
        if ([element isKindOfClass:[DomParagraph class]]) {
            
            //If we have listID that means we have a list of objects...
            if (((DomParagraph *)element).format.listID != -1) {
                //Create unordered list...
                if ([htmlString rangeOfString:ulStr options:NSBackwardsSearch range:NSMakeRange(htmlString.length - ulStr.length, ulStr.length)].location == NSNotFound) {
                    [htmlString appendString:ulStr];
                    [htmlString insertString:[NSString stringWithFormat:@"<li>%@</li>", ((DomParagraph *)element).innerText] atIndex:(htmlString.length - 5)];
                } else {
                    //Add list objects...
                    NSRange range = [htmlString rangeOfString:@"</li>" options:NSBackwardsSearch range:NSMakeRange(0, htmlString.length)];
                    NSInteger insertIndex = range.location + range.length;
                    [htmlString insertString:[NSString stringWithFormat:@"<li>%@</li>", ((DomParagraph *)element).innerText] atIndex:(insertIndex)];
                }
            } else {
                //Create paragraph along with style info...
                if (((DomParagraph *)element).innerText) {
                    [htmlString appendFormat:@"<p style=\"color:%@\">", [self htmlHexColorFromUIColor:((DomParagraph *)element.elementList.firstObject).format.textColor]];
                    [htmlString appendFormat:@"%@</p>", ((DomParagraph *)element).innerText];
                } else {
                    //Insert the break to avaoid loading <nil>
                    [htmlString appendFormat:@"<br>"];
                }
            }
        }
    }
    [htmlString appendString:@"</div></body></html>"];
    return htmlString;
}

- (NSString *)htmlHexColorFromUIColor:(UIColor *)color
{
    NSString *htmlHexColorString = nil;
    if (!color) {
        htmlHexColorString = @"#000000";
    } else if ([color isEqual:[UIColor whiteColor]]) {
        htmlHexColorString = @"#ffffff";
    } else {
        
        CGFloat red = 0.0f;
        CGFloat green = 0.0f;
        CGFloat blue = 0.0f;
        
        [color getRed:&red green:&green blue:&blue alpha:nil];
        
        red *= 255.0f;
        green *= 255.0f;
        blue *= 255.0f;
        
        htmlHexColorString = [NSString stringWithFormat:@"#%02x%02x%02x", (unsigned int)red, (unsigned int)green, (unsigned int)blue];
    }
    return htmlHexColorString;
}

@end
