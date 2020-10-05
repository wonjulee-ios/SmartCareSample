//
//  SmartcareCoordinator.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/09/01.
//  Copyright © 2020 philosys. All rights reserved.
//

import Foundation
import UIKit
import Resource
import SmartCareCom


protocol DeviceSelectViewControllerDelegate: AnyObject {
  
    func tryConnecting(index:Int)
    func removeDevice(index:Int)
}

protocol Coordinator {
  func start()
}

final class AppCoordinator: Coordinator {
    private let navController: UINavigationController
    private let window: UIWindow

    // MARK: - Initializer
    init(navController: UINavigationController, window: UIWindow) {
      self.navController = navController
      self.window = window
    }

    func start() {
      window.rootViewController = navController
      window.makeKeyAndVisible()
      
    }

    
    
}

extension AppCoordinator: DeviceSelectViewControllerDelegate{
    func tryConnecting(index: Int) {
        if index == 0 {
            SmartCareCom.shared.bpManager.select(to: .Hubidic)
            
            let vc:PairingViewController =  R.Storyboard.pairngModeView.instance()
            
            
        } else {
            
        }
    }
    
    func removeDevice(index: Int) {
        
    }
    
    
}
