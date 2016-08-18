/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//  MSFileHelper.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 05/08/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import CompoundFileReader

//Handles all file parsing related operations.
class MSItemHelper {
    
    let msprotectedFileHeader = NSData(bytes: [0x2E,0x70,0x66,0x69,0x6C,0x65,0x02, 0x00] as [UInt8], length: 8)
    let protectedOfficeFileHeader = NSData(bytes: [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1] as [UInt8], length: 8)
    let headerLength = 8
    let EncryptedPackageName = "EncryptedPackage" //For Office files >2007
    let EncryptedPackageNameOldVersion = "DRMContent" //For Office files <2007
    let PrimaryPackageName = "Primary"
    
    var itemPath : String
    
    
    init(path:String) {
        itemPath = path
    }
    
    //Read the first 8 bytes of the file and validate it against the protected header.
    func protectionType() throws -> MSProtectionType {
        var protectionType = MSProtectionType.MSProtectionNone
        do {
            
            let fileHandle = try NSFileHandle(forReadingAtPath: itemPath)
            let fileHeader = fileHandle!.readDataOfLength(headerLength)
            
            if checkForMSProtection(fileHeader) {//Non-Office
                protectionType = MSProtectionType.MSProtection
            } else if checkForCustomProtection(fileHeader) {//Office files
                protectionType = MSProtectionType.MSCustomProtection
            }
            
        }  catch _{
            throw NSError(domain: Constants.Framework.BundleId, code: Constants.ErrorCodes.FileParsingError, userInfo: nil)
        }
        return protectionType
    }
    
    func primaryAndEncryptedData() -> (NSMutableData?,NSData?) {
        var encryptedData:NSData? = nil
        var primaryData:NSMutableData? = nil
        do {
            let cfbfParser  = StorageStreamParser.sharedInstance()
            cfbfParser.setFilePath(itemPath)
            try cfbfParser.processFile()
            let primaryPackage = cfbfParser.rootStorage.getDataFromPropertyKey(PrimaryPackageName)
            
            if(primaryPackage != nil) {
                let tempData =  primaryPackage!.subdataWithRange(NSMakeRange(176, primaryPackage!.length - 176))  // [pldata
                primaryData =  NSMutableData(bytes: [0xEF, 0xBB, 0xBF] as [UInt8], length: 3)
                primaryData!.appendData(tempData)
            }
            
            //Fetch for >2007, if nil then fetch for <2007 office file format.
            encryptedData = cfbfParser.rootStorage.getDataFromPropertyKey(EncryptedPackageName)
            if (encryptedData == nil) {
                encryptedData = cfbfParser.rootStorage.getDataFromPropertyKey(EncryptedPackageNameOldVersion)
            }
            
        } catch _{
            
        }
        return (primaryData,encryptedData)
    }
    
    //Check for non-Office files, compare it with standard header.
    private func checkForMSProtection(itemHeader : NSData) -> Bool {
        return itemHeader.isEqualToData(msprotectedFileHeader)
    }
    
    
    //Check for Office files.
    private func checkForCustomProtection(itemHeader:NSData ) -> Bool {
        
        // This will be true for
        // a)Protected >2007 office files (docx,pptx etc..)
        // b)Protected/NonProtected < 2007 office files (doc,ppt etc.. )
        if itemHeader.isEqualToData(protectedOfficeFileHeader) {
            let parser = StorageStreamParser.sharedInstance()
            parser.setFilePath(itemPath)
            //Check for encrypted directory entry present
            if parser.checkDirectoryEntryPresent(EncryptedPackageName) || parser.checkDirectoryEntryPresent(EncryptedPackageNameOldVersion) {
                return true
            }
        }
        return false
    }
    
    
    
}