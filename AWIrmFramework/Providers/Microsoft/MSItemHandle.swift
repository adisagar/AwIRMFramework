/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  MSItemHandle.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//
import Foundation

//Impliments all methods related to fetching decrypted data.
//This inturn invokes Microsoft APIs.
class MSItemHandle: ItemHandle {
    
    var protectedData : MSProtectedData
    
    
    init(msprotectedData : MSProtectedData){
        protectedData = msprotectedData
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
            //Implimentation goes here
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
            //Todo - Handle execption
        }
    }
    
    //Populates buffer with data of lenght.
    @objc func plainDataBytes(buffer: UnsafeMutablePointer<Void>, length: UInt, error: NSError) {
        do {
            try self.protectedData.getBytes(buffer, length: length)
        }
        catch {
           //Todo - Handle execption 
        }
    }
}
