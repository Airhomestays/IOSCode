

import UIKit

class bookinoneCell: UITableViewCell {

    @IBOutlet weak var outLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var bookstayLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var thingsLabel: UILabel!
    @IBOutlet weak var checkoutLabel: UILabel!
    @IBOutlet weak var checkinLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        checkinLabel.layer.cornerRadius = 5.0
        checkinLabel.layer.masksToBounds = true
        checkoutLabel.layer.cornerRadius = 5.0
        checkoutLabel.layer.masksToBounds = true
        bookstayLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"bookstay"))!)"
        checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkinn"))!)"
        
        outLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"checkoutt"))!)"
        
        thingsLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"thingskeep"))!)"
        stepLabel.font = UIFont(name: APP_FONT, size: 16)
        bookstayLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 25)
        outLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        checkoutLabel.font = UIFont(name: APP_FONT, size: 17)
        checkLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        thingsLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 25)
        checkinLabel.font = UIFont(name: APP_FONT, size: 17)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
