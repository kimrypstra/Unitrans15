//
//  ThemeCell.swift
//  Unitrans
//
//  Created by Kim Rypstra on 19/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit

class ThemeCell: UITableViewCell {

    @IBOutlet weak var background: BackgroundView!
    @IBOutlet weak var bubble: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
