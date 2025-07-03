
import UIKit

class bookcancellationCell: UITableViewCell {

    @IBOutlet var lineView: UILabel!
    @IBOutlet weak var cancelpolicycontentLabel: UILabel!
    @IBOutlet weak var cancelpolicyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        cancelpolicyLabel.font = UIFont(name: APP_FONT, size: 16)
        cancelpolicyLabel.textColor = UIColor(named: "Title_Header")
        cancelpolicycontentLabel.font = UIFont(name: APP_FONT, size: 16)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
