//
//  DataController.swift
//  SmartCareCom
//
//  Created by philosys_macbook on 2020/08/13.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import CoreData

public protocol DataControllerDataSource:AnyObject {
    var persistentContainer:NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject?
    func commit()-> Bool
    func initData(onSuccess:@escaping((Bool)->Void))
    
}
public class DataController:DataControllerDataSource {
    
    // 1.
    /// It represents your data store.
//    public static var shared = DataController()
    init() {
        
    }
    
    public var persistentContainer:NSPersistentContainer = {
        
        let modelURL = Bundle(identifier: "com.gmate.framework.SmartCareCom")!.url(forResource: "smartcarecom", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: "smartcarecom", managedObjectModel: managedObjectModel!)
        
        container.loadPersistentStores { description, error in
            // 3.
            if let error = error {
                fatalError("❌error")
            }
            
        }
        return container
    }()

    public var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    public func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
            
        } catch {
            print(error.localizedDescription)
            return []
            
        }
        
        
    }
    public func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?

        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)

        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        return result
    }
//    public func saveData(connected:Bool, deviceName:String, fwver:String, password:String, selected:Bool, usertype:String, uuidString:String, onSuccess:@escaping((Bool)->Void)){
//
//        if let deviceModel = createRecordForEntity("BloodpressDevice", inManagedObjectContext: context) as? BloodpressDevice {
//            deviceModel.connected = connected
//            deviceModel.deviceName = deviceName
//            deviceModel.fwver = fwver
//            deviceModel.password = password
//            deviceModel.selected = selected
//            deviceModel.usertype = usertype
//            deviceModel.uuidString = uuidString
//
//
//            do {
//              try context.save()
//              onSuccess(true)
//            } catch let error as NSError {
//              print("Could not save. \(error), \(error.userInfo)")
//                onSuccess(false)
//            }
//        } else {
//            onSuccess(false)
//        }
////        guard let entity = NSEntityDescription.entity(forEntityName: "BloodpressDevice", in: context) else { return }
////        }
////        if let deviceModel = NSManagedObject(entity: entity,
////                                             insertInto: context) as? BloodpressDevice {
////            deviceModel.connected = connected
////            deviceModel.deviceName = deviceName
////            deviceModel.fwver = fwver
////            deviceModel.password = password
////            deviceModel.selected = selected
////            deviceModel.usertype = usertype
////            deviceModel.uuidString = uuidString
////
////
////            do {
////              try context.save()
////              onSuccess(true)
////            } catch let error as NSError {
////              print("Could not save. \(error), \(error.userInfo)")
////                onSuccess(false)
////            }
////        } else {
////            onSuccess(false)
////        }
//
//
//    }
//
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)

        // Helpers
        var result = [NSManagedObject]()

        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)

            if let records = records as? [NSManagedObject] {
                result = records
            }

        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }

        return result
    }
    
    public func initData(onSuccess:@escaping((Bool)->Void)){
//        guard let entity = NSEntityDescription.entity(forEntityName: "BloodpressDevice", in: context) else { return }
        
        
        let deviceType = ["\(BloodPressManager.DeviceType.AnD.self)",
            "\(BloodPressManager.DeviceType.Hubidic.self)"]
        
        for i in 0...1 {
//            if let deviceModel = NSManagedObject(entity: entity,
//                                                 insertInto: context) as? BloodpressDevice {
            if let deviceModel = NSEntityDescription.insertNewObject(forEntityName: "BloodpressDevice", into: context) as? BloodpressDevice {
                deviceModel.connected = false // update
                deviceModel.deviceName = deviceType[i]
                deviceModel.fwver = ""
                deviceModel.password = ""
                deviceModel.selected = false
                deviceModel.usertype = ""
                deviceModel.uuidString = ""
            }
        }
        commit() == true ? onSuccess(true) : onSuccess(false)
    }
    @discardableResult
    public func commit()->Bool{
        
        do {
          try context.save()
          return true
        } catch let error as NSError {
          
            print("Could not save. \(error), \(error.userInfo)")
        
            return false
        }
        
    }
    
//    func initalizeStack() {
//        // 2.
//        self.persistentContainer.loadPersistentStores { description, error in
//            // 3.
//            if let error = error {
//                print("could not load store \(error.localizedDescription)")
//                return
//            }
//
//            print("store loaded")
//        }
//    }
    
}
