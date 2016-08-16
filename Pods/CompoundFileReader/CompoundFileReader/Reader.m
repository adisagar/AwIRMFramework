/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Reader.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Reader.h"
#import "Lex.h"

@interface Reader ()

@property (nonatomic, strong) NSMutableArray *layerInfoStack;
@property (nonatomic, strong) NSData *inputData;
@property (nonatomic, strong) Lex *lex;

@end

@implementation Reader

- (void)dealloc
{
    _innerReader = nil;
    _currentToken = nil;
    _keyWord = nil;
    _lastToken = nil;
    _currentLayerInfo = nil;
    _layerInfoStack = nil;
    _inputData = nil;
    _lex = nil;
}

- (id)initWithText:(NSString *)text
{
    if (self = [super init]) {
        _enableDefaultProcess = YES;
        [self loadReader:text];
    }
    return self;
}

- (RtfTokenType)tokenType
{
    return self.currentToken == nil ? RtfTokenTypeNone : self.currentToken.type;
}

- (NSString *)keyWord
{
    return self.currentToken == nil ? nil : self.currentToken.key;
}

- (BOOL)hasParam
{
    return (self.currentToken != nil && self.currentToken.hasParam);
}

- (NSInteger)parameter
{
    return self.currentToken == nil ? 0 : self.currentToken.param;
}

- (NSInteger)contentPosition
{
    if (!_inputData) {
        return 0;
    }
    return _contentPosition;
}

- (NSInteger)contentLength
{
    if (!_inputData) {
        return 0;
    }
    return _inputData.length;
}

- (LayerInfo *)currentLayerInfo
{
    if (self.layerInfoStack.count == 0) {
        [self.layerInfoStack addObject:[[LayerInfo alloc] init]];
    }
    return [self.layerInfoStack objectAtIndex:self.layerInfoStack.count];
}

- (void)loadReader:(NSString *)text
{
    self.currentToken = nil;
    self.innerReader = [[TextReader alloc] initWithString:text];
    self.lex = [[Lex alloc] initWithTextReader:self.innerReader];
}

- (Token *)readToken
{
    _firstTokenInGroup = NO;
    self.lastToken = self.currentToken;
    
    if (self.lastToken != nil && self.lastToken.type == RtfTokenTypeGroupStart) {
        _firstTokenInGroup = YES;
    }
    
    self.currentToken = [self.lex nextToken];
    
    if (!self.currentToken || self.currentToken.type == RtfTokenTypeEof) {
        self.currentToken = nil;
        return nil;
    }
    
    self.tokenCount++;
    
    if (self.currentToken.type == RtfTokenTypeGroupStart) {
        if (self.layerInfoStack.count == 0) {
            [self.layerInfoStack addObject:[[LayerInfo alloc] init]];
        } else {
            LayerInfo *layerInfo = [self.layerInfoStack objectAtIndex:self.layerInfoStack.count];
            [self.layerInfoStack addObject:layerInfo];
        }
        self.level++;
    } else if (self.currentToken.type == RtfTokenTypeGroupEnd) {
        if (self.layerInfoStack.count > 0) {
            [self.layerInfoStack removeObjectAtIndex:self.layerInfoStack.count];
        }
        self.level--;
    }
    
    if (self.enableDefaultProcess) {
        [self defaultProcess];
    }
    return self.currentToken;
}

- (void)defaultProcess
{
    if (!self.currentToken) {
        return;
    }
    
    if ([self.currentToken.key isEqualToString: @"uc"]) {
        self.currentLayerInfo.ucValue = self.parameter;
    }
}

- (void)readToEndGround
{
    NSInteger level = 0;
    while (YES) {
        char c = [self.innerReader peek];
        if (c == -1) {
            break;
        }
        if (c == '{')
        {
            level++;
        }
        else if (c == '}')
        {
            level--;
            if (level < 0)
            {
                break;
            }
        }
        [self.innerReader read];
    }
}

- (RtfTokenType)peekTokenType
{
    return [self.lex peekTokenType];
}

@end
