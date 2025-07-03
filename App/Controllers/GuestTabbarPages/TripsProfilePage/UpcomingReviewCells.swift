

import UIKit

class UpcomingReviewCells: UITableViewCell {

    @IBOutlet weak var viewBackgroundCell: UIView!
    
    
    @IBOutlet var lineview: UILabel!
    @IBOutlet weak var BackGroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var writeReviewView: UIView!
    @IBOutlet weak var writeReviewIcon: UIImageView!
    @IBOutlet weak var writeReviewTitle: UILabel!
    @IBOutlet weak var writeReviewBtn: UIButton!
    
    @IBOutlet weak var viewItenary: UIView!
    @IBOutlet weak var viewItenaryIcon: UIImageView!
    @IBOutlet weak var viewItenaryTitle: UILabel!
    @IBOutlet weak var viewItenaryBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImage.layer.cornerRadius = 24
        self.profileImage.clipsToBounds = true
        
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
       
        
        self.writeReviewTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "Writereviewsmall") ?? "Write a review")"
        self.viewItenaryTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "View_Itinerary_small") ?? "View itinerary")"
        
        self.writeReviewTitle.font = UIFont(name: APP_FONT, size: 12)
        self.viewItenaryTitle.font = UIFont(name: APP_FONT, size: 12)
        
        self.writeReviewTitle.textColor = Theme.PRIMARY_COLOR
        self.viewItenaryTitle.textColor = Theme.PRIMARY_COLOR
        
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        self.viewBackgroundCell.layer.cornerRadius = 8
        self.viewBackgroundCell.layer.masksToBounds = true
        self.viewBackgroundCell.layer.borderWidth = 1.0
        self.viewBackgroundCell.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        
        if Utility.shared.isRTLLanguage() {
            if(self.BackGroundImage != nil) {
            self.BackGroundImage.performRTLTransform()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
