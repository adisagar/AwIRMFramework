/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Lex.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Lex.h"

@interface Lex ()

@property (nonatomic, assign) NSInteger eof;
@property (nonatomic, strong) TextReader *textReader;

@end

@implementation Lex

- (void)dealloc
{
    _textReader = nil;
    _nextToken = nil;
}

- (id)initWithTextReader:(TextReader *)textReader
{
    if (self = [super init]) {
        _textReader = textReader;
        _eof = -1;
    }
    return self;
}

- (RtfTokenType)peekTokenType
{
    char c = [self.textReader peek];
    while (c == '\r' || c == '\n' || c == '\t' || c == '\0') {
        [self.textReader read];
        c = [self.textReader peek];
    }
    
    if (c == self.eof) {
        _peekTokenType = RtfTokenTypeEof;
    }
    
    switch (c) {
        case '{':
            _peekTokenType = RtfTokenTypeGroupStart;
            break;
        case '}':
            _peekTokenType = RtfTokenTypeGroupEnd;
            break;
        case '\\':
            _peekTokenType = RtfTokenTypeControl;
        default:
            _peekTokenType = RtfTokenTypeText;
    }
    return _peekTokenType;
}

- (Token *)nextToken
{
    Token *token = [[Token alloc] init];
    char c = [self.textReader read];
    if (c == '\"' && [self.textReader peek] != '\\') {
        NSMutableString *mutableString = [NSMutableString string];
        while (YES) {
            c = [self.textReader read];
            if (c < 0) {
                break;
            }
            if (c == '\"') {
                break;
            }
            [mutableString appendFormat:@"%c",c];
        }
        token.type = RtfTokenTypeText;
        token.key = mutableString;
        _nextToken = token;
        return _nextToken;
    }
    
    while (c == '\r' || c == '\n' || c == '\t' || c == '\0') {
        c = [self.textReader read];
    }
    
    if (c != self.eof) {
        switch (c) {
            case '{':
                token.type = RtfTokenTypeGroupStart;
                break;
            case '}':
                token.type = RtfTokenTypeGroupEnd;
                break;
            case '\\':
                token = [self parseKeyWord:token];
                break;
            default:
                token.type = RtfTokenTypeText;
                token = [self parseTextWithCharacter:c andToken:token];
                break;
        }
    } else {
        token.type = RtfTokenTypeEof;
    }
    _nextToken = token;
    return _nextToken;
}

- (Token *)parseKeyWord:(Token *)token
{
    Token *tempToken = token;
    BOOL ext = false;
    char c = [self.textReader peek];
    if (!isalpha((char)c)) {
        [self.textReader read];
        if (c == '*') {
            tempToken.type = RtfTokenTypeKeyword;
            [self.textReader read];
            ext = YES;
        } else {
            if (c == '\\' || c == '{' || c == '}') {
                tempToken.type = RtfTokenTypeText;
                tempToken.key = [NSString stringWithFormat:@"%c", c];
            } else {
                tempToken.type = RtfTokenTypeControl;
                tempToken.key = [NSString stringWithFormat:@"%c", c];
                if ([tempToken.key isEqualToString:@"\'"]) {
                    NSMutableString *mutableString = [NSMutableString string];
                    unichar c1 = [self.textReader read];
                    [mutableString appendFormat:@"%hu", c1];
                    c1 = [self.textReader read];
                    [mutableString appendFormat:@"%hu", c1];
                    tempToken.hasParam = YES;
                    tempToken.hex = [mutableString lowercaseString];
                    tempToken.param = [mutableString integerValue];
                }
            }
            return tempToken;
        }
    }
    
    NSMutableString *keyWord = [NSMutableString string];
    c = [self.textReader peek];
    
    while (isalpha((unichar)c)) {
        [self.textReader read];
        [keyWord appendFormat:@"%c", c];
        c = [self.textReader peek];
    }
    
    tempToken.type = ext ? RtfTokenTypeExtKeyword : RtfTokenTypeKeyword;
    tempToken.key = keyWord;
    keyWord = nil;
    
    if (isdigit((char)c) || c == '-') {
        tempToken.hasParam = YES;
        BOOL negative = NO;
        if (c == '-') {
            negative = YES;
            [self.textReader read];
        }
        
        c = [self.textReader peek];
        
        NSMutableString *text = [NSMutableString string];
        while (isdigit((char)c)) {
            [self.textReader read];
            [text appendFormat:@"%c", c];
            c = [self.textReader peek];
        }
        
        NSInteger param = [text integerValue];
        if (negative) {
            param = -param;
        }
        tempToken.param = param;
    }
    
    if (c == ' ') {
        [self.textReader read];
    }
    return tempToken;
}

- (Token *)parseTextWithCharacter:(NSInteger)c andToken:(Token *)token
{
    Token *tempToken = token;
    NSMutableString *mutableString = [NSMutableString stringWithFormat:@"%c", (char)c];
    c = [self clearWhiteSpace];
    while (c != '\\' && c != '}' && c != '{' && c != self.eof) {
        [self.textReader read];
        [mutableString appendFormat:@"%c", (char)c];
        c = [self clearWhiteSpace];
    }
    tempToken.key = mutableString;
    return tempToken;
}

- (NSInteger)clearWhiteSpace
{
    unichar c = [self.textReader peek];
    while (c == '\r' && c == '\n' && c == '\t' && c == '\0') {
        [self.textReader read];
        c = [self.textReader peek];
    }
    return c;
}

@end
