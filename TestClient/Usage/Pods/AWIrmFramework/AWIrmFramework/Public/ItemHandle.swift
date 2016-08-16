/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ItemHandle.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

 import Foundation

//Defines methods related to fetching the decrypted data
//The wrapper class around IRM provider should impliment these methods
@objc(AWIrmItemHandle)
public protocol ItemHandle {
    //Lenght of the decrypted data
    var decryptedDataLength : Int64 {get} ;
    
    //Will return complete plain data
    var completePlainData : NSData {get};

    
    /*Populates buffer with data of lenght.
     @param buffer: byte* for holding decrypted data
     @param length: length of the data required
     */
    func plainDataBytes(length:UInt) throws -> NSData
    
    
    
    /*Populates buffer within the range.
     @param buffer: byte* for holding decrypted data
     @param range: Range of the data required
     */
    func plainDataBytes(with range:NSRange) throws -> NSData
    
}
