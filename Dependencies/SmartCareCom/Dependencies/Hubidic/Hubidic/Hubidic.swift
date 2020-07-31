//
//  Hubidic.swift
//  Hubidic
//
//  Created by philosys_macbook on 2020/07/31.
//  Copyright © 2020 philosys. All rights reserved.
//

import CoreBluetooth

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

public enum HubidicState {
    
    case scanning
    case scanFinished
    case connected
    case connecting
    case connectFailed
    case disconecting
    case disconected
    
}

public enum HubidicUserNo{
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

public struct HubidicDevice {
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

public protocol HubidicDelegate:class {
    func updated(state:HubidicState, data:String?, error:Error?)
//    func Hubidic(scannedDeviceList:[CBPeripheral])
}
public class HubidicTest {
    public init() {}
    
    public func logText(txt: String){
        print(" >>> \(txt)")
    }
}
public class Hubidic: NSObject {
    
    public static let shared = Hubidic()
    var manager:CBCentralManager = CBCentralManager()
    public var scannedDeviceList: [CBPeripheral] = []
    var connectUserFlag:Bool = false
    var selectedUserType:HubidicUserNo?
    private var activePeripheral:CBPeripheral?
//    private var writeCharacteristic:CBCharacteristic?
    private var AppToDeviceCharacteristic:CBCharacteristic?
    private var DeviceToAppCharacteristic:CBCharacteristic?
    
    var state:HubidicState = .disconected
    var delegate:HubidicDelegate?
    var deviceInfo:HubidicDevice = HubidicDevice()
    
    public func initManager(user:HubidicUserNo?){
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
    
    public func scanStop(){
        manager.stopScan()
    }
    
    public func connectDevice(with peripheral:CBPeripheral){
        
        manager.connect(peripheral)
    }
    /*
     The pairing is finished after “[ ]” is shown on the display of the device. The App should store the Password, Model Name, Serial Number, Mac Address, etc for the next connection. The device will disconnected after getting Enable Disconnection Command.
     */
    public func diconnectDevice(){
        
    }
    
    func sendData(data:Data, characteristic:CBCharacteristic){
        
        activePeripheral?.writeValue(data, for: characteristic, type: .withResponse)
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
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            
        } else {
//            if let s = peripheral.services?.last,
//                let c = s.characteristics?.last,
//                c.uuid.uuidString == characteristic.uuid.uuidString {
//                activePeripheral?.readValue(for: characteristic)
//                manager.
//            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor \(characteristic)")
        print(activePeripheral)
        if let error = error {
            
        } else {
            let chartUUID = characteristic.uuid
            guard let data = characteristic.value else { return }
            
//            data.copyBytes(to: &byte, count: 1)
            print("chartUUID String : \(chartUUID.uuidString)")
            switch chartUUID.uuidString {
            case HubidicUUID.ManufacturerNameString_Char:
                deviceInfo.manufacture = String(data: data, encoding: .utf8)
                
            case HubidicUUID.FirmwareRevisionString_Char:
                deviceInfo.firmwareVersion = String(data: data, encoding: .utf8)
                
            case HubidicUUID.SoftwareRevisionString_Char:
                deviceInfo.softwareVersion = String(data: data, encoding: .utf8)
                
            case HubidicUUID.SerialNumber_Char:
                deviceInfo.serialNumber = String(data: data, encoding: .utf8)
            
            case HubidicUUID.BloodPressureIndicateInfo_Char:
                let command:UInt8 = data[0]
                print("command : \(String(format: "%02x", command))")
                
                switch command {
                case HubidicCommand.password:
                    let password:[UInt8] = data.subdata(in: 1..<5).map{ $0 }.reversed()
                    let passwordString = password.map{String(format: "%02x", $0)}.joined(separator: " ")
                    print("APP >>> (password)\(passwordString)")
                    deviceInfo.password = passwordString
                    
                    
                    guard let AppToDeviceCharacteristic = AppToDeviceCharacteristic else { return }
                    sendAccountID(with: AppToDeviceCharacteristic)

                    //set account Id
                case HubidicCommand.randomNumber:
                    //get randomNumber
//                    var randomNumber:[UInt8] = []
//                    randomNumber.append(data[4])
//                    randomNumber.append(data[3])
//                    randomNumber.append(data[2])
//                    randomNumber.append(data[1])
                    let randomNumber:[UInt8] = data.subdata(in: 1..<5).map{ $0 }.reversed()
                    let randomNumberString = randomNumber.map{String(format: "%02x", $0)}.joined(separator: " ")
                    print("DEVICE <<< (random) : \(randomNumberString)")
                    deviceInfo.randomNum = randomNumberString
                    
                    //set verification Code
                    guard let password = deviceInfo.password else {
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
                    if #available(iOS 10.0, *) {
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) {[weak self] _ in
                            self?.enableDisconnect()
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                    
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
        let diff = Calendar.current.dateComponents([.day, .hour], from: baseDate, to: Date())
        
        let day:Int = diff.day! * 24 * 60 * 60
        let hour:Int = diff.hour! * 24 * 60
        let offset:Int = day + hour
        
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
        print("centralManager didDiscover")
        
        print(peripheral.name)
        //if 11585B
        if let name = peripheral.name, name.contains(HubidicUUID.deviceName) {
            if peripheral.state == .connected {
                state = .connected
            } else {
//                if scannedDeviceList.compactMap{$0.name}.filter({$0 == name}).isEmpty {
//                    scannedDeviceList.append(peripheral)
//                    delegate?.updated(state: .scanFinished, data: nil, error: nil)
//                }
                scannedDeviceList.append(peripheral)
                delegate?.updated(state: .scanFinished, data: nil, error: nil)

            }
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
