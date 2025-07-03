

import UIKit
import SwiftMessages

class RequestBookcellTableViewCell: UITableViewCell {

    @IBOutlet weak var specialImage: UIButton!

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var lineTwoLabel: UILabel!
    @IBOutlet weak var lineOneLabel: UILabel!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var servicefeeLabel: UILabel!
    @IBOutlet weak var cleaningpriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceLeftLabel: UILabel!
    
    @IBOutlet weak var priceLabelLeadingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        priceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .left
        priceLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        priceLeftLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        priceLeftLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        priceLeftLabel.font = UIFont(name: APP_FONT, size: 14.0)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
