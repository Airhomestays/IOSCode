
import UIKit

class addPhotosCell: UITableViewCell {

    @IBOutlet weak var addphotosTitleLabel: UILabel!
    
    @IBOutlet weak var photosdescLabel: UILabel!
    @IBOutlet weak var addphotoBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        addphotoBtn.layer.cornerRadius = 4.0
        addphotoBtn.layer.masksToBounds = true
        
        addphotoBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"addphotos"))!)", for:.normal)
        
        addphotosTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"addphotolist"))!)"
        photosdescLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"photolist_desc"))!)"
        addphotoBtn.backgroundColor = Theme.PRIMARY_COLOR
        
        
        
        addphotosTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 25)
        addphotoBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
        photosdescLabel.font = UIFont(name: APP_FONT, size: 19)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
