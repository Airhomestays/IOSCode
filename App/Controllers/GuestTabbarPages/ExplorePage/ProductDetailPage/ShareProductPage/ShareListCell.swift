

import UIKit

class ShareListCell: UITableViewCell {
    @IBOutlet weak var shareImg: UIImageView!
    
    @IBOutlet var lineView: UILabel!
    @IBOutlet weak var shareTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        self.backgroundColor =   UIColor(named: "colorController")
                     shareTitle.font = UIFont(name: APP_FONT, size: 18)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
