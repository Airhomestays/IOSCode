

import UIKit

class ReviewUserCell: UITableViewCell {

    @IBOutlet var lineview: UILabel!
    @IBOutlet var reviewImg: UIImageView!
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var reviewBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"reviews"))!)"
        reviewLabel.textColor = UIColor(named: "Title_Header")
        reviewBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        reviewBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        reviewLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        if(Utility.shared.isRTLLanguage()) {
            reviewBtn.contentHorizontalAlignment = .right
            reviewImg.performRTLTransform()
        }
        
        if(Utility.shared.isRTLLanguage()) {
            reviewLabel.textAlignment = .right
        } else {
            reviewLabel.textAlignment = .left
        }
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
