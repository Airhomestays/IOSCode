//
//  LanguageVC.swift
//  App
//
//  Created on 08/05/19.


import UIKit
import Apollo
import SwiftMessages

protocol LanguageVCDelegate {
    func getcurrencycode(code:String)
    func didupdateAppearanceStatus()
}

class LanguageVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var topConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var languageTable: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var offlineView: UIView!
    
    var payout_currency_symbol = String()
    
    let  imgarray = [#imageLiteral(resourceName: "auto"),#imageLiteral(resourceName: "light-1"),#imageLiteral(resourceName: "dark")]
    
    // var LanguageDataArray = [UserLanguageQuery.Data.UserLanguage.Result]()
    //    var currencyDataArray = [GetCurrenciesListQuery.Data.GetCurrency.Result]()
    var LanguageArray = ["English","Español","Français","Italiano","Português", "العربية","ישראל"]
    var LanguagesymbolArray = [String]()
    var appearanceArray = ["Auto","Light","Dark"]
    
    var userEditProfileArray = GetProfileQuery.Data.UserAccount.Result()
    var selectedLanguageArray = NSMutableArray()
    var selectedAppearanceArray = NSMutableArray()
    var delegate:LanguageVCDelegate!
    var isFromAppearance:Bool = false
    var selectedCurrency = String()
    var selectedLanguageSymbol = String()
    var selectedLanguage = String()
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        // Add additional headers as needed
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"] // Replace `<token>`
        
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        languageTable.register(UINib(nibName: "EditAboutCell", bundle: nil), forCellReuseIdentifier: "EditAboutCell")
        languageTable.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
        self.initialSetup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    func initialSetup() {
        
        if isFromAppearance {
            topConstraints.constant = FULLHEIGHT - 320
        }
        else {
            topConstraints.constant = 200
        }
        
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        
        if(IS_IPHONE_X)
        {
            topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 80)
            languageTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH, height: FULLHEIGHT-210)
        }
        if IS_IPHONE_XR || IS_IPHONE_PLUS
        {
            topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height:80)
            languageTable.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-370)
        }else if IS_IPHONE_678 {
            languageTable.frame = CGRect(x: 0, y:85, width: FULLWIDTH, height: FULLHEIGHT-160)
        }
        else{
            languageTable.frame = CGRect(x: 0, y:85, width: FULLWIDTH, height: FULLHEIGHT-220)
        }
        doneBtn.layer.cornerRadius = 3.0
        doneBtn.layer.masksToBounds = true
        doneBtn.backgroundColor = Theme.PRIMARY_COLOR
        
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.topView.frame.size.width + shadowSize,
                                                   height: self.topView.frame.size.height + shadowSize))
        
        self.topView.layer.masksToBounds = false
        self.topView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.topView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.topView.layer.shadowOpacity = 0.3
        self.topView.layer.shadowPath = shadowPath.cgPath
        
        if(Utility.shared.isfromLanguage)
        {
            self.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"languages"))!)"
        }
        else{
            self.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"currencylist"))!)"
        }
        self.offlineView.isHidden = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        doneBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"done"))!)", for:.normal)
        LanguageArray = ["English","Español","Français","Italiano","Português","العربية","ישראל"]
        LanguagesymbolArray = ["En","es","fr","it","pt","he", "ar"]
        selectedLanguageArray.add("\(Utility.shared.getAppLanguage()!)")
        selectedAppearanceArray.add("\(Utility.shared.getAppTheme() ?? "auto")")
        errorLabel.font = UIFont(name: APP_FONT, size: 15)
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        doneBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 19)
        titleLabel.textColor =  UIColor(named: "Title_Header")
        
        languageTable.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            self.doneBtn.isHidden = false
        }
    }
    
    func langSelected()
    {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            if(!Utility.shared.isfrom_payoutcurrency){
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Utility.shared.setTab(index: 0)
                
                if(Utility.shared.isfromLanguage) {
                    Utility.shared.setAppLanguage(Language: selectedLanguage)
                    Utility.shared.setAppLanguageCode(Language:selectedLanguageSymbol)
                    Utility.shared.configureLanguage()
                }
                
                else if(Utility.shared.isfromCurrency || Utility.shared.isfrom_payoutcurrency)
                {
                    if(selectedCurrency == "")
                    {
                        Utility.shared.selectedCurrency =  Utility.shared.getPreferredCurrency()!
                        selectedCurrency = Utility.shared.getPreferredCurrency()!
                    }
                    else
                    {
                        Utility.shared.selectedCurrency = selectedCurrency
                        Utility.shared.setPreferredCurrency(currency_rate: selectedCurrency)
                    }
                    self.EditProfileAPICall(fieldName: "preferredCurrency", fieldValue:selectedCurrency)
                }else if (Utility.shared.isfrom_payoutcurrency){
                    
                }
                Utility.shared.isfromfloatmap_Page = false
                Utility.shared.isfromGuestProfile = false
                Utility.shared.locationfromSearch  = ""

                if(Utility.shared.searchLocationDict.count > 0)
                {
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
                }
                Utility.shared.instantBook = ""
                Utility.shared.roomtypeArray.removeAllObjects()
                Utility.shared.amenitiesArray.removeAllObjects()
                Utility.shared.priceRangeArray.removeAllObjects()
                Utility.shared.facilitiesArray.removeAllObjects()
                Utility.shared.houseRulesArray.removeAllObjects()
                Utility.shared.beds_count = 0
                Utility.shared.bedrooms_count = 0
                Utility.shared.bathroom_count = 0
                if(Utility.shared.isRTLLanguage()) {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                } else {
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                }
                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                if(((Utility.shared.getTabbar()) != nil) && Utility.shared.getTabbar() == true)
                {
                    Utility.shared.host_message_isfromHost = true
                    appDelegate.addingElementsToObjects()

                    Utility.shared.setHostTab(index: 0)
                    appDelegate.HostTabbarInitialize(initialView: CustomHostTabbar())
                }
                else {
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                }
                
                
            }
            else
            {
                delegate?.getcurrencycode(code:payout_currency_symbol)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            self.doneBtn.isHidden = true
            self.offlineView.isHidden = false
            
        }
        
    }
    
    
    @IBAction func donebtntapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            if(!Utility.shared.isfrom_payoutcurrency){
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Utility.shared.setTab(index: 0)
                
                
                if(Utility.shared.isfromLanguage)
                {
                    
                    Utility.shared.setAppLanguage(Language: selectedLanguage)
                    Utility.shared.setAppLanguageCode(Language:selectedLanguageSymbol)
                    Utility.shared.configureLanguage()
                }
                
                else if(Utility.shared.isfromCurrency || Utility.shared.isfrom_payoutcurrency)
                {
                    if(selectedCurrency == "")
                    {
                        Utility.shared.selectedCurrency =  Utility.shared.getPreferredCurrency()!
                        selectedCurrency = Utility.shared.getPreferredCurrency()!
                    }
                    else
                    {
                        Utility.shared.selectedCurrency = selectedCurrency
                        Utility.shared.setPreferredCurrency(currency_rate: selectedCurrency)
                    }
                    self.EditProfileAPICall(fieldName: "preferredCurrency", fieldValue:selectedCurrency)
                }else if (Utility.shared.isfrom_payoutcurrency){
                    
                }
                Utility.shared.isfromfloatmap_Page = false
                Utility.shared.isfromGuestProfile = false
                Utility.shared.locationfromSearch  = ""
                Utility.shared.TotalFilterCount = 0
                if(Utility.shared.searchLocationDict.count > 0)
                {
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
                }
                Utility.shared.instantBook = ""
                Utility.shared.roomtypeArray.removeAllObjects()
                Utility.shared.amenitiesArray.removeAllObjects()
                Utility.shared.priceRangeArray.removeAllObjects()
                Utility.shared.facilitiesArray.removeAllObjects()
                Utility.shared.houseRulesArray.removeAllObjects()
                Utility.shared.beds_count = 0
                Utility.shared.bedrooms_count = 0
                Utility.shared.bathroom_count = 0
                if(Utility.shared.isRTLLanguage()) {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                } else {
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                }
                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                if(((Utility.shared.getTabbar()) != nil) && Utility.shared.getTabbar() == true)
                {
                    Utility.shared.host_message_isfromHost = true
                    appDelegate.addingElementsToObjects()
                    Utility.shared.setHostTab(index: 0)
                    appDelegate.HostTabbarInitialize(initialView: CustomHostTabbar())
                }
                else {
                    appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                }
                
                
            }
            else
            {
                delegate?.getcurrencycode(code:payout_currency_symbol)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            self.doneBtn.isHidden = true
            self.offlineView.isHidden = false
            
        }
        
    }
    
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        selectedCurrency = ""
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(Utility.shared.isfromLanguage)
        {
            if(LanguageArray.count > 0)
            {
                return LanguageArray.count
            }
        }
        else if(Utility.shared.isfromCurrency || Utility.shared.isfrom_payoutcurrency)
        {
            if(Utility.shared.currencyDataArray.count > 0)
            {
                return Utility.shared.currencyDataArray.count
            }
        }
        else if isFromAppearance {
            return 3
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditAboutCell", for: indexPath)as! EditAboutCell
        cell.phoneLabel.isHidden = true
        cell.editLabel.isHidden = true
        cell.rightArrowimg.frame = CGRect(x:FULLWIDTH-40, y: 30, width: 25, height: 25)
        cell.selectionStyle = .none
        cell.aboutLabel.font = UIFont(name: APP_FONT, size: 16)
        cell.aboutLabel.textColor =  UIColor(named: "Title_Header")
        cell.appearanceImg.isHidden = true
        cell.height.constant = 0
        cell.width.constant = 0
        
        if(Utility.shared.isfromLanguage) {
            cell.aboutLabel.text = LanguageArray[indexPath.row]
            if(selectedLanguageArray.contains(LanguageArray[indexPath.row])) {
                cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
                cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                selectedLanguage = LanguageArray[indexPath.row]
                selectedLanguageSymbol = LanguagesymbolArray[indexPath.row]
            } else {
                cell.rightArrowimg.image = nil
                cell.aboutLabel.textColor =   UIColor(named: "Title_Header")
            }
        }
        
        else if isFromAppearance {
            if appearanceArray[indexPath.row] == "Auto" {
                cell.aboutLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"auto"))!)"
            }
            else if appearanceArray[indexPath.row] == "Light" {
                cell.aboutLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"light"))!)"
            }
            else {
                cell.aboutLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"dark"))!)"
            }
            
            appearanceArray[indexPath.row]
            cell.appearanceImg.isHidden = false
            cell.height.constant = 20
            cell.width.constant = 20
            
            cell.appearanceImg.image = imgarray[indexPath.row].withRenderingMode(.alwaysTemplate)
            
            
            if(selectedAppearanceArray.contains((appearanceArray[indexPath.row]).lowercased()))
            {
                cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
                cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                cell.appearanceImg.tintColor  = Theme.PRIMARY_COLOR
                Utility.shared.selectedAppearance =  appearanceArray[indexPath.row]
                
                
                Utility.shared.setAppTheme(Language: (appearanceArray[indexPath.row]).lowercased())
                
                
                
            }
            
            else{
                cell.rightArrowimg.image = nil
                cell.aboutLabel.textColor =   UIColor(named: "Title_Header")
                cell.appearanceImg.tintColor  = UIColor(named: "Title_Header")
            }
            
        }
        else if(Utility.shared.isfromCurrency || Utility.shared.isfrom_payoutcurrency)
        {
            
            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.currencyDataArray[indexPath.row].symbol!)
            if(currencysymbol == Utility.shared.currencyDataArray[indexPath.row].symbol!) {
                cell.aboutLabel.text = "\(Utility.shared.currencyDataArray[indexPath.row].symbol!)"
            }
            else {
                cell.aboutLabel.text = "\(currencysymbol!) \(Utility.shared.currencyDataArray[indexPath.row].symbol!)"
            }
            if(selectedLanguageArray.contains((Utility.shared.currencyDataArray[indexPath.row].symbol!)))
            {
                cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
                selectedCurrency = "\(Utility.shared.currencyDataArray[indexPath.row].symbol!)"
                
                
            }
            else if((Utility.shared.currencyDataArray[indexPath.row].symbol!) == payout_currency_symbol && Utility.shared.isfrom_payoutcurrency)
            {
                cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
            }
            else if((userEditProfileArray.preferredCurrency) != nil)
            {
                if((userEditProfileArray.preferredCurrency!) == (Utility.shared.currencyDataArray[indexPath.row].symbol!))
                {
                    cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                    cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
                }
                else{
                    cell.aboutLabel.textColor =   UIColor(named: "Title_Header")
                    cell.rightArrowimg.image = nil
                }
            }
            else if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.isfromCurrency)
            {
                if((Utility.shared.getPreferredCurrency()!) == (Utility.shared.currencyDataArray[indexPath.row].symbol!))
                {
                    cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                    cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
                }
                else{
                    cell.aboutLabel.textColor =   UIColor(named: "Title_Header")
                    cell.rightArrowimg.image = nil
                }
            }
            
            
            else{
                cell.aboutLabel.textColor =  UIColor(named: "Title_Header")
                cell.rightArrowimg.image = nil
            }
        }
        else{
            
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                if((Utility.shared.getPreferredCurrency()!) == (Utility.shared.currencyDataArray[indexPath.row].symbol!))
                {
                    cell.aboutLabel.textColor =  Theme.PRIMARY_COLOR
                    cell.rightArrowimg.image = #imageLiteral(resourceName: "redtick")
                }
                else{
                    cell.aboutLabel.textColor =   UIColor(named: "Title_Header")
                    cell.rightArrowimg.image = nil
                }
            }
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        payout_currency_symbol = ""
        
        if(Utility.shared.isfromLanguage) {
            Utility.shared.isSwitchEnable = false
            Utility.shared.TotalFilterCount = 0
            if(selectedLanguageArray.contains(LanguageArray[indexPath.row])) {
            } else {
                selectedLanguageArray.removeAllObjects()
                userEditProfileArray.preferredLanguageName = ""
                selectedLanguageArray.add(LanguageArray[indexPath.row])
            }
            selectedLanguage = LanguageArray[indexPath.row]
            selectedLanguageSymbol = LanguagesymbolArray[indexPath.row]
           
        } else if isFromAppearance {
            if(selectedAppearanceArray.contains(appearanceArray[indexPath.row])) {
            }
            else{
                selectedAppearanceArray.removeAllObjects()
                selectedAppearanceArray.add(appearanceArray[indexPath.row].lowercased())
            }
            
            let window = UIApplication.shared.keyWindow
            if indexPath.row == 0{
                if #available(iOS 13.0, *) {
                    if UITraitCollection.current.userInterfaceStyle == .dark {
                        window?.overrideUserInterfaceStyle = .dark
                    } else {
                        window?.overrideUserInterfaceStyle = .light
                    }
                } else {
                    
                }
            }
            else if indexPath.row == 1 {
                if #available(iOS 13.0, *) {
                    window?.overrideUserInterfaceStyle = .light
                } else {
                }
            }
            else {
                if #available(iOS 13.0, *) {
                    window?.overrideUserInterfaceStyle = .dark
                } else {
                }
            }
            
        }
        
        else if(Utility.shared.isfromCurrency) {
            Utility.shared.TotalFilterCount = 0
            Utility.shared.isSwitchEnable = false
            if(selectedLanguageArray.contains(Utility.shared.currencyDataArray[indexPath.row].symbol!))
            {
                selectedLanguageArray.removeAllObjects()
                userEditProfileArray.preferredCurrency = Utility.shared.currencyDataArray[indexPath.row].symbol!
                self.selectedLanguageArray.add(Utility.shared.currencyDataArray[indexPath.row].symbol!)
            }
            else{
                selectedLanguageArray.removeAllObjects()
                userEditProfileArray.preferredCurrency = Utility.shared.currencyDataArray[indexPath.row].symbol!
                self.selectedLanguageArray.add(Utility.shared.currencyDataArray[indexPath.row].symbol!)
            }
            selectedCurrency = "\(Utility.shared.currencyDataArray[indexPath.row].symbol!)"
            
        }
        else if(Utility.shared.isfrom_payoutcurrency)
        {
            
            payout_currency_symbol = (Utility.shared.currencyDataArray[indexPath.row].symbol!)
            
            
        }
        
        
        if !isFromAppearance {
            languageTable.reloadData()
            self.langSelected()
        }
        else {
            Utility.shared.selectedAppearance = appearanceArray[indexPath.row]
            Utility.shared.setAppTheme(Language: appearanceArray[indexPath.row])
            languageTable.reloadData()
            self.EditProfileAPICall(fieldName: "appTheme", fieldValue:Utility.shared.getAppTheme() ?? "auto")
            delegate?.didupdateAppearanceStatus()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func EditProfileAPICall(fieldName:String,fieldValue:String)
    {
        let editprofileMutation = EditProfileMutation(userId: (Utility.shared.getCurrentUserID()! as String), fieldName: fieldName, fieldValue: fieldValue, deviceType: "iOS", deviceId:Utility.shared.pushnotification_devicetoken)
        apollo_headerClient.perform(mutation: editprofileMutation){ (result,error) in
            
            if(result?.data?.userUpdate?.status == 200)
            {
            }
            else {
                self.view.makeToast(result?.data?.userUpdate?.errorMessage!)
            }
        }
    }
    
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
