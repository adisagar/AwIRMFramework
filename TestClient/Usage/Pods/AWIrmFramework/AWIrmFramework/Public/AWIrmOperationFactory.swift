/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//  AWIRMOperationFactory.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 27/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import UIKit

//This class is responsible for all irm related methods.
public class AWIrmOperationFactory : NSObject{
    
    //Singleton factory. Static properties in Swift are implicitly lazy
    public static let sharedInstance = AWIrmOperationFactory()
    
    
    //Method resposible for Authenticating and parsing the policies of the protected document.
    //If found,the policies are directly returned from cache for particular user/file pair.
    //If only credentails are found to be cached then, authentication screen is skipped.
    public func plainDataFromIRMFile(filePath : String, providerType:AWIrmProviderType, userId:String, appBundleId:String, completionBlock:(irmResponse : AWIrmResponse?, error : NSError?) -> Void){
        
        let irmHandler = irmProviderHandlerForContent(filePath, providerType: providerType, userId: userId, appBundleId: appBundleId)
        
        if (irmHandler != nil) {
            irmHandler!.plainDataFromIRMFile(filePath) { (plainData, error) in
                completionBlock(irmResponse: plainData, error: error)
            }
        } else {
            completionBlock(irmResponse: nil, error: nil)
        }
        
    }
    
    // This will parse the file and detect whether it is protected.
    // It will check for each provider type.
    // Returns None in case the file is not protected from any of the supported providers.
    public func irmProviderForContent(filePath : String) -> AWIrmProviderType{
        
        if AWMSIrmFileOperation.isPluginEnabled() && AWMSIrmFileOperation.isFileIrmProtected(filePath) {
            return .AWIrmProviderTypeMicrosoft
        }
        
        return .AWIrmProviderTypeNone ;
    }
    
    //Returns the coressponding initialized Irm handler.
    private func irmProviderHandlerForContent(filePath:String, providerType:AWIrmProviderType, userId:String, appBundleId:String) -> AWIrmProtocol? {
        
        switch providerType {
        case .AWIrmProviderTypeMicrosoft:
            return AWMSIrmFileOperation(userId: userId, filePath: filePath, appBundleId: appBundleId)
        default:
            return nil
        }
    }
    
}
