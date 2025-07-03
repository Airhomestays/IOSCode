
import UIKit

class ItenaryImageCell: UITableViewCell {
    
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingStarImg: UIImageView!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    
    
    @IBOutlet var topConstant: NSLayoutConstraint!
    @IBOutlet var lineview: UILabel!
    
    @IBOutlet var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var listLocationLabel: UILabel!
    @IBOutlet weak var listTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        listTitleLabel.textColor = UIColor(named: "Title_Header")
        listTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        listTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15.0)
        listTitleLabel.backgroundColor = .clear
        
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        listLocationLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        listLocationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        listLocationLabel.font = UIFont(name: APP_FONT, size: 12.0)
        listLocationLabel.backgroundColor = .clear
        
        ratingCountLabel.textColor = UIColor(named: "Title_Header")
        ratingCountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        ratingCountLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        
        ratingLabel.textColor = UIColor(named: "Title_Header")
        ratingLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        ratingLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        
        
        ratingView.backgroundColor = .clear
        listImage.layer.cornerRadius = 15
        listImage.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
