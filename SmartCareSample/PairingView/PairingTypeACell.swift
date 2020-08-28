//
//  PairingTypeACell.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/25.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

class PairingTypeACell: UITableViewCell {
    @IBOutlet weak var vOuter: UIView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgDevice: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
