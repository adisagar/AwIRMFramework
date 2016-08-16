/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ColorTable.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorTable : NSObject

@property (nonatomic, assign) BOOL checkValueExistWhenAdd;
@property (nonatomic, assign) NSInteger count;

- (UIColor *)colorAtIndex:(NSInteger)index;
- (UIColor *)colorAtIndex:(NSInteger)index andDefaultColor:(UIColor *)defaultColor;
- (void)addColor:(UIColor *)color;
- (void)clearAll;

@end
