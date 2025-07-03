

import UIKit
import SwiftMessages
import Apollo

class SettingsPageVC: UIViewController,LanguageVCDelegate {
    func getcurrencycode(code: String) {
        
    }
    
    func didupdateAppearanceStatus() {
        if Utility.shared.EditProfileArray.userData?.type == "email" {
            let indexPaths = IndexPath(item: 3, section: 0)
            self.tableView.reloadRows(at:[indexPaths] , with: .none)
       }else{
           let indexPaths = IndexPath(item: 2, section: 0)
           self.tableView.reloadRows(at:[indexPaths] , with: .none)
       }
       
       
    }
    
    
   
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var apollo_headerClient:ApolloClient!
    
    var EditProfileArray = GetProfileQuery.Data.UserAccount.Result()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =   UIColor(named: "colorController")
        EdiprofileAPICall()
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
     
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.pageTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "settings") ?? "Settings")"
        self.pageTitleLabel.textColor =  UIColor(named: "Title_Header")
        self.pageTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.pageTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
        
        self.tableView.register(UINib(nibName: "SwitchtohostCell", bundle: nil), forCellReuseIdentifier: "SwitchtohostCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }

    @IBAction func onClickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
    }
    
    func EdiprofileAPICall() {
        var apollo_headerClient: ApolloClient = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
            let url = URL(string:graphQLEndpoint)!
            
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
        let profileQuery = GetProfileQuery()
        apollo_headerClient.fetch(query:profileQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
          
            guard (result?.data?.userAccount?.result) != nil else
            {
                if result?.data?.userAccount?.status == 500{
                    let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.userAccount?.errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "\(Utility.shared.getLanguage()?.value(forKey: "okay") ?? "Okay")", style: .default, handler: { (action) in
                        UserDefaults.standard.removeObject(forKey: "user_token")
                        UserDefaults.standard.removeObject(forKey: "user_id")
                        UserDefaults.standard.removeObject(forKey: "password")
                        UserDefaults.standard.removeObject(forKey: "currency_rate")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let welcomeObj = WelcomePageVC()
                        appDelegate.setInitialViewController(initialView: welcomeObj)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }else{
                    self.view.makeToast(result?.data?.userAccount?.errorMessage!)
                return
                }
            }
            Utility.shared.EditProfileArray  = ((result?.data?.userAccount?.result)!)
            self.EditProfileArray = ((result?.data?.userAccount?.result)!)
        }
    }
}


extension SettingsPageVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if #available(iOS 13.0, *){
            if (Utility.shared.EditProfileArray.userData?.type == "email"){
                return 4
            }else{
                return 3
            }
        }
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchtohostCell", for: indexPath) as! SwitchtohostCell
        cell.selectionStyle = .none
       
       
        if (Utility.shared.EditProfileArray.userData?.type == "email"){
            if indexPath.row == 0 {
                
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "changepassword") ?? "Change password")"
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "changePWicon")
                cell.profileRightValueLabel.isHidden = true
                cell.profilesettingImage.isHidden = false
                cell.profilesettingImage.image = UIImage(named: "rightarrow")
                
            } else if indexPath.row == 1{
                
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "languages") ?? "Languages")"
                cell.profileRightValueLabel.isHidden = false
                cell.profilesettingImage.isHidden = true
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "LanguageIcon")
                cell.profileRightValueLabel.isHidden = false
                cell.profileRightValueLabel.text = Utility.shared.getAppLanguage()
                
            }else if indexPath.row == 2{
                
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "currency") ?? "Currency")"
                cell.profileRightValueLabel.isHidden = false
                cell.profilesettingImage.isHidden = true
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "CurrencyIcon")
                cell.profileRightValueLabel.isHidden = false
                if(Utility.shared.selectedCurrency != "")
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                    
                    if(currencysymbol == Utility.shared.selectedCurrency) {
                        cell.profileRightValueLabel.text =   "\(Utility.shared.selectedCurrency )"
                    }
                    else {
                        cell.profileRightValueLabel.text =  "\(currencysymbol ?? "$") " + "\(Utility.shared.selectedCurrency )"
                    }
                    
                }else{
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    Utility.shared.selectedCurrency = Utility.shared.ProfileAPIArray.preferredCurrency ?? "USD"
                    if(currencysymbol == Utility.shared.selectedCurrency) {
                        cell.profileRightValueLabel.text =   "\(Utility.shared.selectedCurrency )"
                    }
                    else {
                        cell.profileRightValueLabel.text =  "\(currencysymbol ?? "$") " + "\(Utility.shared.getPreferredCurrency() ?? "USD")"
                    }
                    
                }
            } else if indexPath.row == 3{
                
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "theme") ?? "Theme")"
                cell.profileRightValueLabel.isHidden = false
                cell.profilesettingImage.isHidden = true
                cell.profileRightValueLabel.text =  Utility.shared.selectedAppearance != "" ? (Utility.shared.selectedAppearance).firstCapitalized : "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
                if Utility.shared.selectedAppearance == "auto" || Utility.shared.selectedAppearance == "Auto"{
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
                }
                else if  Utility.shared.selectedAppearance == "light" || Utility.shared.selectedAppearance == "Light"{
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"light"))!)"
                }
                else if  Utility.shared.selectedAppearance == "dark" || Utility.shared.selectedAppearance == "Dark"{
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"dark"))!)"
                }
                else {
         
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
                }
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "appearance")
                
            }
            
        } else {
            
              if indexPath.row == 0{
                  
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "languages") ?? "Languages")"
                cell.profileRightValueLabel.isHidden = false
                cell.profilesettingImage.isHidden = true
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "LanguageIcon")
                cell.profileRightValueLabel.isHidden = false
                cell.profileRightValueLabel.text = Utility.shared.getAppLanguage()
                  
            }else if indexPath.row == 1{
                
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "currency") ?? "Currency")"
                cell.profileRightValueLabel.isHidden = false
                cell.profilesettingImage.isHidden = true
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "CurrencyIcon")
                cell.profileRightValueLabel.isHidden = false
                if(Utility.shared.selectedCurrency != "")
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                    
                    if(currencysymbol == Utility.shared.selectedCurrency) {
                        cell.profileRightValueLabel.text =   "\(Utility.shared.selectedCurrency )"
                    }
                    else {
                        cell.profileRightValueLabel.text =  "\(currencysymbol ?? "$") " + "\(Utility.shared.selectedCurrency )"
                    }
                    
                }else{
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    Utility.shared.selectedCurrency = Utility.shared.ProfileAPIArray.preferredCurrency ?? "USD"
                    if(currencysymbol == Utility.shared.selectedCurrency) {
                        cell.profileRightValueLabel.text =   "\(Utility.shared.selectedCurrency )"
                    }
                    else {
                        cell.profileRightValueLabel.text =  "\(currencysymbol ?? "$") " + "\(Utility.shared.getPreferredCurrency() ?? "USD")"
                    }
                    
                }
            } else if indexPath.row == 2 {
                
                cell.profileSettingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "theme") ?? "Theme")"
                cell.profileRightValueLabel.isHidden = false
                cell.profilesettingImage.isHidden = true
                cell.profileRightValueLabel.text =  Utility.shared.selectedAppearance != "" ? (Utility.shared.selectedAppearance).firstCapitalized : "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
                if Utility.shared.selectedAppearance == "auto" || Utility.shared.selectedAppearance == "Auto"{
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
                }
                else if  Utility.shared.selectedAppearance == "light" || Utility.shared.selectedAppearance == "Light"{
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"light"))!)"
                }
                else if  Utility.shared.selectedAppearance == "dark" || Utility.shared.selectedAppearance == "Dark"{
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"dark"))!)"
                }
                else {
         
                    cell.profileRightValueLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
                }
                cell.profileSettingLabel.textColor  =  UIColor(named: "Title_Header")
                cell.iconImage.image =  UIImage(named: "appearance")
                
            }
        }
            
            
            return cell
        }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (Utility.shared.EditProfileArray.userData?.type == "email"){
            
            if(indexPath.row == 0) {
                
                let languageObj = ChangePasswordVC()
                Utility.shared.isfromLanguage = true
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = false
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
                
            }else if(indexPath.row == 1) {
                
                let languageObj = LanguageVC()
                languageObj.userEditProfileArray = EditProfileArray
                Utility.shared.isfromLanguage = true
                languageObj.delegate = self
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = false
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
                
            } else  if(indexPath.row == 2) {
                
                let languageObj = LanguageVC()
                languageObj.userEditProfileArray = EditProfileArray
                languageObj.delegate = self
                Utility.shared.isfromLanguage = false
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = true
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
            } else if(indexPath.row == 3){
                let languageObj = LanguageVC()
                languageObj.delegate = self
                languageObj.userEditProfileArray = EditProfileArray
                Utility.shared.isfromLanguage = false
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = false
                languageObj.isFromAppearance = true
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
            }
            
        }else{
            
            if(indexPath.row == 0) {
                
                let languageObj = LanguageVC()
                languageObj.userEditProfileArray = EditProfileArray
                Utility.shared.isfromLanguage = true
                languageObj.delegate = self
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = false
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
                
            } else  if(indexPath.row == 1) {
                
                let languageObj = LanguageVC()
                languageObj.userEditProfileArray = EditProfileArray
                languageObj.delegate = self
                Utility.shared.isfromLanguage = false
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = true
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
            } else {
                let languageObj = LanguageVC()
                languageObj.delegate = self
                languageObj.userEditProfileArray = EditProfileArray
                Utility.shared.isfromLanguage = false
                Utility.shared.isfrom_payoutcurrency = false
                Utility.shared.isfromCurrency = false
                languageObj.isFromAppearance = true
                languageObj.modalPresentationStyle = .overFullScreen
                self.present(languageObj, animated: true, completion: nil)
            }
        }
    }
}
    
    


