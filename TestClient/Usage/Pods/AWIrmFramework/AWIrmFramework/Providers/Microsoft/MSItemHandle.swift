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
    var irmProvider = MSIrmProvider();
    
    init(msprotectedData:MSProtectedData){
        protectedData = msprotectedData
    }
    
    
    
    //Length of the decypted data
    @objc var decryptedDataLength:Int64 {
        get {
            return protectedData.length(nil)
        }
    }
    
    //Returns completed decrypted data.
    @objc var completePlainData:NSData {
        get {
            return protectedData.retrieveData()
        }
    }
    
    
    /*Populates buffer with data of lenght.
     @param buffer: byte* for holding decrypted data
     @param length: length of the data required
     */
    @objc func plainDataBytes(length:UInt) throws -> NSData {
        do {
            let buffer : UnsafeMutablePointer<Void> = malloc(Int(length))
            try self.protectedData.getBytes(buffer, length: length)
            let plainData = NSData(bytes: buffer, length:Int(length))
            return plainData
        }
        catch let error as NSError?{
            throw NSError(domain: Constants.Framework.BundleId, code:Constants.ErrorCodes.DataDecryptionError, userInfo: error?.userInfo)
        }
    }
    
    /*Populates buffer within the range.
     @param buffer: byte* for holding decrypted data
     @param range: Range of the data required
     */
    @objc func plainDataBytes(with range:NSRange) throws -> NSData {
        do {
            let buffer : UnsafeMutablePointer<Void> = malloc(range.length)
            try self.protectedData.getBytes(buffer, range: range)
            let plainData = NSData(bytes: buffer, length: range.length)
            return plainData
        }
        catch let error as NSError?{
            throw NSError(domain: Constants.Framework.BundleId, code: Constants.ErrorCodes.DataDecryptionError, userInfo: error?.userInfo)
        }
    }
    
}
