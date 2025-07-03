

import UIKit
import IQKeyboardManagerSwift
import Lottie
import Apollo

class LoginPageVC: UIViewController {

    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var emailTF: CustomUITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logintitleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var invalidLabel: UILabel!
    @IBOutlet var passwordTF: CustomUITextField!
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet var nextView: UIView!
    @IBOutlet var emailtickImg: UIImageView!
    
    @IBOutlet var passwordtickImg: UIImageView!
    
    @IBOutlet var signinView: UIView!
    @IBOutlet var GoBtn: UIButton!
    
    @IBOutlet var lottieView: LottieAnimationView!
    @IBOutlet var showBtn: UIButton!
    @IBOutlet weak var invalidcredentialView: UIView!
    

    @IBOutlet weak var showpasswordBtn: UIButton!

    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var offelineView: UIView!
    var lottieWholeView = UIView()
    var pasteEmail = String()
    var pastePassword = String()
   
    var passwordShow = true
    
    var Gobtn_Constraints = NSLayoutConstraint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       if Utility.shared.isRTLLanguage() {
           emailTF.textAlignment = .right
           passwordTF.textAlignment = .right
        
        logintitleLabel.textAlignment = .right
        emailLabel.textAlignment = .right
        passwordLabel.textAlignment = .right
           backBtn.imageView?.performRTLTransform()
        GoBtn.imageView?.performRTLTransform()
       }else{
        emailTF.textAlignment = .left
           passwordTF.textAlignment = .left
        
        logintitleLabel.textAlignment = .left
        emailLabel.textAlignment = .left
        passwordLabel.textAlignment = .left
        }
        passwordTF.clearsOnBeginEditing = false
        let rightToLeftTransition = CATransition()
        
        rightToLeftTransition.type = CATransitionType.push
        rightToLeftTransition.subtype = CATransitionSubtype.fromRight
        rightToLeftTransition.duration = 0.2
        rightToLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        rightToLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        
        if #available(iOS 11.0, *) {
            Gobtn_Constraints = GoBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        } else {
           
        }
       
        Gobtn_Constraints.isActive = true
       
    signinView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
      
        self.signinView.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        self.view.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        emailTF.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
        passwordTF.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
        logintitleLabel.font = UIFont(name: APP_FONT_BOLD, size: 35)
        invalidLabel.font = UIFont(name: APP_FONT, size: 20)
        emailLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        passwordLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
       
        forgotPasswordButton.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        showpasswordBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initialSetup()
        self.lottieView.isHidden = true
        self.lottieWholeView.isHidden = true
        self.pasteEmail = ""
        

       
    }

 
    @IBAction func retryTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        self.offelineView.isHidden = true
        self.lottieWholeView.isHidden = false
            
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.signinView.addSubview(lottieWholeView)
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y: FULLHEIGHT/2-40, width: 80, height: 80)
        self.signinView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        self.checkLoginAPI()
        }
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
    if Utility().isConnectedToNetwork(){
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.signinView.addSubview(lottieWholeView)
        self.offelineView.isHidden = true
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y: FULLHEIGHT/2-40, width: 80, height: 80)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        self.checkLoginAPI()
        }
        else{
            self.offelineView.isHidden = false
            if IS_IPHONE_X || IS_IPHONE_XR {
                self.offelineView.frame = CGRect(x: 0, y: FULLHEIGHT-80, width: FULLWIDTH, height: 60)
                
            }
            else{
                self.offelineView.frame = CGRect(x: 0, y: FULLHEIGHT-60, width: FULLWIDTH, height: 60)
            }
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offelineView.frame.size.width + shadowSize2,
                                                        height: self.offelineView.frame.size.height + shadowSize2))
            
            self.offelineView.layer.masksToBounds = false
            self.offelineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offelineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offelineView.layer.shadowOpacity = 0.3
            self.offelineView.layer.shadowPath = shadowPath2.cgPath
            self.passwordTF.resignFirstResponder()
            self.emailTF.resignFirstResponder()
            
        }
    }
    
    @IBAction func forgotBtnAction(_ sender: Any) {
        let forgotObj = ForgotPasswordVC()
        forgotObj.modalPresentationStyle = .fullScreen
        self.present(forgotObj, animated: false, completion: nil)
    
    }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
 
        let welcomeObj = WelcomePageVC()
        welcomeObj.modalPresentationStyle = .fullScreen
        self.present(welcomeObj, animated:false, completion: nil)
     
    }
    
    @IBAction func showBtnAction(_ sender: Any) {
        if(passwordShow){
            showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"hide"))!)", for: .normal)
            showBtn.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
            showpasswordBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"hidePassword"))!)", for: .normal)
            passwordTF.isSecureTextEntry = false
        }
        else {
            showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"show"))!)", for: .normal)
            showBtn.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
            showpasswordBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"showpassword"))!)", for: .normal)
            passwordTF.isSecureTextEntry = true
            passwordTF.clearsOnBeginEditing = false
        }
        passwordShow = !passwordShow
        if passwordTF!.isFirstResponder {
           self.becomeFirstResponder()
        }
    }
    override func becomeFirstResponder() -> Bool {
        
        let success = super.becomeFirstResponder()
       
        if passwordTF.isSecureTextEntry, let text = passwordTF.text {
            passwordTF.text?.removeAll()
            passwordTF.insertText(text)
        }
        return success
    }
    
    @IBAction func showPasswordAction(_ sender: Any) {
        if(passwordShow){
            showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"hide"))!)", for: .normal)
            showBtn.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
            showpasswordBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"hidePassword"))!)", for: .normal)
            passwordTF.isSecureTextEntry = false
        }
        else {
            showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"show"))!)", for: .normal)
            showBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size:17)
            showpasswordBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"showpassword"))!)", for: .normal)
            passwordTF.isSecureTextEntry = true
            passwordTF.clearsOnBeginEditing = false
        }
        passwordShow = !passwordShow
        if passwordTF!.isFirstResponder {
           becomeFirstResponder()
        }
    }
    
    func initialSetup()
    {
       
        emailtickImg.isHidden = true
        passwordtickImg.isHidden = true
        self.invalidcredentialView.isHidden = true
        self.offelineView.isHidden = true
        emailTF.text = ""
        passwordTF.text = ""
        GoBtn.layer.cornerRadius = GoBtn.frame.size.width/2
        GoBtn.clipsToBounds = true
        emailTF.becomeFirstResponder()
        self.lottieView.isHidden = true
        
        forgotPasswordButton.frame = CGRect(x: FULLWIDTH-210, y: 47, width: 200, height: 30)
        
        if (!((Utility.shared.checkEmptyWithString(value: emailTF.text!)) && (Utility.shared.checkEmptyWithString(value: passwordTF.text!)))) {
            self.configureNextBtn(enable: true)
            
        }
        else{
            self.configureNextBtn(enable: false)
        }
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.lottieView = LottieAnimationView.init(name: "loading_qwe")
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailTF.autocorrectionType = UITextAutocorrectionType.no
        passwordTF.autocorrectionType = UITextAutocorrectionType.no
        if passwordTF!.isFirstResponder {
            self.becomeFirstResponder()
        }
        emailTF.addTarget(self, action: #selector(EmailPageVC.textFieldDidChange(_:)),
                          for: UIControl.Event.editingChanged)
        passwordTF.addTarget(self, action: #selector(EmailPageVC.textFieldDidChange(_:)),
                          for: UIControl.Event.editingChanged)
        logintitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"login_string"))!)"
         emailLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"email_address"))!)"
         passwordLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"password"))!)"
         logintitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"login_string"))!)"
         errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
         invalidLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"invalid_credentials"))!)"
        showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"show"))!)", for:.normal)
        showpasswordBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"showpassword"))!)", for:.normal)
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        forgotPasswordButton.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "Forgot_password"))!)", for: .normal)
        forgotPasswordButton.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        invalidLabel.textColor = .red
    }
    func configureNextBtn(enable:Bool){
        if(enable){
            self.GoBtn.isUserInteractionEnabled = true
            self.GoBtn.alpha = 1.0
        }
        else {
            self.GoBtn.isUserInteractionEnabled = false
            self.GoBtn.alpha = 0.7
        }
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func checkLoginAPI()
    {
        let loginquery = LoginQuery(email: emailTF.text!, password: passwordTF.text!, deviceType:"iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken)
        let apollo = ApolloClient(url: URL(string:graphQLEndpoint)!)
        apollo.fetch(query: loginquery,cachePolicy:.fetchIgnoringCacheData) { (result,error) in
            if(result?.data?.userLogin?.status == 200) {
                
                Utility.shared.logindataArray.removeAll()
                if(result?.data?.userLogin?.result?.user?.preferredCurrency != nil)
                {
                Utility.shared.setPreferredCurrency(currency_rate: (result?.data?.userLogin?.result?.user?.preferredCurrency as AnyObject) as! String)
                }
                else
                {
                Utility.shared.setPreferredCurrency(currency_rate:"USD")
                 Utility.shared.selectedCurrency = "USD"
                }
                Utility.shared.setopenTabbar(iswhichtabbar:false)
                
                if let usertoken = result?.data?.userLogin?.result?.userToken {
                    Utility.shared.setUserToken(userID:"\(usertoken)" as NSString)
                    Utility.shared.logindataArray.append(usertoken as AnyObject)
                }
                
                if let userId = result?.data?.userLogin?.result?.userId {
                                   Utility.shared.setUserID(userid:"\(userId)" as NSString)
                     Utility.shared.logindataArray.append(userId as AnyObject)
                               }

               
                Utility.shared.setPassword(password: self.passwordTF!.text! as NSString)
                if let userId = result?.data?.userLogin?.result?.userToken {
                                                  Utility.shared.setUserToken(userID: "\(userId)" as NSString)
                    Utility.shared.user_token = "\(userId)"
                        }
        if let firstName = result?.data?.userLogin?.result?.user?.firstName {
            Utility.shared.logindataArray.append(firstName as AnyObject)
            }
        if let picture = result?.data?.userLogin?.result?.user?.picture {
                      Utility.shared.logindataArray.append(picture as AnyObject)
                      }
        if let createdAt = result?.data?.userLogin?.result?.user?.createdAt {
                             Utility.shared.logindataArray.append(createdAt as AnyObject)
                             }
        if let isPhoneVerified = result?.data?.userLogin?.result?.user?.verification?.isPhoneVerified {
                    Utility.shared.logindataArray.append(isPhoneVerified as AnyObject)
                    }
         if let isEmailConfirmed = result?.data?.userLogin?.result?.user?.verification?.isEmailConfirmed {
         Utility.shared.logindataArray.append(isEmailConfirmed as AnyObject)
         }
        if let isIdVerification = result?.data?.userLogin?.result?.user?.verification?.isIdVerification {
                   Utility.shared.logindataArray.append(isIdVerification as AnyObject)
                   }
        if let isGoogleConnected = result?.data?.userLogin?.result?.user?.verification?.isGoogleConnected {
            Utility.shared.logindataArray.append(isGoogleConnected as AnyObject)
                                 }
    
                if let isFacebookConnected = result?.data?.userLogin?.result?.user?.verification?.isFacebookConnected {
                           Utility.shared.logindataArray.append(isFacebookConnected as AnyObject)
                        }
                
                
                Utility.shared.locationfromSearch = ""
                Utility.shared.isfromfloatmap_Page = false
                Utility.shared.isfromGuestProfile = false
                if(Utility.shared.searchLocationDict.count > 0)
                {
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
                }
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Utility.shared.setTab(index: 0)


                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)

                appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
               
            }else if result?.data?.userLogin?.status == 500 {
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
             
                self.emailTF.resignFirstResponder()
                self.passwordTF.resignFirstResponder()
                self.view.makeToast("\((result?.data?.userLogin?.errorMessage)!)")
              
            }
            else{

                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.GoBtn.isHidden = true
                self.passwordTF.resignFirstResponder()
                self.emailTF.resignFirstResponder()
                self.invalidcredentialView.isHidden = false
                if IS_IPHONE_X || IS_IPHONE_XR {
                    self.invalidcredentialView.frame = CGRect(x: 0, y: FULLHEIGHT-80, width: FULLWIDTH, height: 60)
                    
                }
                else{
                    self.invalidcredentialView.frame = CGRect(x: 0, y: FULLHEIGHT-60, width: FULLWIDTH, height: 60)
                }
            }
        }
    }
 
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
      
   
        let keyboardHeight = keyboardFrame.height
        Gobtn_Constraints.constant = -5-keyboardHeight
        
        let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
     
       Gobtn_Constraints.constant = -35
       
        let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        
       if ((emailTF.text?.isValidEmail())! && ((passwordTF.text?.count)! > 6)) {
            self.configureNextBtn(enable: true)
          
        }
        else{
             self.configureNextBtn(enable: false)
        }
        
    }
    
    fileprivate func emailValidation () {
        
        
        if(pasteEmail.isValidEmail())
        {
            self.emailtickImg.image = nil
            self.emailtickImg.isHidden = false
            let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            UIView.transition(with: self.emailtickImg, duration:0.2, options: [.transitionCrossDissolve], animations: {
                self.emailtickImg.image = #imageLiteral(resourceName: "right_white")
                self.emailtickImg.transform = expandTransform
            },
                              completion: {(finished: Bool) in
                                UIView.animate(withDuration: 0.5,
                                               delay:0.0,
                                               usingSpringWithDamping:0.40,
                                               initialSpringVelocity:0.2,
                                               options:UIView.AnimationOptions.curveEaseOut,
                                               animations: {
                                                self.emailtickImg.transform = expandTransform.inverted()
                                }, completion:nil)
            })
        }
        else if (emailTF.text?.isValidEmail())! {
            
            if self.emailtickImg.isHidden {
                
                self.emailtickImg.image = nil
                self.emailtickImg.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.emailtickImg, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.emailtickImg.image = #imageLiteral(resourceName: "right_white")
                    self.emailtickImg.transform = expandTransform
                },
                                  completion: {(finished: Bool) in
                                    UIView.animate(withDuration: 0.5,
                                                   delay:0.0,
                                                   usingSpringWithDamping:0.40,
                                                   initialSpringVelocity:0.2,
                                                   options:UIView.AnimationOptions.curveEaseOut,
                                                   animations: {
                                                    self.emailtickImg.transform = expandTransform.inverted()
                                    }, completion:nil)
                })
                
                
            }
            
        }else {
            
            if !self.emailtickImg.isHidden {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    
                    self.emailtickImg.alpha = 0
                    self.GoBtn.isUserInteractionEnabled = false
                    self.GoBtn.alpha = 0.7
                   
                }, completion: { (comp) in
                    
                    self.emailtickImg.isHidden = true
                    self.emailtickImg.alpha = 1
                    self.emailtickImg.image = nil
                    self.configureNextBtn(enable: false)
                   
                })
                
            }
            else if (emailTF.text?.isValidEmail())! {
            
                self.view.endEditing(true)
               self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"email_validalert"))!)")
            }
            
        }
        
    }
    
    
    
    
    fileprivate func passwordValidation () {
        
        if (self.passwordTF.text?.count)! > 6{
            
            if self.passwordtickImg.isHidden {
                
                self.passwordtickImg.image = nil
                self.passwordtickImg.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.passwordtickImg, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.passwordtickImg.image = #imageLiteral(resourceName: "right_white")
                    self.passwordtickImg.transform = expandTransform
                },
                                  completion: {(finished: Bool) in
                                    UIView.animate(withDuration: 0.5,
                                                   delay:0.0,
                                                   usingSpringWithDamping:0.40,
                                                   initialSpringVelocity:0.2,
                                                   options:UIView.AnimationOptions.curveEaseOut,
                                                   animations: {
                                                    self.passwordtickImg.transform = expandTransform.inverted()
                                    }, completion:nil)
                })
                
                
            }
            
        }else {
            
            
            if !self.passwordtickImg.isHidden {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    
                    self.passwordtickImg.alpha = 0
                    self.GoBtn.isUserInteractionEnabled = false
                    self.GoBtn.alpha = 0.7
                   
                }, completion: { (comp) in
                    
                    self.passwordtickImg.isHidden = true
                    self.passwordtickImg.alpha = 1
                    self.passwordtickImg.image = nil
                    self.configureNextBtn(enable: false)
                })
                
            }
        }
        
    }
    
    func goLogin()
    {
        
    }

}


extension LoginPageVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.GoBtn.isHidden = false
        self.invalidcredentialView.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if textField == emailTF {
            if string.count > 1{
            
                pasteEmail = string
             
            }
            else if(string.count == 0)
            {
                pasteEmail = textField.text!
            }
           
              self.emailValidation()
            self.passwordTF.resignFirstResponder()
            
            
            return true
            
        }else if textField == passwordTF {
            if string.count > 1{
                pastePassword = string
            }
            else if(string.count == 0)
            {
                pastePassword = textField.text!
            }
                self.passwordValidation()
            self.emailTF.resignFirstResponder()
        }
        if ((emailTF.text?.isValidEmail())! && ((passwordTF.text?.count)! > 6)) {
            
            self.GoBtn.isUserInteractionEnabled = true
            self.GoBtn.alpha = 1.0
            
        }else {
            
            self.GoBtn.isUserInteractionEnabled = false
            self.GoBtn.alpha = 0.7
        }
        let charsLimit = 25
        
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace =  range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= charsLimit
    }
    
     @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == emailTF {
            
            self.emailValidation()
        }
        else
        {
            self.passwordValidation()
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if Utility.shared.isConnectedToNetwork(){
            if textField == emailTF {
                if !(emailTF.text?.isValidEmail())!{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"email_validalert"))!)")
                }
            }
        }else{
            self.offelineView.isHidden = false
            if IS_IPHONE_X || IS_IPHONE_XR {
                self.offelineView.frame = CGRect(x: 0, y: FULLHEIGHT-80, width: FULLWIDTH, height: 60)
            }
            else{
                self.offelineView.frame = CGRect(x: 0, y: FULLHEIGHT-60, width: FULLWIDTH, height: 60)
            }
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offelineView.frame.size.width + shadowSize2,
                                                        height: self.offelineView.frame.size.height + shadowSize2))
            self.offelineView.layer.masksToBounds = false
            self.offelineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offelineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offelineView.layer.shadowOpacity = 0.3
        }
    }
}

