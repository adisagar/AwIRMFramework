/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  FontTable.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/7/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Font.h"

@interface FontTable : NSObject

- (Font *)fontAtIndex:(NSInteger)fontIndex;
- (Font *)fontByName:(NSString *)fontName;
- (NSString *)fontNameAtIndex:(NSInteger)fontIndex;
- (void)addFontWithName:(NSString *)fontName;
- (void)addFontAtIndex:(NSInteger)index andName:(NSString *)fontName andEncoding:(NSStringEncoding)stringEncoding;
- (void)addFont:(Font *)font;
- (NSInteger)indexOfFontName:(NSString *)fontName;

@end
