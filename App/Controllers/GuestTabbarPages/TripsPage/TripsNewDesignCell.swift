//
//  TripsNewDesignCell.swift
//  Rent_All
//
//  Created by RadicalStart on 10/09/20.
//  Copyright © 2020 RADICAL START. All rights reserved.
//

import UIKit

class TripsNewDesignCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var roundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var tripmainView: UIView!
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    override func awakeFromNib() {
           super.awakeFromNib()
        
        statusLabel.layer.cornerRadius = 6
        statusLabel.layer.masksToBounds = true
        //profileImage.layer.cornerRadius = profileImage.layer.frame.size.width/2
            //  profileImage.clipsToBounds = true
        roundImage.layer.cornerRadius = roundImage.layer.frame.size.width/2
        roundImage.clipsToBounds = true
        roundImage.backgroundColor = Theme.PRIMARY_COLOR
        lineLabel.backgroundColor = Theme.PRIMARY_COLOR
        //listImage.layer.cornerRadius = 4
       // listImage.layer.masksToBounds = true
        self.shadowViewLayout()
           // Initialization code
       }
    
    func shadowViewLayout(){
        tripmainView.layer.cornerRadius = 5.0
        tripmainView.layer.shadowColor = TextLightColor.cgColor
        tripmainView.layer.shadowOffset = CGSize(width: 0.0, height:2)
        tripmainView.layer.shadowRadius = 4
        tripmainView.layer.shadowOpacity = 0.4
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
