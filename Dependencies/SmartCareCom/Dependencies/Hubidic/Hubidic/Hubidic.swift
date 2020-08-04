//
//  hubidic.swift
//  OpenApiSample
//
//  Created by philosys_macbook on 2020/07/09.
//  Copyright © 2020 thejoin. All rights reserved.
//

import Foundation
import CoreBluetooth

struct HubidicUUID {
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

struct HubidicCommand {
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

enum HubidicState {
    
    case scanning
    case scanFinished
    case connected
    case connecting
    case connectFailed
    case disconecting
    case disconected
    
}

enum HubidicUserNo{
    case userA
    case userB
    
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

struct HubidicDevice {
    var manufacture:String?
    var firmwareVersion:String?
    var hardwareVersion:String?
    var softwareVersion:String?
    var serialNumber:String?
    var password:String?
    var userid:String?
    var randomNum:String?
//    var
    
}
struct BloodPressData{
    let measureDt:Date
    let max:Int
    let min:Int
    let hr:Int
}

protocol BloodPressDataSyncDelegate:class {
    func sync(dataList:[BloodPressData])
}

class BloodPressDataManager{
    weak var delegate:BloodPressDataSyncDelegate?
    var bpDataList:[BloodPressData] = []
    var deviceInfo:HubidicDevice //BloodPressDataManager
    var timer:Timer?
    
    init(deviceInfo:HubidicDevice) {
        self.deviceInfo = deviceInfo
    }
    func intoArray(data:BloodPressData){
        timerOn()
        bpDataList.append(data)
    }
    
    @objc private func sync(){
        print("✅ data sync")
        print(bpDataList)
        delegate?.sync(dataList: bpDataList)
    }
    
    func timerOn(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(sync), userInfo: nil, repeats: false)
    }
    
}

class HubidicBleManager{
    

    
}
protocol HubidicDelegate:class {
    func updated(state:HubidicState, data:String?, error:Error?)
//    func Hubidic(scannedDeviceList:[CBPeripheral])
}
class Hubidic: NSObject {
    
    static let shared = Hubidic()
    let manager:CBCentralManager = CBCentralManager()
    var activePeripheral:CBPeripheral?
    var AppToDeviceCharacteristic:CBCharacteristic?
    var DeviceToAppCharacteristic:CBCharacteristic?
    
    var scannedDeviceList: [CBPeripheral] = []
    var connectUserFlag:Bool = false
    var selectedUserType:HubidicUserNo?
    var isPairingMode:Bool = false
    var state:HubidicState = .disconected
    
    weak var delegate:HubidicDelegate?
    
    var timer:Timer?
    let bpDataManager:BloodPressDataManager = BloodPressDataManager(deviceInfo: HubidicDevice())
    func initManager(user:HubidicUserNo?){
//        manager =
        selectedUserType = user
        manager.delegate = self
        
    }
    
    public func scanForDevice(){
        state = .scanning
        manager.scanForPeripherals(withServices: [CBUUID(string: HubidicUUID.serviceUUID)])
//        delegate?.Hubidic(updatedState: state, data: nil, error: nil)
    }
    
    public func scanForKnownDevice(){
        state = .scanning
        manager.retrieveConnectedPeripherals(withServices: [CBUUID(string: HubidicUUID.serviceUUID)])
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
    
    func sendData(data:Data, characteristic:CBCharacteristic){
        
        activePeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func sendToDevice(with data:Data, characteristic: CBCharacteristic){
            
        
        activePeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        
    }
        
    func sendAccountID(with characteristic: CBCharacteristic){
        print("set Account ID")

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
    
    func setTime(){
        
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
        print("🟩 set Time")
        
    }
    func enableDisconnect(){
        
        let disconnect:[UInt8] = [HubidicCommand.enableDisconnection]
        let disconnectData = Data(disconnect)
        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
        sendToDevice(with: disconnectData, characteristic: AppToDeviceCharacteristic)
        print("🟩 enableDisconnect")
    }
    
    func readValue(serviceUUIDString:String, characteristicUUID:String, peripheral:CBPeripheral){
        guard let s = findServiceFromUUID(serviceUUIDString: serviceUUIDString, peripheral: peripheral) else {
            print("❌ error findServiceFromUUID")
            return
            
        }
        guard let c = findCharacteristicFromUUID(characteristicUUID: characteristicUUID, service: s) else {
            print("❌ error findCharacteristicFromUUID")
            return
            
        }
        peripheral.readValue(for: c)
    }
    
    func findServiceFromUUID(serviceUUIDString:String, peripheral:CBPeripheral) -> CBService? {
        guard let services = peripheral.services else { return nil }
        for service in services {
            if let name = peripheral.name, name.contains(HubidicUUID.deviceName) {
                return service
            } else if service.uuid.uuidString == serviceUUIDString {
                return service
            }
        }
        return nil
    }
    
    func findCharacteristicFromUUID(characteristicUUID:String, service:CBService) ->CBCharacteristic?{
        guard let characteristics = service.characteristics else { return nil }
        for characteristic in characteristics {
            if characteristic.uuid.uuidString == characteristicUUID {
                return characteristic
            }
        }
        return nil
        
    }
    
    func readDeviceInformation(){
        
        guard let p = self.activePeripheral else { return}
        readValue(serviceUUIDString: HubidicUUID.serviceUUID, characteristicUUID: HubidicUUID.SerialNumber_Char, peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.serviceUUID, characteristicUUID: HubidicUUID.FirmwareRevisionString_Char, peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.serviceUUID, characteristicUUID: HubidicUUID.HardwareRevisionString_Char, peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.serviceUUID, characteristicUUID: HubidicUUID.SoftwareRevisionString_Char, peripheral: p)
        readValue(serviceUUIDString: HubidicUUID.serviceUUID, characteristicUUID: HubidicUUID.ManufacturerNameString_Char, peripheral: p)
        
    }
}
extension Hubidic: CBPeripheralDelegate {
    
    //#1
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor \(characteristic) ")
        
        if characteristic.uuid.uuidString == HubidicUUID.BloodPressureWrite_Char {
            AppToDeviceCharacteristic = characteristic
        } else if characteristic.uuid.uuidString == HubidicUUID.BloodPressureIndicateInfo_Char {
            DeviceToAppCharacteristic = characteristic
            
        }
        
        
        
    }
    //#2
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            
        } else {
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics {
                let chartUUID = characteristic.uuid
                print("didDiscoverCharacteristicsFor : \(chartUUID.uuidString)")
                
                switch chartUUID.uuidString {
                
                case HubidicUUID.BloodPressureWrite_Char:
                    peripheral.setNotifyValue(true, for: characteristic) // 특성에 대한 구독하기.
//                    // notify값이 true로 하면, 데이터가 변경되면 central쪽으로 데이터를 전송한다.
//
                    
                
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
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsFor characteristic\(characteristic.uuid.uuidString)")
        if let err = error {
            
        } else {
            
//            guard let data = characteristic.value else { return }
//            print("didDiscoverDescriptorsFor : \(characteristic.uuid.uuidString) \(data)")
//            switch characteristic.uuid.uuidString {
//            case HubidicUUID.ManufacturerNameString_Char:
//
//                activePeripheral?.readValue(for: characteristic)
//
//            case HubidicUUID.FirmwareRevisionString_Char:
//                activePeripheral?.readValue(for: characteristic)
//
//            case HubidicUUID.SoftwareRevisionString_Char:
//                activePeripheral?.readValue(for: characteristic)
//
//            case HubidicUUID.SerialNumber_Char:
//                activePeripheral?.readValue(for: characteristic)
//            case HubidicUUID.HardwareRevisionString_Char:
//                activePeripheral?.readValue(for: characteristic)
//            default:
//                break
//            }
            
            
            if let s = peripheral.services?.last,
                let c = s.characteristics?.last,
                c.uuid.uuidString == characteristic.uuid.uuidString {
                readDeviceInformation()

            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("✅ didUpdateValueFor \(characteristic)")
        print(activePeripheral)
        if let error = error {
            
        } else {
            let chartUUID = characteristic.uuid
            guard let data = characteristic.value else { return }
            
            if isPairingMode {
                print("chartUUID String : \(chartUUID.uuidString)")
                switch chartUUID.uuidString {
                case HubidicUUID.ManufacturerNameString_Char:
                    
                    let manufacturerName = String(data: data, encoding: .utf8)
                    print("ManufacturerName : \(manufacturerName)")
                    bpDataManager.deviceInfo.manufacture = manufacturerName
                case HubidicUUID.FirmwareRevisionString_Char:
                    
                    let firmwareVersion = String(data: data, encoding: .utf8)
                    print("firmwareVersion : \(firmwareVersion)")
                    bpDataManager.deviceInfo.firmwareVersion = firmwareVersion
                    
                case HubidicUUID.SoftwareRevisionString_Char:
                    
                    let softwareVersion = String(data: data, encoding: .utf8)
                    print("softwareVersion : \(softwareVersion)")
                    bpDataManager.deviceInfo.softwareVersion = softwareVersion
                    
                case HubidicUUID.SerialNumber_Char:
                    
                    let serialNumber = String(data: data, encoding: .utf8)
                    print("serialNumber : \(serialNumber)")
                    bpDataManager.deviceInfo.serialNumber = String(data: data, encoding: .utf8)
                case HubidicUUID.HardwareRevisionString_Char:
                    
                    let hardwareVersion = String(data: data, encoding: .utf8)
                    print("hardwareVersion : \(hardwareVersion)")
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
                        
                        print("🟩get userInfo \(user.self)")

                        let userNumberByte = data[1]
                        let userNameData = data.subdata(in: 2..<(data.count - 2))
                        let userNameByte:[UInt8] = userNameData.map { $0 }

                        // set UserInfo (connect User)
                        print("🟩set UserInfo (connect User)")
                        var userInfo = [HubidicCommand.connectUser]
                        userInfo.append(userNumberByte)
                        userInfo.append(contentsOf: userNameByte)

                        let userInfoData = Data(userInfo)

                        guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
                        sendToDevice(with: userInfoData, characteristic: AppToDeviceCharacteristic)
                        //set Time
                        setTime()
                        enableDisconnect()
                        readDeviceInformation()
                        
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
                            print("🟥 get password error")
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
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
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
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // ios bluetooth sdk는 peripheral localname을 캐싱하고 있어, 이름이 변하지 않도록 하고있음.
        // 해결방법은 아래와 같이 파싱하여 대신사용
        guard let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        print(advertisementData)
        print(localName)
        
        //if 11585B
        if localName.contains(HubidicUUID.deviceName) {
            
            if peripheral.state == .connected {
                state = .connected
            } else {
                
                isPairingMode = localName[localName.startIndex] == "0" ? false : true
                print("✅ isPairingMode \(isPairingMode)")
                scannedDeviceList.append(peripheral)
                delegate?.updated(state: .scanFinished, data: nil, error: nil)

            }
        }
        // delegate.send(scannedDeviceList)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect")
        state = .connected
        activePeripheral = peripheral
        activePeripheral?.delegate = self
        
//        guard let services = peripheral.services else { return }
        
        activePeripheral?.discoverServices(nil)
        
//        delegate?.Hubidic(updatedState: state, data: nil, error: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
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
