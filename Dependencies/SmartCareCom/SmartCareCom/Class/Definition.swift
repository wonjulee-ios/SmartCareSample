//
//  Definition.swift
//  SmartCareCom
//
//  Created by philosys_macbook on 2020/08/12.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import Hubidic

public protocol BloodPressDeviceSelectable:AnyObject {
    func select(to deviceType:BloodPressManager.DeviceType)
}
public protocol BloodPressDeviceDeletable:AnyObject {
    func remove(to deviceType:BloodPressManager.DeviceType)
}
public protocol DeviceDataSource:AnyObject {
    var name:String {get set}
}

public protocol BleDeviceDataSource:AnyObject {
    
    func bleScanDevice()
    func bleConnect()
    func bleDisconnect()
    func bleScanConnectedDevice()
    func bleStopScan()
}


protocol DeviceManaging:AnyObject {

}






public class BloodGlucoseManager:DeviceManaging{
    public func select() {
        
    }
    
//    var selectedDevice: DeviceDataSource?
    
}
public class BodyWeightManager:DeviceManaging{
    public func select() {
        
    }
    
    
    
}

