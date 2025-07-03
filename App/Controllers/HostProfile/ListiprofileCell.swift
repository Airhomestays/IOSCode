//
//  ListiprofileCell.swift
//  Rent_All
//
//  Created by RadicalStart on 11/09/20.
//  Copyright © 2020 RADICAL START. All rights reserved.
//

import UIKit

class ListiprofileCell: UITableViewCell {

    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var hostedLAbel: UILabel!
    @IBOutlet weak var titleLbel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width/2
        profileImage.layer.masksToBounds = true
        listBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
