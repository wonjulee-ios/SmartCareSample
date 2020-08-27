//
//  Definition.swift
//  Hubidic
//
//  Created by philosys_macbook on 2020/08/12.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation

public struct HubidicUUID {
    static let deviceName = "1585B"
    static let serviceUUID = "0x7889"
//    static let HBP1700BT_Peripheral_Name = "1585B"
    static let HBP1700BT_Peripheral_Name_Pairing = "11585B" // 앞자리 숫자가 플래그임 0:normal, 1:pairing
    static let HBP1700BT_Peripheral_Name_Normal = "01585B"
    static let BloodPressure_Service = "7889"
    static let DateTime_Char = "2A08"
    static let BloodPressureMeasurement_Char = "2A35"
    static let BloodPressureWrite_Char = "8A81"
    static let BloodPressureIndicateInfo_Char = "8A82"
    static let BloodPressureIndicateMeasure_Char = "8A91"
    static let DeviceInformation_Service = "180A"
    static let SerialNumber_Char = "2A25"
    static let FirmwareRevisionString_Char = "2A26"
    static let HardwareRevisionString_Char = "2A27"
    static let SoftwareRevisionString_Char = "2A28"
    static let ManufacturerNameString_Char = "2A29"
    
    
}

public struct HubidicCommand {
    static let password:UInt8 = 0xA0
    static let accountId:UInt8 = 0x21
    static let randomNumber:UInt8 = 0xA1
    static let verification:UInt8 = 0x20
    static let setTime:UInt8 = 0x02
    static let userName:UInt8 = 0x83
    static let connectUser:UInt8 = 0x03
    static let timeOffset:UInt8 = 0x02
    static let enableDisconnection:UInt8 = 0x22
    
}


public struct HubidicDevice {
    public var manufacture:String?
    public var firmwareVersion:String?
    public var hardwareVersion:String?
    public var softwareVersion:String?
    public var serialNumber:String?
    public var password:String?
    public var userid:String?
    public var randomNum:String?
    public var uuid:String?
    public var selectedUserType:HubidicUserNo?
    
    public init(){
        
    }
    
}
public struct BloodPressData{
    public let measureDt:Date
    public let max:Int
    public let min:Int
    public let hr:Int
    public init(measureDt:Date, max:Int, min:Int, hr:Int){
        self.measureDt = measureDt
        self.max = max
        self.min = min
        self.hr = hr
    }
    
}



public protocol HubidicDelegate:class {
    func updated(state:HubidicState, data:String?, error:Error?)
//    func Hubidic(scannedDeviceList:[CBPeripheral])
    func hubidicScannedPeripherals(scannedPeripherals:[[PeripheralDictionaryKey:Any]])
}

public enum PeripheralDictionaryKey {
    case peripheral
    case localName
}
public enum HubidicError:Error {
    case noDeviceInfo
    
    var localizedDescription: String {
        get {
            switch self {
            case .noDeviceInfo:
                return "디바이스 UUID 정보가 없습니다."
            }
        }
    }
}

public enum HubidicState {
    
    case scanning
    case scanFinished
    case connected
    case connecting
    case connectFailed
    case disconecting
    case disconected
    
}

public enum HubidicUserNo:String{
    case userA = "A"
    case userB = "B"
    
    var value:[UInt8] {
        switch self {
        case .userA:
            return [0xa0,0xa0,0xa0,0xa0]
        case .userB:
            return [0xb0,0xb0,0xb0,0xb0]
            
        }
    }
    func getValueReversed() -> [UInt8] {
        return self.value.reversed()
        
    }
}
