
import UIKit

class ReviewInstantCells: UITableViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var tickImgView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet var contentLblBottom: NSLayoutConstraint!
    @IBOutlet var contentlblTop: NSLayoutConstraint!
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.textColor = UIColor(named: "Title_Header")
        contentLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        contentLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
