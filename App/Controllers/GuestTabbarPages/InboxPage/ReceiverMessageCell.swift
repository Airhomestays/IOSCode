

import UIKit

class ReceiverMessageCell: UITableViewCell {

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var circleIndicationView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var receiverDateLabel: UILabel!
    @IBOutlet weak var receiverMsgLabel: UILabel!
    
    @IBOutlet var curveView: UIImageView!
    
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var dateLAbel: UILabel!
    @IBOutlet weak var requestLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        requestLabel.font = UIFont(name: APP_FONT, size: 14)
        requestLabel.textColor = UIColor(named: "Title_Header")
        requestLabel.textAlignment = .center
        
        dateLAbel.font = UIFont(name: APP_FONT, size: 12)
        dateLAbel.textColor = UIColor(named: "searchPlaces_TextColor")
        dateLAbel.textAlignment = .center
        
        receiverMsgLabel.font = UIFont(name: APP_FONT, size: 16)
        receiverMsgLabel.textColor = UIColor(named: "Title_Header")
        receiverMsgLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        receiverDateLabel.font = UIFont(name: APP_FONT, size: 12)
        receiverDateLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        receiverDateLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        circleIndicationView.layer.cornerRadius = circleIndicationView.frame.size.height/2
        circleIndicationView.clipsToBounds = true

        topLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        bottomLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")

        receiverView.backgroundColor =  UIColor(named: "Button_Grey_Color")

        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.masksToBounds = true
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
            receiverView.halfroundedCorners(corners: [.topLeft, .bottomLeft, .bottomRight], radius: 8.0)
        }else{
            receiverView.halfroundedCorners(corners: [.topRight, .bottomLeft, .bottomRight], radius: 8.0)
        }
    }
}
