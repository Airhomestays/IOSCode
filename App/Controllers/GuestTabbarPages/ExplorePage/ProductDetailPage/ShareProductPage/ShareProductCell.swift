

import UIKit

class ShareProductCell: UITableViewCell {
    @IBOutlet weak var imgBckgrdView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        if IS_IPHONE_5{
           imgBckgrdView.frame = CGRect(x: (self.frame.size.width/2-165), y: (self.frame.size.height/2-150), width: 265, height: 300)
       }
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
