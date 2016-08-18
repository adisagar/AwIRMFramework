/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Constants.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//
 


//All constants
struct Constants {
    
    struct ProviderIdentifiers {
        //MicrosoftIrmProvider
        static let MicrosoftIrmProvider = "MICROSOFTIRMPROVIDER"
    }
    
    struct Framework {
        static let BundleId = "com.air-watch.AWIrmFramework"
    }
    
    struct ErrorCodes {
        static let UserCancelledAuthentication = 1000
        static let AuthenticationError = 1001
        static let PermissionDenied = 1002
        static let FileParsingError = 1003
        static let DataDecryptionError = 1004
        static let ProtectionNotDetected = 1005
    }
}
