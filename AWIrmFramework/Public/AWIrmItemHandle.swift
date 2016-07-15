/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmItemHandle.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import UIKit

//Defines methods related to fetching the decrypted data
//The wrapper class around IRM provider should impliment these methods
@objc(AWIrmItemHandle)
public protocol AWIrmItemHandle {
    //Lenght of the decrypted data
    var decryptedDataLength : Int64 {get} ;
    
    //Should return complete plain data
    var completePlainData : NSData {get};
    
    //Should return plain data within the range
    func plainDataBytesWithRange(range:NSRange) -> NSData;
    
}
