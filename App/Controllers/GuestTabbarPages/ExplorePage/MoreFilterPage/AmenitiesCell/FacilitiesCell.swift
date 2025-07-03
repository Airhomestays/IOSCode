

import UIKit

class FacilitiesCell: UITableViewCell {
    
    @IBOutlet var amenitieslistTile: UILabel!
    
    @IBOutlet weak var facilitiesImgIcon: UIImageView!
    
    @IBOutlet var checkBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.layer.borderWidth = 1.5
        checkBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        amenitieslistTile.font = UIFont(name: APP_FONT, size: 14)
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
