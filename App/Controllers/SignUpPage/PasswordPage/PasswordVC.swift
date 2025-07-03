

import UIKit
import Lottie
import IQKeyboardManagerSwift

class PasswordVC: UIViewController {

    
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var passwprdTitleLabel : UILabel!
    @IBOutlet var passwordcontentLabel : UILabel!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet var passwordView: UIView!
    @IBOutlet var Gobtn: UIButton!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var confirmpassTick: UIImageView!
    @IBOutlet var lottieView: LottieAnimationView!
    
    @IBOutlet weak var bottomconstraint: NSLayoutConstraint!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    
 
    var passwordShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Utility.shared.isRTLLanguage() {
            passwordTF.textAlignment = .right
            
            passwprdTitleLabel.textAlignment = .right
            passwordcontentLabel.textAlignment = .right
            backBtn.imageView?.performRTLTransform()
            Gobtn.imageView?.performRTLTransform()
        }else{
            passwordTF.textAlignment = .left
            passwprdTitleLabel.textAlignment = .left
            passwordcontentLabel.textAlignment = .left
        }
        
        self.initialSetup()

    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
  
    @IBAction func nextBtnTapped(_ sender: Any) {
         if Utility().isConnectedToNetwork(){
        passwordTF.resignFirstResponder()
        self.lottieView.isHidden = true
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.passwordView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.white
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
            if  Utility.shared.signupArray.count >= 3 {
                Utility.shared.signupArray.replaceObject(at: 3, with: passwordTF.text as! String)
                
            }
       
            let dateofbithObj = DateofBirthVC()
            dateofbithObj.modalPresentationStyle = .fullScreen
             self.present(dateofbithObj, animated: false, completion: nil)
           
        }
         else{
            self.offlineView.isHidden = false
            passwordTF.resignFirstResponder()
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
    
    @IBAction func backBtnTapped(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
     
    }
    
    @IBAction func retryTapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork(){
            passwordTF.resignFirstResponder()
            self.lottieView.isHidden = true
            self.offlineView.isHidden = true
            self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
            self.passwordView.addSubview(self.lottieView)
            self.lottieView.backgroundColor = UIColor.white
            self.lottieView.layer.cornerRadius = 6.0
            self.lottieView.clipsToBounds = true
            self.lottieView.play()
            self.bottomView.isHidden = false
             if  Utility.shared.signupArray.count >= 3 {
                Utility.shared.signupArray.replaceObject(at: 3, with: passwordTF.text as! String) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                let dateofbithObj = DateofBirthVC()
                dateofbithObj.modalPresentationStyle = .fullScreen
                self.present(dateofbithObj, animated: false, completion: nil)
             
            })
        }else{
         
            self.offlineView.isHidden = false
        }

    }
    @IBAction func showBtnTapped(_ sender: Any) {
        
        if(passwordShow){
            showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"hide"))!)", for: .normal)
            showBtn.titleLabel?.font =  UIFont(name:APP_FONT, size:14)
            passwordTF.isSecureTextEntry = false
        }
        else {
            showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"show"))!)", for: .normal)
            showBtn.titleLabel?.font =  UIFont(name:APP_FONT, size:14)
            passwordTF.isSecureTextEntry = true
        }
        passwordShow = !passwordShow
        if passwordTF!.isFirstResponder {
            passwordTF.becomeFirstResponder()
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
    
    func initialSetup()
    {
        passwordView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        confirmpassTick.isHidden = true
        lottieView.isHidden = true
        self.offlineView.isHidden = true
        
        self.passwordView.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        self.view.applyGradient(colours: Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
       
        passwordTF.text = ""
        Gobtn.layer.cornerRadius = Gobtn.frame.size.width/2
        Gobtn.clipsToBounds = true
        passwordTF.becomeFirstResponder()
        Utility.shared.signupArray.add("")
       
        if((Utility.shared.signupArray[3] as! String) != ""){
            
            passwordTF.text = (Utility.shared.signupArray[3] as! String)
        }
        
        if (!((Utility.shared.checkEmptyWithString(value: passwordTF.text!)))) {
            self.configureNextBtn(enable: true)
            
        }
        else{
            self.configureNextBtn(enable: false)
        }
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        passwordTF.autocorrectionType = UITextAutocorrectionType.no
        passwordTF.autocorrectionType = UITextAutocorrectionType.no
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        passwordTF.addTarget(self, action: #selector(PasswordVC.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        if passwordTF!.isFirstResponder {
            self.becomeFirstResponder()
        }
        
        passwprdTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"password_title"))!)"
         passwordcontentLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"password_info"))!)"
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        showBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"show"))!)", for:.normal)
        passLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"password"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        passwprdTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 30)
        passwordTF.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        passLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        passwordcontentLabel.font = UIFont(name: APP_FONT, size: 17)
        showBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
    }
    func configureNextBtn(enable:Bool){
        if(enable){
            self.Gobtn.isUserInteractionEnabled = true
            self.Gobtn.alpha = 1.0
        }
        else {
            self.Gobtn.isUserInteractionEnabled = false
            self.Gobtn.alpha = 0.7
        }
        
    }
  
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
      
        self.bottomconstraint.constant = keyboardFrame.height
        self.Gobtn.frame.origin.y = keyboardFrame.origin.y - 75
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomconstraint.constant = 35
        self.Gobtn.frame.origin.y = FULLHEIGHT - 90
        
        if ((passwordTF.text?.count)! >= 8) {
            self.configureNextBtn(enable: true)
            
        }
        else{
            self.configureNextBtn(enable: false)
        }
        
    }
    
    fileprivate func passwordValidation () {
        
        if ((self.passwordTF.text?.count)! >= 8) {
            
            if self.confirmpassTick.isHidden {
                
                self.confirmpassTick.image = nil
                self.confirmpassTick.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.confirmpassTick, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.confirmpassTick.image = #imageLiteral(resourceName: "right_white")
                    self.confirmpassTick.transform = expandTransform
                },
                                  completion: {(finished: Bool) in
                                    UIView.animate(withDuration: 0.5,
                                                   delay:0.0,
                                                   usingSpringWithDamping:0.40,
                                                   initialSpringVelocity:0.2,
                                                   options:UIView.AnimationOptions.curveEaseOut,
                                                   animations: {
                                                    self.confirmpassTick.transform = expandTransform.inverted()
                                    }, completion:nil)
                })
                
                
            }
            
        }else {
            
            
            if !self.confirmpassTick.isHidden {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    
                    self.confirmpassTick.alpha = 0
                    self.Gobtn.isUserInteractionEnabled = false
                    self.Gobtn.alpha = 0.7
                    
                }, completion: { (comp) in
                    
                    self.confirmpassTick.isHidden = true
                    self.confirmpassTick.alpha = 1
                    self.confirmpassTick.image = nil
                    self.configureNextBtn(enable: false)
                })
                
            }
        }
        
    }
    

}


extension PasswordVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
           if textField == passwordTF {
               
               
               self.passwordValidation()
           }
           if ((passwordTF.text?.count)! >= 8){
               
               self.Gobtn.isUserInteractionEnabled = true
               self.Gobtn.alpha = 1.0
               
           }else {
               
               self.Gobtn.isUserInteractionEnabled = false
               self.Gobtn.alpha = 0.7
           }
           
           
       }
    
   
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
        {
            let text_Title = textField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            let string_value = string.trimmingCharacters(in:.whitespacesAndNewlines)
                    if(text_Title == "" && (string_value == ""))
                    {
                        return false
                    }
            
            
            return true
            
        }
    
}

