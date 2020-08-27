//
//  BpDataSyncCell.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/26.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

class BpDataSyncCell: UITableViewCell {
    
    @IBOutlet weak var btnCheck: UIImageView!
    @IBOutlet weak var lblMeasureDt: UILabel!
    @IBOutlet weak var lblBpValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
