/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmUserPolicy.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 27/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

 
//User policies as returned form this framework.
public class AWIrmUserPolicy: NSObject {
    
    var canEmail : Bool;
    
    var canPrint : Bool;
    
    var canEdit : Bool;
    
    var canView : Bool;
    
    var canOpenInto : Bool;
    
    var isOwner : Bool;
    
    var canExtract : Bool;
    
    override init() {
        canEdit = false
        canView = false
        canPrint = false
        canEmail = false
        canOpenInto = false
        isOwner = false
        canExtract = false
    }
}
