
import UIKit
import Cosmos

class PastReviewCells: UITableViewCell {

    
    @IBOutlet var btnRating: UIButton!
    
    @IBOutlet weak var startRatingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var backGroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewContentLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet var btnRatingProfile: UIButton!
    
    @IBOutlet var dateLeading: NSLayoutConstraint!
    @IBOutlet var btnratingidth: NSLayoutConstraint!
    @IBOutlet var btnratingLeading: NSLayoutConstraint!
    @IBOutlet weak var profileBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backGroundView.layer.cornerRadius = 8
        self.backGroundView.layer.masksToBounds = true
        self.backGroundView.layer.borderWidth = 1.0
        self.backGroundView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.profileImageView.layer.cornerRadius = 24
        self.profileImageView.clipsToBounds = true
        
        
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.titleLabel.font = UIFont(name:APP_FONT_SEMIBOLD, size:14)
        self.btnRating.titleLabel?.font = UIFont(name:APP_FONT, size: 12)
        self.reviewContentLabel.font = UIFont(name: APP_FONT, size: 12)
        self.reviewContentLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.reviewDateLabel.textColor = Theme.Review_Date_Color
        self.reviewDateLabel.font = UIFont(name: APP_FONT,size: 10)
        self.reviewDateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        if Utility.shared.isRTLLanguage() {
            if(self.backGroundImageView != nil) {
            self.backGroundImageView.performRTLTransform()
            }
        }
    }
    
}
