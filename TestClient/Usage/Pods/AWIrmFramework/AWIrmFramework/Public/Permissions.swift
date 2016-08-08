/*
 Copyright © 2016 AirWatch, LLC. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */
//
//  Permissions.swift
//  AWIrmFramework
//
//  Created by Aditya Prasad on 15/07/16.
//  Copyright © 2016 VMware Airwatch. All rights reserved.
//

 
//Permission.
public struct Permissions: OptionSetType {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let View  = Permissions(rawValue: 1 << 0)
    static let Save  = Permissions(rawValue: 1 << 1)
    static let Share = Permissions(rawValue: 1 << 2)
    static let Print = Permissions(rawValue: 1 << 3)
}