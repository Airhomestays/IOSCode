

import UIKit

class homelistingCell: UITableViewCell {
    @IBOutlet weak var heightConstraint:NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var widthConstraint:NSLayoutConstraint!
    @IBOutlet weak var exploreCollection:UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
