//
//  ManageBleDeviceViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/03.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import Hubidic

struct BleDevice {
    let measureType:String
    let modelList:[String]
}

class ManageBleDeviceViewController: UIViewController {

    @IBOutlet weak var tvList: UITableView!
    var list :[BleDevice] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        list = [BleDevice(measureType: "혈당", modelList: ["Gmate Smart"]),
         BleDevice(measureType: "혈압", modelList: ["Hubidic","A&D"]),
         BleDevice(measureType: "체지방", modelList: ["ICDEV"]),
         BleDevice(measureType: "밴드", modelList: ["Partron"])]
        
        
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

extension ManageBleDeviceViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        cell.textLabel?.text = list[indexPath.section].measureType
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SelectBleDeviceViewController") as! SelectBleDeviceViewController
        vc.dataList = list[indexPath.section].modelList
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
}
