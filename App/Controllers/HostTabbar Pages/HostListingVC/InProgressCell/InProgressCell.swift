
import UIKit

class InProgressCell: UITableViewCell {
    
    @IBOutlet weak var inprogressView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nextLabel: UIImageView!
    @IBOutlet weak var completeStateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        if(IS_IPHONE_XR || IS_IPHONE_PLUS) {
            self.inprogressView.frame.size.width = FULLWIDTH-40
        } else if IS_IPHONE_5 {
            self.inprogressView.frame.size.width = FULLWIDTH - 40
        }
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y:2)
        self.inprogressView.halfroundedCorners(corners: [.topLeft,.bottomRight], radius: 15.0)
        self.listImage.halfroundedCorners(corners: [.topLeft,.bottomRight], radius: 15.0)
        self.listImage.layer.masksToBounds = true
        
        self.nextLabel.image = self.nextLabel.image?.withRenderingMode(.alwaysTemplate)
        self.nextLabel.tintColor = UIColor.lightGray
        progressBar.progressTintColor = Theme.PRIMARY_COLOR
        
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        updateDateLabel.font = UIFont(name: APP_FONT, size: 13)
        completeStateLabel.font = UIFont(name: APP_FONT, size: 13)
        if Utility.shared.isRTLLanguage() {
            nextLabel.performRTLTransform()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
