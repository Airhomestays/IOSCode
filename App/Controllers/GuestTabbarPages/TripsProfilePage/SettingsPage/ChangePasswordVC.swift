

import UIKit
import Apollo
import Toast_Swift


class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var changePWLabel: UILabel!
    @IBOutlet weak var oldpasswordLabel: UILabel!
    @IBOutlet weak var oldPWTF: UITextField!
    @IBOutlet weak var NewPWLabel: UILabel!
    @IBOutlet weak var NewPWTF: CustomUITextField!
    @IBOutlet weak var confirmnewPWLabel: UILabel!
    @IBOutlet weak var confirmnewPWTF: CustomUITextField!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var updateBtn: UIButton!
    var apollo_headerClient:ApolloClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oldPWTF.isSecureTextEntry = !self.oldPWTF.isSecureTextEntry
        self.NewPWTF.isSecureTextEntry = !self.NewPWTF.isSecureTextEntry
        self.confirmnewPWTF.isSecureTextEntry = !self.confirmnewPWTF.isSecureTextEntry
        oldPWTF.delegate = self
        NewPWTF.delegate = self
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.offlineView.backgroundColor = UIColor(named: "Button_Grey_Color")
      
        confirmnewPWTF.delegate = self
        initialsetup()
        newPasswordTF()
        confirmPWTF()
        self.offlineView.isHidden = true
    }
    
    
    func initialsetup(){
        
        let oldPWleftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: oldPWTF.frame.height))
        oldPWTF.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        oldPWTF.leftView = oldPWleftView
        oldPWTF.leftViewMode = .always
        oldPWTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey: "oldPWFTF")) ?? "Enter your old password")"
        oldPWTF.textColor = UIColor(named: "textfieldtextColor")
        oldPWTF.backgroundColor = UIColor(named: "colorController")
        oldPWTF.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        oldPWTF.layer.borderWidth = 1
        oldPWTF.clipsToBounds = true
        oldPWTF.layer.cornerRadius = 5
        
        let newPWleftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: NewPWTF.frame.height))
        NewPWTF.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        NewPWTF.leftView = newPWleftView
        NewPWTF.leftViewMode = .always
        NewPWTF.backgroundColor = UIColor(named: "colorController")
        NewPWTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey: "NewPWTF")) ?? "Enter your new password")"
        NewPWTF.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        NewPWTF.textColor = UIColor(named: "textfieldtextColor")
        NewPWTF.layer.borderWidth = 1
        NewPWTF.clipsToBounds = true
        NewPWTF.layer.cornerRadius = 5
        
        let confirPWleftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: confirmnewPWTF.frame.height))
        confirmnewPWTF.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        confirmnewPWTF.leftView = confirPWleftView
        confirmnewPWTF.leftViewMode = .always
        confirmnewPWTF.backgroundColor = UIColor(named: "colorController")
        confirmnewPWTF.placeholder = "\((Utility.shared.getLanguage()?.value(forKey: "confirmnewPWTF")) ?? "Confirm new password")"
        confirmnewPWTF.textColor = UIColor(named: "")
        confirmnewPWTF.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        confirmnewPWTF.layer.borderWidth = 1
        confirmnewPWTF.clipsToBounds = true
        confirmnewPWTF.layer.cornerRadius = 5
        
        changePWLabel.textColor = UIColor(named:"textfieldtextColor")
        changePWLabel.font = UIFont(name:APP_FONT_SEMIBOLD , size: 20)
        changePWLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:  "changePW")) ?? "Change your password")"
        
        oldpasswordLabel.textColor = UIColor(named: "Title_Header")
        oldpasswordLabel.font = UIFont(name:APP_FONT_MEDIUM , size: 14)
        oldpasswordLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "oldpassword")) ?? "Old password" )"
        
        NewPWLabel.textColor = UIColor(named: "Title_Header")
        NewPWLabel.font = UIFont(name:APP_FONT_MEDIUM , size: 14)
        NewPWLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "newpassword")) ?? "New password")"
        
        confirmnewPWLabel.textColor = UIColor(named: "Title_Header")
        confirmnewPWLabel.font = UIFont(name:APP_FONT_MEDIUM , size: 14)
        confirmnewPWLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "confirmNPW")) ?? "Confirm new password")"
        
      
        updateBtn.backgroundColor = Theme.SECONDARY_COLOR
        updateBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "updatePW"))!)", for: .normal)
        
        updateBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        updateBtn.cornerRadius = 25
        
        
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height:oldPWTF.frame.size.height))
        let eyeIconBtn = UIButton(frame: CGRect(x:0, y: (oldPWTF.frame.size.height - 40) / 2, width: 40, height: 40))
        eyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        eyeIconBtn.setTitle("", for: .normal)
        eyeIconBtn.backgroundColor = .clear
        eyeIconBtn.addTarget(self, action: #selector(showOldPasswordAction), for: .touchUpInside)
        
        eyeView.addSubview(eyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.oldPWTF.leftView = eyeView
            self.oldPWTF.rightViewMode = .always
            self.oldPWTF.clearButtonMode = .whileEditing
            self.oldPWTF.textAlignment = .right
        }else{
            self.oldPWTF.rightView = eyeView
            self.oldPWTF.rightViewMode = .always
            self.oldPWTF.clearButtonMode = .whileEditing
            self.oldPWTF.textAlignment = .left
        }
        
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        if(Utility.shared.isRTLLanguage()) {
            errorLabel.textAlignment = .right
           }else {
            errorLabel.textAlignment = .left
        }
        
    }
    
    func newPasswordTF(){
        
        let npwEyeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height:NewPWTF.frame.size.height))
        let npwEyeIconBtn = UIButton(frame: CGRect(x:0, y: (NewPWTF.frame.size.height - 40) / 2, width: 40, height: 40))
        npwEyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        npwEyeIconBtn.setTitle("", for: .normal)
        npwEyeIconBtn.backgroundColor = .clear
        npwEyeIconBtn.addTarget(self, action: #selector(showNewPasswordAction), for: .touchUpInside)
        
        npwEyeView.addSubview(npwEyeIconBtn)
        
        if Utility.shared.isRTLLanguage(){
            self.NewPWTF.leftView =  npwEyeView
            self.NewPWTF.rightViewMode = .always
            self.NewPWTF.clearButtonMode = .whileEditing
            self.NewPWTF.textAlignment = .right
        }else{
            self.NewPWTF.rightView =  npwEyeView
            self.NewPWTF.rightViewMode = .always
            self.NewPWTF.clearButtonMode = .whileEditing
            self.NewPWTF.textAlignment = .left
        }
        
    }
    
    func confirmPWTF(){
        
        let confirmPWEyeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height:NewPWTF.frame.size.height))
        let confirmPWEyeIconBtn = UIButton(frame: CGRect(x:0, y: (NewPWTF.frame.size.height - 40) / 2, width: 40, height: 40))
        confirmPWEyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        confirmPWEyeIconBtn.setTitle("", for: .normal)
        confirmPWEyeIconBtn.backgroundColor = .clear
        confirmPWEyeIconBtn.addTarget(self, action: #selector(showConfirmPasswordAction), for: .touchUpInside)
        
        confirmPWEyeView.addSubview(confirmPWEyeIconBtn)
        
        if Utility.shared.isRTLLanguage(){
            self.confirmnewPWTF.leftView =  confirmPWEyeView
            self.confirmnewPWTF.rightViewMode = .always
            self.confirmnewPWTF.clearButtonMode = .whileEditing
            self.confirmnewPWTF.textAlignment = .right
        }else{
            self.confirmnewPWTF.rightView =  confirmPWEyeView
            self.confirmnewPWTF.rightViewMode = .always
            self.confirmnewPWTF.clearButtonMode = .whileEditing
            self.confirmnewPWTF.textAlignment = .left
        }
        
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func showOldPasswordAction(_ sender: Any) {
        
        self.oldPWTF.isSecureTextEntry = !self.oldPWTF.isSecureTextEntry
        
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height:oldPWTF.frame.size.height))
        let eyeIconBtn = UIButton(frame: CGRect(x: 0, y: (oldPWTF.frame.size.height - 40) / 2, width: 40, height: 40))
        
        if self.oldPWTF.isSecureTextEntry{
            eyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        }else{
            eyeIconBtn.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        eyeIconBtn.setTitle("", for: .normal)
        eyeIconBtn.backgroundColor = .clear
        eyeIconBtn.addTarget(self, action: #selector(showOldPasswordAction), for: .touchUpInside)
        
        eyeView.addSubview(eyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.oldPWTF.rightView = eyeView
            self.oldPWTF.rightViewMode = .always
            self.oldPWTF.clearButtonMode = .whileEditing
            self.oldPWTF.textAlignment = .right
        }else{
            self.oldPWTF.rightView = eyeView
            self.oldPWTF.rightViewMode = .always
            self.oldPWTF.clearButtonMode = .whileEditing
            self.oldPWTF.textAlignment = .left
        }
        
    }
    
    @objc func showNewPasswordAction() {
        
        self.NewPWTF.isSecureTextEntry = !self.NewPWTF.isSecureTextEntry
        
        let  npwEyeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height:NewPWTF.frame.size.height))
        let npwEyeIconBtn = UIButton(frame: CGRect(x: 0, y: (NewPWTF.frame.size.height - 40) / 2, width: 40, height: 40))
        
        if self.NewPWTF.isSecureTextEntry{
            npwEyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        }else{
            npwEyeIconBtn.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        npwEyeIconBtn.setTitle("", for: .normal)
        npwEyeIconBtn.backgroundColor = .clear
        npwEyeIconBtn.addTarget(self, action: #selector(showNewPasswordAction), for: .touchUpInside)
        
        npwEyeView.addSubview(npwEyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.NewPWTF.rightView =  npwEyeView
            self.NewPWTF.rightViewMode = .always
            self.NewPWTF.clearButtonMode = .whileEditing
            self.NewPWTF.textAlignment = .right
        }else{
            self.NewPWTF.rightView =  npwEyeView
            self.NewPWTF.rightViewMode = .always
            self.NewPWTF.clearButtonMode = .whileEditing
            self.NewPWTF.textAlignment = .left
        }
        
    }
    
    
    @objc func showConfirmPasswordAction(){
        
        self.confirmnewPWTF.isSecureTextEntry = !self.confirmnewPWTF.isSecureTextEntry
        
        let confirmPWEyeView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height:confirmnewPWTF.frame.size.height))
        let confirmPWEyeIconBtn = UIButton(frame: CGRect(x: 0, y: (confirmnewPWTF.frame.size.height - 40) / 2, width: 40, height: 40))
        
        if self.confirmnewPWTF.isSecureTextEntry{
            confirmPWEyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        }else{
            confirmPWEyeIconBtn.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        confirmPWEyeIconBtn.setTitle("", for: .normal)
        confirmPWEyeIconBtn.backgroundColor = .clear
        confirmPWEyeIconBtn.addTarget(self, action: #selector(showConfirmPasswordAction), for: .touchUpInside)
        
        confirmPWEyeView.addSubview(confirmPWEyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.confirmnewPWTF.rightView =  confirmPWEyeView
            self.confirmnewPWTF.rightViewMode = .always
            self.confirmnewPWTF.clearButtonMode = .whileEditing
            self.confirmnewPWTF.textAlignment = .right
        }else{
            self.confirmnewPWTF.rightView =  confirmPWEyeView
            self.confirmnewPWTF.rightViewMode = .always
            self.confirmnewPWTF.clearButtonMode = .whileEditing
            self.confirmnewPWTF.textAlignment = .left
        }
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            
     
            if oldPWTF.text == "" {
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "samepasswordchange"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                return
                
            }else if (oldPWTF.text == "" &&  NewPWTF.text != "") || (oldPWTF.text == "" && confirmnewPWTF.text != ""){
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "samepasswordchange"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                return
            }else if(NewPWTF.text!.count < 8 || NewPWTF.text == "" || NewPWTF.isEmpty()){
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "newPWChar"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
               return
                
            }else if(confirmnewPWTF.text!.count < 8 || confirmnewPWTF.text == "" || confirmnewPWTF.isEmpty()){
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "confirmPWChar"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                return
            }else if(confirmnewPWTF.text!.count < 8 ){
                
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "confirmPWChar"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                return
            }else if oldPWTF.text == ""{
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey:"samepasswordchange"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                return
                
            }else if confirmnewPWTF.text != NewPWTF.text  {
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "sameNewPwConfirmPW"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                 return
            }else{
                changePassword()
            }
         }else{
             self.offlineView.isHidden = false
        }
        
    }
    
    
    func changePassword(){
        
        var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
        
        
        let changepassword = ChangePasswordMutation(oldPassword: oldPWTF.text!, newPassword: NewPWTF.text!,confirmPassword: confirmnewPWTF.text!)
        
        apollo_headerClient.perform(mutation: changepassword){ (result,error)in
            if (result?.data?.changePassword?.status == 200){
                let seconds = 2.0
                self.showToast(message : "\((Utility.shared.getLanguage()?.value(forKey: "password_success"))!)" , font: UIFont(name: APP_FONT, size: 15)! )
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    
                    self.dismiss(animated: true)
                }
               
            }
            else if(result?.data?.changePassword?.status == 400) {
                self.showToast(message : result?.data?.changePassword?.errorMessage ?? "" , font: UIFont(name: APP_FONT, size: 15)! )
                
            }else if(result?.data?.changePassword?.status == 500){
                self.showToast(message : result?.data?.changePassword?.errorMessage ?? "" , font: UIFont(name: APP_FONT, size: 15)! )
             
            }
            
        }
         
    }
    
    
    @IBAction func onclickActionBtn(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
        }
    }
    
       
}


extension ChangePasswordVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 25
        let currentString: NSString = textField.text as! NSString
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maxLength
    }

  

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.oldPWTF{
            self.NewPWTF.becomeFirstResponder()
        }else if textField == self.NewPWTF{
            self.confirmnewPWTF.becomeFirstResponder()
        }else{
            textField.endEditing(true)
        }
        return true
    }
    
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let width:CGFloat = 300
    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - (width/2) , y: self.view.frame.size.height-70, width: width, height: 60))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.numberOfLines = 0
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    DispatchQueue.main.asyncAfter(deadline: .now() + ToastManager.shared.duration ){
        toastLabel.removeFromSuperview()
    }

} }
