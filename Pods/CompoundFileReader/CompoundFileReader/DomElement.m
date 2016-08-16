/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomElement.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomElement.h"
#import "Attribute.h"

@interface DomElement ()

@end

@implementation DomElement

- (void)dealloc
{
    _ownerDocument = nil;
    _attributeList = nil;
    _elementList = nil;
    _parent = nil;
    _innerText = nil;
}

- (id)init
{
    if (self = [super init]) {
        _elementList = [NSMutableArray array];
        _attributeList = [[AttributeList alloc] init];
    }
    return self;
}

- (BOOL)hasAttribute:(NSString *)name
{
   return [self.attributeList containsAttributeByName:name];
}

- (NSInteger)attributeValueFromName:(NSString *)name andDefaultValue:(NSInteger)defaultValue
{
    return [self.attributeList containsAttributeByName:name] ? [self.attributeList attributeValueByName:name] : defaultValue;
}

- (void)setOwnerDocument:(DomElement *)ownerDoc
{
    _ownerDocument = ownerDoc;
    for (DomElement *element in self.elementList) {
        element.ownerDocument = ownerDoc;
    }
}

- (void)appendChild:(DomElement *)domElement
{
    if (!self.locked) {
        domElement.parent = self;
        domElement.ownerDocument = _ownerDocument;
        [self.elementList addObject:domElement];
    }
}

- (void)setAttributeWithName:(NSString *)name andValue:(NSInteger)value
{
    if (!self.locked) {
        [self.attributeList addAttributeWithName:name andValue:value];
    }
}

- (NSString *)innerText
{
    if (!_innerText) {
        if (self.elementList.count > 0) {
            _innerText = [NSString string];
            for (DomElement *element in self.elementList) {
                if (element.innerText) {
                    _innerText = [_innerText stringByAppendingString:element.innerText];
                }
            }
        }
    }
    return _innerText;
}

@end
