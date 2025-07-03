

import UIKit
import Cosmos

class FloatCollectionCell: UICollectionViewCell {

    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var instantView: UIImageView!
    @IBOutlet var homeImage: UIImageView!
    
    @IBOutlet weak var selectedItem: UILabel!
    
    @IBOutlet weak var entireHomeWidthConstraint: NSLayoutConstraint!
    @IBOutlet var transparentView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var entirehomeLabel: UILabel!
    
    @IBOutlet var ratingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        instantView.frame = CGRect(x:82, y: 172, width: 10, height: 12)
        

        entirehomeLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 11)
        priceLabel.font = UIFont(name: APP_FONT, size: 11)
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        entirehomeLabel.textColor = Theme.ENTIRE_COLOR
        ratingView.settings.filledColor = Theme.PRIMARY_COLOR
        ratingView.settings.filledBorderColor = Theme.PRIMARY_COLOR
        selectedItem.backgroundColor = Theme.PRIMARY_COLOR
        
        ratingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight

    }

}
