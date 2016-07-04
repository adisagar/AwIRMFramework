/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmResponse.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 27/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

 
//This contains the user policy details and data provider to read decrypted content.
public class AWIrmResponse: NSObject {
    
    var originalFileExtn : String = ""
    
    var irmDataProvider : AWIrmDataProviderProtocol
    
    var userPolicy : AWIrmUserPolicy
    
    
    init(fileExtn:String, dataProvider:AWIrmDataProviderProtocol, policy:AWIrmUserPolicy) {
        originalFileExtn = fileExtn
        irmDataProvider = dataProvider
        userPolicy = policy
    }
}
