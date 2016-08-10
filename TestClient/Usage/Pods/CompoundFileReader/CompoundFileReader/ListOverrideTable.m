/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ListOverrideTable.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/5/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "ListOverrideTable.h"

@interface ListOverrideTable ()

@property (nonatomic, strong) NSMutableArray *listOverride;

@end

@implementation ListOverrideTable

- (void)dealloc
{
    _listOverride = nil;
}

- (ListOverride *)objectByID:(NSInteger)ID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %@", ID];
    NSArray *filtPredicate = [self.listOverride filteredArrayUsingPredicate:predicate];
    if (filtPredicate.count > 0) {
        return [filtPredicate objectAtIndex:0];
    }
    return nil;
}

- (void)addListOverrideObject:(ListOverride *)listOverride
{
    [self.listOverride addObject:listOverride];
}

@end
