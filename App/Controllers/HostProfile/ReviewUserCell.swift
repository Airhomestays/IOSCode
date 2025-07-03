//
//  ReviewUserCell.swift
//  Rent_All
//
//  Created by RadicalStart on 28/11/19.
//  Copyright © 2019 RADICAL START. All rights reserved.
//

import UIKit

class ReviewUserCell: UITableViewCell {

    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var reviewBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
