//
//  Utility.swift
//  App


import UIKit
import SystemConfiguration
import SwiftMessages


public class Utility: NSObject {
    
    static let shared = Utility()
    var clear:Bool = false
    var timer = Timer()
    var isclearfilter:Bool = false
    var isfromdetailpage:Bool = false
    var isUnderline: Bool = false
    var isFromListing:Bool = false
    var showClearResult = false
    var isDateApplied = false
    var isPriceApplied = false
    var locationfromSearch:String!
    var  oldguestcount = Int()
    var oldbedroomcount = Int()
    var oldbedscount = Int()
    var oldbathroomcount = Int()
    var isfromExplorePage:Bool = false
    var isfromFilterPage:Bool = false
    var isfromMoreFilter:Bool = false
    var isfromLanguage:Bool = false
    var isfromCurrency:Bool = false
    var ContainsTodayDate = false
    var signupArray = NSMutableArray()
    var signupdataArray = [AnyObject]()
    var logindataArray = [AnyObject]()
    var searchLocationDict = NSDictionary()
    var selectedLanguage = String()
    var selectedAppearance = String()
    var selectedphoneNumber = String()
    var selectedCurrency = String()
    var selectedLanguage_code = String()
    var guestc = String()
    var guestBase = String()
    var visitorLimit = String()
    var infantLimit = String()
    var pettLimit = String()
    var aboutme_Name = String()
    var isaboutmechanged : Bool = false
    var isfromcheckingPage:Bool = false
    var phoneBtnTapped:Bool = false
    var blockedDates = NSMutableArray()
    var checkedInDates = NSMutableArray()
    var blocked_date_month = NSMutableArray()
    var fullcheckBlockedDateMonth = NSMutableArray()
    var minimumstay = Int()
    var numberofnights_Selected = Int()
    var maximum_Count_for_booking = Int()
    var maximum_Count_for_additionalGuests = Int()
    var maximum_Count_for_Inafant = Int()
    var maximum_Count_for_Pet = Int()
    var maximum_Count_for_Visitor = Int()
    var maximum_days_notice = Int()
    var isprofilepictureVerified :Bool = false
    var passbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var passCurrencyvaluefromAPI = String()
    var currencyvalue_from_API_base = String()
    var currency_Dict = NSDictionary()
    var getRoomTypeArray = [GetRoomTypeSettingsQuery.Data.GetRoomTypeSetting.Result?]()
    var isfromSavedShortcut: Bool = false
    var isfromMessageShortcut: Bool = false
    var isfrommessageShortcutSplashScreen: Bool = false
    var isfromcancelPAge:Bool = false
    var isfromviewedTripsPage:Bool = false
    
    var showGuestCount:Bool = false
    var showbedCount:Bool = false
    var showbathCount:Bool = false
    var isfromTripsPage:Bool = false
    var maximum_guest_count = Int()
    var min_filter_guest_count = Int()
    var min_filter_bedroom_count = Int()
    var min_filter_bed_count = Int()
    var min_filter_bath_count = Int()
    var filterCount = Int()
    
    var currentIndex = Int()
 
    var bookingListimage = String()
    var bookingListname = String()
    var bookingdateLabel = String()
    var booking_message = String()
    var isfromGuestProfile:Bool = false
    var pushnotification_devicetoken = String()
    var isfromPhonePage: Bool = false
    var deepLinkEmail = String()
    var deepLinkToken = String()
    var PreapproveValue = NSMutableArray()
    var personCapcityForMessagePage = Int()
    var ConfirmEmailString = String()
    var ConfirmEmailToken = String()
    
    // Currency Data and Language Data for Edit Profile Page
    
    var LanguageDataArray = [UserLanguageQuery.Data.UserLanguage.Result]()
     var currencyDataArray = [GetCurrenciesListQuery.Data.GetCurrency.Result]()
    var ListID = String()
    var PreApprovedID: Bool = Bool()
    // Explore Page Call back
   var recommendListingArray = [GetDefaultSettingQuery.Data.GetRecommend.Result]()
//    var mostListingArray = [GetDefaultSettingQuery.Data.GetMostViewedListing.Result]()
    
    //MARK: - Receipt Page
    var isreceiptAccepted : Bool = false
    var showbedRoomCount: Bool = false
    var isreceiptAcceptedHost: Bool = false
    
    var isFromMessageListingPage: Bool = false
    var isFromMessageListingPage_host: Bool = false
    var isFromMessageListingPage_guest: Bool = false
    var isfromPhoneVC:Bool = false
    
      var isGoogleEnable:Bool = false
    
    // Mark: Travel And Host Page
    
    var isfromHost: Bool = true
    var pickedImage_profile = UIImage()
    var imgChanged:Bool = false
     var pickedimageString = String()
    var userName = String ()
    var imgGalleryChanged:Bool = false
    
    var isOneTotal: Bool = false
    
    var EditProfileArray = GetProfileQuery.Data.UserAccount.Result()
    
    //MoreFilterPage
    
    var roomtypeArray = NSMutableArray()
    var amenitiesArray = NSMutableArray()
    var facilitiesArray = NSMutableArray()
    var houseRulesArray = NSMutableArray()
    var priceRangeArray = NSMutableArray()
    
   var myArray = NSMutableArray()
    
    var instantBook = String()
    var bedrooms_count = Int()
    var beds_count = Int()
    var bathroom_count = Int()
    var TotalFilterCount : Int = 0
    var isSwitchEnable:Bool = false
    var user_token = String()
    var filter: Bool = false
    var unpublish_preview_check:Bool = false
    
    let EuropeCountries = ["AT", "BE", "BG", "CY", "CZ", "DK", "EE",
    "FI", "FR", "DE", "GR", "HU", "IE", "IT",
    "LV", "LT", "LU", "MT", "NL", "NO", "PL",
    "PT", "RO", "SK", "SI", "ES", "SE", "CH", "MX", "NZ"]
    let rtlLang_Array = ["العربية","ישראל","","",""]
    
    var phoneNumberStatus = ""
    var guestCountToBeSend = 1
    var basePriceToBeSend = 0
    var visitorToBeSend = 0
    var infantLimitToBeSend = 0
    var petLimitToBeSend = 0
    static var calendar: Calendar {
        get {
            var c = Calendar.current
           // c.timeZone = TimeZone(abbreviation: "GMT")!
           // c.timeZone = TimeZone(identifier: "UTC")!
            return c
        }
    }
    
    //Step 1 Host
    var step1ValuesInfo = [String : Any]()
     var step2ValuesInfo = [String : Any]()
    var createId = Int()
    var step3ValuesInfo = [String : Any]()
    var step1_inactivestatus = String()
    var currencyvalue = ""
    var step3_Edit:Bool = false
    var isfromshowmap:Bool = false

    //MARK: - Host Variables
    
     //MARK: - Host Variables
    var host_specialDay_Array = NSMutableArray()
    var host_bookDay_Array = NSMutableArray()
    var hosr_blockDay_Array = NSMutableArray()
    
    var host_photo_coverid = Int()
    var host_step2_listId = Int()
    var host_step2_title = String()
    var host_step2_isfromEdit:Bool = false
    var host_message_isfromHost:Bool = false
    var host_cancel_isfromCancel:Bool = false
    var host_message_isfrommessage:Bool = false
    var host_blockedDates_Array = NSMutableArray()
    var host_specialPricing_Array = NSMutableArray()
    var host_bookedPricing_Array = NSMutableArray()
    var host_selected_dates_Array = NSMutableArray()
    var host_specialPrice_value_Array = NSMutableArray()
    var host_specialPrice_Array = [[String:Any]]()
    var host_currency_Array = NSMutableArray()
    var host_selected_Array = NSMutableArray()
    var host_isfrom_hostRecipt:Bool = false
    
    var payout_Address_Dict = [String:Any]()
    var bankDetails_Dict = [String:Any]()
    var taxDetails_Dict = [String:Any]()
    
     var calendar_Date_Array = [Date]()
    var isfrom_payoutcurrency : Bool = false
    var selected_Countrycode_Payout = String()
    
    
    var guest_filter = 0

    var isfromNotificationHost: Bool = false
    var isfromOfflineNotification: Bool = false
    
    
    var isfromBackroundBooking: Bool = false
    var isfromOfflineBooking: Bool = false
    
    
    var isfromAppDelegateMessageBackground: Bool = false
    var isfromAppdelegateMessageOffline: Bool = false
    
    var host_basePrice:Double!
    var host_cleanPrice: Double!
    var host_taxPrice: Double!
    
    var host_GuestsOnBasePrice: Int!
    var host_GuestsPrice: Double!
    var host_InfantCount: Int!
    var host_InfantPrice: Double!
    var host_PetCount: Int!
    var host_PetPrice: Double!
    var host_VisitorCount: Int!
    var host_VisitorPrice: Double!
    
    var isfrom_availability_calendar:Bool = false
    var isfrom_availability_calendar_date:Bool = false

     var selectedRules = NSMutableArray()
    var selectedRulesNames = NSMutableArray()
     var selectedAmenityIdList = NSMutableArray()
     var selectedsafetyAmenityIdList = NSMutableArray()
     var selectedspaceAmenityIdList = NSMutableArray()
     var bedtypeInfoArr = [[String : Any]]()
    
    var cancelpolicy = String()
    var cancelpolicy_content = String()
    
    var isfromfloatmap_Page:Bool = false
    var selectedstartDate_filter = String()
    var selectedEndDate_filter = String()
    var selectedstartDate = String()
    var selectedEndDate = String()
    var isfrombecomehoststep1Edit:Bool = false
    
    
    var isTodayEnable: Bool = false
    var step2_Title = String()
    var step2_Description = String()
    var bedcount = 0
    
    var getListSettingsArray = GetListingSettingQuery.Data.GetListingSetting.Result()
    var countrylist = [GetCountrycodeQuery.Data.GetCountry.Result]()

    var ProfileAPIArray = GetProfileQuery.Data.UserAccount.Result()
    var isPhonenumberCountrycode : Bool = false
    
    var listingApproval = String()
    
    
    //MARK: - Configure  App Language
    func configureLanguage()
    {
        if let path = Bundle.main.path(forResource:Utility.shared.getAppLanguage()!, ofType: "json")
        {
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                self.setDefaultLanguage(languageDict: jsonResult as! NSDictionary)
            } catch {
                // handle error
            }
        }
    }
    
    
    //MARK: - Configure  App Language
    func configureCurrency()
    {
        if let path = Bundle.main.path(forResource:"currency", ofType: "json")
        {
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                self.setCurrency(languageDict: jsonResult as! NSDictionary)
            } catch {
                // handle error
            }
        }
    }
    //MARK: - app language setup
    
    func setAppLanguage(Language: String) {
        UserDefaults.standard.set(Language, forKey: "language_name")
    }
    func getAppLanguage() -> String? {
        return UserDefaults.standard.value(forKey: "language_name") as? String
    }
    
    
    func setAppTheme(Language: String) {
        UserDefaults.standard.set(Language, forKey: "theme")
    }
    func getAppTheme() -> String? {
        return UserDefaults.standard.value(forKey: "theme") as? String
    }
    
    func setAppLanguageCode(Language: String) {
        UserDefaults.standard.set(Language, forKey: "language_code")
    }
    func getAppLanguageCode() -> String? {
        return UserDefaults.standard.value(forKey: "language_code") as? String
    }
    func isRTLLanguage() -> Bool {
        return rtlLang_Array.contains(UserDefaults.standard.value(forKey: "language_name") as! String)
    }
    func isRoutingNotNeeded(selectedCountry: String) -> Bool{
        return EuropeCountries.contains(selectedCountry)
    }
    func setappleAccountEmail(email:String)
    {
        UserDefaults.standard.set(email, forKey: "apple_email")
    }
    func getappleAccountEmail() -> String?
    {
        return UserDefaults.standard.value(forKey: "apple_email") as? String
    }
    func setappleAccountname(name:String)
    {
        UserDefaults.standard.set(name, forKey:"apple_name")
    }
    
    func getappleAccountname() -> String?
    {
        return UserDefaults.standard.value(forKey: "apple_name") as? String
    }
    func getLanguage() -> NSDictionary? {
        return UserDefaults.standard.value(forKey: "app_language") as? NSDictionary
    }
    //MARK:set App language
    func setDefaultLanguage(languageDict: NSDictionary){
        UserDefaults.standard.set(languageDict, forKey: "app_language")
    }
    
    func setCurrency(languageDict: NSDictionary){
        UserDefaults.standard.set(languageDict, forKey: "cur_code")
    }

    func getCurrency() -> NSDictionary? {
        return UserDefaults.standard.value(forKey: "cur_code") as? NSDictionary
    }
    
    //***************************************** Gradient Layer ****************************************************>
    
    func gradient(size:CGSize) -> CAGradientLayer{
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = size
        gradientLayer.colors = Theme.LOGIN_GRADIENT_PRIMARY_COLOR
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        //Use diffrent colors
        return gradientLayer
    }
     //MARK:************************************** Check string is empty ********************************************>
    
    func checkEmptyWithString(value:String) -> Bool {
        if  (value == "") || (value == "NULL") || (value == "(null)") || (value == "<null>") || (value == "Json Error") || (value == "0") || (value.isEmpty) ||  value.trimmingCharacters(in: .whitespaces).isEmpty || value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty  {
            return true
        }
        return false
    }
    
   //MARK: ****************************************Network rechability ************************************************.
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
    //MARK: store & get tab index
    func setTab(index: Int){
        UserDefaults.standard.set(index, forKey: "tab_index")
    }
    func tabIndex() -> Int {
        return UserDefaults.standard.value(forKey: "tab_index") as! Int
    }
    
    //MARK: store & get Host tab index
    func setHostTab(index: Int){
        UserDefaults.standard.set(index, forKey: "host_tab_index")
    }
    func tabHostIndex() -> Int {
        return UserDefaults.standard.value(forKey: "host_tab_index") as! Int
    }
    //MARK: Show normal alertview
    func showAlert(msg:String){
        AJAlertController.initialization().showAlertWithOkButton(aStrMessage: msg, completion: { (index, title) in
        })
    }
    func getCurrentUserToken() -> NSString?
    {
        
        return UserDefaults.standard.value(forKey: "user_token") as? NSString
    }
    func getCurrentUserID() -> NSString?
    {
        
        return UserDefaults.standard.value(forKey: "user_id") as? NSString
    }
    
    func getPreferredCurrency() -> String?
    {
        return (UserDefaults.standard.value(forKey: "currency_rate") as? String)
    }
    
    func setPreferredCurrency(currency_rate:String)
    {
        UserDefaults.standard.set(currency_rate, forKey: "currency_rate")
        
    }
    func setopenTabbar(iswhichtabbar:Bool)
    {
       UserDefaults.standard.set(iswhichtabbar, forKey:"which_tabbar")
    }
    func getTabbar() -> Bool?
    {
      return UserDefaults.standard.value(forKey: "which_tabbar") as? Bool
    }
    func setUserToken(userID: NSString){
        UserDefaults.standard.set(userID, forKey: "user_token")
    }
    func setUserID(userid: NSString){
        UserDefaults.standard.set(userid, forKey: "user_id")
    }
    
    func setPassword(password: NSString)
    {
        UserDefaults.standard.set(password, forKey: "password")
    }
    func getPassword() -> NSString {
        
        return UserDefaults.standard.value(forKey: "password") as! NSString
    }
    func setEmail(email: NSString)
    {
        UserDefaults.standard.set(email, forKey: "email")
    }
    func getEmail() -> NSString {
        
        return UserDefaults.standard.value(forKey: "email") as! NSString
    }
    func getCurrencyRate(basecurrency:String,fromCurrency:String,toCurrency:String,CurrencyRate:NSDictionary,amount:Double) -> Double
    {
        if(fromCurrency == basecurrency)
        {
            return (CurrencyRate.object(forKey: toCurrency) as! Double) * (amount)
        }
        else if(toCurrency == basecurrency)
        {
            return  (1 / (CurrencyRate.object(forKey: fromCurrency)as! Double) * (amount))
        }
        else{
            return amount * ((CurrencyRate.object(forKey: toCurrency)as! Double) * ((1 / (CurrencyRate.object(forKey: fromCurrency)as! Double))))
        }
        
    }
    
    func getSymbol(forCurrencyCode code: String) -> String? {
//        if(code == "USD")
//        {
//            return "$"
//        }
//        if(code == "JPY")
//        {
//            return "¥"
//        }
//        if code == "CAD" {
//            return "CA$"
//        }
//        if code == "BGN" || code == "HUF" || code == "IDR" || code == "NOK" || code == "PLN" || code == "RUB" || code == "SEK" || code == "TRY" || code == "AUD"
//        {
//            return code
//        }
//        else{
//        let locale = NSLocale(localeIdentifier: code)
//        if locale.displayName(forKey: .currencySymbol, value: code) == code {
//            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
//            return newlocale.displayName(forKey: .currencySymbol, value: code)
//        }
//        return locale.displayName(forKey: .currencySymbol, value: code)
//        }
//
        
       return "\(Utility.shared.getCurrency()?.value(forKey: code) ?? "$")"
    }

    
    //Restrict date in calender
    func maximum_notice_period(maximumnoticeperiod:String) ->Int?
    {
        if(maximumnoticeperiod == "3months")
        {
            return 3
        }
        else if(maximumnoticeperiod == "6months")
        {
            return 6
        }
        else if(maximumnoticeperiod == "9months")
        {
            return 9
        }
        else if(maximumnoticeperiod == "12months")
        {
            return 9
        }
        else if(maximumnoticeperiod == "available")
        {
            return 0
        }
        return 0
        
    }
    
    func getcolorcode(type:String) -> UIColor?
    
    {
        if(type == "Pending")
        {
            return Theme.inboxRequestBookStatusColor
        }
        else if(type == "Declined")
        {
            return Theme.inboxDeclinedStatusColor
        }
        else if(type == "Cancelled")
        {
            return Theme.inboxCancelledStatusColor
        }
        else if(type == "Completed")
        {
            return Theme.inboxCompletedStatusColor
        }
        else if(type == "Approved")
        {
            return Theme.inboxPreApprovedStatusColor
        }
        else if(type == "Inquiry")
        {
            return Theme.inboxInquiryStatusColor
        }
        else if(type == "CancelledByGuest")
        {
            return Theme.inboxCancelledStatusColor
        }
        else if(type == "CancelledByGuest")
        {
         return Theme.inboxCancelledStatusColor
        }
        else if(type == "RequestToBook")
        {
            return Theme.inboxRequestBookStatusColor
        }
        else if(type == "PreApproved")
        {
            return Theme.inboxPreApprovedStatusColor
        }
        else if(type == "Expired")
        {
            return Theme.inboxExpiredStatusColor
        }
        return Theme.inboxMessageStatusColor
        
    }
    func getbookingtype(type:String) -> String?
    {
        
        if(type == "inquiry"){return "\((Utility.shared.getLanguage()?.value(forKey:"inquiry"))!)"}
        else if(type == "pending"){return "\((Utility.shared.getLanguage()?.value(forKey:"pending"))!)"}
        else if(type == "cancelled"){return "\((Utility.shared.getLanguage()?.value(forKey:"cancelled"))!)"}
        else if(type == "preApproved"){return "\((Utility.shared.getLanguage()?.value(forKey:"preapproved"))!)"}
        else if(type == "declined"){return "\((Utility.shared.getLanguage()?.value(forKey:"declined"))!)"}
        else if(type == "approved"){return "\((Utility.shared.getLanguage()?.value(forKey:"approved"))!)"}
        else if(type == "cancelledByHost"){return "\((Utility.shared.getLanguage()?.value(forKey:"cancelbyhost"))!)"}
        else if(type == "cancelledByGuest"){return "\((Utility.shared.getLanguage()?.value(forKey:"cancelbyguest"))!)"}
        else if(type == "instantBooking"){return "\((Utility.shared.getLanguage()?.value(forKey:"approved"))!)"}
        else if(type == "intantBooking"){return "\((Utility.shared.getLanguage()?.value(forKey:"approved"))!)"}
        else if(type == "confirmed"){return "\((Utility.shared.getLanguage()?.value(forKey:"bookingconfirmed"))!)"}
        else if(type == "expired"){return "\((Utility.shared.getLanguage()?.value(forKey:"expired"))!)"}
        else if(type == "requestToBook"){return "\((Utility.shared.getLanguage()?.value(forKey:"requestbook"))!)"}
        else if(type == "completed"){return "\((Utility.shared.getLanguage()?.value(forKey:"completed"))!)"}
        else if(type == "reflection"){return "\((Utility.shared.getLanguage()?.value(forKey:"reflection"))!)"}
        else if(type == "message"){return "\((Utility.shared.getLanguage()?.value(forKey:"message"))!)"}
        return ""
    }
    
    func getbookingtypeColor(type:String) -> UIColor?
    {
        if(type == "inquiry"){return Theme.inboxInquiryStatusColor}
        else if(type == "pending"){return Theme.inboxPendingStatusColor}
        else if(type == "cancelled"){return Theme.inboxCancelledStatusColor}
        else if(type == "preApproved" || type == "Approved"){return Theme.inboxPreApprovedStatusColor}
        else if(type == "declined"){return Theme.inboxDeclinedStatusColor}
        else if(type == "approved"){return Theme.inboxPreApprovedStatusColor}
        else if(type == "cancelledByHost"){return Theme.inboxCancelledStatusColor}
        else if(type == "cancelledByGuest"){return Theme.inboxCancelledStatusColor}
        else if(type == "instantBooking"){return Theme.inboxPreApprovedStatusColor}
        else if(type == "intantBooking"){return Theme.inboxPreApprovedStatusColor}
        else if(type == "confirmed"){return Theme.inboxConfirmedStatusColor}
        else if(type == "expired"){return Theme.inboxExpiredStatusColor}
        else if(type == "requestToBook"){return Theme.inboxRequestBookStatusColor}
        else if(type == "completed"){return Theme.inboxCompletedStatusColor}
        else if(type == "reflection"){return Theme.inboxReflectionStatusColor}
        else if(type == "message"){return Theme.inboxMessageStatusColor}
        return Theme.inboxMessageStatusColor
    }
    
    func getdateformatter(date:String) -> String {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat =  "yyyy-MM-dd"

    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "MMM dd yyyy"

    if let datefor = dateFormatterGet.date(from: date) {
        return (dateFormatterPrint.string(from: datefor))
        
    } else {
       print("There was an error decoding the string")
        }
        return ""
    }
    func getdateformatter1(date:String) -> String {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat =  "yyyy-MM-dd"

    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "EEE"

    if let datefor = dateFormatterGet.date(from: date) {
        return (dateFormatterPrint.string(from: datefor))
        
    } else {
       print("There was an error decoding the string")
        }
        return ""
    }
    
    func convertTimeStampToString(timestamp:String,toFormat: String) -> String
    {
        if (timestamp == ""){
            return ""
        }else{
            let timestamValue = Int(timestamp)!/1000
            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = toFormat //Specify your format that you want
            
            return dateFormatter.string(from: newTime)
        }
    }
    
    //func to perform spring animation on imageview
    func performSpringAnimation(imgView: UIImageView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            imgView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in
        }
    }
    
   
    //Func to get Attributedtsrings
    func getAtrributedstring(fullString:String,ChangedString:String) -> NSMutableAttributedString
    {
        let main_string = fullString
        let string_to_color = ChangedString
        
        let range = (main_string as NSString).range(of: string_to_color)
        let attributedString = NSMutableAttributedString(string:main_string)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray , range: range)
        return attributedString
    }
    

}

@IBDesignable
extension UIView {
    // Shadow
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    fileprivate func addShadow(shadowColor: CGColor = Theme.TextLightColor.cgColor, shadowOffset: CGSize = CGSize(width: 3.0, height: 3.0), shadowOpacity: Float = 0.35, shadowRadius: CGFloat = 5.0) {
        let layer = self.layer
        layer.masksToBounds = false
        
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        
        let backgroundColor = self.backgroundColor?.cgColor
        self.backgroundColor = nil
        layer.backgroundColor =  backgroundColor
    }
    
    
    // Corner radius
    @IBInspectable var circle: Bool {
        get {
            return layer.cornerRadius == self.bounds.width*0.5
        }
        set {
            if newValue == true {
                self.cornerRadius = self.bounds.width*0.5
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    
    // Borders
    // Border width
    @IBInspectable
    public var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        
        get {
            return layer.borderWidth
        }
    }
    
    // Border color
    @IBInspectable
    public var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        
        get {
            if let borderColor = layer.borderColor {
                return UIColor(cgColor: borderColor)
            }
            return nil
        }
    }
    
    func halfroundedCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        print(bounds)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setMiddleButtonGB(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        layer.cornerRadius = 30
        clipsToBounds = true
        
       layer.insertSublayer(gradientLayer, at: 0)
    }
}


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
