/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  AWIrmProviderRegistry.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

import UIKit

public class AWIrmProviderRegistry: NSObject {
    
    //Singleton factory. Static properties in Swift are implicitly lazy
    public static let instance = AWIrmProviderRegistry()
    

      /// Looks up a Provider by its identifier
    public func provider(identifier:String) -> AWIrmProvider? {
        return AWMSIrmFileOperation()
    }
    
    /// Finds a Provider for the specified file
    public func provider(for item:NSURL) -> AWIrmProvider? {
        return nil 
    }
    
    
    /// Enables / Disables a Provider
    public func setProvider(identifier: String, enabled: Bool) {
        
    }
    
    public func test() ->String  {
        return "asd"
    }

}
