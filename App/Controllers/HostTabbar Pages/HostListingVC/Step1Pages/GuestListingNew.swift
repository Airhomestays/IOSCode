
import UIKit

class GuestListingNew: UITableViewCell {
    
    @IBOutlet var lineView: UILabel!
    @IBOutlet var arrow_img: UIImageView!
    @IBOutlet var btn: UIButton!
    @IBOutlet var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(Utility.shared.isRTLLanguage()){
            arrow_img.performRTLTransform()
        }
        
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
