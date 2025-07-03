
import UIKit

class UpdatedEditAboutCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var actionTitleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var actionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = UIColor(named: "Title_Header")
        titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        descLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        descLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        descLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        actionTitleLabel.textColor = Theme.PRIMARY_COLOR
        actionTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        actionTitleLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        actionBtn.setTitle("", for: .normal)
        actionBtn.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
