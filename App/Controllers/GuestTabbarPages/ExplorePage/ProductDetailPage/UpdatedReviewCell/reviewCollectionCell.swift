
import UIKit
import Cosmos

class reviewCollectionCell: UICollectionViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewContentLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var starRationgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var readMoreBtn: UIButton!
    
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var ratingBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.backGroundView.layer.cornerRadius = 10
        self.backGroundView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        self.backGroundView.layer.borderWidth = 1
        self.backGroundView.clipsToBounds = true
        
        self.imgView.layer.cornerRadius = 20
        self.imgView.clipsToBounds = true
        
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.titleLabel.font = UIFont(name: APP_FONT, size: 14)
        self.ratingBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 12)
        self.titleLabel.textColor =  UIColor(named: "Title_Header")
        
       self.ratingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
        
        self.reviewContentLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.reviewContentLabel.font = UIFont(name: APP_FONT, size: 14)
        self.reviewContentLabel.textColor =  UIColor(named: "Title_Header")
        
        
        self.reviewDateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.reviewDateLabel.font = UIFont(name: APP_FONT, size: 13)
        self.reviewDateLabel.textColor = Theme.Review_Date_Color
        
        self.readMoreBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "readmore") ?? "Read More")", for: .normal)
        self.readMoreBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        self.readMoreBtn.titleLabel?.font = UIFont(name: APP_FONT_BOLD, size: 13)
    }
    

}
