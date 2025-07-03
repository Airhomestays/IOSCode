
import UIKit
import SwiftMessages

class SwitchtohostCell: UITableViewCell {

    @IBOutlet weak var profileSettingLabel: UILabel!

    @IBOutlet weak var profilesettingImagewidth: NSLayoutConstraint!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var profilesettingImage: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var profilesettingtrailingconstraint: NSLayoutConstraint!
    @IBOutlet weak var profileRightValueLabel: UILabel!
    @IBOutlet weak var profileLblLeadingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileSettingLabel.font = UIFont(name: APP_FONT, size: 14)
        if(Utility.shared.isRTLLanguage()) {
            profilesettingImage.performRTLTransform() }
        
        lineLabel.backgroundColor =  UIColor(named: "Review_Page_Line_Color")
        
        profileRightValueLabel.isHidden = true
        profileRightValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        profileRightValueLabel.textColor = Theme.Button_BG
        profileRightValueLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        
        profileSettingLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
