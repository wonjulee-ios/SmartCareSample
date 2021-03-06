//
//  BpUserSelectViewController.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/28.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import Resource
class BpUserSelectViewController: UIViewController {
    @IBOutlet weak var vBackground: UIView!
    @IBOutlet weak var vOuter: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvList: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    let cellHeight:CGFloat = 50
    var userTypeList:[BpUserSelectDataModel]!
    public var selectFinishClosure: ((Any) -> Void)?
    class BpUserSelectDataModel {
        var isSelected:Bool
        let userType:String
        
        init(isSelected:Bool, userType:String) {
            self.isSelected = isSelected
            self.userType = userType
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        vOuter.clipsToBounds = true
        vOuter.layer.cornerRadius = 10
        
        userTypeList = [BpUserSelectDataModel(isSelected: false, userType: "모든 사용자"),
                        BpUserSelectDataModel(isSelected: true, userType: "사용자 A"),
                        BpUserSelectDataModel(isSelected: false, userType: "사용자 B")]
        
        let nib = R.Nib.BpUserSelectCell.instance()
        tvList.register(nib, forCellReuseIdentifier: R.Nib.BpUserSelectCell.identifier)
        tvList.delegate = self
        tvList.dataSource = self
        
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
    @IBAction func onSave(_ sender: Any) {
        if let selectedUserType = userTypeList.filter{$0.isSelected}.last {
            if let closure = selectFinishClosure{
                closure(selectedUserType.userType)
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
}
extension BpUserSelectViewController:UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTypeList.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.Nib.BpUserSelectCell.identifier, for: indexPath) as! BpUserSelectCell
        cell.lblUserType.text = userTypeList[indexPath.row].userType
        if userTypeList[indexPath.row].isSelected == true {
            cell.imgCheck.image = R.Image.btnMeasureChoicePressed
            cell.backgroundColor = R.Color.paleBlue
        } else {
            cell.imgCheck.image = R.Image.btnMeasureChoice
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userTypeList.filter{$0.isSelected}.compactMap{$0.isSelected = false}
        userTypeList[indexPath.row].isSelected.toggle()
        tvList.reloadData()
//        tvList.reloadRows(at: [indexPath], with: .fade)
        
        
    }
}
