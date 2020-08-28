//
//  ScanViewCell.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/18.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

public class ScanViewCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUUID: UILabel!
    @IBOutlet weak var lblRssi: UILabel!
    
    
    public func setData(name:String, uuid:String, rssi:String){
        
        lblName.text = name
        lblUUID.text = uuid
        lblRssi.text = rssi
    }
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
