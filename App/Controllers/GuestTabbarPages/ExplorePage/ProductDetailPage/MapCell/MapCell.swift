

import UIKit

class MapCell: UITableViewCell {

    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var mapMarkerView: UIView!
    @IBOutlet weak var centerCircleView: UIImageView!
    @IBOutlet weak var mapView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

              mapLabel.font = UIFont(name: APP_FONT, size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
