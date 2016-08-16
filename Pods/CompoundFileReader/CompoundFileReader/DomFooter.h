/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  DomFooter.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 9/4/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import "DomElement.h"
#import "RTFEnums.h"

@interface DomFooter : DomElement

@property (nonatomic, assign) RtfHeaderFooterStyle style;
@property (nonatomic, assign) BOOL hasContentElement;

@end
