//
//  HeaderprofileCell.swift
//  Rent_All
//
//  Created by RadicalStart on 28/11/19.
//  Copyright © 2019 RADICAL START. All rights reserved.
//

import UIKit

class HostprofileviewCell: UITableViewCell {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var memberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
