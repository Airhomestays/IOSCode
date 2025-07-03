
import UIKit

class ManageAccVC: UIViewController {
    
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var lblmanageAcc: UILabel!
    @IBOutlet var btnDelAcc: UIButton!
    
    @IBOutlet var topView: UIView!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var lblDelAcc: UILabel!
    @IBOutlet var lblCaution: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblmanageAcc.text = "\(Utility.shared.getLanguage()?.value(forKey:"manage_acc") ?? "Manage your account")"
        lblmanageAcc.textColor = UIColor(named: "Title_Header")
        lblmanageAcc.font = UIFont(name:APP_FONT_MEDIUM, size: 18)
        
        btnDelAcc.titleLabel?.font = UIFont(name:APP_FONT_MEDIUM, size: 16)
        btnDelAcc.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        lblCaution.font = UIFont(name:APP_FONT, size: 16)
        lblDelAcc.font = UIFont(name: APP_FONT, size: 14)
        
        
        
        
        btnDelAcc.setImage(#imageLiteral(resourceName: "DeleteAcc").withRenderingMode(.alwaysTemplate), for: .normal)
        btnDelAcc.tintColor = UIColor(named: "Title_Header")
        
        let boldAttribute = [
            NSAttributedString.Key.font: UIFont(name:APP_FONT_BOLD, size: 14.0)!
        ]
        let regularAttribute = [
            NSAttributedString.Key.font: UIFont(name:APP_FONT, size: 14.0)!
        ]
        let boldText = NSAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"caution") ?? "Caution:") ", attributes: boldAttribute)
        let regularText = NSAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"deleteCaution") ?? "All of your data and current reservations and bookings will be lost if you delete your RentALL account.")", attributes: regularAttribute)
        let newString = NSMutableAttributedString()
        newString.append(boldText)
        newString.append(regularText)
        lblCaution.attributedText = newString
        
        lblCaution.textColor = UIColor(named: "searchPlaces_TextColor")
        topView.backgroundColor = UIColor(named: "colorController")
        
        lblDelAcc.text = "\(Utility.shared.getLanguage()?.value(forKey:"ConfirmDeelete") ?? "Delete your account permanently")"
        btnDelAcc.setTitle("   \(Utility.shared.getLanguage()?.value(forKey:"deleteaccount") ?? "Delete account")   ", for: .normal)
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.topView.frame.size.width + shadowSize,
                                                   height: self.topView.frame.size.height + shadowSize))
        
        self.topView.layer.masksToBounds = false
        self.topView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.topView.layer.shadowOpacity = 0.3
        self.topView.layer.shadowPath = shadowPath.cgPath
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if(Utility.shared.isRTLLanguage()) {
            backBtn.imageView?.performRTLTransform()
            imgArrow.performRTLTransform()
            lblCaution.textAlignment = .right
        }
        else{
            
        }
        
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func deleteAccTapped(_ sender: Any) {
        
        let deleteObj = DeleteAccountVC()
        deleteObj.modalPresentationStyle = .overFullScreen
        self.present(deleteObj, animated: false, completion: nil)
    }
    
}
