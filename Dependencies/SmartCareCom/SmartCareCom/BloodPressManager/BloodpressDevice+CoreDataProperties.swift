//
//  BloodpressDevice+CoreDataProperties.swift
//  SmartCareCom
//
//  Created by philosys_macbook on 2020/08/14.
//  Copyright © 2020 philosys. All rights reserved.
//
//

import Foundation
import CoreData


extension BloodpressDevice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BloodpressDevice> {
        return NSFetchRequest<BloodpressDevice>(entityName: "BloodpressDevice")
    }

    @NSManaged public var connected: Bool
    @NSManaged public var deviceName: String?
    @NSManaged public var fwver: String?
    @NSManaged public var password: String?
    @NSManaged public var selected: Bool
    @NSManaged public var usertype: String?
    @NSManaged public var uuidString: String?

}
