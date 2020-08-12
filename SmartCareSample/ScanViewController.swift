//
//  ScanViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/11.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import Hubidic

class ScanCell:UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblRssi: UILabel!
    
    
    func setData(name:String, uuid:String, rssi:String){
        
        lblName.text = name
        lblUUID.text = uuid
        lblRssi.text = rssi
    }
    
}

class ScanViewController: UIViewController {
    @IBOutlet weak var tvList: UITableView!
    @IBOutlet weak var btnScan: UIButton!
    var scanStartClosure: (() -> Void)?
    var scanFinishClosure: (() -> Void)?
    var isScanning:Bool = false{
        willSet {
            if newValue == true,
                let scan = scanStartClosure {
                scan()
            } else if let scanfinish = scanFinishClosure {
                scanfinish()
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
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


