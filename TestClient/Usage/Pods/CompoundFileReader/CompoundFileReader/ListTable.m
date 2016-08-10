/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ListTable.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/14/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ListTable.h"

@interface ListTable ()

@property (nonatomic, strong) NSMutableArray *listTableArray;

@end

@implementation ListTable

- (void)dealloc
{
    _listTableArray = nil;
}

- (id)init
{
    if (self = [super init]) {
        _listTableArray = [NSMutableArray array];
    }
    return self;
}

- (RtfObject *)objectById:(NSInteger)ID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"listID == %@", ID];
    NSArray *filteredArray = [self.listTableArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0) {
        return [filteredArray objectAtIndex:0];
    }
    return nil;
}

- (void)addObject:(RtfObject *)rtfObject
{
    [self.listTableArray addObject:rtfObject];
}

@end
