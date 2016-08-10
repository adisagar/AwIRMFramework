/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  TextConatiner.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "TextConatiner.h"

@interface TextConatiner ()

@property (nonatomic, strong) NSData *byteBuffer;
@property (nonatomic, copy) NSMutableString *stringBuilder;

@end

@implementation TextConatiner

- (void)dealloc
{
    _domDoc = nil;
    _text = nil;
    _byteBuffer = nil;
    _stringBuilder = nil;
}

- (id)initWithDomDocument:(DomDocument *)domDoc
{
    if (self = [super init]) {
        _level = 0;
        _domDoc = domDoc;
        _stringBuilder = [NSMutableString string];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        _level = 0;
        _stringBuilder = [NSMutableString string];
    }
    return self;
}

- (BOOL)acceptWithToken:(Token *)token andWithReader:(Reader *)reader
{
    if (!token) {
        return NO;
    }
    
    if (token.type == RtfTokenTypeText) {
        if (reader) {
            if ([token.key characterAtIndex:0] == '?') {
                if (reader.lastToken.type == RtfTokenTypeKeyword
                    && [reader.lastToken.key isEqualToString:@"u"]
                    && reader.lastToken.hasParam) {
                    if (token.key.length > 0) {
                        [self checkBuffer];
                        return YES;
                    }
                }
            }
        }
        
        [self checkBuffer];
        [self.stringBuilder appendString:token.key];
        return YES;
    }
    
    if ([token.key isEqualToString:@"u"] && token.hasParam) {
        [self checkBuffer];
        [self.stringBuilder appendFormat:@"%ld", (long)token.param];
        reader.currentLayerInfo.ucValueCount = reader.currentLayerInfo.ucValue;
        return YES;
    }
    
    if ([token.key isEqualToString:@"tab"]) {
        [self checkBuffer];
        [self.stringBuilder appendFormat:@"\t"];
        return true;
    }
    
    if ([token.key isEqualToString:@"emdash"]) {
        [self checkBuffer];
        [self.stringBuilder appendFormat:@"-"];
        return YES;
    }
    
    if ([token.key isEqualToString:@""]) {
        [self checkBuffer];
        [self.stringBuilder appendFormat:@"-"];
        return YES;
    }
    
    return NO;
}

- (void)checkBuffer
{
    if (_byteBuffer.length > 0) {
        NSString *text = [[NSString alloc] initWithData:self.byteBuffer encoding:self.domDoc.runtimeEncoding];
        [self.stringBuilder appendString:text];
        _byteBuffer = nil;
    }
}

- (void)clear
{
    _byteBuffer = nil;
    _stringBuilder = nil;
    _stringBuilder = [NSMutableString string];
}

- (void)append:(NSString *)text
{
    if (text) {
        [self checkBuffer];
        [self.stringBuilder appendString:text];
    }
}

- (NSString *)text
{
    [self checkBuffer];
    return self.stringBuilder;
}

- (BOOL)hasContent
{
    [self checkBuffer];
    return (self.stringBuilder.length > 0);
}

@end
