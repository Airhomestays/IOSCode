

import UIKit

class EditAboutCell: UITableViewCell {
    
    @IBOutlet var width: NSLayoutConstraint!
    @IBOutlet var height: NSLayoutConstraint!
    @IBOutlet var appearanceImg: UIImageView!
    @IBOutlet var lineLbl: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var rightArrowimg: UIImageView!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        editLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"edit"))!)"
        editLabel.textColor = Theme.PRIMARY_COLOR
        phoneLabel.textColor = Theme.PRIMARY_COLOR
        aboutLabel.font = UIFont(name: APP_FONT, size: 18)
        editLabel.font = UIFont(name: APP_FONT, size: 18)
        phoneLabel.font = UIFont(name: APP_FONT, size: 18)
        
        aboutLabel.textColor =  UIColor(named: "Title_Header")
        
        lineLbl.backgroundColor = UIColor(named: "Review_Page_Line_Color")
  
        if(Utility.shared.isRTLLanguage()) {
            editLabel.textAlignment = .left
            phoneLabel.textAlignment = .left
           
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
