/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//The following is implemented using http://msdn.microsoft.com/en-us/library/cc425505(v=exchg.80).aspx
//
//  DomElement.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttributeList.h"

@interface DomElement : NSObject

@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) NSInteger nativeLevel;
@property (nonatomic, strong) DomElement *ownerDocument;
@property (nonatomic, strong) AttributeList *attributeList;
@property (nonatomic, strong) NSMutableArray *elementList;
@property (nonatomic, strong) DomElement *parent;
@property (nonatomic, copy) NSString *innerText;

- (void)appendChild:(DomElement *)domElement;
- (void)setAttributeWithName:(NSString *)name andValue:(NSInteger)value;
- (BOOL)hasAttribute:(NSString *)name;
- (NSInteger)attributeValueFromName:(NSString *)name andDefaultValue:(NSInteger)defaultValue;

@end
