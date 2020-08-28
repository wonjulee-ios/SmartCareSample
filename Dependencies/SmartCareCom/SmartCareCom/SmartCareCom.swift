//
//  SmartCareCom.swift
//  SmartCareCom
//
//  Created by philosys_macbook on 2020/08/03.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import Hubidic

public class SmartCareCom {
    
//    let bpManager:DeviceManaging
//    let glucoseManager:DeviceManaging
//    let bodyWeightManager:DeviceManaging
    
    public static let shared = SmartCareCom()
    public let bpManager:BloodPressManager
    public let glucoseManager:BloodGlucoseManager
    public let bodyWeightManager:BodyWeightManager
    
    public init(){
        
        self.bpManager = BloodPressManager()
        self.glucoseManager = BloodGlucoseManager()
        self.bodyWeightManager = BodyWeightManager()
    }
}

public protocol DeviceManagerScannable {
    func DeviceManagerScanning(dictArray:[[String:String]])
}
