/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWMSIrmFileOperation.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 27/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//



class AWMSIrmFileOperation: NSObject, AWIrmProtocol, MSAuthenticationCallback {
    var userid:String;
    var filePath:String;
    var appClientId:String;
    var consentManager = AWMSIrmConsent();
    
    
    init(userId:String,filePath:String, appBundleId:String) {
        self.userid = userId
        self.filePath = filePath
        self.appClientId = appBundleId 
    }
    
    func plainDataFromIRMFile(filePath: String, completionBlock: ((response: AWIrmResponse?, error: NSError?) -> Void)) {
        
        let fileHandle = NSFileHandle(forReadingAtPath: filePath)
        
        if fileHandle == nil {
            completionBlock(response: nil, error: NSError(domain: "", code: 0, userInfo: nil))
            return;
        }
        
        plainDataFromProtectedFile(filePath) { (response, error) in
            completionBlock(response: response, error: nil)
        }
 
    }
    
    func accessTokenWithAuthenticationParameters(authenticationParameters: MSAuthenticationParameters!, completionBlock: ((String!, NSError!) -> Void)!) {
        
        let error : AutoreleasingUnsafeMutablePointer<ADAuthenticationError?> = nil
        let context =  ADAuthenticationContext(authority: authenticationParameters.authority, error:error)
        context.validateAuthority = false;
       
        let redirectURI = NSURL(string: "local://authorize")//(fileURLWithPath: "local://authorize")

        context.acquireTokenWithResource(authenticationParameters.resource, clientId: self.appClientId, redirectUri: redirectURI, userId: self.userid) { (let result : ADAuthenticationResult!) in
            
            if result.status != AD_SUCCEEDED {
                if result.status == AD_USER_CANCELLED {
                    completionBlock("",NSError(domain: "", code: 5001, userInfo: result.error.userInfo))
                } else {
                    completionBlock("",result.error)
                }
            } else {
                completionBlock(result.accessToken, result.error)
            }
        }
    }
    
    //takes the file path and returns plain data after successfull authentication
    //This is for ppdf,ptxt etc..
    
    func plainDataFromProtectedFile(filePath:String, completionBlock : (response:AWIrmResponse?, error:NSError?)->Void ) {
        
        MSProtectedData .protectedDataWithProtectedFile(filePath, userId: self.userid, authenticationCallback: self, consentCallback: self.consentManager, options: Default) { (data:MSProtectedData!, error:NSError!) in
            if error == nil {
                completionBlock(response: nil, error: nil)
                return
            }
            
            //let plainData = data.retrieveData()
            let irmResponse = AWIrmResponse(fileExtn: data.originalFileExtension, dataProvider: AWMSIrmDataProvider(data: data), policy: AWIrmUserPolicy())
            completionBlock(response: irmResponse, error: nil)
        }
    }
    
 
    static func isFileIrmProtected(filePath:String) -> Bool {
        return true //Todo - Parsing using Compund file reader
    }
    
    static func isPluginEnabled() -> Bool {
        return true
    }
    
}
