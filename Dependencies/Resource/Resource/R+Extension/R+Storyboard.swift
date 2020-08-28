//
//  R+Storyboard.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/14.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

extension R.Storyboard {
   
    public typealias Storyboard = R.Storyboard
    
    public static var scanView: Storyboard { Storyboard(name: "ScanViewController") }
    public static var deviceSelectView: Storyboard { Storyboard(name: "DeviceSelectViewController") }
    public static var pairngModeView: Storyboard { Storyboard(name: "PairingViewController") }
    public static var bpDataSyncView: Storyboard { Storyboard(name: "BpDataSyncViewController") }
    public static var bpUserSelectView: Storyboard { Storyboard(name: "BpUserSelecctViewController") }
    public static var bpMeasureView: Storyboard { Storyboard(name: "BpMeasureViewController") }
    
    
    
    
    
}

extension R {
    public class Storyboard {
        let identifier: String
        public let storyboard: UIStoryboard
        public init(name: String, identifier: String) {
            self.identifier = identifier
            self.storyboard = UIStoryboard(name: name, bundle: R.bundle)
        }
        public convenience init(name: String) {
            self.init(name: name, identifier: name)
        }
        public func instance<T: UIViewController>() -> T {
            storyboard.instantiateViewController(withIdentifier: identifier) as! T
        }
    }
}
