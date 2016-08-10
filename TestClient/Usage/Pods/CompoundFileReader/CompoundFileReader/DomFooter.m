/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomFooter.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomFooter.h"
#import "DomParagraph.h"

@implementation DomFooter

- (id)init
{
    if (self = [super init]) {
        _style = RtfHeaderFooterStyleAllPages;
    }
    return self;
}

- (BOOL)hasContentElement
{
    return [self hasContentElementInRootElement:self];
}

- (BOOL)hasContentElementInRootElement:(DomElement *)rootElement
{
    if (rootElement.elementList.count == 0) {
        return NO;
    }
    
    if (rootElement.elementList.count == 1) {
        if ([rootElement.elementList[0] isKindOfClass:[DomParagraph class]]) {
            DomParagraph *domPara = (DomParagraph *)rootElement.elementList[0];
            if (domPara.elementList.count == 0) {
                return NO;
            }
        }
    }
    return YES;
}

@end
