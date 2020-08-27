//
//  DeviceSelectModel.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/24.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import UIKit

struct DeviceSelectDataModel {
    var isSelected:Bool
    var isConnected:Bool
    let deviceImage:UIImage
    var userInfo:String? = nil
    let titleName:String
    let deviceModelName:String
    var isConnectedString:String? = nil
    var manageButtonColor:UIColor
    var manageButtonText:String
    
    init(isSelected:Bool, isConnected:Bool, titleName:String, deviceModelName:String, userInfo:String?) {
        
        self.isSelected = isSelected
        self.isConnected = isConnected
        
        self.titleName = titleName
        self.deviceModelName = deviceModelName
        deviceImage = R.Image.imgDeviceAnD
        manageButtonColor = R.Color.mango
        if isConnected {
            self.manageButtonText = "기기 해제"
            self.isConnectedString = "연결됨"
        } else {
            self.manageButtonText = "기기 등록"
        }
        
        self.userInfo = userInfo
        
    }
}
