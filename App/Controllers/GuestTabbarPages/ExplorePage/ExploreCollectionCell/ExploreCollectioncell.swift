

import UIKit
import Cosmos

class ExploreCollectioncell: UICollectionViewCell {
    
 
    
    @IBOutlet var homeImage: UIImageView!
    
    @IBOutlet weak var homeHeight: NSLayoutConstraint!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet var transparentView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var entirehomeLabel: UILabel!

    @IBOutlet weak var thunderImage: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        entirehomeLabel.textColor = Theme.ENTIRE_COLOR
        ratingView.settings.filledColor = Theme.PRIMARY_COLOR
        ratingView.settings.filledBorderColor = Theme.PRIMARY_COLOR
        
    titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
         priceLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 13)
         entirehomeLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 13)
         countLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 10)

        
        ratingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
        
    }

}
