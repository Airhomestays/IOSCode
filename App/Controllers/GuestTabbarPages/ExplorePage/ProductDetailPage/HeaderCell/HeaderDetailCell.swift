

import UIKit

class HeaderDetailCell: UITableViewCell {
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var hostedLabel: UILabel!
    @IBOutlet weak var customcountryLabel: UILabel!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var entireLabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        entireLabel.textColor = Theme.ENTIRE_COLOR
 
             entireLabel.font = UIFont(name: APP_FONT_BOLD, size: 17)
         itemTitleLabel.font = UIFont(name: APP_FONT_BOLD, size: 28)
         customcountryLabel.font = UIFont(name: APP_FONT, size: 15)
         hostedLabel.font = UIFont(name: APP_FONT, size: 15)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
