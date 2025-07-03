

import UIKit
import Cosmos

class ContactheaderCell: UITableViewCell {

    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var entireLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        listImage.layer.cornerRadius = 6.0
        listImage.layer.masksToBounds = true
        ratingView.settings.filledBorderColor = Theme.PRIMARY_COLOR
        ratingView.settings.filledColor = Theme.PRIMARY_COLOR
        entireLabel.textColor = Theme.ENTIRE_COLOR
        listBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        entireLabel.font = UIFont(name: APP_FONT, size: 15)
        priceLabel.font = UIFont(name: APP_FONT, size: 18)
        reviewLabel.font = UIFont(name: APP_FONT, size: 13)
        
        ratingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
