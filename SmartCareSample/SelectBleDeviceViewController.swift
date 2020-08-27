//
//  SelectBleDeviceViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/03.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import SmartCareCom
import Resource

class SelectBleDeviceViewController: UIViewController {
    
    @IBOutlet weak var tvList: UITableView!
    var dataList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SelectBleDeviceViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell", for: indexPath)
        cell.textLabel?.text = dataList[indexPath.section]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let deviceSelectView = R.Storyboard.deviceSelectView.instance()
        
//        let scanView: ScanViewController = R.Storyboard.scanView.instance()
//        if dataList[indexPath.section] == "A&D" {
//            SmartCareCom.shared.bpManager.select(to: .AnD)
//        } else {
//            SmartCareCom.shared.bpManager.select(to: .Hubidic)
//        }
//
//        scanView.scanStartClosure = { [unowned scanView] in
//            print("start")
//            SmartCareCom.shared.bpManager.selectedDevice?.bleScanDevice()
//        }
//        scanView.scanFinishClosure = { [unowned scanView] in
//            print("finish")
//            SmartCareCom.shared.bpManager.selectedDevice?.bleStopScan()
////            SmartCareCom.shared.bpManager.selectedDevice?.bleStopScan()
//        }
//        scanView.scanSelectUUIDClosure = {[weak scanView] a in
//
//
//        }
        
        self.navigationController?.pushViewController(deviceSelectView, animated: true)
    }
    
    
}


extension ScanViewController : DeviceManagerScannable {
    public func DeviceManagerScanning(dictArray: [[String : String]]) {
        
        for dict in 0...5 {
            scanList.append([.deviceName:"안녕", .rssi:"-59", .uuidSrting : "ABAB"])
        }
        
        
    }
    
    
}
