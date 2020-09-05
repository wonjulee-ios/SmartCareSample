//
//  BloodPressManager.swift
//  SmartCareCom
//
//  Created by philosys_macbook on 2020/08/12.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import Hubidic
import CoreData

import CoreBluetooth
/**
 구현단계에서 사용할 델리게이트

*/
extension SmartCareCom {
    public enum ScanViewDictionrayKey{
        case deviceName
        case rssi
        case uuidSrting
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
    
    public enum BloodPressManagerState{
        
        case scanning
        case scanFinished
        case connected
        case connecting
        case connectFailed
        case disconecting
        case disconected
        
    }


}


public protocol BloodPressManageDelegate:AnyObject {
    func updated(state: SmartCareCom.BloodPressManagerState, data: String?)
    
    func scannedPeripherals(scannedPeripherals: [[SmartCareCom.ScanViewDictionrayKey : Any]])
    
    func sync(with bpData:[SmartCareCom.BloodPressData])
}
public protocol BloodPressDatabaseUpdatable:AnyObject {
     func updateData(connected:Bool?, deviceName: String, fwver:String?, password:String?, selected:Bool?, usertype:String?, uuidString:String?)
    
}
extension DataController:BloodPressDatabaseUpdatable {
    public func updateData(connected: Bool? = nil, deviceName: String, fwver: String? = nil, password: String? = nil, selected: Bool? = nil, usertype: String? = nil, uuidString: String? = nil) {
        let request: NSFetchRequest<BloodpressDevice> = BloodpressDevice.fetchRequest()
        request.predicate = NSPredicate(format: "deviceName = %@", deviceName)
        
        guard let entity = self.fetch(request: request).last else { return }
        
        if let connected = connected {
            entity.connected = connected
        }
        
        if let fwver = fwver {
            entity.fwver = fwver
        }
        
        if let password = password {
            entity.password = password
        }
        
        if let selected = selected {
            entity.selected = selected
        }
        
        if let usertype = usertype {
            entity.usertype = usertype
        }
        
        if let uuidString = uuidString {
            entity.uuidString = uuidString
        }
        HubidicDebugManager.log(entity)
        commit()
    }
    
}
public class BloodPressManager:DeviceManaging{
    
    public weak var delegate:BloodPressManageDelegate?
    public var selectedDevice: BleDeviceDataSource?
    public let dataController:BloodPressDatabaseUpdatable & DataControllerDataSource
    /**
    hubidic 또는 AnD 오브젝트를 사용할 것인지 정하기 위해서 사용함.

    */
    public enum DeviceType {
        case Hubidic
        case AnD
    }
    
    init() {
        dataController = DataController()
        // 초기화 데이터가 없으면, 초기화 데이터 생성할 것
        if fetchData().isEmpty {
            
            dataController.initData { (result) in
                if result {
                    HubidicDebugManager.log("혈압기기관리 데이터테이블 초기화 성공!")
                }
            }
        }
        
        
    }
    

    @discardableResult
    public func fetchData(deviceType:BloodPressManager.DeviceType? = nil) -> [NSManagedObject] {
        let request: NSFetchRequest<BloodpressDevice> = BloodpressDevice.fetchRequest()
        guard let deviceType = deviceType else {
            return dataController.fetch(request: request)
        }
        request.predicate = NSPredicate(format: "deviceName = %@", "\(deviceType.self)")
        return dataController.fetch(request: request)
    }
    
    
}
//MARK: Hubidic Delegate
extension BloodPressManager:HubidicDelegate{
    public func updated(state: HubidicState, data: String?, error: Error?) {
        
        switch state {
        case .connectFailed:
            delegate?.updated(state: .connectFailed, data: data)
        default:
            break
        }
        
    }
    
    public func hubidicScannedPeripherals(scannedPeripherals: [[PeripheralDictionaryKey : Any]]) {
        
        var dictArray:[[SmartCareCom.ScanViewDictionrayKey:Any]] = []
        for i in scannedPeripherals {
            guard let object:CBPeripheral = i[.peripheral] as? CBPeripheral else { return }
            guard let localName:String = i[.localName] as? String else { return }
            guard let rssi:NSNumber = i[.rssi] as? NSNumber else { return }
            let dict:[SmartCareCom.ScanViewDictionrayKey:Any] = [.deviceName:localName,.uuidSrting:object.identifier.uuidString, .rssi:rssi.stringValue]
            dictArray.append(dict)
        }
        delegate?.scannedPeripherals(scannedPeripherals: dictArray)
    }
    
    
}
//MARK: HubidicDataManager Delegate
extension BloodPressManager:HubidicDataSyncDelegate{
    
    public func HubidicDeviceInfo(info: HubidicDevice) {
        dataController.updateData(connected: true, deviceName: "Hubidic", fwver: info.firmwareVersion, password: info.password, selected: true, usertype: "\(info.selectedUserType.self)", uuidString: info.uuid)
    }
    
    public func sync(dataList: [BloodPressData]) {
        
        HubidicDebugManager.log(dataList)
        let data:[SmartCareCom.BloodPressData] = dataList.map{SmartCareCom.BloodPressData(measureDt: $0.measureDt, max: $0.max, min: $0.min, hr: $0.hr)}
        delegate?.sync(with: data)
    }
}


extension BloodPressManager:BloodPressDeviceSelectable{
    public func select(to deviceType: BloodPressManager.DeviceType) {
        HubidicDebugManager.log("\(deviceType.self)")
        if deviceType == .Hubidic {
            if let object = selectedDevice as? Hubidic {
                return
            } else {
                selectedDevice = nil
            }
            
            guard let dbInfo = fetchData(deviceType: .Hubidic) as? [BloodpressDevice], dbInfo.count == 1 else { return }
            
            var info = HubidicDevice()
            info.firmwareVersion = dbInfo[0].fwver
            info.password = dbInfo[0].password
            info.selectedUserType = HubidicUserNo(rawValue: dbInfo[0].usertype ?? "")
            info.uuid = dbInfo[0].uuidString
            
            let object = Hubidic(deviceInfo: info)
            object.delegate = self //HubidicDelegate
//            object.bpDataManager.delegate = self //HubidicDataSyncDelegate
            selectedDevice = object
            
        } else {
            
        }

    }
}


extension Hubidic:BleDeviceDataSource{
    public func bleScanDevice() {
        
        self.scanForDevice()
    }
    
    public func bleConnect() {
        
    }
    
    public func bleDisconnect() {
        
    }
    
    public func bleScanConnectedDevice() {
        self.scanForKnownDevice {[weak self] (e) in
            self?.delegate?.updated(state: .connectFailed, data: "", error: e)
        }
    }
    
    public func bleStopScan() {
        
        self.scanStop()
    }
    
}

extension Hubidic:DeviceDataSource{
    public var name: String {
        get {
            return self.name
        }
        set {
            name = newValue
        }
    }
}
