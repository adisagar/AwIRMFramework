/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  RtfObject.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTFEnums.h"

@interface RtfObject : NSObject

@property (nonatomic, assign) NSInteger listID;
@property (nonatomic, assign) NSInteger listTemplateID;
@property (nonatomic, assign) BOOL listSimple;
@property (nonatomic, assign) BOOL listHybrid;
@property (nonatomic, copy) NSString *listName;
@property (nonatomic, copy) NSString *listStyleName;
@property (nonatomic, assign) NSInteger levelStartAt;
@property (nonatomic, assign) RtfLevelNumberType levelNfc;
@property (nonatomic, assign) NSInteger levelJC;
@property (nonatomic, assign) NSInteger levelFollow;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, copy) NSString *levelText;

@end
