

import UIKit
import IQKeyboardManagerSwift
import Lottie

class EmailPageVC: UIViewController {
    
   
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var emailLAbel: UILabel!
    @IBOutlet weak var emailexistView: UIView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet weak var bottomconstraint: NSLayoutConstraint!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailexistLAbel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var nextBtn: UIButton!
    @IBOutlet var emailtickimg: UIImageView!
    @IBOutlet var lottieView: LottieAnimationView!
    @IBOutlet var emailView: UIView!
     
    var lottieWholeView = UIView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if Utility.shared.isRTLLanguage() {
             emailTF.textAlignment = .right
             backBtn.imageView?.performRTLTransform()
            nextBtn.imageView?.performRTLTransform()
         }
          self.initialSetup()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.lottieView.isHidden = true
       self.lottieWholeView.isHidden = true
        self.offlineView.isHidden = true
    }
       
    @IBAction func backBtnTapped(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
      
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    @IBAction func retryTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        self.checkexistingemailAPI()
        }
    }
    @IBAction func loginBtnTapped(_ sender: Any) {
        let loginObj = LoginPageVC()
        loginObj.modalPresentationStyle = .fullScreen
         self.present(loginObj, animated: false, completion: nil)
       
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
             self.view.endEditing(true)
            if (emailTF.text?.isValidEmail())! {

                self.offlineView.isHidden = true
                self.checkexistingemailAPI()
                
            } else {
                self.view.endEditing(true)
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"email_validalert"))!)")
            }
        } else {
            self.offlineView.isHidden = false
            emailTF.resignFirstResponder()
            self.lottieView.isHidden = true
            self.bottomView.isHidden = true
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineView.frame.size.width + shadowSize2,
                                                        height: self.offlineView.frame.size.height + shadowSize2))
            
            self.offlineView.layer.masksToBounds = false
            self.offlineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineView.layer.shadowOpacity = 0.3
            self.offlineView.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-75, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func initialSetup()
    {
        emailView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        emailtickimg.isHidden = true
        self.offlineView.isHidden = true
        nextBtn.layer.cornerRadius = nextBtn.frame.size.width/2
        nextBtn.clipsToBounds = true
        emailTF.becomeFirstResponder()
        lottieView.isHidden = true
        emailTF.autocorrectionType = UITextAutocorrectionType.no
        emailTF.text = ""
        emailexistView.isHidden = true
        Utility.shared.signupArray.add("")
        self.emailView.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        self.view.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        
        if((Utility.shared.signupArray[2] as! String) != ""){
            emailTF.text = (Utility.shared.signupArray[2] as! String)
            
        }
        
        if (!(Utility.shared.checkEmptyWithString(value: emailTF.text!))) {
            self.configureNextBtn(enable: true)
            
        } else {
            self.configureNextBtn(enable: false)
        }
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        lottieView = LottieAnimationView.init(name: "loading_qwe")

        emailTF.addTarget(self, action: #selector(EmailPageVC.textFieldDidChange(_:)),
                            for: UIControl.Event.editingChanged)
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        emailLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"email_address"))!)"
        info.text = "\((Utility.shared.getLanguage()?.value(forKey:"email_info"))!)"
        emailexistLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"emailexist"))!)"
        emailTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"andyouremail"))!)"
        loginBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"login_string"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        
        emailTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 30)
        emailLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        emailTF.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        info.font = UIFont(name: APP_FONT, size: 17)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
             retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        info.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
    }
    
    func configureNextBtn(enable:Bool){
        if(enable){
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.alpha = 1.0
        } else {
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
        }
    }
    func checkexistingemailAPI()
    {
        emailTF.resignFirstResponder()
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.lottieWholeView.backgroundColor =  UIColor.clear
        self.emailView.addSubview(lottieWholeView)
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.white
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        let checkemail = CheckEmailExistsQuery(email: emailTF.text!)
        apollo.fetch(query: checkemail,cachePolicy:.fetchIgnoringCacheData){ (result,error) in
            
            if(result?.data?.validateEmailExist?.status == 200){
                self.nextBtn.isHidden = false
                if Utility.shared.signupArray.count >= 3 {
                Utility.shared.signupArray.replaceObject(at: 2, with: self.emailTF.text! as AnyObject)
                }
    
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                let passwordObj = PasswordVC()
                passwordObj.modalPresentationStyle = .fullScreen
                 self.present(passwordObj, animated: false, completion: nil)
              
            })
            } else {
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.bottomView.isHidden = true
                self.nextBtn.isHidden = true
                self.emailexistView.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR {
                self.emailexistView.frame = CGRect(x: 0, y: FULLHEIGHT-80, width: FULLWIDTH, height: 60)
                   
                } else {
                    self.emailexistView.frame = CGRect(x: 0, y: FULLHEIGHT-60, width: FULLWIDTH, height: 60)
                }
            }
        }
    }
    
 
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
 
        self.bottomconstraint.constant = keyboardFrame.height 
        self.bottomView.frame.origin.y = keyboardFrame.origin.y - 75
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomconstraint.constant = 35
        self.bottomView.frame.origin.y = FULLHEIGHT - 90
        
        if (emailTF.text?.isValidEmail())! {
            self.configureNextBtn(enable: true)
            
        } else{
            self.configureNextBtn(enable: false)
        }
    }
    
    fileprivate func emailValidation () {
        if (emailTF.text?.isValidEmail())! {
            if self.emailtickimg.isHidden {
                self.emailtickimg.image = nil
                self.emailtickimg.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.emailtickimg, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.emailtickimg.image = #imageLiteral(resourceName: "right_white")
                    self.emailtickimg.transform = expandTransform
                },
                                  completion: {(finished: Bool) in
                                    UIView.animate(withDuration: 0.5,
                                                   delay:0.0,
                                                   usingSpringWithDamping:0.40,
                                                   initialSpringVelocity:0.2,
                                                   options:UIView.AnimationOptions.curveEaseOut,
                                                   animations: {
                                                    self.emailtickimg.transform = expandTransform.inverted()
                                    }, completion:nil)
                })
            }
        } else {
            if !self.emailtickimg.isHidden {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    self.emailtickimg.alpha = 0
                    self.nextBtn.isUserInteractionEnabled = false
                    self.nextBtn.alpha = 0.7
                }, completion: { (comp) in
                   self.emailtickimg.isHidden = true
                    self.emailtickimg.alpha = 1
                    self.emailtickimg.image = nil
                    self.configureNextBtn(enable: false)
                })
                }else{
                
            }
        }
    }
    
   
}

    extension EmailPageVC:UITextFieldDelegate{
    
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
        self.bottomView.isHidden = false
         self.emailexistView.isHidden = true
            nextBtn.isHidden = false
        }
    
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
        {
        

        return true
}
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == emailTF {
            
            self.emailValidation()
        }
        if (emailTF.text?.isValidEmail())! {
            
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.alpha = 1.0
            
        }else {
           
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTF{
            if !(emailTF.text?.isValidEmail())!{
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"email_validalert"))!)")
              
            }
        }
    }
}
extension String {
    var isBackspace: Bool {
        let char = self.cString(using: String.Encoding.utf8)!
        return strcmp(char, "\\b") == -92
    }
}
