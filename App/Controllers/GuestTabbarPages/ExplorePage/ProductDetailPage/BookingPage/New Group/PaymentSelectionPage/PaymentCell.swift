

import UIKit

class PaymentCell: UITableViewCell {

    @IBOutlet var rightArrowimg: UIImageView!
    @IBOutlet var aboutLabel: UILabel!
    
    @IBOutlet var typeImg: UIImageView!
    
    @IBOutlet var lineLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        self.aboutLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
