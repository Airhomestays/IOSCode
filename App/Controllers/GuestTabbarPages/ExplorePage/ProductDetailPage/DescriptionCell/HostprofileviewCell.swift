
import UIKit

class HostprofileviewCell: UITableViewCell {

    @IBOutlet var cityLbl: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var memberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 47
        profileImage.layer.masksToBounds = true
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        nameLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        cityLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        memberLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 13)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
