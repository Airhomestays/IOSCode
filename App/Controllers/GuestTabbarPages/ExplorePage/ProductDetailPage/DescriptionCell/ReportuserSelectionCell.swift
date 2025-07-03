

import UIKit

class ReportuserSelectionCell: UITableViewCell {
    
    

    @IBOutlet var lineview: UIView!
    @IBOutlet var selectionImg: UIImageView!
    @IBOutlet var reportuserLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        reportuserLabel.textColor = UIColor(named: "Title_Header")
             reportuserLabel.font = UIFont(name: APP_FONT, size: 16)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
