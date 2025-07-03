

import UIKit
import IQKeyboardManagerSwift
import Lottie

class DateofBirthVC: UIViewController {
    

    @IBOutlet var birthTF: UITextField!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var birthTitleLabel: UILabel!
    @IBOutlet weak var bottomconstraint: NSLayoutConstraint!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var birthcontentLabel: UILabel!
    @IBOutlet var dateOfBirthView: UIView!
    @IBOutlet var goBtn: UIButton!
    @IBOutlet var birthtick: UIImageView!
    @IBOutlet var lottieView: LottieAnimationView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var backBtn: UIButton!
   
    var datePicker:UIDatePicker!
     var customView:UIView!
     var lottieWholeView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        if Utility.shared.isRTLLanguage() {
            birthTF.textAlignment = .right
            
            birthTitleLabel.textAlignment = .right
            birthcontentLabel.textAlignment = .right
            
            backBtn.imageView?.performRTLTransform()
            goBtn.imageView?.performRTLTransform()
        }else{
            birthTF.textAlignment = .left
            
            birthTitleLabel.textAlignment = .left
            birthcontentLabel.textAlignment = .left
        }
      
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.lottieView.isHidden = true
        self.lottieWholeView.isHidden = true
        self.offlineView.isHidden = true
        
        self.datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: FULLWIDTH, height: 220))
        
          datePicker.datePickerMode = UIDatePicker.Mode.date
      
          customView.addSubview(datePicker)

        datePicker.maximumDate = NSCalendar.current.date(byAdding: .year, value: -18, to: NSDate() as Date)

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
    @IBAction func retryTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        self.bottomView.isHidden = false
        self.offlineView.isHidden = true
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
     
    }
    @objc func autoscrolling(){
        self.lottieView.play()
}
    @IBAction func goBtnTapped(_ sender: Any) {
         if Utility().isConnectedToNetwork(){
        self.offlineView.isHidden = true
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
             self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.dateOfBirthView.addSubview(lottieWholeView)
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.white
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
        signupAPICall()
        }
         else{
            self.offlineView.isHidden = false
            birthTF.resignFirstResponder()
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
    func initialSetup() {
        dateOfBirthView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        birthtick.isHidden = true
        goBtn.layer.cornerRadius = goBtn.frame.size.width/2
        goBtn.clipsToBounds = true
        birthTF.becomeFirstResponder()
        self.offlineView.isHidden = true
        lottieView.isHidden = true
        birthTF.autocorrectionType = UITextAutocorrectionType.no
        birthTF.text = ""
        
        self.dateOfBirthView.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        self.view.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        
        if (!(Utility.shared.checkEmptyWithString(value: birthTF.text!))) {
            self.configureNextBtn(enable: true)
            
        }
        else {
            self.configureNextBtn(enable: false)
        }
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "\((Utility.shared.getLanguage()?.value(forKey:"done"))!)"
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        
        
        customView = UIView(frame:CGRect(x: 0, y: FULLHEIGHT-220, width: FULLWIDTH, height: 220))
        customView.backgroundColor = UIColor.clear

        birthTF.inputView = customView
        
        customView.isHidden = true
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        birthTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"birthday"))!)"
          birthcontentLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"birth_info"))!)"
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        birthTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 30)
               
        birthTF.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
                      
        birthcontentLabel.font = UIFont(name: APP_FONT, size: 17)
                   errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
                    retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
       
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    fileprivate func DOBValidation () {
        
    if (!(Utility.shared.checkEmptyWithString(value: birthTF.text!))) {
            if self.birthtick.isHidden {
                self.birthtick.image = nil
                self.birthtick.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.birthtick, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.birthtick.image = #imageLiteral(resourceName: "right_white")
                    self.birthtick.transform = expandTransform
                },
                                  completion: {(finished: Bool) in
                                    UIView.animate(withDuration: 0.5,
                                            delay:0.0,
                                            usingSpringWithDamping:0.40,
                                            initialSpringVelocity:0.2,
                                            options:UIView.AnimationOptions.curveEaseOut,
                                            animations: {
                                            self.birthtick.transform = expandTransform.inverted()
                    }, completion:nil)
                })
            }
            }else {
            if !self.birthtick.isHidden {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                self.birthtick.alpha = 0
                self.goBtn.isUserInteractionEnabled = false
                self.goBtn.alpha = 0.7
                }, completion: { (comp) in
                self.birthtick.isHidden = true
                self.birthtick.alpha = 1
                self.birthtick.image = nil
                self.configureNextBtn(enable: false)
                })
            }
        }
    }
    
    func signupAPICall(){
       
        let signupMutation = SignupMutation(firstName:(Utility.shared.signupArray[0] as! String), lastName: (Utility.shared.signupArray[1] as! String), email: Utility.shared.signupArray[2] as! String, password: Utility.shared.signupArray[3] as! String, dateOfBirth:birthTF.text, deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "email")
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
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
      }
      else {
            self.lottieWholeView.isHidden = true
            self.lottieView.isHidden = true
            Utility.shared.showAlert(msg:((result?.data?.createUser?.errorMessage)!))
            }
        }
    }
    
        @objc func keyboardWillShow(sender: NSNotification) {
            let info = sender.userInfo!
            let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
            self.bottomconstraint.constant = keyboardFrame.height
            self.goBtn.frame.origin.y = keyboardFrame.origin.y - 75
    }
    func configureNextBtn(enable:Bool){
        if(enable){
            self.goBtn.isUserInteractionEnabled = true
            self.goBtn.alpha = 1.0
        }
        else {
            self.goBtn.isUserInteractionEnabled = false
            self.goBtn.alpha = 0.7
        }
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomconstraint.constant = 35
        self.goBtn.frame.origin.y = FULLHEIGHT - 120
        
        if (!(Utility.shared.checkEmptyWithString(value: birthTF.text!))) {
            self.configureNextBtn(enable: true)
        }
        else{
            self.configureNextBtn(enable: false)
        }
    }
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy-dd"
        birthTF.text = dateFormatter.string(from: sender.date)
        self.DOBValidation()
    }
    
   
}
import UIKit

public extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension DateofBirthVC:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        customView.isHidden = false
        datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    
    
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == birthTF {
            self.DOBValidation()
        }
        if (!(Utility.shared.checkEmptyWithString(value: birthTF.text!))) {
            self.goBtn.isUserInteractionEnabled = true
            self.goBtn.alpha = 1.0
        }else {
            self.goBtn.isUserInteractionEnabled = false
            self.goBtn.alpha = 0.7
        }
        return true
    }
}

