/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomObject.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomElement.h"
#import "RTFEnums.h"

@interface DomObject : DomElement

@property (nonatomic, strong) NSMutableDictionary *customAttributes;
@property (nonatomic, assign) RtfObjectType type;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSData *content;
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger scaleX;
@property (nonatomic, assign) NSInteger scaleY;

@end
