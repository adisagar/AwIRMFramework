/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  FontTable.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "FontTable.h"

@interface FontTable ()

@property (nonatomic, strong) NSMutableArray *fontArray;

@end

@implementation FontTable

- (void)dealloc
{
    _fontArray = nil;
}

- (id)init
{
    if (self = [super init]) {
        _fontArray = [NSMutableArray array];
    }
    return self;
}

- (Font *)fontAtIndex:(NSInteger)fontIndex
{
    for (Font *font in self.fontArray) {
        if (font.index == fontIndex) {
            return font;
        }
    }
    return nil;
}

- (Font *)fontByName:(NSString *)fontName
{
    for (Font *font in self.fontArray) {
        if (font.fontName == fontName) {
            return font;
        }
    }
    return nil;
}

- (NSString *)fontNameAtIndex:(NSInteger)fontIndex
{
    Font *font = [self fontAtIndex:fontIndex];
    return font != nil ? font.fontName : nil;
}

- (void)addFontWithName:(NSString *)fontName
{
    [self addFontAtIndex:self.fontArray.count andName:fontName andEncoding:NSUTF8StringEncoding];
}

- (void)addFont:(Font *)font
{
    [self.fontArray addObject:font];
}

- (void)addFontAtIndex:(NSInteger)index andName:(NSString *)fontName andEncoding:(NSStringEncoding)stringEncoding
{
    if ([self fontByName:fontName] == nil) {
        Font *font = [[Font alloc] initWithIndex:index andFontName:fontName];
        if (stringEncoding != -1) {
            font.charset = [font charsetForEncoding:stringEncoding];
        }
        [self.fontArray addObject:font];
    }
}

- (NSInteger)indexOfFontName:(NSString *)fontName
{
    for (Font *font in self.fontArray) {
        if (font.fontName == fontName) {
            return font.index;
        }
    }
    return -1;
}

@end
