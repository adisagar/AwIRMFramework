/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  TextReader.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "TextReader.h"

@interface TextReader ()

@property (nonatomic, copy) NSString *string;
@property (nonatomic, assign) NSInteger peekIndex;
@property (nonatomic, assign) NSInteger readIndex;

@end

@implementation TextReader

- (void)dealloc
{
    _string = nil;
}

- (id)initWithString:(NSString *)string
{
    if (self = [super init]) {
        _string = string;
        _peekIndex = 0;
        _readIndex = 0;
    }
    return self;
}

- (unichar)peek
{
    unichar c = -1;
    if (self.peekIndex <= self.string.length) {
       c = [self.string characterAtIndex:self.peekIndex];
    }
    return c;
}

- (unichar)read
{
    unichar c = -1;
    if (self.peekIndex <= (self.string.length - 1)) {
        c = [self.string characterAtIndex:self.readIndex];
    }
    self.readIndex++;
    self.peekIndex = self.readIndex;
    return c;
}

@end
