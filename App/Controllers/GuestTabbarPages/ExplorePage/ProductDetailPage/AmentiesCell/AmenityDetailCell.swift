

import UIKit

class AmenityDetailCell: UITableViewCell {
    
    @IBOutlet weak var amenityImage: UIImageView!
    @IBOutlet  var amenityLabel:UILabel!
    @IBOutlet weak var amenityLblLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var amenityImgLeading: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        amenityLabel.font = UIFont(name: APP_FONT, size: 14)
        amenityLabel.textColor = UIColor(named: "searchPlaces_TextColor")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
