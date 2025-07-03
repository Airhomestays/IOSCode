
import UIKit

class FeedbackFooterCell: UITableViewCell {

    @IBOutlet weak var bugImgView: UIImageView!
    @IBOutlet weak var feedbckImgView: UIImageView!
    @IBOutlet weak var bugBtn: UIButton!
    @IBOutlet weak var feedbcakcBtn: UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedbcakcBtn.layer.cornerRadius = 5.0
        feedbcakcBtn.layer.masksToBounds = true
        feedbcakcBtn.layer.borderWidth = 1.0
        feedbcakcBtn.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        
        bugBtn.layer.cornerRadius = 5.0
        bugBtn.layer.masksToBounds = true
        bugBtn.layer.borderWidth = 1.0
        bugBtn.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        
        if(Utility.shared.isRTLLanguage()) {
            feedbcakcBtn.contentHorizontalAlignment = .right
            feedbcakcBtn.titleEdgeInsets = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 15)
            bugBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
            bugBtn.contentHorizontalAlignment = .right
            feedbckImgView.performRTLTransform()
        }
        titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"whtwould"))!)"
        titleLabel.textColor = UIColor(named: "Title_Header")
        titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        
        feedbcakcBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"givefeedbck"))!)", for: .normal)
        feedbcakcBtn.setTitleColor(UIColor(named: "searchPlaces_TextColor"), for: .normal)
        feedbcakcBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
        bugBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"reportbug"))!)", for: .normal)
        bugBtn.setTitleColor(UIColor(named: "searchPlaces_TextColor"), for: .normal)
        bugBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
