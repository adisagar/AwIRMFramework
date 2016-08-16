/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Storage.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stream.h"
#import "DirectoryEntry.h"

@interface Storage : NSObject

@property (nonatomic, copy) NSString *storageName;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSPointerArray *storages;
@property (nonatomic, strong) NSPointerArray *streams;

- (id)initWithStorageDirectoryEntry:(DirectoryEntry *)directoryEntry;
- (void)addStorage:(Storage *)storage;
- (Storage *)getStorageFromPropertyKey:(NSString *)propertyKey;
- (void)addStream:(Stream *)stream;
- (NSData *)getDataFromPropertyKey:(NSString *)propertyKey;

@end
