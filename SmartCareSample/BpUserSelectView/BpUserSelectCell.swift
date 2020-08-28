//
//  BpUserSelectCell.swift
//  SmartCareSample
//
//  Created by philosys_macbook on 2020/08/28.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit
class BpUserSelectCell: UITableViewCell {
    
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblUserType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
