

import UIKit

class VerifiedInfoCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var imgLeftIcon: UIImageView!
    @IBOutlet weak var imgRightView: UIImageView!
    @IBOutlet weak var verifyConnectLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIImageView!
    @IBOutlet var info_button: UIButton!
    @IBOutlet weak var trailingConstraints: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraints: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.layer.cornerRadius = 10
        borderView.clipsToBounds = true
        borderView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        borderView.layer.borderWidth = 1.0
        
        titleLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        titleLabel.font = UIFont(name: APP_FONT, size: 13.0)
        
        verifyConnectLabel.font = UIFont(name: APP_FONT, size: 13.0)
        verifyConnectLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
