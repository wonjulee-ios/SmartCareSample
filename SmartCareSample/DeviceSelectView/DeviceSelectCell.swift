//
//  DeviceSelectCell.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/18.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
protocol DeviceSelectViewManageDelegate:AnyObject {
    func DeviceAddButtonPressed(with cell:UITableViewCell)
}
class DeviceSelectCell: UITableViewCell {

    @IBOutlet weak var vOuter: UIView!
    @IBOutlet weak var vBackDimming: UIView!
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var imgDevice: UIImageView!
    @IBOutlet weak var svMain: UIStackView!
    @IBOutlet weak var lblUserTitle: UILabel!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblDeviceModelName: UILabel!
    @IBOutlet weak var lblConnectState: UILabel!
    @IBOutlet weak var btnDeviceManage: UIButton!
    weak var delegate:DeviceSelectViewManageDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        shadowLayer.removeFromSuperlayer()
    }
    
    @IBAction func onButtonPress(_ sender: Any) {
        delegate?.DeviceAddButtonPressed(with: self)
    }
}
