/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DocumentInfo.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/8/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *manager;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *mOperator;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *keyWords;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *docComm;
@property (nonatomic, copy) NSString *hLinkBase;
@property (nonatomic, assign) NSInteger editMinutes;
@property (nonatomic, copy) NSString *vern;
@property (nonatomic, copy) NSString *numberOfPages;
@property (nonatomic, copy) NSString *numberOfWords;
@property (nonatomic, copy) NSString *numberOfCharactersWithWhiteSpaces;
@property (nonatomic, copy) NSString *numberOfCharactersWithoutWhiteSpaces;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, strong) NSDate *backUpTime;
@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, strong) NSDate *printTime;
@property (nonatomic, strong) NSDate *revesionTime;
@property (nonatomic, strong) NSMutableDictionary *infoStringDictionary;

- (NSArray *)arrayFromDictionary;

@end
