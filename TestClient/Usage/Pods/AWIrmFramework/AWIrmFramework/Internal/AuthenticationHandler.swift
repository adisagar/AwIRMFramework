//
//  AuthenticationHandler.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 06/08/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import ADAL

class AuthenticationHandler: NSObject {

     var redirectUrl = "local://authorize"
    
    //MSAuthenticationCallback delegate implimentation.
    func acquireTokenWithResource(resource:String,
                                  authority:String,
                                  clientId:String,
                                  completionBlock: ((String!, NSError!) -> Void)!) {
        
        let error : AutoreleasingUnsafeMutablePointer<ADAuthenticationError?> = nil
        let context =  ADAuthenticationContext(authority: authority, error:error)
        context.validateAuthority = false;
        
        let redirectURI = NSURL(string: redirectUrl)
        
        dispatch_async(dispatch_get_main_queue()) {
            context.acquireTokenWithResource(resource,
                                             clientId:clientId,
                                             redirectUri: redirectURI,
                                             userId: nil)
            { (let result : ADAuthenticationResult!) in
                
                if result.status != AD_SUCCEEDED {
                    if result.status == AD_USER_CANCELLED {
                        completionBlock("",NSError(domain: Constants.Application.BundleId, code: 0, userInfo: result.error.userInfo))
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
