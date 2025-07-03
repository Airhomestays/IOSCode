
import UIKit

class EmailGoogleFBTableViewCell: UITableViewCell {
    
    @IBOutlet var NewView: UIView!
    @IBOutlet var title_label: UILabel!
    @IBOutlet var logo_imageView: UIImageView!
    @IBOutlet var des_text_label: UILabel!
    @IBOutlet var action_Button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title_label.textColor =  UIColor(named: "Title_Header")
        action_Button.setTitleColor(UIColor.white, for:.normal)

        action_Button.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 13)
               title_label.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        des_text_label.font = UIFont(name: APP_FONT, size: 14)
               
        if(Utility.shared.isRTLLanguage()) {
            des_text_label.textAlignment = .right
        } else {
            des_text_label.textAlignment = .left
        }
        NewView.dropShadow(scale: true)
        
        self.action_Button.layer.borderWidth = 1.5
        self.action_Button.layer.borderColor = Theme.Button_BG.cgColor
        self.action_Button.backgroundColor = Theme.Button_BG
        self.action_Button.layer.cornerRadius = self.action_Button.frame.size.height / 2
        self.action_Button.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
