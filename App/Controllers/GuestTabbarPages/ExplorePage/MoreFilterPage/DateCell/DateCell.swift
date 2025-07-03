

import UIKit

class DateCell: UITableViewCell {

    @IBOutlet var rightArrow: UIImageView!
    @IBOutlet var dateBtn: UIButton!
    @IBOutlet var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet var dateBtnLeading: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        if(Utility.shared.isRTLLanguage()){
           
            rightArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        
        dateView.layer.cornerRadius = (dateView.frame.size.height / 2)
        dateBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        dateLabel.textColor = UIColor(named: "Title_Header")
        dateView.layer.masksToBounds = true
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
