/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Provider.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 14/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import Foundation

//Protocol to be conformed by all Irm providers.
@objc(AWIrmProvider)
public protocol Provider {
    
    /// Unique identifier for the Provider
    var identifier: String { get }
    
    /*This method will return provider to read the decrypted data.
     Before that this will take care of authenticating the user and other preprocessing steps if present.
     @param  item: url of the item/file
     @param  userId: user id of the user to fetch polices/decrypt
     @param  clientId: identifier of the provider.
     */
    func irmItemHandle(forReading item: NSURL,
                                  userId:String,
                                  clientId:String,
                                  completionBlock:(ItemHandle?,NSError?)->Void)
}
