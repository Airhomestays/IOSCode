
import UIKit

class TopCollectioViewCell: UICollectionViewCell {
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var topImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.underlineView.alpha = 0.0
        showUnderline(index: 0, currentIndex: 0)
    }
    
    func showUnderline(index: Int, currentIndex: Int) {
        if index == currentIndex {
            nameLbl.textColor = UIColor(named: "Title_Header")
            topImg.tintColor = UIColor(named: "Title_Header")
            underlineView.backgroundColor = UIColor(named: "Title_Header")
        } else {
            nameLbl.textColor = UIColor.grayColor()
            topImg.tintColor = UIColor.grayColor()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.underlineView.alpha = index != currentIndex ? 0.0 : 1.0
            self.underlineView.transform = index != currentIndex ? CGAffineTransform(scaleX: 0.0, y: 1.0) : .identity
        }, completion: nil)
    }
}
