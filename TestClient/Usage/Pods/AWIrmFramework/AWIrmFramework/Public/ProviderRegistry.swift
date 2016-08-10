/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  ProviderRegistry.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//
import Foundation
 
//Factory class 
@objc(AWIrmProviderRegistry)
public class ProviderRegistry: NSObject {
    
    //Static properties in Swift are implicitly lazy
    public static let instance = ProviderRegistry()
    
    /* Looks up a Provider by its identifier
     @param  identifier: unique identifier of the provider
     */
    public func provider(identifier:String) -> Provider? {
        switch identifier {
        case Constants.ProviderIdentifiers.MicrosoftIrmProvider:
            return MSIrmProvider()
        default:
            return nil
        }
    }
    
    /* Finds a Provider for the specified file
     @param  item: url of the item/file
     */
    public func provider(for item:NSURL) throws -> Provider? {
        let msProvider = MSIrmProvider()
 
           // let error:NSErrorPointer=nil
        do {
            if  try msProvider.canProvide(item) {
                return msProvider
            }
        }catch _{
                throw NSError(domain: Constants.Framework.BundleId, code:Constants.ErrorCodes.FileParsingError, userInfo: nil)
            }
        
        return nil
    }
    
    /// Enables / Disables a Provider
    public func setProvider(identifier: String, enabled: Bool) {
        
    }
}
