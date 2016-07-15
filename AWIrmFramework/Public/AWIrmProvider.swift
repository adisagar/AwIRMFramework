/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmProvider.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 14/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import UIKit

@objc(AWIrmProvider)
public protocol AWIrmProvider {
    
    /// Unique identifier for the Provider
    var identifier: String { get }
    
    ///This method should return provider to read the decrypted data.
    ///Before that this should take care of authenticating the user and other preprocessing steps if present.
    func dataProvider(forReading item: NSURL, userId:String, appBundleId:String,completionBlock:(AWIrmItemHandle?))
}
