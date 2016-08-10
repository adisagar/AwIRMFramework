/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  MSProvider.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 11/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import Foundation
import ADAL

//This class directly interacts with Microsoft Irm framework.
//Impliments authentication call backs,decryption.

class MSIrmProvider:NSObject, Provider, InternalProtocol, MSAuthenticationCallback {
    
    var consent = MSConsentHandler()
    var clientId = ""
    
    
    //MARK: Provider protocol implimentations
    
    /// Unique identifier for the Provider
    @objc var identifier: String {
        get {
            return Constants.ProviderIdentifiers.MicrosoftIrmProvider
        }
    }
    
    ///This method should return provider to read the decrypted data.
    ///Before that this should take care of authenticating the user and other preprocessing steps if present.
    @objc func irmItemHandle(forReading item: NSURL, userId:String, clientId:String,completionBlock:(ItemHandle?,NSError?)->Void) {
        self.clientId = clientId
        let itemHelper = MSItemHelper(url: item)
        var protectionType = MSProtectionType.MSProtectionNone
        
        do {
            protectionType = try itemHelper.protectionType()
        } catch _{
            completionBlock(nil,NSError(domain: Constants.Framework.BundleId, code:  Constants.ErrorCodes.FileParsingError, userInfo: nil))
            return
        }
        //For non-office files.
        if protectionType == .MSProtection {
            plainDataFromProtectedFile(item.path!, userId: userId, clientId: clientId, completionBlock: { (itemHandle:ItemHandle?,error: NSError?) in
                completionBlock(itemHandle,error)
            })
        } else if(protectionType == .MSCustomProtection) {
            //Todo handle office files.
        } else {
            completionBlock(nil,NSError(domain: Constants.Framework.BundleId, code:  Constants.ErrorCodes.ProtectionNotDetected, userInfo: nil))
        }
    }
    
    //MARK: InternalProtocol
    
    //Determine whether file is protected
    internal func canProvide(item: NSURL) throws -> Bool {
        var canProvide = false
        do {
            let itemHelper = MSItemHelper(url: item)
            let protectionType = try itemHelper.protectionType()
            
            if protectionType != .MSProtectionNone {
                canProvide = true
            }
        } catch _{
            throw  NSError(domain: Constants.Framework.BundleId, code: Constants.ErrorCodes.FileParsingError, userInfo: nil)
        }
        return canProvide
    }
    
    
    //MARK: MSAuthenticationCallback

    //MSAuthenticationCallback delegate implimentation.
    func accessTokenWithAuthenticationParameters(authenticationParameters: MSAuthenticationParameters!, completionBlock: ((String!, NSError!) -> Void)!) {
        let authenticationHandler = AuthenticationHandler()
        authenticationHandler.acquireTokenWithResource(authenticationParameters.resource, authority: authenticationParameters.authority, clientId: self.clientId)
        { (accessToekn:String!,error: NSError!) in
            completionBlock(accessToekn,error)
        }
    }
    
    //MARK: Private implimentaions
    
    //takes the file path and returns plain data after successfull authentication
    //This is for ppdf,ptxt etc..
    private func plainDataFromProtectedFile(filePath:String,
                                            userId:String,
                                            clientId:String,
                                            completionBlock : (itemHandle:ItemHandle?,NSError?)->Void ) {
        
        MSProtectedData .protectedDataWithProtectedFile(filePath,
                                                        userId: userId,
                                                        authenticationCallback: self,
                                                        consentCallback: self.consent, options: Default)
        { (protectedData:MSProtectedData!, error:NSError!) in
            if error != nil {
                completionBlock(itemHandle: nil, error)
                return
            }
            let itemHandle = MSItemHandle(msprotectedData:protectedData)
            completionBlock(itemHandle: itemHandle, nil)
        }
    }
    
}

