

import UIKit
import IQKeyboardManagerSwift
import Lottie
import MaterialComponents

class FirstLastnamePageVC: UIViewController {
 
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var firstLastView: UIView!
    
    @IBOutlet weak var bottomconstraint: NSLayoutConstraint!
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var lastNameTF: UITextField!
    
    @IBOutlet var firstnameTick: UIImageView!
    @IBOutlet var lastNameTick: UIImageView!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet var nextBtn: MDCFloatingButton!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var firstnameLabel: UILabel!
    @IBOutlet var lottieView: LottieAnimationView!
    @IBOutlet var bottomGoView: UIView!
    @IBOutlet var nameTitleLAbel: UILabel!
    var lottieWholeView = UIView()
    var firstname = String()
    var lastname = String()
    var text_Title = String()
    var string_value   = String()
    var firstNameCount = 0
    
    var firstCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
          self.initialSetup()
          if Utility.shared.isRTLLanguage() {
            firstNameTF.textAlignment = .right
            lastNameTF.textAlignment = .right
            
            firstnameLabel.textAlignment = .right
            lastnameLabel.textAlignment = .right
            
            nameTitleLAbel.textAlignment = .right
            backBtn.imageView?.performRTLTransform()
            nextBtn.imageView?.performRTLTransform()
          }else{
            firstNameTF.textAlignment = .left
            lastNameTF.textAlignment = .left
            
            nameTitleLAbel.textAlignment = .left
            firstnameLabel.textAlignment = .left
            lastnameLabel.textAlignment = .left
        }
        
         nextBtn.setElevation(ShadowElevation(rawValue: 6), for: .normal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
      firstNameTF.becomeFirstResponder()
        self.lottieWholeView.isHidden = true
        self.lottieView.isHidden = true
        self.offlineView.isHidden = true
    }
  
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
     
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
        self.offlineView.isHidden = true
        self.bottomGoView.isHidden = false
        lastNameTF.resignFirstResponder()
        firstNameTF.resignFirstResponder()
        self.lottieView.isHidden = false
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor(named: "Title_Header")!.withAlphaComponent(0.5)
        self.firstLastView.addSubview(lottieWholeView)
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.white
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Utility.shared.signupArray.replaceObject(at: 0, with: firstNameTF.text! as AnyObject)
        Utility.shared.signupArray.replaceObject(at: 1, with: lastNameTF.text! as AnyObject)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            let emailObj = EmailPageVC()
            emailObj.modalPresentationStyle = .fullScreen
             self.present(emailObj, animated: false, completion: nil)
         
        })
        }
        else{
            self.offlineView.isHidden = false
            firstNameTF.resignFirstResponder()
            lastNameTF.resignFirstResponder()
            self.lottieView.isHidden = true
            self.bottomGoView.isHidden = true
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    @IBAction func retryTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        self.offlineView.isHidden = true
        self.lottieWholeView.isHidden = false
        self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor(named: "Title_Header")!.withAlphaComponent(0.5)
        self.firstLastView.addSubview(lottieWholeView)
        self.bottomGoView.isHidden = false
        lastNameTF.resignFirstResponder()
        firstNameTF.resignFirstResponder()
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-50, y: FULLHEIGHT/2-50, width: 100, height: 100)
        self.lottieWholeView.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.white
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Utility.shared.signupArray.replaceObject(at: 0, with: firstNameTF.text! as AnyObject)
        Utility.shared.signupArray.replaceObject(at: 1, with: lastNameTF.text! as AnyObject)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            let emailObj = EmailPageVC()
            emailObj.modalPresentationStyle = .fullScreen
            self.present(emailObj, animated: false, completion: nil)
         
        })
        }
        
    }
    
    func initialSetup()
    {
      firstLastView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        self.offlineView.isHidden = true
       firstnameTick.isHidden = true
        lastNameTick.isHidden = true
        lottieView.isHidden = true
        lastNameTF.text = ""
        firstNameTF.text = ""
        Utility.shared.signupArray.add("")
        Utility.shared.signupArray.add("")
        lastNameTF.autocorrectionType = UITextAutocorrectionType.no
        firstNameTF.autocorrectionType = UITextAutocorrectionType.no
        self.nextBtn.isUserInteractionEnabled = false
        lottieView = LottieAnimationView.init(name: "loading_qwe")
        nextBtn.layer.cornerRadius = nextBtn.frame.size.width/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.width/2
        nextBtn.clipsToBounds = true
        firstNameTF.becomeFirstResponder()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
         nameTitleLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"tellname"))!)"
        firstnameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"firstname"))!)"
        firstNameTF.addTarget(self, action: #selector(FirstLastnamePageVC.textFieldDidChange(_:)),
                             for: UIControl.Event.editingChanged)
        lastNameTF.addTarget(self, action: #selector(FirstLastnamePageVC.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        lastnameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"lastname"))!)"
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
    retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        
        self.firstLastView.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        self.view.applyGradient(colours: Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        firstnameLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        firstNameTF.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
        lastnameLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        lastNameTF.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
        nameTitleLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 30)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
       
            retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
     
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
      
        self.bottomconstraint.constant = keyboardFrame.height
      
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
      
      
         self.bottomconstraint.constant = 35
        
        if (!((Utility.shared.checkEmptyWithString(value:firstNameTF.text!)) && (Utility.shared.checkEmptyWithString(value: lastNameTF.text!)))) {
            
            if (Utility.shared.checkEmptyWithString(value: lastNameTF.text!)){
                  self.configureNextBtn(enable: false)
            }else{
                  self.configureNextBtn(enable: true)
            }
          
            
        }
        else{
            self.configureNextBtn(enable: false)
        }
        
    }

    fileprivate func FirstNameValidation () {
        

    if(firstNameCount > -1){
        if self.firstnameTick.isHidden   {
                self.firstnameTick.image = nil
                self.firstnameTick.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.firstnameTick, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.firstnameTick.image = #imageLiteral(resourceName: "right_white")
                    self.firstnameTick.transform = expandTransform
                },
                    completion: {(finished: Bool) in
                            UIView.animate(withDuration: 0.5,
                                        delay:0.0,
                                        usingSpringWithDamping:0.40,
                                        initialSpringVelocity:0.2,
                                        options:UIView.AnimationOptions.curveEaseOut,
                                        animations: {
                                                    self.firstnameTick.transform = expandTransform.inverted()
                                    }, completion:nil)
                })
        }
    else if(firstNameTF.text!.count == 0) {
        if(firstNameTF.text!.count > firstname.count) {
            firstname = ""
            self.firstnameTick.image = nil
            self.firstnameTick.isHidden = true
            let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            UIView.transition(with: self.firstnameTick, duration:0.2, options: [.transitionCrossDissolve], animations: {
            self.firstnameTick.image = #imageLiteral(resourceName: "right_white")
            self.firstnameTick.transform = expandTransform
},
            completion: {(finished: Bool) in
            UIView.animate(withDuration: 0.5,
                           delay:0.0,
                           usingSpringWithDamping:0.40,
                           initialSpringVelocity:0.2,
                           options:UIView.AnimationOptions.curveEaseOut,
                           animations: {
                                        self.firstnameTick.transform = expandTransform.inverted()
                                        }, completion:nil)
                        })
                    }
                    else{
                        UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                        self.firstnameTick.alpha = 0
                        self.nextBtn.isUserInteractionEnabled = false
                        self.nextBtn.alpha = 0.7
                                                }, completion: { (comp) in
                                                self.firstnameTick.isHidden = false
                                                self.firstnameTick.alpha = 1
                                                self.firstnameTick.image = nil
                                                self.configureNextBtn(enable: false)
                            })
                        }
                    }
        else if(firstNameCount == 0){
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    self.firstnameTick.alpha = 0
                    self.nextBtn.isUserInteractionEnabled = false
                    self.nextBtn.alpha = 0.7
                }, completion: { (comp) in
                    self.firstnameTick.isHidden = true
                    self.firstnameTick.alpha = 1
                    self.firstnameTick.image = nil
                    self.configureNextBtn(enable: false)
                })
            }
        firstname = firstNameTF.text!
    }
        else  {
                if !(self.firstnameTick.isHidden){
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    self.firstnameTick.alpha = 0
                    self.nextBtn.isUserInteractionEnabled = false
                    self.nextBtn.alpha = 0.7
            }, completion: { (comp) in
                self.firstnameTick.isHidden = true
                self.firstnameTick.alpha = 1
                self.firstnameTick.image = nil
                self.configureNextBtn(enable: false)
            })
        }
    }
}
    fileprivate func IfFirstNameFieldEmpty() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
            self.firstnameTick.alpha = 0
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
        }, completion: { (comp) in
            self.firstnameTick.isHidden = true
            self.firstnameTick.alpha = 1
            self.firstnameTick.image = nil
            self.configureNextBtn(enable: false)
        })
    }
    fileprivate func LastNameValidation () {

            if((lastNameTF.text?.count)! > -1)
            {
            if self.lastNameTick.isHidden {
                lastname = ""
                self.lastNameTick.image = nil
                self.lastNameTick.isHidden = false
                let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                UIView.transition(with: self.lastNameTick, duration:0.2, options: [.transitionCrossDissolve], animations: {
                    self.lastNameTick.image = #imageLiteral(resourceName: "right_white")
                    self.lastNameTick.transform = expandTransform
                },
                                  completion: {(finished: Bool) in
                                    UIView.animate(withDuration: 0.5,
                                                   delay:0.0,
                                                   usingSpringWithDamping:0.40,
                                                   initialSpringVelocity:0.2,
                                                   options:UIView.AnimationOptions.curveEaseOut,
                                                   animations: {
                                                    self.lastNameTick.transform = expandTransform.inverted()
                    }, completion:nil)
                })
        }
        else if(lastNameTF.text!.count == 0){
                if(lastNameTF.text!.count > lastname.count)
                {
                    self.lastNameTick.image = nil
                    self.lastNameTick.isHidden = true
                    let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    UIView.transition(with: self.lastNameTick, duration:0.2, options: [.transitionCrossDissolve], animations: {
                        self.lastNameTick.image = #imageLiteral(resourceName: "right_white")
                        self.lastNameTick.transform = expandTransform
                    },
                                      completion: {(finished: Bool) in
                                        UIView.animate(withDuration: 0.5,
                                                       delay:0.0,
                                                       usingSpringWithDamping:0.40,
                                                       initialSpringVelocity:0.2,
                                                       options:UIView.AnimationOptions.curveEaseOut,
                                                       animations: {
                                                        self.lastNameTick.transform = expandTransform.inverted()
                                        }, completion:nil)
        })
}
    else{
        UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
            self.lastNameTick.alpha = 0
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
            }, completion: { (comp) in
                        self.lastNameTick.isHidden = true
                        self.lastNameTick.alpha = 1
                        self.lastNameTick.image = nil
                        self.configureNextBtn(enable: false)
            })
        }
    }
            else if(lastNameTF.text!.count <= 0){
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                self.lastNameTick.alpha = 0
                self.nextBtn.isUserInteractionEnabled = false
                self.nextBtn.alpha = 0.7
                    
            }, completion: { (comp) in
                    self.lastNameTick.isHidden = true
                    self.lastNameTick.alpha = 1
                    self.lastNameTick.image = nil
                    self.configureNextBtn(enable: false)
                    })
                }
                lastname = lastNameTF.text!
            }
            else {
            if !self.lastNameTick.isHidden {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
                    
                    self.lastNameTick.alpha = 0
                    self.nextBtn.isUserInteractionEnabled = false
                    self.nextBtn.alpha = 0.7
                    
                }, completion: { (comp) in
                    
                    self.lastNameTick.isHidden = true
                    self.lastNameTick.alpha = 1
                    self.lastNameTick.image = nil
                    self.configureNextBtn(enable: false)
                    })
            }
        }
}
    fileprivate func IfLastNameIsEmpty() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
            
            self.lastNameTick.alpha = 0
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
            
        }, completion: { (comp) in
            
            self.lastNameTick.isHidden = true
            self.lastNameTick.alpha = 1
            self.lastNameTick.image = nil
            self.configureNextBtn(enable: false)
            })
    }

}

extension FirstLastnamePageVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
            string_value = string.trimmingCharacters(in:.whitespacesAndNewlines)
        
        if ((((firstNameTF.text?.count)! > 0) && ((lastNameTF.text?.count)! > -1)) &&  (!(text_Title == "" && (string_value == ""))) && !lastNameTF.text!.isBlank && !firstNameTF.text!.isBlank) {
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.alpha = 1.0
                }
        else {
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
            }
    return true
}

     @objc func textFieldDidChange(_ textField: UITextField) {
         text_Title = textField.text!.trimmingCharacters(in:.whitespacesAndNewlines)
        firstNameCount = firstNameTF.text!.count
       if textField == firstNameTF {
        if (!(text_Title == "" && (string_value == ""))){
            self.FirstNameValidation()
         
        } else {
            self.IfFirstNameFieldEmpty()
          
        }

      }else if textField == lastNameTF {
        
        if (!(text_Title == "" && (string_value == ""))){
            self.LastNameValidation()
           
        }else {
            self.IfLastNameIsEmpty()
           
            }
        }
        if (!(firstNameTF.isEmpty()) && !(lastNameTF.isEmpty())) {
             self.configureNextBtn(enable: true)
        }else {
            self.configureNextBtn(enable: false)
        }
    }
    
}

