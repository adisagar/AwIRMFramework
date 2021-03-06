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
        static let NotificationProgressKey = "IrmProgressStatus"
        static let NotificationName = "IRMAuthenticationDidFinishNotification"
    }
    
    struct ErrorCodes {
        static let InternalSDKError = 1000
        static let UserCancelledAuthentication = 1001
        static let AuthenticationError = 1002
        static let PermissionDenied = 1003
        static let FileParsingError = 1004
        static let DataDecryptionError = 1005
        static let ProtectionNotDetected = 1006
    }
    
    struct IrmProgressStatus {
        static let AuthenticationCompleted = "AuthenticationCompleted"
    }
}
