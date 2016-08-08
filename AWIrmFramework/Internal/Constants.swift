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
        static let UserCancelledAuthentication = 100
        static let AuthenticationError = 101
        static let ViewPermissionDenied = 102
        static let FileParsingError = 103
        static let DataDecryptionError = 104
        static let ProtectionNotDetected = 105
    }
}
