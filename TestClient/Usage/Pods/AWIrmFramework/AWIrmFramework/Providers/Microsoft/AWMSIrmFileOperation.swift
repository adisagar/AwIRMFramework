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
import Foundation
import ADAL
import CompoundFileReader

enum ProtectedFileType : Int {
   case NoProtection = 0,
    ProtectedFile ,
    ProtectedOfficeFile
}


class AWMSIrmFileOperation: NSObject, AWIrmProtocol, MSAuthenticationCallback {
    var userid:String;
    var filePath:String;
    var appClientId:String;
    var consentManager = AWMSIrmConsent();
    let EncryptedPackage = "EncryptedPackage";
    let DRMContent = "\tDRMContent";
    
    
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
        
        var cache : ADKeychainTokenCache =  ADKeychainTokenCache.defaultKeychainCache()
        var result = cache.allItems(nil);
        
        let error : AutoreleasingUnsafeMutablePointer<ADAuthenticationError?> = nil
        let context =  ADAuthenticationContext(authority: authenticationParameters.authority, error:error)
        context.validateAuthority = false;
        
        let redirectURI = NSURL(string: "local://authorize")//(fileURLWithPath: "local://authorize")
        
        dispatch_async(dispatch_get_main_queue()) {
            context.acquireTokenWithResource(authenticationParameters.resource, clientId: self.appClientId, redirectUri: redirectURI, userId: self.userid) { (let result : ADAuthenticationResult!) in
                
                if result.status != AD_SUCCEEDED {
                    if result.status == AD_USER_CANCELLED {
                        completionBlock("",NSError(domain: "", code: 5001, userInfo: result.error.userInfo))
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
    
    //takes the file path and returns plain data after successfull authentication
    //This is for ppdf,ptxt etc..
    
    func plainDataFromProtectedFile(filePath:String, completionBlock : (response:AWIrmResponse?, error:NSError?)->Void ) {
        var present = NSFileManager.defaultManager().fileExistsAtPath(filePath)
        MSProtectedData .protectedDataWithProtectedFile(filePath, userId: self.userid, authenticationCallback: self, consentCallback: self.consentManager, options: Default) { (data:MSProtectedData!, error:NSError!) in
            if error != nil {
                completionBlock(response: nil, error: nil)
                return
            }
            
            let plainData = data.retrieveData()
            let irmResponse = AWIrmResponse(fileExtn: data.originalFileExtension, dataProvider: AWMSIrmDataProvider(data: data), policy: AWIrmUserPolicy())
            completionBlock(response: irmResponse, error: nil)
        }
    }
    
    
    func plainDataFromOfficeFiles(filePath:String, completionBlock : (response:AWIrmResponse?, error:NSError?)->Void ) {
        
        let cfbfParser  = StorageStreamParser.sharedInstance()
        cfbfParser.setFilePath(filePath)
        do{
        try cfbfParser.readFile()
        } catch {
            
        }
        
        
        let plData = cfbfParser.rootStorage.getDataFromPropertyKey("Primary")
        
        var encryptedData = cfbfParser.rootStorage.getDataFromPropertyKey(self.EncryptedPackage)
        if (encryptedData == nil) {
            encryptedData = cfbfParser.rootStorage.getDataFromPropertyKey(self.DRMContent)
        }
        
        let tempData =  plData.subdataWithRange(NSMakeRange(176, plData.length - 176))  // [pldata
        let primaryData =  NSMutableData(bytes: [0xEF, 0xBB, 0xBF] as [UInt8], length: 3)
        primaryData.appendData(tempData)
        
        MSUserPolicy.userPolicyWithSerializedPolicy(primaryData, userId: self.userid, authenticationCallback: self, consentCallback: self.consentManager, options: Default) { (userPolicy:MSUserPolicy!, error:NSError!) in
            
            
            if error != nil {
                completionBlock(response: nil, error: error)
            }
            else if userPolicy == nil {
                completionBlock(response: nil, error: nil)
            }
            
            else {
      
              
                MSCustomProtectedData.customProtectedDataWithPolicy(userPolicy, protectedData: encryptedData, contentStartPosition: 8, contentSize: UInt(encryptedData.length - 8) , completionBlock: { (customProtectedData : MSCustomProtectedData!,  error:NSError!) in
                    let plainData = customProtectedData.retrieveData()
                    let irmResponse = AWIrmResponse(fileExtn: "", dataProvider: AWMSIrmDataProvider(data: customProtectedData), policy: AWIrmUserPolicy())
                    completionBlock(response: irmResponse, error: nil)
                    
                })
            }
            
            
            
        }
        
    }
    
    
    static func isFileIrmProtected(filePath:String) -> Bool {
        let fileHandle = NSFileHandle(forReadingAtPath: filePath)
        
        if fileHandle == nil {
            return false
        }
        
        let fileHeader = fileHandle?.readDataOfLength(8)
        fileHandle?.closeFile()
        
        if(AWMSIrmFileOperation.protectionType(filePath, headerBytes: fileHeader!) != .NoProtection) {
            return true
        }
        return false
    }
    
    static func isPluginEnabled() -> Bool {
        return true
    }
    
    
    static func protectionType(filePath:String, headerBytes:NSData) -> ProtectedFileType {
        
        let pfileHeader = NSData(bytes: [0x2E,0x70,0x66,0x69,0x6C,0x65,0x02, 0x00] as [UInt8], length: 8)
        let officeFileHeader = NSData(bytes: [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1] as [UInt8], length: 8)
        
        if(headerBytes.isEqualToData(pfileHeader)){
            return .ProtectedFile;
        }
        
        if(headerBytes.isEqualToData(officeFileHeader)) {
            let parser = StorageStreamParser.sharedInstance()
            parser.setFilePath(filePath)
            //                            if parser.checkDirectoryEntryPresent("EncryptedPackage") || parser.checkDirectoryEntryPresent("DRMContent") {
            //                              return .ProtectedOfficeFile;
            //                            }
            
        }
        return .NoProtection;
    }
}
