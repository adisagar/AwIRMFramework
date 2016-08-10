/*
 Copyright © 2014 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  CFileReaderError.h
//  CompoundFileReader
//
//  Created by Sachin Vas on 7/22/14.
//  Copyright (c) 2014 AirWatch. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const CFileReaderErrorDomain;

/**
 * Error codes for NSError.
 */
typedef NS_ENUM(NSInteger, CFileReaderErrorCode)
{
    /*
     if invalid header signature detected
     */
    CFileReaderCorruptedHeaderErrorCode,
    
    /*
     if major version neither 3 nor 4
     */
    CFileReaderUnsupportedVersionErrorCode,
    
    /*
     if secID is invalid
     */
    CFileReaderInvalidSIDErrorCode,
    
    /*
     if storage is invalid
     */
    CFileReaderInvalidStorageErrorCode,
    
    /*
     if storage type is invalid
     */
    CFileReaderInvalidStorageTypeErrorCode,
    
    /*
     if chain type is invalid
     */
    CFileReaderInvalidChainTypeErrorCode
};