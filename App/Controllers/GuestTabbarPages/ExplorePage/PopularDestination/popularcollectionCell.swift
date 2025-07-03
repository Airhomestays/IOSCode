
import UIKit


class popularcollectionCell: UICollectionViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popularImage:UIImageView!
    @IBOutlet weak var popularLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        popularLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        widthConstraint.constant = 125
        heightConstraint.constant = 150
        
        
    }

    override func layoutSubviews() {
        self.shadowView.skeletonCornerRadius = 15
    }
    
}
