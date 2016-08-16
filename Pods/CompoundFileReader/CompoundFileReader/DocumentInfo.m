/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DocumentInfo.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DocumentInfo.h"

@interface DocumentInfo ()

@end

@implementation DocumentInfo

- (void)dealloc
{
    _infoStringDictionary = nil;
    _title = nil;
    _subject = nil;
    _author = nil;
    _manager = nil;
    _company = nil;
    _mOperator = nil;
    _category = nil;
    _keyWords = nil;
    _comment = nil;
    _docComm = nil;
    _hLinkBase = nil;
    _vern = nil;
    _numberOfPages = nil;
    _numberOfWords = nil;
    _numberOfCharactersWithWhiteSpaces = nil;
    _numberOfCharactersWithoutWhiteSpaces = nil;
    _ID = nil;
    _backUpTime = nil;
    _creationTime = nil;
    _printTime = nil;
    _revesionTime = nil;
}

- (id)init
{
    if (self = [super init]) {
        _infoStringDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)arrayFromDictionary
{
    __block NSMutableArray *array = [NSMutableArray array];
    [self.infoStringDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [array addObject:[key stringByAppendingFormat:@"=%@", obj]];
    }];
    [array addObject:[NSString stringWithFormat:@"Creatim=%@", self.creationTime]];
    [array addObject:[NSString stringWithFormat:@"Revtim=%@", self.creationTime]];
    [array addObject:[NSString stringWithFormat:@"Printim=%@", self.creationTime]];
    [array addObject:[NSString stringWithFormat:@"Buptim=%@", self.creationTime]];
    return array;
}

@end
