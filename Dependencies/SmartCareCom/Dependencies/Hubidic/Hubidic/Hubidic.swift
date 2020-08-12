//
//  hubidic.swift
//  OpenApiSample
//
//  Created by philosys_macbook on 2020/07/09.
//  Copyright © 2020 thejoin. All rights reserved.
//

import Foundation
import CoreBluetooth

public class Hubidic: NSObject {
    
//    public static let shared = Hubidic()
    private let manager:CBCentralManager = CBCentralManager()
    private var activePeripheral:CBPeripheral?
    private var AppToDeviceCharacteristic:CBCharacteristic?
    private var DeviceToAppCharacteristic:CBCharacteristic?
    
    var scannedDeviceList: [[PeripheralDictionaryKey:Any]] = []
    private var connectUserFlag:Bool = false
    private var selectedUserType:HubidicUserNo?
    private var isPairingMode:Bool = false
    var state:HubidicState = .disconected
    
    weak var delegate:HubidicDelegate?
    
    var timer:Timer?
    let bpDataManager:BloodPressDataManager = BloodPressDataManager(deviceInfo: HubidicDevice())
    
    public init(user:HubidicUserNo?) {
        super.init()
        selectedUserType = user
        manager.delegate = self
        
    }
//    public func initManager(user:HubidicUserNo?){
//        manager =
//        selectedUserType = user
//        manager.delegate = self
        
//    }
    
    public func scanForDevice(){
        isPairingMode = true
        state = .scanning
        manager.scanForPeripherals(withServices: [CBUUID(string: HubidicUUID.serviceUUID)],
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)]) // RSSI read
        
        
//        delegate?.Hubidic(updatedState: state, data: nil, error: nil)
    }
    
    public func scanForKnownDevice(completion: ((HubidicError) -> Void)? = nil){
        
        guard let uuidString = bpDataManager.deviceInfo.uuid else {
            
//            completion(HubidicError.noDeviceInfo)
            return
        }
        guard let uuid = UUID(uuidString: uuidString) else {
//            completion(HubidicError.noDeviceInfo)
            return
        }
        isPairingMode = false
        state = .scanning
        manager.retrievePeripherals(withIdentifiers: [uuid])
    }
    
    func scanStop(){
        manager.stopScan()
    }
    
    func connectDevice(with peripheral:CBPeripheral){
        
        manager.connect(peripheral)
    }
    /*
     The pairing is finished after “[ ]” is shown on the display of the device. The App should store the Password, Model Name, Serial Number, Mac Address, etc for the next connection. The device will disconnected after getting Enable Disconnection Command.
     */
    func diconnectDevice(){
        
    }
    
    private func sendData(data:Data, characteristic:CBCharacteristic){
        
        activePeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    private func sendToDevice(with data:Data, characteristic: CBCharacteristic){
            
        
        activePeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        
    }
        
    private func sendAccountID(with characteristic: CBCharacteristic){
        HubidicDebugManager.log("sendAccountID")

        
        guard let value = selectedUserType?.getValueReversed() else {
            
            // usertype이 nil 즉, all일 때
            let accountInfo:[UInt8] = [HubidicCommand.accountId,0x4B,0x09,0xDF,0x78]
            let data = Data(accountInfo)
            sendData(data: data, characteristic: characteristic)
            
            return
            
        }
        var accountId = [HubidicCommand.accountId]
        accountId.append(contentsOf: value)
        let data = Data(accountId)
        
        sendData(data: data, characteristic: characteristic)
    }
    
    private func setTime(){
        
        // HuBDIC에서 정의한 기준시간 : 2010/01/01 00:00:00
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyyMMdd"
        guard let baseDate = dateformatter.date(from: "20100101") else { return }
        let diff = Calendar.current.dateComponents([.day, .hour, .minute,.second], from: baseDate, to: Date())
        
        let day:Int = diff.day! * 24 * 60 * 60
        let hour:Int = diff.hour! * 60 * 60
        let minute:Int = diff.minute! * 60
        let sec:Int = diff.second!
        let offset:Int = day + hour + minute + sec
        print("offSet TimeStamp : \(offset)")
        let offsetData = withUnsafeBytes(of: offset.littleEndian) { Data($0) }
        var offsetByte:[UInt8] = offsetData.map { $0 }
        offsetByte.removeSubrange(4...offsetData.count - 1)
//        let offsetByte:[UInt8] = offsetData.withUnsafeBytes{
//            [UInt8](UnsafeBufferPointer(start: $0, count: offsetData.count))
//        }
        var result:[UInt8] = []
        result.append(HubidicCommand.setTime)
        result.append(contentsOf: offsetByte)
        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
        let resultOffset = Data(result)
        sendToDevice(with: resultOffset, characteristic: AppToDeviceCharacteristic)
        
        print("App >>> \(String(format: "%02x %02x %02x %02x %02x", resultOffset[0],resultOffset[1],resultOffset[2],resultOffset[3],resultOffset[4]))")
        HubidicDebugManager.log("set Time")
        
    }
    private func enableDisconnect(){
        
        let disconnect:[UInt8] = [HubidicCommand.enableDisconnection]
        let disconnectData = Data(disconnect)
        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
        sendToDevice(with: disconnectData, characteristic: AppToDeviceCharacteristic)
        HubidicDebugManager.log("enableDisconnect")
    }
    
    private func readValue(serviceUUIDString:String, characteristicUUID:String, peripheral:CBPeripheral){
        guard let s = findServiceFromUUID(serviceUUIDString: serviceUUIDString, peripheral: peripheral) else {
            HubidicDebugManager.log("error findServiceFromUUID", type: .error)
            return
            
        }
        guard let c = findCharacteristicFromUUID(characteristicUUID: characteristicUUID, service: s) else {
            HubidicDebugManager.log("error findCharacteristicFromUUID", type: .error)
            return
            
        }
        peripheral.readValue(for: c)
    }
    
    private func findServiceFromUUID(serviceUUIDString:String, peripheral:CBPeripheral) -> CBService? {
        guard let services = peripheral.services else { return nil }
        for service in services {
            if let name = peripheral.name, name.contains(HubidicUUID.deviceName) {
                if service.uuid.uuidString == serviceUUIDString {
                    return service
                }
            }
        }
        return nil
    }
    
    private func findCharacteristicFromUUID(characteristicUUID:String, service:CBService) ->CBCharacteristic?{
        guard let characteristics = service.characteristics else { return nil }
        for characteristic in characteristics {
            if characteristic.uuid.uuidString == characteristicUUID {
                return characteristic
            }
        }
        return nil
        
    }
    
    private func readDeviceInformation(){
        
        guard let p = self.activePeripheral else { return}
        readValue(serviceUUIDString: HubidicUUID.DeviceInformation_Service,
                  characteristicUUID: HubidicUUID.SerialNumber_Char,
                  peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.DeviceInformation_Service,
                  characteristicUUID: HubidicUUID.FirmwareRevisionString_Char,
                  peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.DeviceInformation_Service,
                  characteristicUUID: HubidicUUID.HardwareRevisionString_Char,
                  peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.DeviceInformation_Service,
                  characteristicUUID: HubidicUUID.SoftwareRevisionString_Char,
                  peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.DeviceInformation_Service,
                  characteristicUUID: HubidicUUID.ManufacturerNameString_Char,
                  peripheral: p)
        HubidicDebugManager.log("readDeviceInformation ok")
        
        
    }
}
extension Hubidic: CBPeripheralDelegate {
    
    //#1
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices \(error.debugDescription)")
        guard let services = peripheral.services else { return }
        
        // 서비스 3개, 각 서비스당 복수개의 Characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    // noti값이 잘 변경되었는지 확인하는 델리게이트.
    // 잘 변경 안되었으면 error 가 나올 것임.
    // 여기서 정보를 던져야 하는 특성(characteristic)을 저장한다.
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor \(characteristic) ")
        
        if characteristic.uuid.uuidString == HubidicUUID.BloodPressureWrite_Char {
            AppToDeviceCharacteristic = characteristic
        } else if characteristic.uuid.uuidString == HubidicUUID.BloodPressureIndicateInfo_Char {
            DeviceToAppCharacteristic = characteristic
            
        }
        
        
        
    }
    //#2
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            
        } else {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics {
                let chartUUID = characteristic.uuid
                
                switch chartUUID.uuidString {
                
                case HubidicUUID.BloodPressureWrite_Char:
                    peripheral.setNotifyValue(true, for: characteristic)
                case HubidicUUID.BloodPressureIndicateInfo_Char:
                    peripheral.setNotifyValue(true, for: characteristic)
                
                case HubidicUUID.BloodPressureIndicateMeasure_Char:
                    peripheral.setNotifyValue(true, for: characteristic)
                
                default:
                    
                    peripheral.discoverDescriptors(for: characteristic)
                    
                }
            }

        }
        
                
        
        
    }
    //peripheral found descriptors for a characteristic.
    //주변장치
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            
        } else {
            
            if let s = peripheral.services?.last,
                let c = s.characteristics?.last,
                c.uuid.uuidString == characteristic.uuid.uuidString {
                if isPairingMode {
                    readDeviceInformation()
                }

            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            
        } else {
            let chartUUID = characteristic.uuid
            guard let data = characteristic.value else { return }
            
            if isPairingMode {
                print("chartUUID String : \(chartUUID.uuidString)")
                switch chartUUID.uuidString {
                case HubidicUUID.ManufacturerNameString_Char:
                    
                    let manufacturerName = String(data: data, encoding: .utf8)
                    
                    bpDataManager.deviceInfo.manufacture = manufacturerName
                case HubidicUUID.FirmwareRevisionString_Char:
                    
                    let firmwareVersion = String(data: data, encoding: .utf8)
                    bpDataManager.deviceInfo.firmwareVersion = firmwareVersion
                    
                case HubidicUUID.SoftwareRevisionString_Char:
                    
                    let softwareVersion = String(data: data, encoding: .utf8)
                    bpDataManager.deviceInfo.softwareVersion = softwareVersion
                    
                case HubidicUUID.SerialNumber_Char:
                    
                    let serialNumber = String(data: data, encoding: .utf8)
                    bpDataManager.deviceInfo.serialNumber = String(data: data, encoding: .utf8)
                case HubidicUUID.HardwareRevisionString_Char:
                    
                    let hardwareVersion = String(data: data, encoding: .utf8)
                    bpDataManager.deviceInfo.hardwareVersion = String(data: data, encoding: .utf8)
                case HubidicUUID.BloodPressureIndicateInfo_Char:
                    let command:UInt8 = data[0]
                    print("command : \(String(format: "%02x", command))")
                    
                    switch command {
                    case HubidicCommand.password:
                        let password:[UInt8] = data.subdata(in: 1..<5).map{ $0 }.reversed()
                        let passwordString = password.map{String(format: "%02x", $0)}.joined(separator: " ")
                        print("APP >>> (password)\(passwordString)")
                        bpDataManager.deviceInfo.password = passwordString
                        
                        
                        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
                        sendAccountID(with: AppToDeviceCharacteristic)

                        //set account Id
                    case HubidicCommand.randomNumber:

                        let randomNumber:[UInt8] = data.subdata(in: 1..<5).map{ $0 }.reversed()
                        let randomNumberString = randomNumber.map{String(format: "%02x", $0)}.joined(separator: " ")
                        print("DEVICE <<< (random) : \(randomNumberString)")
                        bpDataManager.deviceInfo.randomNum = randomNumberString
                        
                        //set verification Code
                        guard let password = bpDataManager.deviceInfo.password else {
                            print("🟥 get password error")
                            return
                            
                        }
                        print("🟩get password from deviceInfo \(password)")
                        let passwordArray = password.split(separator: " ").map{$0.hexaBytes}.flatMap{$0}
                        let verification:[UInt8] = [HubidicCommand.verification,
                                                    passwordArray[3]^randomNumber[3],
                                                    passwordArray[2]^randomNumber[2],
                                                    passwordArray[1]^randomNumber[1],
                                                    passwordArray[0]^randomNumber[0]
                        ]
                        
                        print("App >>> \(verification)")
                        //set verification
                        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
                        sendToDevice(with: Data(verification), characteristic: AppToDeviceCharacteristic)
                    case HubidicCommand.userName:
                        //get UserInfo
                        let user:HubidicUserNo
                        if data[1] == 0x01 {
                            if connectUserFlag == false {
                                connectUserFlag = true
                                user = .userA
                            } else {
                                user = .userB
                            }
                        } else {
                            user = .userB
                        }
                        HubidicDebugManager.log("🟩get userInfo \(user.self)")
                        

                        let userNumberByte = data[1]
                        let userNameData = data.subdata(in: 2..<(data.count - 2))
                        let userNameByte:[UInt8] = userNameData.map { $0 }

                        // set UserInfo (connect User)
                        HubidicDebugManager.log("🟩set UserInfo (connect User)")
                        var userInfo = [HubidicCommand.connectUser]
                        userInfo.append(userNumberByte)
                        userInfo.append(contentsOf: userNameByte)

                        let userInfoData = Data(userInfo)

                        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
                        sendToDevice(with: userInfoData, characteristic: AppToDeviceCharacteristic)
                        //set Time
                        setTime()
                        enableDisconnect()
//                        readDeviceInformation()
                        
                    case HubidicCommand.timeOffset:
                        print("🟪timeoffset")
    //                    enableDisconnect()
                        break
                    default:
                        break
                    }
                default:
                
                break
                }
            } else {
                switch chartUUID.uuidString {
                case HubidicUUID.BloodPressureIndicateInfo_Char:
                    let command:UInt8 = data[0]
                    print("command : \(String(format: "%02x", command))")
                    HubidicDebugManager.log("command : \(String(format: "%02x", command))")

                    switch command {
                        case HubidicCommand.randomNumber:
                        // get random
                        // get password
                        
                        let randomNumber:[UInt8] = data.subdata(in: 1..<5).map{ $0 }.reversed()
                        let randomNumberString = randomNumber.map{String(format: "%02x", $0)}.joined(separator: " ")
                        print("DEVICE <<< (random) : \(randomNumberString)")
                        bpDataManager.deviceInfo.randomNum = randomNumberString
                        
                        //set verification Code
                        guard let password = bpDataManager.deviceInfo.password else {
                            HubidicDebugManager.log("get password error", type: .error)
                            return
                            
                        }
                        print("🟩get password from bpDataManager.deviceInfo \(password)")
                        let passwordArray = password.split(separator: " ").map{$0.hexaBytes}.flatMap{$0}
                        let verification:[UInt8] = [HubidicCommand.verification,
                                                    passwordArray[3]^randomNumber[3],
                                                    passwordArray[2]^randomNumber[2],
                                                    passwordArray[1]^randomNumber[1],
                                                    passwordArray[0]^randomNumber[0]
                        ]
                        
                        print("App >>> \(verification)")
                        //set verification
                        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
                        sendToDevice(with: Data(verification), characteristic: AppToDeviceCharacteristic)
                        //
                        setTime()

                    default:
                        break
                    }
                case HubidicUUID.BloodPressureIndicateMeasure_Char:

                    guard data.count > 14 else { return }
                    
                    let sys:[UInt32] = data.subdata(in: 1..<3).map{UInt32($0)}.reversed()
                    let sysValue = sys[1] << 0 | sys[0] << 8
                    
                    let dia:[UInt32] = data.subdata(in: 3..<5).map{UInt32($0)}.reversed()
                    let diaValue = dia[1] << 0 | dia[0] << 8
//
                    let hr:[UInt32] = data.subdata(in: 11..<13).map{UInt32($0)}.reversed()
                    let hrValue = hr[1] << 0 | hr[0] << 8
                    
                    let time:[UInt32] = data.subdata(in: 7..<11).map{UInt32($0)}
                    
                    let timeStamp = time[3] << 24 | time[2] << 16 | time[1] << 8 | time[0] << 0
                    print(timeStamp)
//
                    
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyyMMdd"
                    guard let baseDate = dateformatter.date(from: "20100101") else {
                        
                        return
                        
                    }
                    
                    let dateFromTimestamp = Date(timeInterval: TimeInterval(timeStamp), since: baseDate)
                    
                    let bpData = BloodPressData(measureDt: dateFromTimestamp,
                                                max: Int(sysValue),
                                                min: Int(diaValue),
                                                hr: Int(hrValue))
                    print(bpData)
                    
                    bpDataManager.intoArray(data: bpData)
                    
                    
                default:
                    break
                }
            }
//            data.copyBytes(to: &byte, count: 1)
            
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor \(characteristic.uuid.uuidString)")
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let chartUUID = characteristic.uuid
            guard let data = characteristic.value else { return }

//            data.copyBytes(to: &byte, count: 1)
            print("🟪chartUUID String : \(chartUUID.uuidString)")
            switch chartUUID.uuidString {
                case HubidicUUID.BloodPressureWrite_Char:
                let command:UInt8 = data[0]
                print("command : \(String(format: "%02x", command))")

                switch command {
                   
                    case HubidicCommand.timeOffset:
                        print("🟪timeoffset")
                        enableDisconnect()
                        break
                    default:
                        break
                }
            default:
                break
            }

        }
    }
}
    
    

extension Hubidic: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            break
        @unknown default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // ios bluetooth sdk는 peripheral localname을 캐싱하고 있어, 이름이 변하지 않도록 하고있음.
        // 해결방법은 아래와 같이 파싱하여 대신사용
        guard let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        print(advertisementData)
        print(localName)
        
        //if 11585B
        if localName.contains(HubidicUUID.deviceName) {
            
//            isPairingMode = localName[localName.startIndex] == "0" ? false : true
            print("✅ isPairingMode \(isPairingMode)")
            let dict : [PeripheralDictionaryKey : Any] = [.peripheral : peripheral, .localName : localName]
            
            scannedDeviceList.append(dict)
            
//            delegate?.hubidicScannedPeripherals(scannedPeripherals: scannedDeviceList)
            
        }
        // delegate.send(scannedDeviceList)
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect")
        state = .connected
        activePeripheral = peripheral
        activePeripheral?.delegate = self
        
//        guard let services = peripheral.services else { return }
        
        activePeripheral?.discoverServices(nil)
        
//        delegate?.Hubidic(updatedState: state, data: nil, error: nil)
    }

    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error.debugDescription)
        state = .connectFailed
        //delegate.state(state)
    }
    
    
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
