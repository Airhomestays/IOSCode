
import UIKit

class BankDetCell: UITableViewCell {
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTtl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        if(IS_IPHONE_XR || IS_IPHONE_X || IS_IPHONE_XS_MAX || IS_IPHONE_PLUS) {
            self.detailView.frame.size.width = FULLWIDTH-40
        }
        
        self.detailView.layer.cornerRadius = 5.0
        self.detailView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        self.detailView.layer.borderWidth = 1.0
        self.detailView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
