/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Storage.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "Storage.h"

@implementation Storage

- (void)dealloc
{
    _storages = nil;
    _streams = nil;
}

- (id)initWithStorageDirectoryEntry:(DirectoryEntry *)directoryEntry
{
    if (self = [super init]) {
        _storages = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality];
        _streams = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality];
    }
    return self;
}

- (void)addStorage:(Storage *)storage
{
    [self.storages addPointer:(__bridge void *)(storage)];
    self.count++;
}

- (void)addStream:(Stream *)stream
{
    [self.streams addPointer:(__bridge void *)(stream)];
    self.count++;
}

- (Storage *)getStorageFromPropertyKey:(NSString *)propertyKey
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"storageName == %@", propertyKey];
    NSArray *a = [[self.storages allObjects] filteredArrayUsingPredicate:predicate];
    if (a.count > 0) {
        return a[0];
    }
    return nil;
}

- (NSData *)getDataFromPropertyKey:(NSString *)propertyKey
{
    //Storage Doesn't have data...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"propertyKey == %@", propertyKey];
    NSArray *a = [[self.streams allObjects] filteredArrayUsingPredicate:predicate];
    if (a.count > 0) {
        return [a[0] propertyData];
    }
    return nil;
}

@end
