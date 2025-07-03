//
//  TripsoptionsCell.swift
//  Rent_All
//
//  Created by RadicalStart on 11/09/20.
//  Copyright © 2020 RADICAL START. All rights reserved.
//

import UIKit

class TripsoptionsCell: UITableViewCell {

    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var firstBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        secondBtn.layer.cornerRadius = 6
        secondBtn.layer.masksToBounds = true
        firstBtn.layer.cornerRadius = 6
        firstBtn.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
