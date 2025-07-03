//
//  ReportuserCell.swift
//  Rent_All
//
//  Created by RadicalStart on 28/11/19.
//  Copyright © 2019 RADICAL START. All rights reserved.
//

import UIKit

class ReportuserCell: UITableViewCell {

    @IBOutlet var reportuserLAbel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        reportuserLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"reportuser"))!)"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
