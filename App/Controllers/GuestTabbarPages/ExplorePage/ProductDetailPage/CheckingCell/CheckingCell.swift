

import UIKit

class CheckingCell: UITableViewCell {

    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var flexLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

              checkLabel.font = UIFont(name: APP_FONT, size: 17)
         flexLabel.font = UIFont(name: APP_FONT, size: 17)
        if(Utility.shared.isRTLLanguage()) {
            flexLabel.textAlignment = .left
        } else {
            flexLabel.textAlignment = .right
        }
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
