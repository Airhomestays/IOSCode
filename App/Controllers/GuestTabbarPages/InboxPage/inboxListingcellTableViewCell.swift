
import UIKit

class inboxListingcellTableViewCell: UITableViewCell {

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var circleIndicationView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLAbel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var dateLAbel: UILabel!
    @IBOutlet weak var requestLAbel: UILabel!
    
    @IBOutlet var curveView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        requestLAbel.font = UIFont(name: APP_FONT, size: 14)
        requestLAbel.textColor = UIColor(named: "Title_Header")
        requestLAbel.textAlignment = .center
        
        dateLAbel.font = UIFont(name: APP_FONT, size: 12)
        dateLAbel.textColor = UIColor(named: "searchPlaces_TextColor")
        dateLAbel.textAlignment = .center
        
        messageLAbel.font = UIFont(name: APP_FONT, size: 16)
        messageLAbel.textColor = UIColor(named: "Title_Header")
        messageLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        messageDateLabel.font = UIFont(name: APP_FONT, size: 12)
        messageDateLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        messageDateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        circleIndicationView.layer.cornerRadius = circleIndicationView.frame.size.height/2
        circleIndicationView.clipsToBounds = true

        topLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        bottomLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")

        senderView.backgroundColor = UIColor(named: "sendMessageBGColor")
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        curveView.image = #imageLiteral(resourceName: "blue-center").withRenderingMode(.alwaysTemplate)
        curveView.tintColor = UIColor(named: "sendMessageBGColor")
       if Utility.shared.isRTLLanguage(){
        curveView.performRTLTransform()
        senderView.halfroundedCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 8.0)
        }else{
            senderView.halfroundedCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 8.0)
       }
    }
    
}
