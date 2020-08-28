//
//  R+Image.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/14.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

public extension R {
    enum Image {}
}

public extension R.Image {
    static var icMeasureChoice: UIImage { .load(name: "icMeasureChoice") }
    static var icMeasureChoicePressed: UIImage { .load(name: "icMeasureChoicePressed") }
    static var imgDeviceAnD: UIImage { .load(name: "imgDeviceAnD") }
    static var imgDeviceHubidic: UIImage { .load(name: "imgDeviceHubidic") }
    static var icMeasureClose: UIImage { .load(name: "icMeasureClose") }
    static var icMeasureNext: UIImage { .load(name: "icMeasureNext") }
    static var btnMeasureChoice: UIImage { .load(name: "btnMeasureChoice") }
    static var btnMeasureChoicePressed: UIImage { .load(name: "btnMeasureChoicePressed") }
    static var imgMeasureDevice1P1: UIImage { .load(name: "imgMeasureDevice1P1") }
    static var imgMeasureDevice1P2: UIImage { .load(name: "imgMeasureDevice1P2") }
    static var imgMeasureDevice2P1: UIImage { .load(name: "imgMeasureDevice2P1") }
    static var imgMeasureDevice2P2: UIImage { .load(name: "imgMeasureDevice2P2") }
    
    
    
    
    
//    static var icPopupChoice: UIImage { .load(name: "icPopupChoice") }
//    static var icPopupChoicePressed: UIImage { .load(name: "icPopupChoicePressed") }
    
}

/// Extension.swift
extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: R.bundle, compatibleWith: nil) else {
            assert(false, "\(name) 이미지 로드 실패")
            return UIImage()
        }
        return image
    }
}
