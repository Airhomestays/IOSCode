

import UIKit
import Lottie
import IQKeyboardManagerSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var firstNameTitleLabel: UILabel!
    @IBOutlet weak var firstNametxtField: CustomUITextField!
    
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var lastNameTitleLabel: UILabel!
    @IBOutlet weak var lastNameTxtField: CustomUITextField!
    
    @IBOutlet weak var EmailView: UIView!
    @IBOutlet weak var EmailTitleLabel: UILabel!
    @IBOutlet weak var EmailTxtField: CustomUITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var passwordTxtField: CustomUITextField!
    
    @IBOutlet weak var birthdayView: UIView!
    @IBOutlet weak var birthdayTitleLabel: UILabel!
    @IBOutlet weak var birthdayTxtField: CustomUITextField!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    
    var datePicker:UIDatePicker!
    var customView:UIView!
    var lottieWholeView = UIView()
    var lottieView: LottieAnimationView!
    var convertedDate = ""
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineTitleLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.lottieView = LottieAnimationView.init(name: "loading_qwe")
        
        self.backBtn.setImage(UIImage(named: "close-black"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = .clear
        
        self.createAccountLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"createacc") ?? "Create your account")"
        self.createAccountLabel.textColor = UIColor(named: "Title_Header")
        self.createAccountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.createAccountLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 20.0)
        
        
        firstNameTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "firstname") ?? "First name")"
        firstNameTitleLabel.textColor = UIColor(named: "Title_Header")
        firstNameTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        firstNameTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        firstNametxtField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "firstname") ?? "First name")"
        firstNametxtField.textColor = UIColor(named: "searchPlaces_TextColor")
        firstNametxtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        firstNametxtField.font = UIFont(name: APP_FONT, size: 14.0)
        firstNametxtField.delegate = self
        
        lastNameTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "LastName") ?? "Last name")"
        lastNameTitleLabel.textColor = UIColor(named: "Title_Header")
        lastNameTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        lastNameTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        lastNameTxtField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "LastName") ?? "Last name")"
        lastNameTxtField.textColor = UIColor(named: "searchPlaces_TextColor")
        lastNameTxtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        lastNameTxtField.font = UIFont(name: APP_FONT, size: 14.0)
        lastNameTxtField.delegate = self
        
        
        EmailTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "email") ?? "Email")"
        EmailTitleLabel.textColor = UIColor(named: "Title_Header")
        EmailTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        EmailTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        EmailTxtField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "emailaddress") ?? "Email address")"
        EmailTxtField.textColor = UIColor(named: "searchPlaces_TextColor")
        EmailTxtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        EmailTxtField.font = UIFont(name: APP_FONT, size: 14.0)
        EmailTxtField.delegate = self
        
        passwordTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "password") ?? "Password")"
        passwordTitleLabel.textColor = UIColor(named: "Title_Header")
        passwordTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        passwordTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        passwordTxtField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "password") ?? "Password")"
        passwordTxtField.textColor = UIColor(named: "searchPlaces_TextColor")
        passwordTxtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        passwordTxtField.font = UIFont(name: APP_FONT, size: 14.0)
        passwordTxtField.delegate = self
        
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
        let eyeIconBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 50, height: 50))
        
        eyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        eyeIconBtn.setTitle("", for: .normal)
        eyeIconBtn.backgroundColor = .clear
        eyeIconBtn.addTarget(self, action: #selector(onClickEyeIcon), for: .touchUpInside)
        
        eyeView.addSubview(eyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.passwordTxtField.rightView = eyeView
            self.passwordTxtField.rightViewMode = .always
            self.passwordTxtField.clearButtonMode = .whileEditing
            self.passwordTxtField.textAlignment = .right
        }else{
            self.passwordTxtField.rightView = eyeView
            self.passwordTxtField.rightViewMode = .always
            self.passwordTxtField.clearButtonMode = .whileEditing
            self.passwordTxtField.textAlignment = .left
        }
        
        birthdayTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Signup_Birthday") ?? "Birthday")"
        birthdayTitleLabel.textColor = UIColor(named: "Title_Header")
        birthdayTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        birthdayTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        birthdayTxtField.placeholder = "MM / DD / YYYY"
        birthdayTxtField.textColor = UIColor(named: "searchPlaces_TextColor")
        birthdayTxtField.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        birthdayTxtField.font = UIFont(name: APP_FONT, size: 14.0)
        birthdayTxtField.delegate = self
        
        
        firstNametxtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        firstNametxtField.layer.borderWidth = 1
        firstNametxtField.layer.cornerRadius = 5
        firstNametxtField.clipsToBounds = true
        let firstNametxtFieldleftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        firstNametxtField.leftView = firstNametxtFieldleftView
        firstNametxtField.leftViewMode = .always
        
        
        lastNameTxtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        lastNameTxtField.layer.borderWidth = 1
        lastNameTxtField.layer.cornerRadius = 5
        lastNameTxtField.clipsToBounds = true
        let lastNameTxtFieldleftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        lastNameTxtField.leftView = lastNameTxtFieldleftView
        lastNameTxtField.leftViewMode = .always
        
        
        
        
        EmailTxtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        EmailTxtField.layer.borderWidth = 1
        EmailTxtField.layer.cornerRadius = 5
        EmailTxtField.clipsToBounds = true
        let EmailTxtFieldleftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        EmailTxtField.leftView = EmailTxtFieldleftView
        EmailTxtField.leftViewMode = .always
        
        passwordTxtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        passwordTxtField.layer.borderWidth = 1
        passwordTxtField.layer.cornerRadius = 5
        passwordTxtField.clipsToBounds = true
        let passwordTxtFieldleftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        passwordTxtField.leftView = passwordTxtFieldleftView
        passwordTxtField.leftViewMode = .always
        
        birthdayTxtField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        birthdayTxtField.layer.borderWidth = 1
        birthdayTxtField.layer.cornerRadius = 5
        birthdayTxtField.clipsToBounds = true
        let birthdayTxtFieldleftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        birthdayTxtField.leftView = birthdayTxtFieldleftView
        birthdayTxtField.leftViewMode = .always
        
        customView = UIView(frame:CGRect(x: 0, y: FULLHEIGHT-220, width: FULLWIDTH, height: 220))
        customView.backgroundColor = UIColor.clear
        customView.isHidden = true
        
        birthdayTxtField.inputView = customView
        
        
        descLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "signupdesc") ?? "By signing up, I agree to Terms Of Service and Privacy Policy.")"
        descLabel.textColor = UIColor(named: "Title_Header")
        descLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        descLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        signupBtn.layer.cornerRadius = signupBtn.frame.size.height/2
        signupBtn.clipsToBounds = true
        signupBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SignupBtn") ?? "Signup")", for:.normal)
        signupBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        signupBtn.setTitleColor(UIColor.white, for: .normal)
        signupBtn.backgroundColor = Theme.Button_BG
        signupBtn.alpha = 0.4
        signupBtn.isEnabled = false
        
        offlineView.isHidden = true
        
        self.signupBtn.isEnabled = true
        self.signupBtn.alpha = 1.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lottieView.isHidden = true
        self.lottieWholeView.isHidden = true
        
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: FULLWIDTH, height: 220))
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.locale = Locale(identifier: "en-US")
    

        datePicker.maximumDate = NSCalendar.current.date(byAdding: .year, value: -18, to: NSDate() as Date)

        customView.addSubview(datePicker)
        
        if #available(iOS 14.0, *) {
          datePicker.preferredDatePickerStyle = .wheels
        } else {
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        datePicker.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 220)
        datePicker.layoutIfNeeded()
    }

    @objc func onClickEyeIcon(){
        self.passwordTxtField.isSecureTextEntry = !self.passwordTxtField.isSecureTextEntry
        
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
        let eyeIconBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 50, height: 50))
        
        if self.passwordTxtField.isSecureTextEntry{
            eyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        }else{
            eyeIconBtn.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        eyeIconBtn.setTitle("", for: .normal)
        eyeIconBtn.backgroundColor = .clear
        eyeIconBtn.addTarget(self, action: #selector(onClickEyeIcon), for: .touchUpInside)
        
        eyeView.addSubview(eyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.passwordTxtField.rightView = eyeView
            self.passwordTxtField.rightViewMode = .always
            self.passwordTxtField.clearButtonMode = .whileEditing
            self.passwordTxtField.textAlignment = .right
        }else{
            self.passwordTxtField.rightView = eyeView
            self.passwordTxtField.rightViewMode = .always
            self.passwordTxtField.clearButtonMode = .whileEditing
            self.passwordTxtField.textAlignment = .left
        }
    }
    
    @IBAction func onClickRetryBtn(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
        self.offlineView.isHidden = true
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.contentSize.height)
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.scrollView.addSubview(lottieWholeView)
        self.lottieView.isHidden = false
            self.lottieView.frame = CGRect(x:self.scrollView.frame.size.width/2-40, y: self.scrollView.bounds.height/2-40, width: 80, height: 80)
        self.scrollView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        self.signupAPICall()
        }
    }
    
    
    @IBAction func onClickSignupBtn(_ sender: UIButton) {
        firstNametxtField.resignFirstResponder()
        lastNameTxtField.resignFirstResponder()
        EmailTxtField.resignFirstResponder()
        passwordTxtField.resignFirstResponder()
        birthdayTxtField.resignFirstResponder()
        
        if !validation(){
            if Utility().isConnectedToNetwork(){
                self.lottieWholeView.isHidden = false
                self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.contentSize.height)
                self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
                self.scrollView.addSubview(lottieWholeView)
                self.offlineView.isHidden = true
                self.lottieView.isHidden = false
                self.lottieView.frame = CGRect(x:self.scrollView.frame.size.width/2-40, y: self.scrollView.contentSize.height/2-40, width: 80, height: 80)
                self.lottieWholeView.addSubview(self.lottieView)
                self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
                self.lottieView.layer.cornerRadius = 6.0
                self.lottieView.clipsToBounds = true
                self.lottieView.play()
                self.signupAPICall()
            } else {
                self.offlineView.isHidden = false
            }
        }
    }
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM / dd / yyyy"
        self.birthdayTxtField.text = dateFormatter.string(from: sender.date)
        dateFormatter.dateFormat = "MM-yyyy-dd"
        convertedDate = dateFormatter.string(from: sender.date)
        
    }
    
    
    func signupAPICall(){
      
        let signupMutation = SignupMutation(firstName: firstNametxtField.text ?? "", lastName: lastNameTxtField.text ?? "", email: EmailTxtField.text ?? "", password: passwordTxtField.text ?? "", dateOfBirth: convertedDate , deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "email")
        apollo.perform(mutation: signupMutation){ (result,error) in
            if(result?.data?.createUser?.status == 200) {
                Utility.shared.signupArray.removeAllObjects()
                Utility.shared.signupdataArray.removeAll()
                if let token = result?.data?.createUser?.result?.userToken {
                    Utility.shared.setUserToken(userID:token as NSString)
                      Utility.shared.user_token = "\(token)"
                    }
            if let userId = result?.data?.createUser?.result?.userId {
                    Utility.shared.setUserID(userid:userId as NSString)
                }
             if let firstName = result?.data?.createUser?.result?.user?.firstName {
                               Utility.shared.signupdataArray.append(firstName as AnyObject)
                           }
            if let createdAt = result?.data?.createUser?.result?.user?.createdAt {
                Utility.shared.signupdataArray.append(createdAt as AnyObject)
                        }
              if let picture = result?.data?.createUser?.result?.user?.picture {
              Utility.shared.signupdataArray.append(picture as AnyObject)
                      }
                if let isEmailConfirmed = result?.data?.createUser?.result?.user?.verification?.isEmailConfirmed {
                    Utility.shared.signupdataArray.append(isEmailConfirmed as AnyObject)
                    }
                 if let isIdVerification = result?.data?.createUser?.result?.user?.verification?.isIdVerification {
                 Utility.shared.signupdataArray.append(isIdVerification as AnyObject)
                 }
                if let isFacebookConnected = result?.data?.createUser?.result?.user?.verification?.isFacebookConnected {
                    Utility.shared.signupdataArray.append(isFacebookConnected as AnyObject)
                }
                if let isPhoneVerified = result?.data?.createUser?.result?.user?.verification?.isPhoneVerified {
                    Utility.shared.signupdataArray.append(isPhoneVerified as AnyObject)
                    }
                if let isGoogleConnected = result?.data?.createUser?.result?.user?.verification?.isGoogleConnected {
                    Utility.shared.signupdataArray.append(isGoogleConnected as AnyObject)
                    }
                 
              
                
                if(result?.data?.createUser?.result?.user?.preferredCurrency != nil)
                {
                Utility.shared.setPreferredCurrency(currency_rate: (result?.data?.createUser?.result?.user?.preferredCurrency as AnyObject) as! String)
                }
                else
                {
                    Utility.shared.setPreferredCurrency(currency_rate:"USD")
                    Utility.shared.selectedCurrency = "USD"
                }
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.profileAPICall()
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
      }
      else {
            self.lottieWholeView.isHidden = true
            self.lottieView.isHidden = true
          self.view.makeToast("\((result?.data?.createUser?.errorMessage)!)")
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.birthdayTxtField{
            customView.isHidden = false
            datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstNametxtField{
            self.lastNameTxtField.becomeFirstResponder()
        }else if textField == self.lastNameTxtField {
            self.EmailTxtField.becomeFirstResponder()
        }else if textField == self.EmailTxtField {
            self.passwordTxtField.becomeFirstResponder()
        }else if textField == self.passwordTxtField {
            self.birthdayTxtField.becomeFirstResponder()
            customView.isHidden = false
        }else{
            customView.isHidden = true
            textField.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let valueTobeChecked = textField.text ?? ""
        
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charsLimit = 25
        if textField != EmailTxtField {
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace =  range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= charsLimit
        
        }
        return true
    }
}
