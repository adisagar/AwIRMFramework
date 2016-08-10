/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AttributeList.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "AttributeList.h"

@interface AttributeList ()

@property (nonatomic, strong) NSMutableArray *attributeList;

@end

@implementation AttributeList

- (void)dealloc
{
    _attributeList = nil;
}

- (id)init
{
    if (self = [super init]) {
        _attributeList = [NSMutableArray array];
    }
    return self;
}

- (Attribute *)itemAtIndex:(NSInteger)index
{
    return self.attributeList[index];
}

- (NSInteger)attributeValueByName:(NSString *)name
{
    for (Attribute *attribute in self.attributeList) {
        if (attribute.name == name) {
            return attribute.value;
        }
    }
    return NSIntegerMin;
}

- (void)setAttributeValue:(NSInteger)value withAttributeName:(NSString *)name
{
    for (Attribute *attribute in self.attributeList) {
        if (attribute.name == name) {
            attribute.value = value;
            return;
        }
    }
    Attribute *attr = [[Attribute alloc] init];
    attr.name = name;
    attr.value = value;
    [self.attributeList addObject:attr];
}

- (void)addAttributeWithName:(NSString *)name andValue:(NSInteger)value
{
    Attribute *attr = [[Attribute alloc] init];
    attr.name = name;
    attr.value = value;
    [self.attributeList addObject:attr];
}

- (void)removeAttributeByName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *filtArray = [self.attributeList filteredArrayUsingPredicate:predicate];
    if (filtArray.count > 0) {
        [self.attributeList removeObjectsInArray:filtArray];
    }
}

- (BOOL)containsAttributeByName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *filtArray = [self.attributeList filteredArrayUsingPredicate:predicate];
    if (filtArray.copy > 0) {
        return YES;
    }
    return NO;
}

- (void)removeAllObjects
{
    [self.attributeList removeAllObjects];
}

@end
