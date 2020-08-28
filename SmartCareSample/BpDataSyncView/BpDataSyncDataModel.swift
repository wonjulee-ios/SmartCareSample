//
//  BpDataSyncDataModel.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/26.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
//import SmartCareCom
import Hubidic
class BpDataSyncDataModel {
    
    var isSelected:Bool
    let data:BloodPressData

    init(data:BloodPressData) {
        self.data = data
        self.isSelected = true
    }
}
