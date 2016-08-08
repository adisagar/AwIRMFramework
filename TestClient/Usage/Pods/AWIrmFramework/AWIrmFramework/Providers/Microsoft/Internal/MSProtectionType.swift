//
//  MSProtectionType.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 05/08/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//


//Protection types applied on Office/Non-Office files.
//File structure will be different between these and based on that decryption has be handled differently.
public enum MSProtectionType: Int {
    
    case MSProtectionNone = 0,
    
         MSCustomProtection = 1, // This is for Office files
    
         MSProtection = 2  //This is for non office files.
}