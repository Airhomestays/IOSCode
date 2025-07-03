
import UIKit

class StepTwoCell: UITableViewCell {
    @IBOutlet weak var stepLabel: UILabel!
    
    @IBOutlet var editTrailingConstraints: NSLayoutConstraint!
    @IBOutlet var editBottomConstraints: NSLayoutConstraint!
    @IBOutlet var editTopConstraints: NSLayoutConstraint!
    @IBOutlet var editLbl: UILabel!
    
    @IBOutlet weak var stepTitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var verifyImage: UIImageView!
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet var stepImg: UIImageView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var arrow_img: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        changeBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        stepLabel.font = UIFont(name: APP_FONT, size: 16)
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        descriptionLabel.font = UIFont(name: APP_FONT, size: 14)
        
        descriptionLabel.textColor = UIColor(named: "Title_Header")!
        
        lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        containerView.layer.borderColor =  UIColor(named: "Review_Page_Line_Color")?.cgColor
        containerView.borderWidth = 1.0
        
        
        containerView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        if(Utility.shared.isRTLLanguage()){
            editLbl.textAlignment = .left
            arrow_img.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
