

import UIKit

class InboxCell: UITableViewCell {

    @IBOutlet weak var inboxTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        inboxTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"inbox"))!)"
        inboxTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 30)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
