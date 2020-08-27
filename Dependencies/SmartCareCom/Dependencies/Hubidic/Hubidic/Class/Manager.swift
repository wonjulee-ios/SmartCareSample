//
//  Manager.swift
//  Hubidic
//
//  Created by philosys_macbook on 2020/08/12.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation

public class HubidicDebugManager{
    
    public enum LogType{
        case debugging
        case crash
        case error
        case realase
    }

    public static func log(_ msg:Any, type:HubidicDebugManager.LogType = .debugging, file:String = #file, function:String = #function, line: Int = #line){
        
        #if DEBUG
        let filename = file.split(separator: "/").last ?? ""
        let funcName = function.split(separator: "(").first ?? ""
        
        switch type {
        case .debugging:
            print("🪒[\(filename)] \(funcName)(\(line)): \(msg)")
        case .error:
            print("🔥[\(filename)] \(funcName)(\(line)): \(msg)")
        case .crash:
            print("❌[\(filename)] \(funcName)(\(line)): \(msg)")
        case .realase:
            print("✅[\(filename)] \(funcName)(\(line)): \(msg)")
        }
        
        #endif
    }

}

public class HubidicDataManager{
    public weak var delegate:HubidicDataSyncDelegate?
    var bpDataList:[BloodPressData] = []
    var deviceInfo:HubidicDevice //HubidicDataManager
    var timer:Timer?
    
    init(deviceInfo:HubidicDevice) {
        self.deviceInfo = deviceInfo
    }
    func intoArray(data:BloodPressData){
        timerOn()
        bpDataList.append(data)
    }
    
    @objc private func sync(){
        
        HubidicDebugManager.log("✅ data sync \(bpDataList)")
        delegate?.sync(dataList: bpDataList)
    }
    
    func timerOn(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(sync), userInfo: nil, repeats: false)
    }
    
}
public protocol HubidicDataSyncDelegate:AnyObject {
    func sync(dataList:[BloodPressData])
    func HubidicDeviceInfo(info:HubidicDevice)
    
}
