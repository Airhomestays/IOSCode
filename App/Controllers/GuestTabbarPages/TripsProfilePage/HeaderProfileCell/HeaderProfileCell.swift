
import UIKit

class HeaderProfileCell: UITableViewCell {
    
    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var headerimage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"viewprofile"))!)"
        viewLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        profileName.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        profileName.textColor = UIColor(named: "Title_Header")
        viewLabel.font = UIFont(name: APP_FONT, size: 13)
              
        if(Utility.shared.isRTLLanguage()){
            headerimage.performRTLTransform()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
