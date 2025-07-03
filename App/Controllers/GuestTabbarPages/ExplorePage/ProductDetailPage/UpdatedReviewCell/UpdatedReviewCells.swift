

import UIKit
import Cosmos

class UpdatedReviewCells: UITableViewCell {

    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var ratingTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showAllReviewsBtn: UIButton!
    @IBOutlet weak var showAllBtnHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.ratingTitle.textColor =  UIColor(named: "Title_Header")
        self.ratingTitle.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        self.ratingTitle.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                
        self.showAllReviewsBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        self.showAllReviewsBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        self.showAllReviewsBtn.layer.cornerRadius = self.showAllReviewsBtn.frame.size.height/2
        self.showAllReviewsBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        self.showAllReviewsBtn.layer.borderWidth = 1
        self.showAllReviewsBtn.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
