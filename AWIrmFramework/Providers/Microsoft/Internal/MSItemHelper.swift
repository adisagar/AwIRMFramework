//
//  MSFileHelper.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 05/08/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//


class MSItemHelper {
    
    let msprotectedFileHeader = NSData(bytes: [0x2E,0x70,0x66,0x69,0x6C,0x65,0x02, 0x00] as [UInt8], length: 8)
    let officeFileHeader = NSData(bytes: [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1] as [UInt8], length: 8)
    let headerLength = 8
    
    var itemURL : NSURL
    
    
    init(url:NSURL) {
        itemURL = url
    }
    
    //Read the first 8 bytes of the file and validate it against the protected header.
    func protectionType() -> MSProtectionType {
        var protectionType = MSProtectionType.MSProtectionNone
        do {
            
            let fileHandle = try NSFileHandle(forReadingFromURL: itemURL)
            let fileHeader = fileHandle.readDataOfLength(headerLength)
            
            if checkForMSProtection(fileHeader) {
                protectionType = MSProtectionType.MSProtection
            } else if checkForCustomProtection(fileHeader) {
                protectionType = MSProtectionType.MSCustomProtection
            }
            
        }  catch {
            //Todo handle exception case.
        }
        return protectionType
    }
    
    //Check for non-Office files, compare it with standard header.
    private func checkForMSProtection(itemHeader : NSData) -> Bool {
       return itemHeader.isEqualToData(msprotectedFileHeader)
    }
    
    
    //Check for Office files.
    private func checkForCustomProtection(itemHeader : NSData) -> Bool {
        return false //Todo Implimentation pending.
    }
    
}