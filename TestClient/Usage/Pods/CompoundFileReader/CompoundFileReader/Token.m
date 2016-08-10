/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Token.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Token.h"

@interface Token ()

@end

@implementation Token

- (void)dealloc
{
    _key = nil;
    _hex = nil;
    _parent = nil;
}

- (id)init
{
    if (self = [super init]) {
        _type = RtfTokenTypeNone;
        _parent = nil;
        _param = 0;
    }
    return self;
}

- (BOOL)isTextToken
{
    if (self.type == RtfTokenTypeText) {
        return YES;
    }
    return (self.type == RtfTokenTypeControl && [self.key isEqualToString:@"'"] && self.hasParam);
}

@end
