
import UIKit

class StepPublishCell: UITableViewCell {
    
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var listnameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        previewBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"previewlist"))!)  ", for:.normal)
        
        previewBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        publishBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        
        publishBtn.setTitleColor(UIColor.white, for: .normal)
        
        listnameLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        listnameLabel.textColor =  UIColor(named: "Title_Header")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
