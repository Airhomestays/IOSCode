

import UIKit
import Lottie
import IQKeyboardManagerSwift

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var resetPasswordView: UIView!
    @IBOutlet weak var confirmTick: UIImageView!
    @IBOutlet weak var newtick: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var confirmPasswordTF: CustomUITextField!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var newPasswordTF: CustomUITextField!
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet var reset_title_label: UILabel!
    @IBOutlet var error_Label: UILabel!
    @IBOutlet var newPassword_label: UILabel!
    @IBOutlet var confirmpassword_label: UILabel!
    @IBOutlet var newShow_button: UIButton!
    @IBOutlet var confirmShow_button: UIButton!
    
    @IBOutlet var viewConfirmPassword: UIView!
    @IBOutlet var viewNewPassword: UIView!
    @IBOutlet var retry_button: UIButton!
 
    var newpasswordShow = true
    var confirmpasswordShow = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialSetup()
        if Utility.shared.isConnectedToNetwork() {
            offlineView.isHidden = true
        }
        if Utility.shared.isRTLLanguage() {
            confirmPasswordTF.textAlignment = .right
            newPasswordTF.textAlignment = .right
            backBtn.imageView?.performRTLTransform()
            nextBtn.imageView?.performRTLTransform()
        }
        self.setupToHideKeyboardOnTapOnView()
       
    }

    @IBAction func confirmshowTapped(_ sender: Any) {
        
    if(confirmpasswordShow){
            confirmPasswordTF.isSecureTextEntry = false
            confirmShow_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "hide"))!)", for: .normal)
            confirmShow_button.titleLabel?.font =  UIFont(name:APP_FONT, size:14)!
        confirmShow_button.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        else {
            confirmPasswordTF.isSecureTextEntry = true
            confirmShow_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "show"))!)", for: .normal)
            confirmShow_button.titleLabel?.font =  UIFont(name:APP_FONT, size:14)!
            confirmShow_button.setImage(UIImage(named: "passwordEye"), for: .normal)
        }
        confirmpasswordShow = !confirmpasswordShow
    }
    
    @IBAction func retryTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
        }
        
    }
    @IBAction func newshowTapped(_ sender: Any) {
        
        if(newpasswordShow){
            newPasswordTF.isSecureTextEntry = false

            newShow_button.titleLabel?.font =  UIFont(name:APP_FONT, size:14)!
            newShow_button.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        else {
            newPasswordTF.isSecureTextEntry = true

            newShow_button.titleLabel?.font =  UIFont(name:APP_FONT, size:14)!
            newShow_button.setImage(UIImage(named: "passwordEye"), for: .normal)
        }
        
       
        newpasswordShow = !newpasswordShow
    }
    func initialSetup()
    {
        resetPasswordView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)

        lottieView.isHidden = true
        viewNewPassword.layer.cornerRadius = 5.0
        viewNewPassword.layer.masksToBounds = true
        viewNewPassword.layer.borderWidth = 1
        viewNewPassword.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        
        viewConfirmPassword.layer.cornerRadius = 5.0
        viewConfirmPassword.layer.masksToBounds = true
        viewConfirmPassword.layer.borderWidth = 1
        viewConfirmPassword.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
       
        newPasswordTF.text = ""
        confirmPasswordTF.text = ""
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        nextBtn.backgroundColor = Theme.Button_BG
        nextBtn.titleLabel?.font = UIFont(name:APP_FONT_MEDIUM, size:16 )
        nextBtn.clipsToBounds = true
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "submit"))!)", for: .normal)
        

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        newPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        newPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        confirmPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        confirmPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        
        newPasswordTF.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "new_password") ?? "New Password")"
        
        confirmPasswordTF.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "confirm_password") ?? "Confirm Password")"
        
        newPasswordTF.keyboardType = .asciiCapable
        confirmPasswordTF.keyboardType = .asciiCapable
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        self.bottomView.frame.origin.y = FULLHEIGHT - 85
        
        
        error_Label.text = "\((Utility.shared.getLanguage()?.value(forKey: "error_field"))!)"
        retry_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "retry"))!)", for: .normal)
        reset_title_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "reset_title"))!)"
       
        newPassword_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "new_password"))!)"
        confirmpassword_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "confirm_password"))!)"
        newShow_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "show"))!)", for: .normal)
        confirmShow_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "show"))!)", for: .normal)
        error_Label.textColor =  UIColor(named: "Title_Header")
        retry_button.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        reset_title_label.font = UIFont(name: APP_FONT_MEDIUM, size: 20)
        newPassword_label.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        newPasswordTF.font = UIFont(name: APP_FONT, size: 14)
        confirmpassword_label.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        confirmPasswordTF.font = UIFont(name: APP_FONT, size: 14)
        
        
        error_Label.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        retry_button.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
         retry_button.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
         retry_button.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
        
        
    }
    func configureNextBtn(enable:Bool){
        if(enable){
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.alpha = 1.0
        }
        else {
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
        }
        
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
   
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
   
        
        if (!((Utility.shared.checkEmptyWithString(value: newPasswordTF.text!)) && (Utility.shared.checkEmptyWithString(value: confirmPasswordTF.text!)))) {
            self.configureNextBtn(enable: true)
            
        }
        else{
            self.configureNextBtn(enable: false)
        }
        
    }
    
    fileprivate func passwordValidation () {
        
        if ((self.newPasswordTF.text?.count)! >= 7) {

            
        }else {
            
        }
        
    }
    
    
    fileprivate func confirmpasswordValidation () {
        
        if ((self.confirmPasswordTF.text?.count)! >= 7) {
            
            
        }else {
            
        }
        
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        
        if ((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
            let WelcomeVc = WelcomePageVC()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setInitialViewController(initialView: WelcomeVc)
            
        }else{
               self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    @IBAction func nextButton_Tapped(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork(){
            
            
            if newPasswordTF.text!.count >= 8 && confirmPasswordTF.text!.count >= 3{
                
                if newPasswordTF.text == confirmPasswordTF.text {
                    let resetpass = ResetPasswordMutation(email: Utility.shared.deepLinkEmail, password: newPasswordTF.text!, token: Utility.shared.deepLinkToken)
                    apollo.perform(mutation: resetpass){ (result,error)in
        
                        if result?.data?.updateForgotPassword?.status == 200 {
                            
                            let alert = UIAlertController(title: "\((Utility.shared.getLanguage()?.value(forKey: "success"))!)", message: "\((Utility.shared.getLanguage()?.value(forKey: "Password_reset"))!)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey: "okay"))!)", style: .default, handler: { (NavigatingtoLogin) in
                                let logpage = LoginPageVC()
                                logpage.modalPresentationStyle = .fullScreen
                                self.present(logpage, animated: false, completion: nil)
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }else{
                            
                            

                            let alert = UIAlertController(title: "\((Utility.shared.getLanguage()?.value(forKey: "oops"))!)", message: "\((result?.data?.updateForgotPassword?.errorMessage)!)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey: "okay"))!)", style: .default, handler: { (NavigatingtoLogin) in
                                let welcomeObj = WelcomePageVC()
                                welcomeObj.modalPresentationStyle = .fullScreen
                                self.present(welcomeObj, animated:false, completion: nil)
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                         
                        }
                    }
                    
                }else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "mismatch_password"))!)")
                }
                
            }else{
                
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "passcode_count"))!)")
            }

        }else{
            offlineView.isHidden = false
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-75, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    
}

extension ResetPasswordVC
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ResetPasswordVC.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
extension ResetPasswordVC:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        newPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        newPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        confirmPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        confirmPasswordTF.autocorrectionType = UITextAutocorrectionType.no
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        
        
        if textField == newPasswordTF {
            
            
            self.passwordValidation()
            
        }else if textField == confirmPasswordTF {
            
            
            self.confirmpasswordValidation()
            
        }
        if (((newPasswordTF.text?.count)! >= 7) && ((confirmPasswordTF.text?.count)! >= 7)){
            
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.alpha = 1.0
            
        }else {
            
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
        }
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                if textField == newPasswordTF {
                    
                    if ((newPasswordTF.text?.count)! <= 7) {

                    }
                    

                    
                }else if textField == confirmPasswordTF {
                    if ((confirmPasswordTF.text?.count)! <= 7){
                        

                    }

                    
                }
            }
        }
        
       
                let charsLimit = 25
                
                let startingLength = textField.text?.count ?? 0
                let lengthToAdd = string.count
                let lengthToReplace =  range.length
                let newLength = startingLength + lengthToAdd - lengthToReplace
                
                return newLength <= charsLimit
           
            
          
       
        
       
        
    }
    
    
    
}

