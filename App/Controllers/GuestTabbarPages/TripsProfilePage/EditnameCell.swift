
import UIKit

class EditnameCell: UITableViewCell {

    
    @IBOutlet var arrowView: UIImageView!
    @IBOutlet var tfTrailing: NSLayoutConstraint!
    @IBOutlet weak var lineViewLabel: UILabel!
    @IBOutlet weak var EditProfileTF: CustomUITextField!
    @IBOutlet weak var textfieldNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textfieldNameLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        textfieldNameLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        textfieldNameLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
        EditProfileTF.textColor = Theme.PRIMARY_COLOR
        EditProfileTF.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        EditProfileTF.font = UIFont(name: APP_FONT, size: 12.0)
        
        lineViewLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        if Utility.shared.isRTLLanguage(){
            arrowView.performRTLTransform()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
