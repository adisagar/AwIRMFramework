/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Reader.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextReader.h"
#import "Token.h"
#import "LayerInfo.h"

@interface Reader : NSObject

@property (nonatomic, strong) TextReader *innerReader;
@property (nonatomic, strong) Token *currentToken;
@property (nonatomic, assign) RtfTokenType tokenType;
@property (nonatomic, copy) NSString *keyWord;
@property (nonatomic, assign) BOOL hasParam;
@property (nonatomic, assign) NSInteger parameter;
@property (nonatomic, assign) NSInteger contentPosition;
@property (nonatomic, assign) NSInteger contentLength;
@property (nonatomic, assign) BOOL firstTokenInGroup;
@property (nonatomic, strong) Token *lastToken;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger tokenCount;
@property (nonatomic, assign) BOOL enableDefaultProcess;
@property (nonatomic, strong) LayerInfo *currentLayerInfo;

- (id)initWithText:(NSString *)text;
- (Token *)readToken;
- (void)readToEndGround;
- (RtfTokenType)peekTokenType;

@end
