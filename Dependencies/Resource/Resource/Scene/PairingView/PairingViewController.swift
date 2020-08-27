//
//  PairingViewController.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/25.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit


/// - data : 해당 프로퍼티를 반드시 할당하고 초기화할 것.
class PairingViewController: UIViewController {
    @IBOutlet weak var tvList: UITableView!
    
    var data:PairingViewModel!
    let paringTypeCellIdentifier = "PairingTypeACell"
    let pairingUserSelectCellIdentifier = "PairingUserSelectCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "페어링"
        tvList.backgroundColor = R.Color.paleGrey
        let nibName = UINib(nibName: paringTypeCellIdentifier, bundle: R.bundle)
        let nibName2 = UINib(nibName: pairingUserSelectCellIdentifier, bundle: R.bundle)
        
        tvList.register(nibName, forCellReuseIdentifier: paringTypeCellIdentifier)
        tvList.register(nibName2, forCellReuseIdentifier: pairingUserSelectCellIdentifier)
//        tvList.rowHeight = UITableView.automaticDimension
        tvList.delegate = self
        tvList.dataSource = self
        
        data = PairingViewModel(textString: "모니터가 꺼진 혈압계의\n시작(START)버튼을 길게 누릅니다.", deviceImage: R.Image.imgMeasureDevice2P1, userType: "nil")
        
        // Do any additional setup after loading the view.
    }

}

extension PairingViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
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
        return 1
    }
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.contentView.backgroundColor = UIColor.clear
//    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: paringTypeCellIdentifier, for: indexPath) as! PairingTypeACell
            
            cell.vOuter.layer.shadowColor = UIColor.lightGray.cgColor
            cell.vOuter.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            cell.vOuter.layer.shadowOpacity = 0.5
            cell.vOuter.layer.cornerRadius = 10
            cell.vContent.layer.cornerRadius = 10
            cell.vContent.clipsToBounds = true
            cell.backgroundColor = R.Color.paleGrey
            cell.imgDevice.image = data.deviceImage
            cell.lblTitle.text = data.textString
            
            cell.vOuter.layoutIfNeeded()
            cell.vOuter.setNeedsDisplay()
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: pairingUserSelectCellIdentifier, for: indexPath) as! PairingUserSelectCell
            cell.vOuter.layer.shadowColor = UIColor.lightGray.cgColor
            cell.vOuter.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            cell.vOuter.layer.shadowOpacity = 0.5
            cell.vOuter.layer.cornerRadius = 10
            cell.vContent.layer.cornerRadius = 10
            cell.vContent.clipsToBounds = true
            cell.backgroundColor = R.Color.paleGrey
            
            if let userType = data.userType {
                cell.lblUserType.text = userType
                
            } else {
                cell.arrowTrailing.constant = 0
                cell.imgNext.isHidden = true
                cell.lblUserType.text = "블루투스가 정상적으로 켜져있는지 확인해"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
