/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmDataProvider.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 27/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

//Defines methods related to fetching the decrypted data
protocol AWIrmDataProviderProtocol {
    
    var decryptedDataLength : Int64 {get} ;

    var completePlainData : NSData {get};

    func plainDataBytes(buffer:UnsafePointer<Void>, range:NSRange, error:NSError);

    func plainDataBytes(buffer:UnsafePointer<Void>, length:Int64, error:NSError);

    func plainDataBytesWithRange(range:NSRange) -> NSData;

}
