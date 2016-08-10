/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomShape.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomElement.h"

@interface DomShape : DomElement

@property (nonatomic, assign) NSInteger left;
@property (nonatomic, assign) NSInteger top;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger zIndex;
@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSMutableDictionary *extAttbs;

@end
