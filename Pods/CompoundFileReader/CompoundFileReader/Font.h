/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Font.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/12/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Font : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL nilFlag;
@property (nonatomic, assign) NSInteger charset;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, assign) NSString *fontName;

- (id)initWithIndex:(NSInteger)index andFontName:(NSString *)fontName;
- (NSInteger)charsetForEncoding:(NSStringEncoding)stringEncoding;

@end
