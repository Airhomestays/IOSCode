

import UIKit

class bookingsteptwoCell: UITableViewCell {

    @IBOutlet weak var hostcontentLabel: UILabel!
    @IBOutlet weak var tellhostLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        tellhostLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"tellhost"))!)"
        hostcontentLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"tellhost_content"))!)"
        stepLabel.font = UIFont(name: APP_FONT, size: 16)
         tellhostLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 25)
         hostcontentLabel.font = UIFont(name: APP_FONT, size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
