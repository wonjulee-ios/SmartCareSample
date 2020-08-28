//
//  R+Nib.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/27.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

extension R.Nib {
   
    public typealias Nib = R.Nib
    
    public static var BpDataSyncCell:Nib{ Nib(name: "BpDataSyncCell") }
    public static var BpUserSelectCell:Nib{ Nib(name: "BpUserSelectCell") }
    public static var PairingTypeACell:Nib{ Nib(name: "PairingTypeACell") }
    public static var PairingUserSelectCell:Nib{ Nib(name: "PairingUserSelectCell") }
    public static var DeviceSelectCell:Nib{ Nib(name: "DeviceSelectCell") }
    public static var ScanViewCell:Nib{ Nib(name: "ScanViewCell") }
    
}

extension R {
    public class Nib {
        let nib: UINib
        public let identifier:String
        public init(name: String) {
            self.identifier = name
            self.nib = UINib(nibName: name, bundle: R.bundle)
        }
        public func instance<T: UINib>() -> T {
            return nib as! T
        }
    }
}
