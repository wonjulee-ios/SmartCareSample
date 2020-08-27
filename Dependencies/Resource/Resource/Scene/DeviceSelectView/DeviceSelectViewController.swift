//
//  DeviceSelectViewController.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/18.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit


class DeviceSelectViewController: UIViewController {

    @IBOutlet weak var tvList: UITableView!
    var dataList:[DeviceSelectDataModel]!
    let cellIdentifier:String = "DeviceSelectCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "혈압기기 선택"
        tvList.backgroundColor = R.Color.warmGrey
        let nibName = UINib(nibName: cellIdentifier, bundle: R.bundle)
        tvList.delegate = self
        tvList.dataSource = self
        tvList.register(nibName, forCellReuseIdentifier: cellIdentifier)
        
        dataList = [DeviceSelectDataModel(isSelected: true, isConnected: true, titleName: "AnD", deviceModelName: "HBP-1700", userInfo: "사용자 A"),
                    DeviceSelectDataModel(isSelected: false, isConnected: false, titleName: "HuBIDIC", deviceModelName: "HBP-1700", userInfo: nil)]
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
    @objc func deviceManageAction(sender:Any){
        
    }

}

extension DeviceSelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // Set the spacing between sections
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 16
//    }
//
//    // Make the background color show through
//    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        dataList.count
    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.contentView.backgroundColor = UIColor.clear
//    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DeviceSelectCell
//        cell.backgroundColor = R.Color.warmGrey
//        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOpacity = 0.8
//        cell.layer.shadowOffset = CGSize(width: 1.7, height: 2.9)
//        cell.layer.shadowRadius = 10
        
//        cell.layer.shadowPath = UIBezierPath(rect: cell.bounds).cgPath
        
        cell.btnDeviceManage.addTarget(self, action: #selector(deviceManageAction(sender:)), for: .touchUpInside)
        let data = dataList[indexPath.section]
        
        // 사용자 A? or nil
        if let selectedUserType = data.userInfo {
            cell.lblUserTitle.text = selectedUserType
        } else {
            cell.lblUserTitle.isHidden = true
        }
        
        if let connectedString = data.isConnectedString, data.isConnected {
            cell.lblConnectState.text = connectedString
            cell.lblDeviceName.text = data.deviceModelName
        } else {
            cell.lblConnectState.isHidden = true
            cell.lblDeviceModelName.isHidden = true
        }
        
        cell.imgDevice.image = data.deviceImage
        cell.btnCheckbox.isSelected = data.isSelected
        
        cell.btnDeviceManage.layer.borderWidth = 1.3
        cell.btnDeviceManage.layer.cornerRadius = 10
        cell.btnDeviceManage.layer.borderColor = data.manageButtonColor.cgColor
        cell.btnDeviceManage.setTitle(data.manageButtonText, for: .normal)
        cell.btnDeviceManage.setTitleColor(data.manageButtonColor, for: .normal)
        
//        cell.vOuter.layer.fillColor = UIColor.white.cgColor
        cell.vOuter.layer.shadowColor = UIColor.lightGray.cgColor
//        shadowLayer.shadowPath = UIBezierPath()
        cell.vOuter.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cell.vOuter.layer.shadowOpacity = 0.5
        cell.vOuter.layer.cornerRadius = 10
        cell.vBackDimming.layer.cornerRadius = 10
        cell.vBackDimming.clipsToBounds = true
        
        cell.vOuter.layoutIfNeeded()
        cell.vOuter.setNeedsDisplay()
        
        
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        
    }

}
