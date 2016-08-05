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
    var redirectUrl = "local://authorize"
    
    /// Unique identifier for the Provider
    @objc var identifier: String {
        get {
            return Constants.ProviderIdentifiers.MicrosoftIrmProvider
        }
    }
    
    ///This method should return provider to read the decrypted data.
    ///Before that this should take care of authenticating the user and other preprocessing steps if present.
    @objc func irmItemHandle(forReading item: NSURL, userId:String, bundleId:String,completionBlock:(ItemHandle?,NSError?)->Void) {
        
        let itemHelper = MSItemHelper(url: item)
        let protectionType = itemHelper.protectionType()
        if protectionType == .MSProtection {
            plainDataFromProtectedFile(item.absoluteString, userId: userId, bundleId: bundleId, completionBlock: { (itemHandle:ItemHandle?,error: NSError?) in
            })
            
        } else if(protectionType == .MSCustomProtection) {
            //Todo handle office files.
        } else {
            completionBlock(nil,NSError(domain: "", code: 0, userInfo: nil)) //Todo handle error.
        }
    }
    
    
    //Determine whether file is protected
    internal func canProvide(item: NSURL) -> Bool {
        var canProvide = false
        let itemHelper = MSItemHelper(url: item)
        let protectionType = itemHelper.protectionType()
        
        if protectionType != .MSProtectionNone {
            canProvide = true
        }
        return canProvide
    }
    
    
    //Private implimentaions
    
    //takes the file path and returns plain data after successfull authentication
    //This is for ppdf,ptxt etc..
    private func plainDataFromProtectedFile(filePath:String,
                                            userId:String,
                                            bundleId:String,
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
            
            let itemHandle = MSItemHandle(msprotectedData: protectedData)
            
            completionBlock(itemHandle: itemHandle, nil)
        }
    }
    
    
    //MSAuthenticationCallback delegate implimentation.
    func accessTokenWithAuthenticationParameters(authenticationParameters: MSAuthenticationParameters!, completionBlock: ((String!, NSError!) -> Void)!) {
        
        let error : AutoreleasingUnsafeMutablePointer<ADAuthenticationError?> = nil
        let context =  ADAuthenticationContext(authority: authenticationParameters.authority, error:error)
        context.validateAuthority = false;
        
        let redirectURI = NSURL(string: redirectUrl)
        
        dispatch_async(dispatch_get_main_queue()) {
            context.acquireTokenWithResource(authenticationParameters.resource,
                                             clientId: self.clientId,
                                             redirectUri: redirectURI,
                                             userId: nil)
            { (let result : ADAuthenticationResult!) in
                
                if result.status != AD_SUCCEEDED {
                    if result.status == AD_USER_CANCELLED {
                        completionBlock("",NSError(domain: "", code: 0, userInfo: result.error.userInfo))
                    } else {
                        completionBlock("",result.error)
                    }
                } else {
                    completionBlock(result.accessToken, result.error)
                    
                    let token = result.accessToken;
                    NSLog(token)
                }
            }
            
        }
    }
}
