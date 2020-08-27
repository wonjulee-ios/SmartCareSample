//
//  BpDataSyncViewController.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/26.
//  Copyright © 2020 philosys. All rights reserved.
//

//
//  BpUserSelectViewController.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/26.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
import Hubidic

class BpDataSyncViewController: UIViewController {

    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblCheckAll: UILabel!
    @IBOutlet weak var btnCheckAll: UIButton!
    @IBOutlet weak var tvList: UITableView!
    var syncList:[BpDataSyncDataModel]!
    let cellIdentifier: String = "BpDataSyncCell"
    let cellHeight:CGFloat = 50
    var isCheckAll:Bool = false {
        willSet {
            btnCheckAll.isSelected = newValue
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tvList.backgroundColor = R.Color.paleGrey
        let nibName = UINib(nibName: cellIdentifier, bundle: R.bundle)
        tvList.register(nibName, forCellReuseIdentifier: cellIdentifier)
        tvList.delegate = self
        tvList.dataSource = self
        isCheckAll = true
        syncList = [BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    BpDataSyncDataModel(data:BloodPressData(measureDt: Date(), max: 128, min: 90, hr: 88)),
                    
        ]
        
        vContent.layer.cornerRadius = 10
        vContent.clipsToBounds = true
        
        let fullHeight = view.bounds.height
        let dataLength = CGFloat(syncList.count)
        
        let calculResult = ((cellHeight * 2) + (dataLength * cellHeight)) / fullHeight
        print(calculResult)
        if calculResult > 1 {
            print("max")
            viewHeightConstraint.constant = fullHeight - (100) // margin
        } else {
            viewHeightConstraint.constant = (dataLength * cellHeight) + (cellHeight * 2)
            print("it's okay")
        }
        
        
        
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
    @IBAction func onCheckAll(_ sender: Any) {
        isCheckAll.toggle()
        syncList.map{$0.isSelected = isCheckAll}
        syncList[0].isSelected = true
        tvList.reloadData()
    }
    
    @IBAction func onSave(_ sender: Any) {
        let candidateSyncList = syncList.filter{$0.isSelected}
        print(candidateSyncList.count)
        self.dismiss(animated: true, completion: nil)
    }
}

extension BpDataSyncViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return syncList.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BpDataSyncCell
        
        let syncData = syncList[indexPath.row]
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "ko")
        dateFormatter.dateFormat = "MMM d일 a HH:mm"
        let dateString = dateFormatter.string(from: syncData.data.measureDt)
                
        cell.btnCheck.image = syncData.isSelected == true ? R.Image.icPopupChoicePressed : R.Image.icPopupChoice
        cell.backgroundColor = syncData.isSelected == true ? R.Color.paleBlue : .white
        cell.lblBpValue.text = "\(syncData.data.max)/\(syncData.data.min) (\(syncData.data.hr))"
        cell.lblMeasureDt.text = dateString
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        syncList[indexPath.row].isSelected.toggle()
        tvList.reloadRows(at: [indexPath], with: .fade)
        
        if syncList[indexPath.row].isSelected == false {
            isCheckAll = false
        } else {
            let checkLength = syncList.filter{$0.isSelected}.count
            if syncList.count == checkLength {
                isCheckAll = true
            }
        }
    }
        
        
}

