/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWMSIrmPolicyParser.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 29/06/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//


class AWMSIrmPolicyParser: NSObject {

    let MSCanEdit = "EDIT";
    let MSCanPrint = "PRINT";
    let MSCanView = "VIEW";
    let MSCanEmail = "";
    let MSCanExport = "EXPORT"; //todo - Need to verify this
    let MSIsOwner = "OWNER";
    let MSExtract = "EXTRACT";
    
    func mapIrmPolicy(/*userPolicy MSUserPolicy*/)-> AWIrmUserPolicy {
    
        //TODO - Call actual Microsoft API.
    
//    if ([userPolicy accessCheck: MSCanEdit] ) {
//    awPolicy.canEdit = NO; //Always no here since we are not suporting protected doc edit in this phase.
//    }
//    if ([userPolicy accessCheck:MSCanExport] ) {
//    awPolicy.canOpenInto = YES;
//    awPolicy.canEmail = YES;
//    }
//    
//    if ([userPolicy accessCheck:MSCanPrint] ) {
//    awPolicy.canPrint = YES;
//    }
//    
//    if ([userPolicy accessCheck:MSIsOwner] ) {
//    awPolicy.isOwner = YES;
//    }
//    
//    if ([userPolicy accessCheck:MSCanView] ) {
//    awPolicy.canView = YES;
//    }
//    
//    if ([userPolicy accessCheck:MSExtract] ) {
//    awPolicy.canExtract = YES;
//    awPolicy.canOpenInto = YES;
//    awPolicy.canEmail = YES;
//    }
//    
//    return awPolicy;
    
        return AWIrmUserPolicy()
    }
    
}
