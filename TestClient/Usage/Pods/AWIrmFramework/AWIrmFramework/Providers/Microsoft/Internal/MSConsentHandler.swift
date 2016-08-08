/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//  MsConsent.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 05/08/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//
 
//Consent for Microsoft IRM. This will silently accept the consent and returns
class MSConsentHandler: NSObject , MSConsentCallback {
    

    func consents(consents: [AnyObject]!, consentsCompletionBlock: (([AnyObject]!) -> Void)!) {
        if consents.count > 0 {
        let thisConsent = consents[0] as! MSConsent
        thisConsent.consentResult.accepted = true
        thisConsent.consentResult.showAgain = false
        consentsCompletionBlock([thisConsent])
        }
    }
    
}
