//
//  ViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/07/31.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import SmartCareCom
import Resource
class ViewController: UIViewController {

    @IBOutlet weak var tvList: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    @IBAction func openSetting(_ sender: Any) {
        
    }
    @IBAction func onSyncTest(_ sender: Any) {
        let vc = R.Storyboard.bpDataSyncView.instance()
        
//        vc.modalPresentationStyle = .overFullScreen
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
}


extension ViewController : BloodPressManageDelegate{
    
}
