

import UIKit

class ReviewlistCellTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var profileImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
  
            nameLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
         dateLabel.font = UIFont(name: APP_FONT, size: 14)
         messageLabel.font = UIFont(name: APP_FONT, size: 15)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
