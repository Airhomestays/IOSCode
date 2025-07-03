

import UIKit
import IQKeyboardManagerSwift
import Apollo
import Lottie
import SwiftMessages

class ContactusVC: UIViewController,UITextViewDelegate {
  
    @IBOutlet weak var contactTextView: UITextView!
   
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var contactTitleLabel: UILabel!

    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var topView: UIView!
    var Listid = Int()
    var reservationid = Int()
    var lottieWholeView = UIView()
    var lottieView: LottieAnimationView!
    var placeholderLabel : UILabel!
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
       
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.initialSetup()
        if(Utility.shared.isRTLLanguage()) {
                    
            contactTextView.textAlignment = .right
                                
                                        }
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func lottieanimation()
    {
        lottieView = LottieAnimationView.init(name: "animation_white")
        self.lottieWholeView.isHidden = false
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:20, y:-25, width:100, height:100)
        self.sendBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.white
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    func initialSetup()
    {
        contactTextView.layer.borderWidth = 1.0;
        contactTextView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        contactTextView.layer.cornerRadius = 5.0
   
    contactTextView.isScrollEnabled = true
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        contactTextView.font = UIFont(name: APP_FONT, size: 14)
        lottieView = LottieAnimationView.init(name: "animation_white")
        contactTextView.delegate = self
        contactTextView.returnKeyType = .default
        contactTextView.isEditable = true
        contactTextView.text = ""
        contactTextView.isScrollEnabled = true
        placeholderLabel = UILabel()
        placeholderLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"writemessage"))!)"
        placeholderLabel.font = contactTextView.font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        contactTextView.addSubview(placeholderLabel)
        placeholderLabel.frame = CGRect(x:9, y:3, width:contactTextView.frame.size.width-20, height:30)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !contactTextView.text.isEmpty
        
      
         contactTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"contactus"))!)"
        let cancel = "\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)"
        let send = "\((Utility.shared.getLanguage()?.value(forKey:"send"))!)"
      
        cancelBtn.setTitle(cancel.capitalized, for: .normal)
        sendBtn.setTitle(send, for: .normal)
     
        cancelBtn.titleLabel?.textColor = Theme.PRIMARY_COLOR
        
        contactTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        sendBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        cancelBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
    }
    
  
   
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(contactTextView.text == "") {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"messagealert"))!)")
            } else {
                self.contactSupportAPICall(message: contactTextView.text, listId: Listid, reservationId: reservationid, userType:GUEST)
            }
        }
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
           
            self.lottieView.isHidden = false
            self.lottieWholeView.isHidden = false
            self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
            self.view.addSubview(lottieWholeView)
            self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
            self.lottieWholeView.addSubview(self.lottieView)
            self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
            self.lottieView.layer.cornerRadius = 6.0
            self.lottieView.clipsToBounds = true
            self.lottieView.play()
            self.contactSupportAPICall(message: contactTextView.text, listId: Listid, reservationId: reservationid, userType:GUEST)
        }
    }
    func contactSupportAPICall(message:String,listId:Int,reservationId:Int,userType:String)
    {
        let contactsupportQuery = ContactSupportQuery(message: message, listId: listId, reservationId: reservationId, userType: userType)
        apollo_headerClient.fetch(query: contactsupportQuery){(result,error) in
            if(result?.data?.contactSupport?.status) != 200 {
                self.view.makeToast(result?.data?.contactSupport?.errorMessage)
                return
            }
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"contacthost_alert"))!)")
            self.lottieView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 250
    }
}
