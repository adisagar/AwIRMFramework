/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AttributeList.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Attribute.h"

@interface AttributeList : NSObject

@property (nonatomic, assign) NSInteger count;

- (Attribute *)itemAtIndex:(NSInteger)index;
- (NSInteger)attributeValueByName:(NSString *)name;
- (void)addAttributeWithName:(NSString *)name andValue:(NSInteger)value;
- (void)setAttributeValue:(NSInteger)value withAttributeName:(NSString *)name;
- (void)removeAttributeByName:(NSString *)name;
- (BOOL)containsAttributeByName:(NSString *)name;
- (void)removeAllObjects;

@end
