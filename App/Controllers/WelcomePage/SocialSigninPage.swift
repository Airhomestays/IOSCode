

import UIKit
import GoogleSignIn
import Lottie
import AuthenticationServices
class SocialSigninPage: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var Close_Button: UIButton!
    @IBOutlet var appleView: UIView!
    @IBOutlet var facebookView: UIView!
    @IBOutlet var googleView: UIView!
    @IBOutlet var appleView_Label: UILabel!
    @IBOutlet var appleView_imageView: UIImageView!
    @IBOutlet var facebookView_Label: UILabel!
    @IBOutlet var facebookView_imageView: UIImageView!
    @IBOutlet var googleView_label: UILabel!
    @IBOutlet var googleView_imageView: UIImageView!
    
    @IBOutlet var ImageView: UIImageView!
    
    @IBOutlet var socialloginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"welcome_rent"))!)"
        appleView_imageView.image = #imageLiteral(resourceName: "apple-black-shape-logo-with-a-bite-hole")
        appleView_Label.text = "\((Utility.shared.getLanguage()?.value(forKey: "appleSignin"))!)"
        appleView_Label.textColor = .white
        appleView.layer.cornerRadius = 28.0
        appleView.clipsToBounds = true
        socialloginView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: FULLHEIGHT)
        
        welcomeLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        welcomeLabel.font = UIFont(name: APP_FONT_BOLD, size: 30)
        appleView_Label.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        facebookView_Label.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        googleView_label.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        self.socialloginView.applyGradient(colours:Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
        self.view.applyGradient(colours: Theme.LOGIN_GRADIENT_PRIMARY_COLOR)
       
        facebookView_Label.text = "\((Utility.shared.getLanguage()?.value(forKey: "facebook_login"))!)"
        facebookView.layer.cornerRadius = 28.0
        facebookView_Label.textColor = .white
        facebookView.clipsToBounds = true
         let facebookGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(faceBookLogin))
        facebookView.addGestureRecognizer(facebookGesture)
        googleView.backgroundColor = Theme.SECONDARY_COLOR
        facebookView_imageView.image = #imageLiteral(resourceName: "fb_logo").withRenderingMode(.alwaysTemplate)
        facebookView_imageView.tintColor = .white
        googleView_imageView.image = #imageLiteral(resourceName: "g_logo").withRenderingMode(.alwaysTemplate)
        googleView_imageView.tintColor = .white
        googleView_label.text = "\((Utility.shared.getLanguage()?.value(forKey: "google_login"))!)"
        googleView_label.textColor = .white
        googleView.layer.cornerRadius = 28.0
        googleView.clipsToBounds = true
        
        let GoogleGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(googleLogin))
        googleView.addGestureRecognizer(GoogleGesture)
        
        let AppleGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(applelogin))
        appleView.addGestureRecognizer(AppleGesture)
        if Utility.shared.isRTLLanguage() {
            Close_Button.imageView?.performRTLTransform()
            appleView_Label.textAlignment = .right
            facebookView_Label.textAlignment = .right
            googleView_label.textAlignment = .right
        }
    }
    @objc func applelogin(){
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

    @objc func faceBookLogin(){
        
       
    }

    func facebookSignup(){
           
            
        }

    @objc func googleLogin(){
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if(error == nil)
               {
                  
                   let name = user.profile?.name
                   let email = user.profile?.email
                   let userImageURL = user.profile?.imageURL(withDimension: 200)!

                   
               
                   let params = [
                       "name": "\(name ?? "")",
                       "email": "\(email ?? "")",
                       "image": "\(userImageURL)"
                   ]
                   
                   let signupMutation = SocialLoginQuery(firstName: "\(name ?? "")", lastName: "", email: "\(email ?? "")", dateOfBirth: "", deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "google", gender: "", profilePicture:"\(userImageURL!)")
                   
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

                           self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)


                           appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())


                       }
                       else
                       {
                        Utility.shared.showAlert(msg:((result?.data?.userSocialLogin?.errorMessage) != nil ? ((result?.data?.userSocialLogin?.errorMessage)!) : ""))
                       }
                       
                   }
                   
                   
               }
               else
               {
                  
               }
    }
    
    @IBAction func close_tapped(_ sender: Any) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
}
extension SocialSigninPage: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        
        }
        
        if(appleIDCredential.email != nil)
        {
            KeychainService.saveEmail(email: "\(appleIDCredential.email!)" as NSString)
            KeychainService.saveUsername(name: "\((appleIDCredential.fullName?.givenName!)!)\((appleIDCredential.fullName?.familyName)!)" as NSString)
        Utility.shared.setappleAccountname(name: "\((appleIDCredential.fullName?.givenName!)!)\((appleIDCredential.fullName?.familyName)!)")
        Utility.shared.setappleAccountEmail(email: "\(appleIDCredential.email!)")
        }
       
       
        let email = KeychainService.loadEmail() != nil ? KeychainService.loadEmail()! : ""
          
        let name = KeychainService.loadUsername() != nil ? KeychainService.loadUsername()! : ""
       
        
        let signupMutation = SocialLoginQuery(firstName:name as String, lastName: "", email:email as String, dateOfBirth: "", deviceType: "iOS", deviceDetail: "", deviceId:Utility.shared.pushnotification_devicetoken, registerType: "apple", gender: "", profilePicture:"")
        
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

                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)


                appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())


            }
            else
            {
                
                 Utility.shared.showAlert(msg:((result?.data?.userSocialLogin?.errorMessage)!))
            }
        }
        
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       
    }
}
extension SocialSigninPage: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

