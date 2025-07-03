

import UIKit
import IQKeyboardManagerSwift
import Lottie
import SwiftMessages

class ForgotPasswordVC: UIViewController {

    
    @IBOutlet var forgotView: UIView!
    @IBOutlet var nextbtn: UIButton!
    @IBOutlet var forgotTF: CustomUITextField!
    
   
    @IBOutlet var lottieView: LottieAnimationView!
    @IBOutlet var forgotTickImg: UIImageView!
    @IBOutlet var backBtn: UIButton!
    
    @IBOutlet var forgot_label: UILabel!
    
    @IBOutlet var forgot_description_label: UILabel!
    
    @IBOutlet var txtContainer: UIView!
    @IBOutlet var email_label: UILabel!
    
    @IBOutlet weak var Offline_View: UIView!
    
    @IBOutlet weak var retry_Btn: UIButton!
    @IBOutlet weak var Error_label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextbtn.isUserInteractionEnabled = true
        self.nextbtn.alpha = 1.0
        self.nextbtn.backgroundColor = Theme.Button_BG
        self.initialSetup()
        if Utility.shared.isConnectedToNetwork() {
            Offline_View.isHidden = true
        }
        if Utility.shared.isRTLLanguage() {
            forgotTF.textAlignment = .right
            backBtn.imageView?.performRTLTransform()
            
            forgot_label.textAlignment = .right
            forgot_description_label.textAlignment = .right
            
        }else{
            forgot_label.textAlignment = .left
            forgot_description_label.textAlignment = .left
            
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func nextActionTapped(_ sender: Any) {
        forgotView.resignFirstResponder()
        forgotTF.resignFirstResponder()
        
        if let email = forgotTF.text, !email.isValidEmail() || email.count == 0 {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "validemailenter"))!)")
        }

        else {
        lottieView.isHidden = false
        lottieView.frame = CGRect(x:FULLWIDTH/2-40, y: FULLHEIGHT/2-40, width: 80, height: 80)
        forgotView.addSubview(lottieView)
         lottieView.backgroundColor = UIColor.white
        lottieView.layer.cornerRadius = 6.0
        lottieView.clipsToBounds = true
       
       self.view.endEditing(true)
        lottieView.play()
        
        self.sendEmail()
        }
       
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func initialSetup()
    {
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        forgotView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        txtContainer.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        txtContainer.layer.borderWidth = 1
        txtContainer.layer.cornerRadius = 5
        txtContainer.layer.masksToBounds = true
         forgotTF.autocorrectionType = UITextAutocorrectionType.no
        
        forgotTF.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "forgotplaceholder") ?? "forgotplaceholder")"
      
        nextbtn.layer.cornerRadius = nextbtn.frame.size.height/2
        nextbtn.titleLabel?.font = UIFont(name:APP_FONT_MEDIUM, size:16 )
        nextbtn.clipsToBounds = true
        nextbtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "forgotsubmit"))!)", for: .normal)
       
        lottieView.isHidden = true
        retry_Btn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        Error_label.textColor =  UIColor(named: "Title_Header")
        if (!(Utility.shared.checkEmptyWithString(value: forgotTF.text!))) {
            self.configureNextBtn(enable: true)
            
        }
        else{
            self.configureNextBtn(enable: false)
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        lottieView = LottieAnimationView.init(name: "loading_qwe")
       
        
        forgotTF.addTarget(self, action: #selector(ForgotPasswordVC.textFieldDidChange(_:)),
                          for: UIControl.Event.editingChanged)
      
        forgot_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "Forgot_password"))!)"
        forgot_label.textColor = UIColor(named: "Title_Header")
        forgot_description_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "forgot_description"))!)"
        forgot_description_label.textColor = UIColor(named: "Title_Header")
        Error_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "error_field"))!)"
        retry_Btn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "retry"))!)", for: .normal)
        
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.Offline_View.frame.size.width + shadowSize2,
                                                    height: self.Offline_View.frame.size.height + shadowSize2))
        
        self.Offline_View.layer.masksToBounds = false
        self.Offline_View.layer.shadowColor = Theme.TextLightColor.cgColor
        self.Offline_View.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.Offline_View.layer.shadowOpacity = 0.3
        self.Offline_View.layer.shadowPath = shadowPath2.cgPath
        if IS_IPHONE_X || IS_IPHONE_XR{
            Offline_View.frame = CGRect.init(x: 0, y: FULLHEIGHT-75, width: FULLWIDTH, height: 55)
        }else{
            Offline_View.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
        }
        
       
       
        forgotTF.font = UIFont(name: APP_FONT, size: 14)
        forgot_description_label.font = UIFont(name: APP_FONT, size: 14)
        forgot_label.font = UIFont(name: APP_FONT_SEMIBOLD, size: 20)
              Error_label.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
         retry_Btn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
    }
    func configureNextBtn(enable:Bool){

            self.nextbtn.isUserInteractionEnabled = true
            self.nextbtn.alpha = 1.0

    }
    
   
    @IBAction func retry_Tapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            self.Offline_View.isHidden = true
        }
    }
    
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
   
        self.nextbtn.frame.origin.y = keyboardFrame.origin.y - 60
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.nextbtn.frame.origin.y = FULLHEIGHT - 100
        
        if (!(Utility.shared.checkEmptyWithString(value: forgotTF.text!))) {
            self.configureNextBtn(enable: true)
            
        } else {
            self.configureNextBtn(enable: false)
        }
        
    }
    
    fileprivate func emailValidation () {
        
        if (forgotTF.text?.isValidEmail())! {

           
        } else {


        }
        
    }
    
    func sendEmail()
    {
        if Utility.shared.isConnectedToNetwork(){
            
            self.Offline_View.isHidden = true
            let forgotmutation = ForgotPasswordMutation(email:forgotTF.text!)
            apollo.perform(mutation: forgotmutation){(result,error) in
               
                if result?.data?.userForgotPassword?.status == 200 {
                    
                    self.lottieView.isHidden = true

                    let alert = UIAlertController(title: "\((Utility.shared.getLanguage()?.value(forKey: "success"))!)", message: "\((Utility.shared.getLanguage()?.value(forKey: "email_sent_success"))!)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey: "okay"))!)", style: .default, handler: { (NavigatingtoLogin) in
                        let logpage = WelcomePageVC()
                        logpage.modalPresentationStyle = .fullScreen
                        self.present(logpage, animated: false, completion: nil)
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
                } else {
                    self.lottieView.isHidden = true
                    
                     self.view.makeToast(result?.data?.userForgotPassword?.errorMessage)
                }
               
                }
        } else {
            self.lottieView.isHidden = true
            self.Offline_View.isHidden = false
          
        }

    }
    
   
}


extension ForgotPasswordVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        

        if (forgotTF.text?.isValidEmail())! {
            
            self.nextbtn.isUserInteractionEnabled = true
            self.nextbtn.alpha = 1.0
            
        } else {

        }
        
        
        return true
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == forgotTF {
            
            self.emailValidation()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if Utility.shared.isConnectedToNetwork(){
            if textField == forgotTF {
                if !(forgotTF.text?.isValidEmail())!{

                }
            }
        }
        
    }
}
