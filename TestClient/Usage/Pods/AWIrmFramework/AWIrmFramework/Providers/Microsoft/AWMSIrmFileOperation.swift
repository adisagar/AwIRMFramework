/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWMSIrmFileOperation.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 11/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import UIKit

//This class directly interacts with Microsoft Irm framework.
//Impliments authentication call backs,decryption.
class AWMSIrmFileOperation : AWIrmProvider, AWIrmInternalProtocol {
    
    /// Unique identifier for the Provider
    @objc var identifier: String {
        get {
            return Constants.ProviderIdentifiers.microsoftIrmProvider
        }
    }
    
    ///This method should return provider to read the decrypted data.
    ///Before that this should take care of authenticating the user and other preprocessing steps if present.
    @objc func dataProvider(forReading item: NSURL, userId:String, appBundleId:String,completionBlock:( AWIrmItemHandle?)) {
        
    }
    
    
    //Determine whether file is protected
    internal func canProvide(item: NSURL) -> Bool {
        return true
    }

}
