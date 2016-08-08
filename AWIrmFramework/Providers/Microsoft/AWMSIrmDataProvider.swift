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
    @objc var decryptedDataLength: Int64 {
        get {
            return protectedData.length(nil)
        }
    }
    
    //Returns completed decrypted data.
    @objc var completePlainData: NSData {
        get {
            return protectedData.retrieveData()
        }
    }
    
    //Fetches decrypted data within the range.
    @objc func plainDataBytesWithRange(range: NSRange) -> NSData {
        
        return protectedData.subdataWithRange(range)
        
    }
    
    //Populates buffer within the range.
    @objc func plainDataBytes(buffer: UnsafeMutablePointer<Void>, range: NSRange, error: NSError) {
        
        do {
            
            try self.protectedData.getBytes(buffer, range: range)
        }
        catch {
            
        }
        
    }
    
    //Populates buffer with data of lenght.
    @objc func plainDataBytes(buffer: UnsafeMutablePointer<Void>, length: UInt, error: NSError) {
        do {
            
            try self.protectedData.getBytes(buffer, length: length)
        }
        catch {
            
        }
    }
    
    
    
}
