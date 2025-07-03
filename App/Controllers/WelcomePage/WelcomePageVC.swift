

import UIKit
import MaterialComponents.MaterialButtons
import GoogleSignIn
import AuthenticationServices
import Lottie
import Apollo
import FirebaseCore

class WelcomePageVC: UIViewController  {
    
    
    @IBOutlet weak var welcomeScroll: UIScrollView!
    @IBOutlet var loginalterBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
    @IBOutlet var welcomeLabel: UILabel!
    
    
    @IBOutlet var lineView2: UIView!
    @IBOutlet var lineView1: UIView!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextView: CustomUITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: CustomUITextField!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    @IBOutlet weak var continueWithLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
  
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineTextLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    var lottieWholeView = UIView()
    var lottieView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.navigationController?.isNavigationBarHidden = true
        self.initialSetup()
        NotificationCenter.default.removeObserver(self)
        self.lottieView = LottieAnimationView.init(name: "loading_qwe")
        Utility.shared.isSwitchEnable = false
      
    }

   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor =   UIColor(named: "colorController")
        lineView1.backgroundColor = UIColor(named: "Title_Header")
        lineView2.backgroundColor = UIColor(named: "Title_Header")
        
        self.lottieView.isHidden = true
        self.lottieWholeView.isHidden = true
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        Utility.shared.TotalFilterCount = 0
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        Utility.shared.setTab(index: 0)
        appdelegate.GuestTabbarInitialize(initialView: CustomTabbar())
    }
    
    @IBAction func onClickForgotBtn(_ sender: UIButton) {
        let forgotObj = ForgotPasswordVC()
        forgotObj.modalPresentationStyle = .fullScreen
        self.present(forgotObj, animated: false, completion: nil)
    }
    
    @IBAction func FacebookAction(_ sender: Any) {
        
       
        faceBookLogin(viewC: self)
    }
    
    @IBAction func googleAction(_ sender: Any) {
        URLCache.shared.removeAllCachedResponses()
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        GIDSignIn.sharedInstance.signOut()
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

     
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else { return }
            
           

            self.googleAPICall(data:result!)
        
          }
       
      
    }
    
    func googleAPICall(data:GIDSignInResult) {
       
        let name = data.user.profile?.givenName
        let fname = data.user.profile?.familyName
        let email = data.user.profile?.email
        let userImageURL = data.user.profile?.imageURL(withDimension: 200)!
            self.lottieWholeView.isHidden = false
                
                self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
            self.view.addSubview(lottieWholeView)
            self.lottieView.isHidden = false
            self.lottieView.frame = CGRect(x:self.view.frame.size.width/2-40, y: self.view.frame.size.height/2-40, width: 80, height: 80)
            self.lottieWholeView.addSubview(self.lottieView)
                self.view.bringSubviewToFront(lottieWholeView)
            self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
            self.lottieView.layer.cornerRadius = 6.0
            self.lottieView.clipsToBounds = true
            self.lottieView.play()
                
            
                let params = [
                 "name": "\(name ?? "")",
                    "email": "\(email ?? "")",
                 "image": "\(userImageURL)"
                ]
                
                let signupMutation = SocialLoginQuery(firstName: "\(name ?? "")", lastName: "\(fname ?? "")", email: "\(email ?? "")", dateOfBirth: "", deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "google", gender: "", profilePicture:"\(userImageURL)")
                
                 apollo.fetch(query: signupMutation,cachePolicy:.fetchIgnoringCacheData){ (result,error) in
                     
                     self.lottieWholeView.isHidden = true
                     self.lottieView.isHidden = true

                    if(result?.data?.userSocialLogin?.status == 200)
                    {
                        Utility.shared.setopenTabbar(iswhichtabbar:false)
                        Utility.shared.signupArray.removeAllObjects()
                        Utility.shared.signupdataArray.removeAll()
                     if let token = result?.data?.userSocialLogin?.result?.userToken {
                         Utility.shared.setUserToken(userID:token as NSString)
                     }
                     if let userid = result?.data?.userSocialLogin?.result?.userId {
                         Utility.shared.setUserID(userid:userid as NSString)
                     }
                     
                     if(result?.data?.userSocialLogin?.result?.user?.preferredCurrency != nil)
                     {
                       
                         Utility.shared.setPreferredCurrency(currency_rate: (result?.data?.userSocialLogin?.result?.user?.preferredCurrency as AnyObject) as! String)
                     }
                     else
                     {
                         Utility.shared.setPreferredCurrency(currency_rate:"USD")
                         Utility.shared.selectedCurrency = "USD"
                     }
                     if let firstName = result?.data?.userSocialLogin?.result?.user?.firstName {
                         Utility.shared.signupdataArray.append(firstName as AnyObject)
                     }
                     if let createdAt = result?.data?.userSocialLogin?.result?.user?.createdAt {
                         Utility.shared.signupdataArray.append(createdAt as AnyObject)
                     }
                     if let picture = result?.data?.userSocialLogin?.result?.user?.picture {
                         Utility.shared.signupdataArray.append(picture as AnyObject)
                     }
                     if let isEmailConfirmed = result?.data?.userSocialLogin?.result?.user?.verification?.isEmailConfirmed {
                         Utility.shared.signupdataArray.append(isEmailConfirmed as AnyObject)
                     }
                     if let isIdVerification = result?.data?.userSocialLogin?.result?.user?.verification?.isIdVerification {
                         Utility.shared.signupdataArray.append(isIdVerification as AnyObject)
                     }
                     if let isFacebookConnected = result?.data?.userSocialLogin?.result?.user?.verification?.isFacebookConnected {
                         Utility.shared.signupdataArray.append(isFacebookConnected as AnyObject)
                     }
                     if let isPhoneVerified = result?.data?.userSocialLogin?.result?.user?.verification?.isPhoneVerified {
                         Utility.shared.signupdataArray.append(isPhoneVerified as AnyObject)
                     }
                     if let isGoogleConnected = result?.data?.userSocialLogin?.result?.user?.verification?.isGoogleConnected {
                         Utility.shared.signupdataArray.append(isGoogleConnected as AnyObject)
                     }
                     if let userToken = result?.data?.userSocialLogin?.result?.userToken {
                         Utility.shared.user_token = userToken
                     }

                        Utility.shared.setTab(index: 0)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.profileAPICall()
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        Utility.shared.TotalFilterCount = 0
                        appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())


                    }
                    else
                    {
                            self.view.makeToast("\((result?.data?.userSocialLogin?.errorMessage) != nil ? ((result?.data?.userSocialLogin?.errorMessage)!) : "")")
                    }
                    
                
                
            }
           
          }
    

    @IBAction func onClickAppleBtn(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
        if #available(iOS 13.0, *) {
        let authorizationProvider = ASAuthorizationAppleIDProvider()
                let request = authorizationProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
              let authorizationController = ASAuthorizationController(authorizationRequests: [request])
               authorizationController.delegate = self
               authorizationController.presentationContextProvider = self
               authorizationController.performRequests()
        }
        else
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "appleloginalert"))!)")
        }
        }
        else
        {
           self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "error_field"))!)")
        }
    }
    @IBAction func createAccountAction(_ sender: Any) {
        Utility.shared.signupArray.removeAllObjects()
        let FirstnameObj = FirstLastnamePageVC()
        FirstnameObj.modalPresentationStyle = .fullScreen
         self.present(FirstnameObj, animated: false, completion: nil)
    }
 
    @IBAction func onClickRetryBtn(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
        self.offlineView.isHidden = true
        self.lottieWholeView.isHidden = false
            
            self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(lottieWholeView)
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:self.view.frame.size.width/2-40, y: self.view.frame.size.height/2-40, width: 80, height: 80)
        self.lottieWholeView.addSubview(self.lottieView)
            self.view.bringSubviewToFront(lottieWholeView)
        self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        self.checkLoginAPI()
        }
    }
    @IBAction func socialLoginAction(_ sender: Any) {
        let socialloginObj = SocialSigninPage()
        socialloginObj.modalPresentationStyle = .fullScreen
        self.present(socialloginObj, animated: false, completion: nil)
    }

    
    @IBAction func loginBtnAction(_ sender: Any) {
        emailTextView.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if (!emailTextView.text!.isValidEmail()) {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"email_validalert"))!)")
            return
        }
        else if (passwordTextField.text!.count < 7) {
        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"passcode_count"))!)")
            return ;
        }
        
        if Utility().isConnectedToNetwork(){
            self.lottieWholeView.isHidden = false
            self.lottieWholeView.frame = self.view.frame
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
            self.welcomeScroll.addSubview(lottieWholeView)
            self.offlineView.isHidden = true
            self.lottieView.isHidden = false
            self.lottieView.frame = CGRect(x:self.lottieWholeView.frame.size.width/2-40, y: self.lottieWholeView.frame.size.height/2-40, width: 80, height: 80)
            self.lottieWholeView.addSubview(self.lottieView)
            self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
            self.lottieView.layer.cornerRadius = 6.0
            self.lottieView.clipsToBounds = true
            self.lottieView.play()
            self.checkLoginAPI()
            }
            else{
                self.offlineView.isHidden = false
            }
        }
    
    func checkLoginAPI()
    {
        let loginquery = LoginQuery(email: emailTextView.text ?? "", password: passwordTextField.text ?? "", deviceType:"iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken)
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

               
                Utility.shared.setPassword(password: self.passwordTextField.text! as NSString)
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

                appDelegate.profileAPICall()
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                Utility.shared.TotalFilterCount = 0
                appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
               
            }else if result?.data?.userLogin?.status == 500 {
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.view.makeToast("\((result?.data?.userLogin?.errorMessage)!)")
              
            }
            else{
                self.passwordTextField.resignFirstResponder()
              
                self.lottieView.isHidden = true
                self.lottieWholeView.isHidden = true
                self.view.makeToast("\(result?.data?.userLogin?.errorMessage ?? "\(Utility.shared.getLanguage()?.value(forKey: "somethingwrong") ?? "Something went wrong!")")")
            }
        }
    }

 
    func initialSetup()
    {
        
        closeBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Skip") ?? "Skip")", for: .normal)
        closeBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        closeBtn.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        closeBtn.layer.borderWidth = 1.0
        closeBtn.layer.cornerRadius = closeBtn.frame.size.height/2
        closeBtn.clipsToBounds = true
        closeBtn.backgroundColor = .clear
        closeBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        welcomeLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"welcome_rent") ?? "Welcome to RentALL")"
        welcomeLabel.textColor = UIColor(named: "Title_Header")
        welcomeLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        welcomeLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 20.0)
        
        emailLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "email") ?? "Email")"
        emailLabel.textColor = UIColor(named: "Title_Header")
        emailLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        emailLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        emailTextView.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "emailaddress") ?? "Email address")"
        emailTextView.textColor = UIColor(named: "searchPlaces_TextColor")
        emailTextView.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        emailTextView.font = UIFont(name: APP_FONT, size: 14.0)
        emailTextView.delegate = self
        emailTextView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        
        emailTextView.layer.borderWidth = 1
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        emailTextView.leftView = leftView
        emailTextView.leftViewMode = .always
        
        
        passwordLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "password") ?? "Password")"
        passwordLabel.textColor = UIColor(named: "Title_Header")
        passwordLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        passwordLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        passwordTextField.placeholder = "\(Utility.shared.getLanguage()?.value(forKey: "password") ?? "Password")"
        passwordTextField.textColor = UIColor(named: "searchPlaces_TextColor")
        passwordTextField.font = UIFont(name: APP_FONT, size: 14.0)
        passwordTextField.delegate = self
        passwordTextField.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        
        let leftView1 = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
        passwordTextField.leftView = leftView1
        passwordTextField.leftViewMode = .always
        
        passwordTextField.layer.borderWidth = 1
        
        passwordTextField.layer.cornerRadius = 5
        emailTextView.layer.cornerRadius = 5
        passwordTextField.clipsToBounds = true
        emailTextView.clipsToBounds = true
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
        let eyeIconBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 50, height: 50))
        
        eyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        eyeIconBtn.setTitle("", for: .normal)
        eyeIconBtn.backgroundColor = .clear
        eyeIconBtn.addTarget(self, action: #selector(onClickEyeIcon), for: .touchUpInside)
        
        eyeView.addSubview(eyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.passwordTextField.leftView = eyeView
            self.passwordTextField.leftViewMode = .always
            self.passwordTextField.clearButtonMode = .whileEditing
            self.passwordTextField.textAlignment = .right
        }else{
            self.passwordTextField.rightView = eyeView
            self.passwordTextField.rightViewMode = .always
            self.passwordTextField.clearButtonMode = .whileEditing
            self.passwordTextField.textAlignment = .left
        }
        
        
        forgotPasswordBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "forgotpassword") ?? "Forgot password?")", for: .normal)
        forgotPasswordBtn.backgroundColor = .clear
        forgotPasswordBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        forgotPasswordBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 14.0)
        forgotPasswordBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .trailing : .leading
        
        loginalterBtn.layer.cornerRadius = loginalterBtn.frame.size.height/2
        loginalterBtn.clipsToBounds = true
        loginalterBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"login") ?? "Login")", for:.normal)
        loginalterBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        loginalterBtn.setTitleColor(UIColor.white, for: .normal)
        loginalterBtn.backgroundColor = Theme.Button_BG
        loginalterBtn.isEnabled = true
        loginalterBtn.alpha = 1
        
        continueWithLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"continuewith") ?? "or continue with")"
        continueWithLabel.textColor = UIColor(named: "Title_Header")
        continueWithLabel.textAlignment = .center
        continueWithLabel.font = UIFont(name: APP_FONT, size: 14.0)

        
        googleBtn.setTitle("", for: .normal)
        googleBtn.layer.cornerRadius = googleBtn.frame.size.height / 2
        googleBtn.clipsToBounds = true
        
        appleBtn.setTitle("", for: .normal)
        appleBtn.layer.cornerRadius = appleBtn.frame.size.height / 2
        appleBtn.clipsToBounds = true
        
        appleBtn.imageView?.contentMode = .scaleAspectFill
        
        
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14.0),
            NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
        ]
            
        let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"donthaveacc") ?? "Don't have an account")" + " " , attributes: attributes as [NSAttributedString.Key : Any])
        
        let attributes2 = [
            NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14.0),
            NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
        ]
        
        
        let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"SignupBtn") ?? "SignupBtn")", attributes: attributes2 as [NSAttributedString.Key : Any])
        
        attributedString2.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString2.length))
        attributedString2.addAttribute(NSAttributedString.Key.underlineColor, value: Theme.PRIMARY_COLOR, range: NSRange(location: 0, length: attributedString2.length))
        
        attributedString.append(attributedString2)
        
        
        
        
        signUpLabel.attributedText = attributedString
        signUpLabel.textAlignment = .center
        signUpLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        offlineView.isHidden = true
        
        
        signUpButton.setTitle("", for: .normal)
        signUpButton.backgroundColor = .clear
        
    }
    
    @objc func onClickEyeIcon(){
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        
        let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
        let eyeIconBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 50, height: 50))
        
        if self.passwordTextField.isSecureTextEntry{
            eyeIconBtn.setImage(UIImage(named: "passwordEye"), for: .normal)
        }else{
            eyeIconBtn.setImage(UIImage(named: "passwordEyeOpen"), for: .normal)
        }
        eyeIconBtn.setTitle("", for: .normal)
        eyeIconBtn.backgroundColor = .clear
        eyeIconBtn.addTarget(self, action: #selector(onClickEyeIcon), for: .touchUpInside)
        
        eyeView.addSubview(eyeIconBtn)
        if Utility.shared.isRTLLanguage(){
            self.passwordTextField.rightView = eyeView
            self.passwordTextField.rightViewMode = .always
            self.passwordTextField.clearButtonMode = .whileEditing
            self.passwordTextField.textAlignment = .right
        }else{
            self.passwordTextField.rightView = eyeView
            self.passwordTextField.rightViewMode = .always
            self.passwordTextField.clearButtonMode = .whileEditing
            self.passwordTextField.textAlignment = .left
        }
        
    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        let FirstnameObj = SignUpViewController()
        FirstnameObj.modalPresentationStyle = .fullScreen
        self.present(FirstnameObj, animated: false, completion: nil)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error == nil)
        {
           
            let name = user.profile?.givenName
            let email = user.profile?.email
            let userImageURL = user.profile?.imageURL(withDimension: 200)!

            
        
            let params = [
                "name": "\(name ?? "")",
                "email": "\(email ?? "")",
                "image": "\(userImageURL)"
            ]
            
            
            self.lottieWholeView.isHidden = false
                
                self.lottieWholeView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
            self.lottieWholeView.backgroundColor =  UIColor.black.withAlphaComponent(0.5)
            self.view.addSubview(lottieWholeView)
            self.lottieView.isHidden = false
            self.lottieView.frame = CGRect(x:self.view.frame.size.width/2-40, y: self.view.frame.size.height/2-40, width: 80, height: 80)
            self.lottieWholeView.addSubview(self.lottieView)
                self.view.bringSubviewToFront(lottieWholeView)
            self.lottieView.backgroundColor = UIColor(named: "lottie-bg")
            self.lottieView.layer.cornerRadius = 6.0
            self.lottieView.clipsToBounds = true
            self.lottieView.play()
            let signupMutation = SocialLoginQuery(firstName: "\(name ?? "")", lastName: "", email: "\(email ?? "")", dateOfBirth: "", deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "google", gender: "", profilePicture:"\(userImageURL)")
            
             apollo.fetch(query: signupMutation,cachePolicy:.fetchIgnoringCacheData){ (result,error) in

                if(result?.data?.userSocialLogin?.status == 200)
                {
                    Utility.shared.setopenTabbar(iswhichtabbar:false)
                    Utility.shared.signupArray.removeAllObjects()
                    Utility.shared.signupdataArray.removeAll()
                    if let token = result?.data?.userSocialLogin?.result?.userToken {
                        Utility.shared.setUserToken(userID:token as NSString)
                    }
                
                    if let userid = result?.data?.userSocialLogin?.result?.userId {
                        Utility.shared.setUserID(userid:userid as NSString)
                                       }
                  
                    if(result?.data?.userSocialLogin?.result?.user?.preferredCurrency != nil)
                    {
                    Utility.shared.setPreferredCurrency(currency_rate: (result?.data?.userSocialLogin?.result?.user?.preferredCurrency as AnyObject) as! String)
                    }
                    else
                    {
                        Utility.shared.setPreferredCurrency(currency_rate:"USD")
                        Utility.shared.selectedCurrency = "USD"
                    }
                    if let firstName = result?.data?.userSocialLogin?.result?.user?.firstName {
                       Utility.shared.signupdataArray.append(firstName as AnyObject)
                    }
                    if let createdAt = result?.data?.userSocialLogin?.result?.user?.createdAt {
                        Utility.shared.signupdataArray.append(createdAt as AnyObject)
                    }
                    if let picture = result?.data?.userSocialLogin?.result?.user?.picture {
                        Utility.shared.signupdataArray.append(picture as AnyObject)
                    }
                    if let isEmailConfirmed = result?.data?.userSocialLogin?.result?.user?.verification?.isEmailConfirmed {
                        Utility.shared.signupdataArray.append(isEmailConfirmed as AnyObject)
                    }
                    if let isIdVerification = result?.data?.userSocialLogin?.result?.user?.verification?.isIdVerification {
                        Utility.shared.signupdataArray.append(isIdVerification as AnyObject)
                    }
                    if let isFacebookConnected = result?.data?.userSocialLogin?.result?.user?.verification?.isFacebookConnected {
                        Utility.shared.signupdataArray.append(isFacebookConnected as AnyObject)
                    }
                    if let isPhoneVerified = result?.data?.userSocialLogin?.result?.user?.verification?.isPhoneVerified {
                        Utility.shared.signupdataArray.append(isPhoneVerified as AnyObject)
                    }
                    if let isGoogleConnected = result?.data?.userSocialLogin?.result?.user?.verification?.isGoogleConnected {
                        Utility.shared.signupdataArray.append(isGoogleConnected as AnyObject)
                    }
                   if let userToken = result?.data?.userSocialLogin?.result?.userToken {
                       Utility.shared.user_token = userToken
                   }
                    
                    Utility.shared.setTab(index: 0)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.profileAPICall()
                    Utility.shared.TotalFilterCount = 0
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                }
                else
                {
                    if(result?.data?.userSocialLogin?.errorMessage != nil)
                    {
                        self.view.makeToast("\((result?.data?.userSocialLogin?.errorMessage)!)")
                     
                    }
                }
                
            }
            
            
        }
        else
        {
           
        }
    }
    
    func facebookSignup(){
        
       
        
    }
    
    func faceBookLogin(viewC: UIViewController){


    }
    
}

extension WelcomePageVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextView{
            self.passwordTextField.becomeFirstResponder()
        }else{
            textField.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let valueTobeChecked = string == "" ? (textField.text ?? "") : ((textField.text ?? "") + string)

        if textField == emailTextView{
            if (valueTobeChecked.isValidEmail() && ((passwordTextField.text?.count ?? 0) > 6)){

            }else{

            }
        }else{
            if (emailTextView.isValidEmail() && (valueTobeChecked.count > 6)){
                self.loginalterBtn.isEnabled = true
                self.loginalterBtn.alpha = 1.0
            }else{
            }
            let charsLimit = 25
            
            let startingLength = textField.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace =  range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            
            return newLength <= charsLimit
        }
        let charsLimit = 100
        
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace =  range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= charsLimit
    }
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}
extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x : 0.0, y : 0.5)
        gradient.endPoint = CGPoint(x :1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension WelcomePageVC: ASAuthorizationControllerPresentationContextProviding ,ASAuthorizationControllerDelegate {
    
        @available(iOS 13.0, *)
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            
            }
            
          
            
            if(appleIDCredential.email != nil)
            {
                
                KeychainService.saveEmail(email: "\(appleIDCredential.email!)" as NSString)
                KeychainService.saveUsername(name: "\((appleIDCredential.fullName?.givenName!)!)" as NSString)
                KeychainService.savelname(name: "\((appleIDCredential.fullName?.familyName)!)" as NSString)
            Utility.shared.setappleAccountname(name: "\((appleIDCredential.fullName?.givenName!)!)\((appleIDCredential.fullName?.familyName)!)")
            Utility.shared.setappleAccountEmail(email: "\(appleIDCredential.email!)")
            }
           
           
            let email = KeychainService.loadEmail() != nil ? KeychainService.loadEmail()! : ""
              
            let name = KeychainService.loadUsername() != nil ? KeychainService.loadUsername()! : ""
            let fname = KeychainService.loadlname() != nil ? KeychainService.loadlname()! : ""
           
            
            let signupMutation = SocialLoginQuery(firstName:name as String, lastName: fname as String, email:email as String, dateOfBirth: "", deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "apple", gender: "", profilePicture:"")
            
             apollo.fetch(query: signupMutation,cachePolicy:.fetchIgnoringCacheData){ (result,error) in

                if(result?.data?.userSocialLogin?.status == 200)
                {
                    Utility.shared.setopenTabbar(iswhichtabbar:false)
                    Utility.shared.signupArray.removeAllObjects()
                    Utility.shared.signupdataArray.removeAll()
                     if let token = result?.data?.userSocialLogin?.result?.userToken {
                                                       Utility.shared.setUserToken(userID:token as NSString)
                                                   }
                                                 
                                                   if let userid = result?.data?.userSocialLogin?.result?.userId {
                                                       Utility.shared.setUserID(userid:userid as NSString)
                                                                      }
                                                
                                                   if(result?.data?.userSocialLogin?.result?.user?.preferredCurrency != nil)
                                                   {
                                                   Utility.shared.setPreferredCurrency(currency_rate: (result?.data?.userSocialLogin?.result?.user?.preferredCurrency as AnyObject) as! String)
                                                   }
                                                   else
                                                   {
                                                       Utility.shared.setPreferredCurrency(currency_rate:"USD")
                                                       Utility.shared.selectedCurrency = "USD"
                                                   }
                                                   if let firstName = result?.data?.userSocialLogin?.result?.user?.firstName {
                                                      Utility.shared.signupdataArray.append(firstName as AnyObject)
                                                   }
                                                   if let createdAt = result?.data?.userSocialLogin?.result?.user?.createdAt {
                                                       Utility.shared.signupdataArray.append(createdAt as AnyObject)
                                                   }
                                                   if let picture = result?.data?.userSocialLogin?.result?.user?.picture {
                                                       Utility.shared.signupdataArray.append(picture as AnyObject)
                                                   }
                                                   if let isEmailConfirmed = result?.data?.userSocialLogin?.result?.user?.verification?.isEmailConfirmed {
                                                       Utility.shared.signupdataArray.append(isEmailConfirmed as AnyObject)
                                                   }
                                                   if let isIdVerification = result?.data?.userSocialLogin?.result?.user?.verification?.isIdVerification {
                                                       Utility.shared.signupdataArray.append(isIdVerification as AnyObject)
                                                   }
                                                   if let isFacebookConnected = result?.data?.userSocialLogin?.result?.user?.verification?.isFacebookConnected {
                                                       Utility.shared.signupdataArray.append(isFacebookConnected as AnyObject)
                                                   }
                                                   if let isPhoneVerified = result?.data?.userSocialLogin?.result?.user?.verification?.isPhoneVerified {
                                                       Utility.shared.signupdataArray.append(isPhoneVerified as AnyObject)
                                                   }
                                                   if let isGoogleConnected = result?.data?.userSocialLogin?.result?.user?.verification?.isGoogleConnected {
                                                       Utility.shared.signupdataArray.append(isGoogleConnected as AnyObject)
                                                   }
                                                    if let userToken = result?.data?.userSocialLogin?.result?.userToken {
                                                                          Utility.shared.user_token = userToken
                                                                      }
                    Utility.shared.setTab(index: 0)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate

                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    Utility.shared.TotalFilterCount = 0
                    appDelegate.profileAPICall()
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())


                }
                else
                {
                    self.view.makeToast("\((result?.data?.userSocialLogin?.errorMessage)!)")
                    
                }
            }
        
            
        }
        @available(iOS 13.0, *)
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
           
        }
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
