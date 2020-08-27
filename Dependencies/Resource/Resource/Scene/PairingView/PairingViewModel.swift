//
//  PairingViewModel.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/26.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import UIKit

struct PairingViewModel {
    let textString:String?
    let deviceImage:UIImage?
    let userType:String?
    
    init(textString:String?, deviceImage:UIImage?, userType:String? = nil) {
        self.textString = textString
        self.deviceImage = deviceImage
        self.userType = userType
    }
}
