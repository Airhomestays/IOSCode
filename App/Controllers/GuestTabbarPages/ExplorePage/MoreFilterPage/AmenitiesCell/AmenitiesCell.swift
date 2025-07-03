
import UIKit
import SwiftMessages

class AmenitiesCell: UITableViewCell {
    
    @IBOutlet var amenitieslistTile: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var amenitiesImgIcon: UIImageView!
    
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var checkBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        amenitieslistTile.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        amenitieslistTile.textColor = UIColor(named: "Title_Header")
        amenitieslistTile.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        checkBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        checkBtn.layer.borderWidth = 1.0
        checkBtn.layer.cornerRadius = 5.0
        checkBtn.clipsToBounds = true
      
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
