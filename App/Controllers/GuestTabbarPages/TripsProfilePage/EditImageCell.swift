
import UIKit

class EditImageCell: UITableViewCell {

    @IBOutlet var uploadBtn: UIButton!
    @IBOutlet weak var editProfileimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editProfileimage.layer.cornerRadius = editProfileimage.frame.size.height/2
        editProfileimage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
