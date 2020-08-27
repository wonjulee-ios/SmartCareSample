//
//  PairingUserSelectCell.swift
//  Resource
//
//  Created by philosys_macbook on 2020/08/25.
//  Copyright © 2020 philosys. All rights reserved.
//

import UIKit

class PairingUserSelectCell: UITableViewCell {

    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var arrowTrailing: NSLayoutConstraint!
    @IBOutlet weak var vOuter: UIView!
    @IBOutlet weak var vContent: UIView!
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
