/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  LayerInfo.m
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "LayerInfo.h"

@interface LayerInfo ()

@end

@implementation LayerInfo

- (BOOL)checkValueCount
{
    self.ucValueCount--;
    return self.ucValueCount < 0;
}

@end
