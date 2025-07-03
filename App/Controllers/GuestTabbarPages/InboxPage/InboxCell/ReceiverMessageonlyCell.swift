
import UIKit

class ReceiverMessageonlyCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var curveView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var receiverView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        messageLabel.font = UIFont(name: APP_FONT, size: 18)
        dateLabel.font = UIFont(name: APP_FONT, size: 14)
        
        messageLabel.font = UIFont(name: APP_FONT, size: 16)
        messageLabel.textColor = UIColor(named: "Title_Header")
        messageLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        dateLabel.font = UIFont(name: APP_FONT, size: 12)
        dateLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        dateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        profileimage.layer.cornerRadius = profileimage.frame.size.height / 2
        profileimage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        curveView.image = #imageLiteral(resourceName: "grey-centers").withRenderingMode(.alwaysTemplate)
        curveView.tintColor = UIColor(named: "Button_Grey_Color")
        if Utility.shared.isRTLLanguage(){
        curveView.performRTLTransform()
        }else{
        }
    }
    
}
