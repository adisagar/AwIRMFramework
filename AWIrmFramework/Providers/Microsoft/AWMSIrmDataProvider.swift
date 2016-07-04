/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWMSIrmDataProvider.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 28/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//


//Impliments all method related to fetching decrypted data.
//This uses Microsoft Provider.
class AWMSIrmDataProvider: AWIrmDataProviderProtocol{
    
    
    var protectedData : MSProtectedData
        init(data : MSProtectedData) {
            protectedData = data
        }
    
    //Length of the decypted data
    var decryptedDataLength: Int64 {
        get {
            return protectedData.length(nil)
        }
    }
    
    //Returns completed decrypted data.
    var completePlainData: NSData {
        get {
            return protectedData.retrieveData()
        }
    }
    
    //Fetches decrypted data within the range.
    func plainDataBytesWithRange(range: NSRange) -> NSData {
        return NSData()//Todo: Calling Microsoft API
    }
    
    //Populates buffer within the range.
    func plainDataBytes(buffer: UnsafePointer<Void>, range: NSRange, error: NSError) {
        return;//Todo: Calling Microsoft API
    }
    
    //Populates buffer with data of lenght.
    func plainDataBytes(buffer: UnsafePointer<Void>, length: Int64, error: NSError) {
        return;//Todo: Calling Microsoft API
    }
    


}
