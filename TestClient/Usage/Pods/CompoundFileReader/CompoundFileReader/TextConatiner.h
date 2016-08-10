/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  TextConatiner.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DomDocument.h"
#import "Token.h"
#import "Reader.h"

@interface TextConatiner : NSObject

@property (nonatomic, strong) DomDocument *domDoc;
@property (nonatomic, assign) BOOL hasContent;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger level;

- (id)initWithDomDocument:(DomDocument *)domDoc;
- (BOOL)acceptWithToken:(Token *)token andWithReader:(Reader *)reader;
- (void)clear;
- (void)append:(NSString *)text;

@end
