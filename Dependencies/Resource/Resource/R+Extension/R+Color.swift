//
//  R+Color.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/14.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

public extension R {
    enum Color {}
}

public extension R.Color {
    
    static var topaz: UIColor { .load(name: "topaz") }
    static var mango: UIColor { .load(name: "mango") }
    static var clearBlue: UIColor { .load(name: "clearBlue") }
    static var warmGrey: UIColor { .load(name: "warmGrey") }
    static var paleGrey: UIColor { .load(name: "paleGrey") }
    static var paleBlue: UIColor { .load(name: "paleBlue") }
    
}

/// Extension.swift
extension UIColor {
    static func load(name: String) -> UIColor {
        guard let color = UIColor(named: name, in: R.bundle, compatibleWith: nil) else {
            assert(false, "\(name) Color 로드 실패")
            return UIColor()
        }
        return color
    }
}
