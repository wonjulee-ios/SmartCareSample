//
//  ScanViewController.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/14.
//  Copyright © 2020 philosys. All rights reserved.
//
//
//  ScanViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/11.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import Resource

public enum ScanViewDictionrayKey{
    case deviceName
    case rssi
    case uuidSrting
}
public class ScanViewController: UIViewController {
    @IBOutlet public weak var tvList: UITableView!
    @IBOutlet public weak var btnScan: UIButton!
    public var scanStartClosure: (() -> Void)?
    public var scanFinishClosure: (() -> Void)?
    public var scanSelectUUIDClosure: ((String) -> Void)?
    public var scanList:[[ScanViewDictionrayKey:String]] = [] {
        willSet {
            tvList.reloadData()
        }
    }
    public var isScanning:Bool = false{
        willSet {
            if newValue == true,
                let scan = scanStartClosure {
                scan()
                btnScan.setTitle("스캔중...", for: .normal)
            } else if let scanfinish = scanFinishClosure {
                scanfinish()
                btnScan.setTitle("스캔 중지", for: .normal)
            }
            
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "ScanViewCell", bundle: R.bundle)
        tvList.delegate = self
        tvList.dataSource = self
        tvList.register(nibName, forCellReuseIdentifier: "ScanViewCell")

        // Do any additional setup after loading the view.
    }
    

    @IBAction func scanToogle(_ sender: Any) {
        isScanning.toggle()
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

extension ScanViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScanViewCell", for: indexPath) as! ScanViewCell
        let deviceName = scanList[indexPath.row][.deviceName] ?? ""
        let uuidString = scanList[indexPath.row][.uuidSrting] ?? ""
        let rssi = scanList[indexPath.row][.rssi] ?? ""
        
        cell.setData(name: deviceName, uuid: uuidString, rssi: rssi)
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uuidString = scanList[indexPath.row][.uuidSrting] ?? ""
        if let select = scanSelectUUIDClosure {
            select((uuidString))
        }
    }
    
    
}
