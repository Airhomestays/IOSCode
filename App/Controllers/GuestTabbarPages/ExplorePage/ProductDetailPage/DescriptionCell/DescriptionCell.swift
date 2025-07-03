

import UIKit

class DescriptionCell: UITableViewCell {
    
 
    @IBOutlet weak var bedroomLabel: UILabel!
    @IBOutlet weak var privateBathLabel: UILabel!
    @IBOutlet weak var bedLabel: UILabel!
    @IBOutlet weak var guestLabel: UILabel!
    @IBOutlet weak var readmoreBtn: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        readmoreBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"readmore"))!)", for: .normal)
        readmoreBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        readmoreBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        guestLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
         bedroomLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
         descriptionLabel.font = UIFont(name: APP_FONT, size: 17)
         privateBathLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        descriptionTitle.font = UIFont(name: APP_FONT_BOLD, size: 17)
        descriptionTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "Description_Title") ?? "About this listing")"
         bedLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        if(Utility.shared.isRTLLanguage()) {
            
            readmoreBtn.titleLabel?.textAlignment = .right
        } else {
            readmoreBtn.titleLabel?.textAlignment = .left
        }
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
