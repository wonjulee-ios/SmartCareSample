//
//  SelectBleDeviceViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/03.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import Hubidic
import SmartCareCom
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
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        vc.scanStartClosure = { [weak self] in
            print("start")
        }
        vc.scanFinishClosure = { [weak self] in
            print("finish")
        }
        
        
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
}
