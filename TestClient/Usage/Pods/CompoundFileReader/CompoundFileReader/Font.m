/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Font.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/12/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Font.h"

@interface Font ()

@property (nonatomic, strong) NSMutableDictionary *encodingCharset;

@end

@implementation Font

- (void)dealloc
{
    _encodingCharset = nil;
    _fontName = nil;
}

- (id)initWithIndex:(NSInteger)index andFontName:(NSString *)fontName
{
    if (self = [super init]) {
        _nilFlag = NO;
        _stringEncoding = -1;
        _index = index;
        _fontName = fontName;
    }
    return self;
}

- (void)setCharset:(NSInteger)chrset
{
    _charset = chrset;
    _stringEncoding = [self rtfEncoding:_charset];
}

- (NSStringEncoding)rtfEncoding:(NSInteger)chrset
{
    if (chrset == 0) {
        return NSASCIIStringEncoding;
    }
    
    if (chrset == 1) {
        return NSUTF8StringEncoding;
    }
    
    if ([[self.encodingCharset allKeys] containsObject:@(chrset)]) {
        return [self.encodingCharset[@(chrset)] integerValue];
    }
    return -1;
}

- (NSMutableDictionary *)encodingCharset
{
    if (!_encodingCharset) {
        _encodingCharset = [NSMutableDictionary dictionary];
        _encodingCharset[@(77)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingMacRomanLatin1));
        _encodingCharset[@(128)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSJapanese));
        _encodingCharset[@(130)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSKorean));
        _encodingCharset[@(134)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif));
        _encodingCharset[@(136)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseTrad));
        _encodingCharset[@(161)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsGreek));
        _encodingCharset[@(162)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsLatin5));
        _encodingCharset[@(163)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsVietnamese));
        _encodingCharset[@(177)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsHebrew));
        _encodingCharset[@(178)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic));
        _encodingCharset[@(179)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic));
        _encodingCharset[@(180)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic));
        _encodingCharset[@(181)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic));
        _encodingCharset[@(204)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSCyrillic));
        _encodingCharset[@(222)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSThai));
        _encodingCharset[@(255)] = @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSLatinUS));
    }
    return _encodingCharset;
}

- (NSInteger)charsetForEncoding:(NSStringEncoding)stringEncoding
{
    for (NSNumber *key in self.encodingCharset.allKeys) {
        if ([self.encodingCharset[key] isEqualToNumber:@(stringEncoding)]) {
            return [key integerValue];
        }
    }
    return 1;
}

@end
