/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  LayerInfo.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 8/11/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayerInfo : NSObject

@property (nonatomic, assign) NSInteger ucValue;
@property (nonatomic, assign) NSInteger ucValueCount;

- (BOOL)checkValueCount;

@end
