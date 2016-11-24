//
//  CustomCell.swift
//  Unitrans
//
//  Created by Kim Rypstra on 14/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var nativeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
