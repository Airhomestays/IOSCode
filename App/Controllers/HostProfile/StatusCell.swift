//
//  StatusCell.swift
//  Rent_All
//
//  Created by RadicalStart on 11/09/20.
//  Copyright © 2020 RADICAL START. All rights reserved.
//

import UIKit

class StatusCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Theme.PRIMARY_COLOR
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
