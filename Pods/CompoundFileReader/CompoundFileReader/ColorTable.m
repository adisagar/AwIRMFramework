/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ColorTable.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ColorTable.h"

@interface ColorTable ()

@property (nonatomic, strong) NSMutableArray *colorTableArray;

@end

@implementation ColorTable

- (void)dealloc
{
    _colorTableArray = nil;
}

- (id)init
{
    if (self = [super init]) {
        _colorTableArray = [NSMutableArray array];
    }
    return self;
}

- (UIColor *)colorAtIndex:(NSInteger)index
{
    if (self.colorTableArray.count > index && self.colorTableArray[index]) {
        return self.colorTableArray[index];
    }
    return nil;
}

- (UIColor *)colorAtIndex:(NSInteger)index andDefaultColor:(UIColor *)defaultColor
{
    index--;
    if (index >= 0 && self.colorTableArray.count > index && self.colorTableArray[index]) {
        return self.colorTableArray[index];
    }
    return defaultColor;
}

- (void)addColor:(UIColor *)color
{
    CGFloat alpha = 1.0f;
    [color getWhite:nil alpha:&alpha];
    if (fabs(alpha) == abs(0)) {
        return;
    } else {
        if (self.checkValueExistWhenAdd) {
            if (![self.colorTableArray indexOfObject:color]) {
                [self.colorTableArray addObject:color];
            }
        } else {
            [self.colorTableArray addObject:color];
        }
    }
}

- (void)clearAll
{
    [self.colorTableArray removeAllObjects];
}

@end
