//
//  NocellnewDesignCell.swift
//  Rent_All
//
//  Created by RadicalStart on 10/09/20.
//  Copyright © 2020 RADICAL START. All rights reserved.
//

import UIKit

class NocellnewDesignCell: UITableViewCell {
    @IBOutlet weak var roundImage: UIImageView!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var nolistLAbel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
       nolistLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)"
        profileImage.layer.cornerRadius = profileImage.layer.frame.size.width/2
        profileImage.clipsToBounds = true
              roundImage.layer.cornerRadius = roundImage.layer.frame.size.width/2
              roundImage.clipsToBounds = true
        roundImage.backgroundColor = UIColor.lightGray
              lineLabel.backgroundColor = UIColor.lightGray
        shadowViewLayout()
        // Initialization code
    }
    func shadowViewLayout(){
        borderView.layer.cornerRadius = 5.0
        borderView.layer.shadowColor = TextLightColor.cgColor
        borderView.layer.shadowOffset = CGSize(width: 0.0, height:2)
        borderView.layer.shadowRadius = 4
        borderView.layer.shadowOpacity = 0.4
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
