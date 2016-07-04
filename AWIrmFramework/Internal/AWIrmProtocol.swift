/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmOperation.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 29/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//


//Defines the set of methods that all IRM providers should impliment.
protocol AWIrmProtocol {
    
    //Method to decrypt the file and policies.
    func plainDataFromIRMFile(filePath:String,completionBlock:(response:AWIrmResponse?, error:NSError?)-> Void);
    
    //Determine whether file is protected
    static func isFileIrmProtected(filePath:String) -> Bool
    
    //This is the setting to turn Off/On each of the IRM Providers.
    //In the initial release this will be always true
    static func isPluginEnabled() -> Bool
}
