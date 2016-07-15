/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWMSIrmItemHandle.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import UIKit

//Impliments all methods related to fetching decrypted data.
//This inturn invokes Microsoft APIs.
class AWMSIrmItemHandle: AWIrmItemHandle {
    
    
    //Length of the decypted data
    @objc var decryptedDataLength: Int64 {
        get {
            //Implimentation goes here
            return 0
        }
    }
    
    //Returns completed decrypted data.
    @objc var completePlainData: NSData {
        get {
            //Implimentation goes here
            return NSData()
        }
    }
    
    //Fetches decrypted data within the range.
    @objc func plainDataBytesWithRange(range: NSRange) -> NSData {
        //Implimentation goes here
        return NSData()
    }
}
