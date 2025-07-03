
import UIKit
import IQKeyboardManagerSwift
import GoogleSignIn
import GoogleMaps
import GooglePlacePicker
import Apollo
import Stripe
import Firebase
import FirebaseCrashlytics
import UserNotifications
import FirebaseMessaging
import PayPalCheckout

var tabNameArray = NSMutableArray()
var tabImageArray = NSMutableArray()
var tabImage_RedArray = NSMutableArray()
 var locationfromSearch:String!
var LauchShortcutItem: UIApplicationShortcutItem?

//com.airhomestays.app
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {

    var window: UIWindow?
    var navController : UINavigationController?
    var apollo_headerClient:ApolloClient!

  var statusBarStyle: UIStatusBarStyle = .lightContent
    var isreplyenabled:Bool = false
    let tabBarController = UITabBarController()
    let middleView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    let middleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
    let semiCircleLayer = CAShapeLayer()

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        Utility.shared.showGuestCount = false
        Utility.shared.showbedRoomCount = false


        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
        
        self.getStripePublishableKey()
        self.LanguageinitialSetup()
        self.themeInitialSetUp()
        self.GetSecureSettingAPICall()
        self.GetDefaultSettingAPICall()
        self.getcurrencyAPICall()
        self.profileAPICall()
        
        
        var shortCutItemIsCalled = false
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem{
            LauchShortcutItem = shortcutItem
        
            shortCutItemIsCalled = true
        }
        

        if let option = launchOptions {
            let info = option[UIApplication.LaunchOptionsKey.remoteNotification]
            if (info != nil) {
            }}

        var isuniversalLinkClick: Bool = false
        let activityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [UIApplication.LaunchOptionsKey: Any]
        let userActivity = activityDictionary?.values.first(where: { $0 is NSUserActivity }) as? NSUserActivity
    
        if activityDictionary != nil {
            isuniversalLinkClick = true
        }
        
    
        
        var isRemoteNotification: Bool = false
        var contentDict =  [String: Any]()
        var NotificationString = String()
        var userType = String()
        var listID = String()
        
        if let notifiedoptions = launchOptions{
            if   let info = notifiedoptions[UIApplication.LaunchOptionsKey.remoteNotification] as! [String: Any]? {
                           if info != nil{
                            
                            let variableName = info["content"] as! String
                            
                            if let data = variableName.data(using: String.Encoding.utf8) {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                                    contentDict = json!
                                  
                                } catch {
                                 
                                }
                            }
                            
                            if contentDict.count > 0 {
                               NotificationString =  contentDict["title"] as! String
                              
                                userType = contentDict["userType"] as! String
                               isRemoteNotification = true
                            }

                           }
            }
            
            

            
        }
        

        if isuniversalLinkClick{
            
            if userActivity?.activityType == NSUserActivityTypeBrowsingWeb{
                let url = userActivity?.webpageURL!
                var view = url?.pathComponents
                var str = url?.absoluteString
              
                if view?.contains("review") ?? false{
                     if ((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                        let loginpage =  ()
                    
                     }else{
                        let writeReview = WriteReview()
                                                           
                        if view?.count ?? 0 >= 4{
                            writeReview.reservationID = Int(view?[3] ?? "") ?? 0
                        }else{
                            writeReview.reservationID = 0
                        }
                        writeReview.isFromEmailNavigation = true
                        self.setInitialViewController(initialView: writeReview)
                    }
                   
                }else{
                let urlString = queryParameters(from: url!)
              
                if ((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                    if view!.count > 0{
                        if view!.contains("password"){
                            Utility.shared.deepLinkEmail = urlString["email"]!
                            Utility.shared.deepLinkToken = urlString["token"]!
                            let resetPasswordPage = ResetPasswordVC()
                            self.setInitialViewController(initialView: resetPasswordPage)
                        }else{
                            let loginpage = WelcomePageVC()
                            self.setInitialViewController(initialView: loginpage)
                        }
                        
                    }else{
                        
                        let loginpage = WelcomePageVC()
                        self.setInitialViewController(initialView: loginpage)
                    }
                    
                }else{
                    if view!.count > 0{
                        if view!.contains("user"){
                            Utility.shared.ConfirmEmailString = urlString["email"]!
                            Utility.shared.ConfirmEmailToken = urlString["confirm"]!
                            let VerifyEmail = VerificationSuccessVC()
                            setInitialViewController(initialView: VerifyEmail)
                        }else if view!.contains("review/write"){
                            let writeReview = WriteReview()
                            
                            let reservID = str?.components(separatedBy: "/")
                            
                            writeReview.reservationID = Int("\(reservID?.last ?? "0")") ?? 0
                            writeReview.isFromEmailNavigation = true
                            self.setInitialViewController(initialView: writeReview)
                        }else{
                            
                            let loginpage = WelcomePageVC()
                            self.setInitialViewController(initialView: loginpage)
                        }
                        
                    }else{
                        let loginpage = WelcomePageVC()
                        self.setInitialViewController(initialView: loginpage)
                    }
                }
                }
            }
            

 
        }else if isRemoteNotification {
            

            if Utility.shared.isConnectedToNetwork() && (Utility.shared.getCurrentUserToken()) != nil {
                
                if NotificationString == "New Inquiry" || NotificationString == "New Enquiry" || NotificationString == "New Message"{
                    
                    if userType == "guest"{
                        
                        
                        let inboxpageVc = InboxListingVC()
                        Utility.shared.ListID = (contentDict["listId"] as! NSString) as String
                        Utility.shared.isfromAppdelegateMessageOffline = true
                        inboxpageVc.threadId = Int((contentDict["threadId"] as! NSString).intValue)
                        inboxpageVc.getmessageListquery.removeAll()
                        inboxpageVc.getMessageListAPICall(threadId: Int((contentDict["threadId"] as! NSString).intValue))
                        self.setInitialViewController(initialView: inboxpageVc)
                        
                    }else{
                        
                        let inboxpageVc = InboxListingVC()
                        Utility.shared.ListID = (contentDict["listId"] as! NSString) as String
                        Utility.shared.isfromOfflineNotification = true
                        inboxpageVc.threadId = Int((contentDict["threadId"] as! NSString).intValue)
                        inboxpageVc.getmessageListquery.removeAll()
                        inboxpageVc.getMessageListAPICall(threadId: Int((contentDict["threadId"] as! NSString).intValue))
                        self.setInitialViewController(initialView: inboxpageVc)
                    }
                    
                }

                else if NotificationString == "The Admin has verified your listing" || NotificationString == "Admin has declined your listing"  {
                    Utility.shared.isfromNotificationHost = true
                    Utility.shared.isfromOfflineNotification = true
                 
                   
                    
                    let becomeHost = BecomeHostVC()
                    becomeHost.listID = "\(contentDict["listId"]!)"
                    becomeHost.showListingStepsAPICall(listID:"\(contentDict["listId"]!)")
                 
                    becomeHost.modalPresentationStyle = .fullScreen
                    self.window?.rootViewController = becomeHost
                    
               
                   
                }
            }else{
                Utility.shared.setTab(index: 0)
                self.GuestTabbarInitialize(initialView: CustomTabbar())
                
            }
  
        }else if shortCutItemIsCalled == true {
            

        }else{
            if((Utility.shared.getCurrentUserToken()) != nil)
            {

                apollo_headerClient = {
                    let configuration = URLSessionConfiguration.default
                   
                    configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                    let url = URL(string:graphQLEndpoint)!

                    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
                }()
                self.UserBanStatus()

            }

            else{
                Utility.shared.setTab(index: 0)
                self.GuestTabbarInitialize(initialView: CustomTabbar())
            }

        }

        
       
        
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        window?.backgroundColor =   UIColor(named: "colorController")
        FirebaseApp.configure()
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true

        
        if #available(iOS 10, *) {

            
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                
                guard error == nil else {
                  
                    return
                }
                
                if granted {
                   
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                        UNUserNotificationCenter.current().delegate = self
                    }
                }
                else {
                  
                }
            }
            
         
            application.registerForRemoteNotifications()
        }
        else {
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            UNUserNotificationCenter.current().delegate = self
            application.registerForRemoteNotifications()
            
        }
        
        
        
        return true
    }
    
    func getStripePublishableKey(){
        
        let mostlistingquery = GetSecureSiteSettingsQuery(settingsType:"config_settings", securityKey: SECURE_KEY)
        apollo.fetch(query: mostlistingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
        
            guard (result?.data?.getSecureSiteSettings?.results) != nil else {
                STPPaymentConfiguration.shared.publishableKey = STRIPE_PUBLISHABLE_KEY
               
                return
            }
            
            if let value = result?.data?.getSecureSiteSettings?.results{
                for i in value{
                    if (i?.name == "stripePublishableKey"){
                        STPPaymentConfiguration.shared.publishableKey = i?.value ?? ""
                        STPPaymentConfiguration.shared.requiredBillingAddressFields = .none
                    }
                }
            }
        }
    }

    func themeInitialSetUp(){
        let window = UIApplication.shared.keyWindow
        if Utility.shared.getAppTheme() == nil || Utility.shared.getAppTheme() == "auto"{
            Utility.shared.setAppTheme(Language: "auto")
            Utility.shared.selectedAppearance = "auto"
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    window?.overrideUserInterfaceStyle = .dark
                    
                } else {
                    window?.overrideUserInterfaceStyle = .light
                }
            } else {
               
            }
        }
       else if Utility.shared.getAppTheme() == "dark"{
           Utility.shared.setAppTheme(Language: "dark")
           Utility.shared.selectedAppearance = "dark"
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .dark
            } else {
               
            }
        }
        else if Utility.shared.getAppTheme() == "light"{
            Utility.shared.setAppTheme(Language: "light")
            Utility.shared.selectedAppearance = "light"
            if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .light
               
            } else {
             
            }
        }
        
        
        
        
       
        window?.backgroundColor =  UIColor(named: "colorController")
     
          
        self.window?.rootViewController?.view.backgroundColor =  UIColor(named: "colorController")
    }
    
  
    func LanguageinitialSetup(){
      
      
        if Utility.shared.getAppLanguage() == nil{
            Utility.shared.setAppLanguage(Language: DEFAULT_LANGUAGE)
            
            
        }else{
            Utility.shared.setAppLanguage(Language: Utility.shared.getAppLanguage()!)
            
        }
          if Utility.shared.getAppLanguageCode() == nil{
            
             Utility.shared.setAppLanguageCode(Language:"en")
        }
        else
          {
            if(Utility.shared.isRTLLanguage()){
                           UIView.appearance().semanticContentAttribute = .forceRightToLeft
                       } else {
                           UIView.appearance().semanticContentAttribute = .forceLeftToRight
                       }
            Utility.shared.setAppLanguageCode(Language:Utility.shared.getAppLanguageCode()!)
        }
        Utility.shared.configureLanguage()
        Utility.shared.configureCurrency()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
    
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            var view = url.pathComponents
            var str = url.absoluteString
            if view.contains("review"){
                 if ((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                    let loginpage = WelcomePageVC()
                    self.setInitialViewController(initialView: loginpage)
                 }else{
                    let writeReview = WriteReview()
                                                       
                                   if view.count >= 4{
                                   writeReview.reservationID = Int(view[3]) ?? 0
                                   }else{
                                       writeReview.reservationID = 0
                                   }
                                   writeReview.isFromEmailNavigation = true
                                   self.setInitialViewController(initialView: writeReview)
                }
               
            }else{
            let urlString = queryParameters(from: url)
            
            if ((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                if view.count > 0{
                    if view.contains("password"){
                        Utility.shared.deepLinkEmail = urlString["email"]!
                        Utility.shared.deepLinkToken = urlString["token"]!
                        let resetPasswordPage = ResetPasswordVC()
                        self.setInitialViewController(initialView: resetPasswordPage)
                    }else{
                        let loginpage = WelcomePageVC()
                        self.setInitialViewController(initialView: loginpage)
                    }
                    
                }else{
                   let loginpage = WelcomePageVC()
                   self.setInitialViewController(initialView: loginpage)
                    
                }

            }else{
                
                 if view.count > 0{
                    if view.contains("user"){
                        Utility.shared.ConfirmEmailString = urlString["email"]!
                        Utility.shared.ConfirmEmailToken = urlString["confirm"]!
                        let VerifyEmail = VerificationSuccessVC()
                        setInitialViewController(initialView: VerifyEmail)
                    }else{
                        
                       let loginpage = WelcomePageVC()
                      self.setInitialViewController(initialView: loginpage)
                    }

                 }else{
                   let loginpage = WelcomePageVC()
                  self.setInitialViewController(initialView: loginpage)
                }

            }
            }

            
        }
        return true
    }
    
    func queryParameters(from url: URL) -> [String: String]{
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryParams = [String: String]()
        for queryItem: URLQueryItem in (urlComponents?.queryItems)!{
            if queryItem.value == nil{
                continue
            }
            queryParams[queryItem.name] = queryItem.value
        }
        return queryParams
    }
    

   

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
       
        let userdata = response.notification.request.content.userInfo
        if let textResponse =  response as? UNTextInputNotificationResponse {
            let sendText =  textResponse.userText
           
            var threadid = String()
            if let bedtypeInfo = userdata["content"] as? String
            {
                if let dict = convertToDictionary(text:bedtypeInfo)
                {
                    threadid = (dict["threadId"] as?String)!
                    sendMessageAPICall(threadid:Int(threadid)!, message:sendText)
                }
            }
        }
        
        
        let appstatechecker = UIApplication.shared.applicationState
        
       
            let userContent = userdata["content"] as? String
          
            let ContentDictionary = convertToDictionary(text:userContent!)
          
            let userType = ContentDictionary!["userType"] as? String
            
            Utility.shared.isfromNotificationHost = false
            Utility.shared.isfromBackroundBooking = false
            Utility.shared.isfromOfflineBooking = false
            
            let navigationString = (ContentDictionary!["title"] as? String)
        
            
        if Utility.shared.isConnectedToNetwork() && (Utility.shared.getCurrentUserToken()) != nil {
                
                
                if navigationString == "New Inquiry" || navigationString == "New Enquiry" || navigationString == "New Message" {
                    
                    if userType == "guest"{
                        
                        let inboxPage = InboxListingVC()
                        Utility.shared.ListID = "\(ContentDictionary!["listId"] as! NSString)"

                        Utility.shared.isfromAppDelegateMessageBackground = true
        
                        inboxPage.threadId = Int((ContentDictionary!["threadId"] as! NSString).intValue)
                        inboxPage.getmessageListquery.removeAll()
                        inboxPage.getMessageListAPICall(threadId: Int((ContentDictionary!["threadId"] as! NSString).intValue))
                        self.setInitialViewController(initialView: inboxPage)
                        
                    }else{
                        let inboxPage = InboxListingVC()
                         Utility.shared.ListID = "\(ContentDictionary!["listId"] as! NSString)"
                        Utility.shared.isfromNotificationHost = true
                        inboxPage.threadId = Int((ContentDictionary!["threadId"] as! NSString).intValue)
                        inboxPage.getmessageListquery.removeAll()
                        inboxPage.getMessageListAPICall(threadId: Int((ContentDictionary!["threadId"] as! NSString).intValue))
                        self.setInitialViewController(initialView: inboxPage)
                    }
                    
                }else if navigationString == "New Booking" || navigationString == "Booking is Cancelled" || navigationString == "Approved" || navigationString == "Declined"{
                    
                    
                    if userType == "guest" {
                        Utility.shared.setTab(index: 2)
                        self.GuestTabbarInitialize(initialView: CustomTabbar())
                        
                    }else{
                        
                        Utility.shared.isfromBackroundBooking = true
                          Utility.shared.isfromNotificationHost = true
                        self.addingElementsToObjects()
                        Utility.shared.setHostTab(index: 2)
                        self.HostTabbarInitialize(initialView: CustomHostTabbar())
                        
                    }
                    
                }
                else if navigationString == "The Admin has verified your listing" || navigationString == "Admin has declined your listing"  {
                    Utility.shared.isfromNotificationHost = true
                    Utility.shared.isfromOfflineNotification = true
                    
                    let becomeHost = BecomeHostVC()
                    becomeHost.listID = "\(ContentDictionary!["listId"]!)"
                    becomeHost.showListingStepsAPICall(listID:"\(ContentDictionary!["listId"]!)")
                    becomeHost.modalPresentationStyle = .fullScreen
                    self.window?.rootViewController = becomeHost
               
                }
            }else{
                
                Utility.shared.setTab(index: 0)
                self.GuestTabbarInitialize(initialView: CustomTabbar())
            }
            
            
            
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                center.removeAllDeliveredNotifications()
            } else {
                UIApplication.shared.cancelAllLocalNotifications()
            }
       
        
        
        completionHandler()
    }


    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
               
            }
        }
        return nil
    }
    func sendMessageAPICall(threadid:Int,message:String)
    {
        var apollo_headerClient: ApolloClient = {
            let configuration = URLSessionConfiguration.default
          
            configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
            let url = URL(string:graphQLEndpoint)!
            
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
        let sendMsgMutation = SendMessageMutation(threadId:threadid,content:message, type: "message")
        
        apollo_headerClient.perform(mutation: sendMsgMutation){(result,error) in
            guard (result?.data?.sendMessage?.results) != nil else{
             
                return
            }
            
            let appstatechecker = UIApplication.shared.applicationState
            if(appstatechecker == UIApplication.State.inactive)
            {
                if #available(iOS 10.0, *) {
                    let center = UNUserNotificationCenter.current()
                    center.removeAllPendingNotificationRequests()
                    center.removeAllDeliveredNotifications()
                } else {
                    UIApplication.shared.cancelAllLocalNotifications()
                }
            }
            
            
        }
    }
    func GetDefaultSettingAPICall()
    {
        
        apollo_headerClient = {
            let configuration = URLSessionConfiguration.default
            let url = URL(string:graphQLEndpoint)!
            
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
            let mostlistingquery = GetDefaultSettingQuery()
            apollo_headerClient.fetch(query: mostlistingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
               
                guard (result?.data?.currency?.result) != nil else {
                   
                    return
                }
                Utility.shared.currencyvalue_from_API_base = (result?.data?.currency?.result?.base)!
                let currency_value = result?.data?.currency?.result?.rates
                Utility.shared.currency_Dict = self.convertToDictionary(text: currency_value!)! as NSDictionary
                
               
        }
        
    }
    
    func GetSecureSettingAPICall()
    {
        
        apollo_headerClient = {
            let configuration = URLSessionConfiguration.default
           
            let url = URL(string:graphQLEndpoint)!
            
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
            let mostlistingquery = GetSecureSiteSettingsQuery(settingsType:"site_settings", securityKey: SECURE_KEY)
            apollo_headerClient.fetch(query: mostlistingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
              
                guard (result?.data?.getSecureSiteSettings?.results) != nil else {
                   
                    return
                }
               
                
                if let value = result?.data?.getSecureSiteSettings?.results{
                    for i in value{
                        if (i?.name == "phoneNumberStatus"){
                            Utility.shared.phoneNumberStatus = i?.value ?? ""
                        }
                    }
                }
        }
        
    }
    
    
    func profileAPICall()
    {
        if Utility().isConnectedToNetwork(){
        if(Utility.shared.getCurrentUserToken() != nil)
        {
        let profileQuery = GetProfileQuery()
            apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
             
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
               
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
        apollo_headerClient.fetch(query:profileQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            
            guard (result?.data?.userAccount?.result) != nil else
            {
               
                Utility.shared.setUserToken(userID: "")
                return
            }
            
            
            Utility.shared.ProfileAPIArray = ((result?.data?.userAccount?.result)!)
            Utility.shared.userName  = "\(Utility.shared.ProfileAPIArray.firstName != nil ? Utility.shared.ProfileAPIArray.firstName! : "User")!"
            
            
            
            if let theme = result?.data?.userAccount?.result?.appTheme {
                Utility.shared.setAppTheme(Language:theme)
                Utility.shared.selectedAppearance = theme
            }
            else {
                Utility.shared.setAppTheme(Language:"auto")
                Utility.shared.selectedAppearance = "auto"
            }
            
            self.themeInitialSetUp()
          
            
            if let profImage = Utility.shared.ProfileAPIArray.picture{
                Utility.shared.pickedimageString = "\(IMAGE_AVATAR_MEDIUM)\(profImage)"
            }
            else {
                Utility.shared.pickedimageString = "avatar"
            }
            
            
            Utility.shared.setEmail(email:(result?.data?.userAccount?.result?.email as AnyObject)as! NSString)
         
           
            }
        }
            
        }
        }
        
    
    func getcurrencyAPICall()
    {
       
        apollo_headerClient = {
            let configuration = URLSessionConfiguration.default
           
            let url = URL(string:graphQLEndpoint)!
            
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
        let currencyQuery = GetCurrenciesListQuery()
        apollo_headerClient.fetch(query: currencyQuery){(result,error) in
            guard (result?.data?.getCurrencies?.results) != nil else{
              
                return
            }
            Utility.shared.currencyDataArray = ((result?.data?.getCurrencies?.results)!) as! [GetCurrenciesListQuery.Data.GetCurrency.Result]
            Utility.shared.currencyvalue = Utility.shared.currencyDataArray.first!.symbol!
        }
       
    }

    func UserBanStatus()
    {
        let UserbanstatusQuery = UserBanStatusQuery()
        
        apollo_headerClient.fetch(query: UserbanstatusQuery){(result,error) in
            
            if(result?.data?.getUserBanStatus?.status == 200)
            {
                if(((Utility.shared.getTabbar()) != nil) && Utility.shared.getTabbar() == true)
                {
                    Utility.shared.host_message_isfromHost = true
                    self.addingElementsToObjects()

                    Utility.shared.setHostTab(index: 0)
                    self.HostTabbarInitialize(initialView: CustomHostTabbar())
                }
                else
                {
                Utility.shared.setTab(index: 0)
                self.GuestTabbarInitialize(initialView: CustomTabbar())
                }
                

                
            }
            else if(result?.data?.getUserBanStatus == nil)
            {
            
                 if(Utility.shared.getTabbar() != nil && Utility.shared.getTabbar() == true)
                {
                    Utility.shared.host_message_isfromHost = true
                    self.addingElementsToObjects()

                     Utility.shared.setHostTab(index: 0)
                     self.HostTabbarInitialize(initialView: CustomHostTabbar())
                }
                else
                {
            Utility.shared.setTab(index: 0)

            self.GuestTabbarInitialize(initialView: CustomTabbar())
                }
            }
            else
            {
           
                if(Utility.shared.getTabbar() != nil && Utility.shared.getTabbar() == true)
                {
                    Utility.shared.host_message_isfromHost = true
                    self.addingElementsToObjects()

                    Utility.shared.setHostTab(index: 0)
                    self.HostTabbarInitialize(initialView: CustomHostTabbar())
                }
                else
                {
            Utility.shared.setTab(index: 0)

            self.GuestTabbarInitialize(initialView: CustomTabbar())
                }
            }
            
            
        }
        
    }
        

    func setInitialViewController(initialView: UIViewController)  {
         IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
       
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController?.definesPresentationContext = true
        window?.rootViewController?.dismiss(animated: true, completion: nil)
        window?.backgroundColor =  UIColor(named: "colorController")
        let homeViewController = initialView
       
     
      
        
        
        let nav = UINavigationController(rootViewController: homeViewController)
      
        window?.backgroundColor =  UIColor(named: "colorController")
        nav.isNavigationBarHidden = true
       
        self.window!.rootViewController = nav
        self.window!.makeKeyAndVisible()
            
       
        self.themeInitialSetUp()
       
        
    
    }
    func GuestTabbarInitialize(initialView:UITabBarController)
    {
       
        Utility.shared.setopenTabbar(iswhichtabbar:false)
        Utility.shared.host_message_isfromHost = false
        Utility.shared.host_message_isfrommessage = false
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor =  UIColor(named: "colorController")
      
            
            self.window?.rootViewController = initialView
        self.window?.rootViewController?.view.backgroundColor =  UIColor(named: "colorController")
            self.window?.makeKeyAndVisible()
        self.themeInitialSetUp()
        
    }
    func HostTabbarInitialize(initialView:UITabBarController)
    {
        
        
        Utility.shared.setopenTabbar(iswhichtabbar:true)
        Utility.shared.host_message_isfromHost = true
        Utility.shared.host_message_isfrommessage = false
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor =  UIColor(named: "colorController")
     
        window?.rootViewController = initialView
        window?.rootViewController?.view.backgroundColor = UIColor(named: "colorController")
        window?.makeKeyAndVisible()
        self.themeInitialSetUp()
        
    }
    
    

    public func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
       window?.rootViewController = ResetPasswordVC()
        window?.makeKeyAndVisible()
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = Stripe.handleURLCallback(with: url)
                if (stripeHandled) {
                    return true
                } else {
                  
                }
            }
        }


        return true
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
      
        var str = url.absoluteString

        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("com.airhomestays.app") == .orderedSame,
            let view = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }

        }
        
        let stripeHandled = Stripe.handleURLCallback(with: url)
               if (stripeHandled) {
                   return true
               } else {
                 
               }
        return true
    }
    
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        LauchShortcutItem = shortcutItem
        completionHandler(handleShortcutItem(item: shortcutItem))
     
    }
    

    enum shortCutItemIdentifier: String{
        
        case first
        case message
        case saved
        init?(fullnameForType: String){
            guard let last = fullnameForType.components(separatedBy: ".").last else{return nil}
            self.init(rawValue: last)
        }
        
        var type: String{
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }
    
    
    
    func configureDynamicData(){
        
        if Utility.shared.getTabbar() != nil && Utility.shared.getTabbar() == true{
             if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                
                let welcomepage = WelcomePageVC()
                self.setInitialViewController(initialView: welcomepage)
    
             }else{
                Utility.shared.isfromMessageShortcut = true
                 self.addingElementsToObjects()
                 Utility.shared.setHostTab(index: 3)
                 self.HostTabbarInitialize(initialView: CustomHostTabbar())
            }
        }else{
             if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                let welcomepage = WelcomePageVC()
                self.setInitialViewController(initialView: welcomepage)
             }else{
                Utility.shared.setTab(index: 3)
                self.GuestTabbarInitialize(initialView: CustomTabbar())
            }
        }
    }
    
    
    func NavigatetoSavedPage(){

        if Utility.shared.getTabbar() != nil && Utility.shared.getTabbar() == true{
            
            Utility.shared.isfromHost = true
            Utility.shared.isfromSavedShortcut = true
            let splashscreen  = SwitchTravelAndHostVC()
            self.setInitialViewController(initialView: splashscreen)
            
        }else{
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == ""){
                let welcomepage = WelcomePageVC()
                self.setInitialViewController(initialView: welcomepage)
               
            }else{
                Utility.shared.setTab(index: 1)
                self.GuestTabbarInitialize(initialView: CustomTabbar())
            }
        }

    }
    func handleShortcutItem(item: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard shortCutItemIdentifier(fullnameForType: item.type) != nil else {return false}
        guard let shortcutType = item.type as String? else {return false}
        

        switch shortcutType {
            
        case shortCutItemIdentifier.first.type:
            handled = true
            Utility.shared.setTab(index: 3)
            self.GuestTabbarInitialize(initialView: CustomTabbar())
        case shortCutItemIdentifier.message.type:
            self.configureDynamicData()
            return true
        case shortCutItemIdentifier.saved.type:
            self.NavigatetoSavedPage()
            return true
        default: break
     
        }
        return handled
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
     
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
      
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        Utility.shared.phoneBtnTapped = false
      
        if let shortcutItem = LauchShortcutItem {
               var message = "\(shortcutItem.type) triggered"

                LauchShortcutItem = nil
            }
        
        if Utility.shared.getAppTheme() == "auto" || Utility.shared.getAppTheme() == nil{
           self.themeInitialSetUp()
        }

    }

    func applicationWillTerminate(_ application: UIApplication) {
  
    }


    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
          
            guard granted else { return }
    
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        
        if Utility.shared.isConnectedToNetwork() {
          
         
            let userdata = userInfo
            let userContent = userdata["content"] as? String
           
            let ContentDictionary = convertToDictionary(text:userContent!)
           
            let aps = userInfo["aps"] as! NSDictionary
          
            if let userAlert = aps["alert"] as? NSDictionary{
            }
            
          
            var screentype = String()
            if let bedtypeInfo = userdata["content"] as? String
            {
                if let dict = convertToDictionary(text:bedtypeInfo)
                {
                    screentype = (dict["title"] as?String)!
                    if(screentype == "New Message")
                    {
                        isreplyenabled = true
                        
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                            if error != nil
                            {
                              
                            }
                            else
                            {
                                if granted
                                {
                                   
                                    let commentAction = UNTextInputNotificationAction(identifier:"myNotificationCategory", title: "Comment", options: [], textInputButtonTitle: "Send", textInputPlaceholder: "")
                                    let category = UNNotificationCategory(identifier:"", actions: [commentAction], intentIdentifiers: [], options: [])
                                    UNUserNotificationCenter.current().setNotificationCategories([category])
                                    UNUserNotificationCenter.current().delegate = self
                                    return
                                    
                                }
                                else
                                {
                                
                                    let center = UNUserNotificationCenter.current()
                                    center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                                     
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        isreplyenabled = false
                        
                        let category = UNNotificationCategory(identifier:"", actions:[], intentIdentifiers: [], options: [])
                        UNUserNotificationCenter.current().setNotificationCategories([category])
                        UNUserNotificationCenter.current().delegate = self
                        
                        return
                        
                    }
                    
                    
                }
            }
        }else{
            
        }
 
    }

  
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        

        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
    
        Messaging.messaging().apnsToken = deviceToken as Data
    }
  
 
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
                
                let dataDict:[String: String] = ["token": fcmToken ?? ""]
                Utility.shared.pushnotification_devicetoken  = fcmToken ?? ""
                NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
                
            }
   
    
    func registerForPushNotification(_ application: UIApplication)  {
        if #available(iOS 10.0, *) {
         
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
    }
    
    
    
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
     
    }
    
 

  
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
 

    
    func settingRootViewControllerFunction()
    {
   
        if let aSize = UIFont(name: "Avenir Next Demi", size: 15.0) {
            UITabBarItem.appearance().setTitleTextAttributes([
                NSAttributedString.Key.font : aSize,
                NSAttributedString.Key.foregroundColor : Theme.PRIMARY_COLOR
                ], for: .selected)
        }
        if let aSize = UIFont(name: "Avenir Next Demi", size: 15.0) {
            UITabBarItem.appearance().setTitleTextAttributes([
                 NSAttributedString.Key.font : aSize,
                 NSAttributedString.Key.foregroundColor :  UIColor(named: "Title_Header")
                ], for: .normal)
        }
    
        tabBarController.tabBar.tintColor = Theme.PRIMARY_COLOR
        tabBarController.tabBar.unselectedItemTintColor = .black
    
        UITabBar.appearance().barTintColor = UIColor(named: "colorController")
        
        tabBarController.tabBarItem.titlePositionAdjustment =  UIOffset(horizontal: 0, vertical: -4)
        
        let explorePageObj = HostListingVC(
            nibName: "HostListingVC",
            bundle: nil)
        let savedPAgeObj = HostCalendarVC(
            nibName: "HostCalendarVC",
            bundle: nil)
        let TripsPageObj = HostProgressVC(
            nibName: "HostProgressVC",
            bundle: nil)
        let MessagePageObj = TripsMessageVC(
            nibName: "TripsMessageVC",
            bundle: nil)
        let ProfilePageObj = ProfilePageVC(
            nibName: "ProfilePageVC",
            bundle: nil)
        explorePageObj.tabBarItem.tag = 0
        savedPAgeObj.tabBarItem.tag = 1
        TripsPageObj.tabBarItem.tag = 2
        MessagePageObj.tabBarItem.tag = 3
        ProfilePageObj.tabBarItem.tag = 4
        
       
        
        let controllers = [explorePageObj,savedPAgeObj,TripsPageObj,MessagePageObj,ProfilePageObj]
      
      
        let navController = UINavigationController(rootViewController: explorePageObj)
        navController.isNavigationBarHidden = true
       
        tabBarController.viewControllers = controllers
        tabBarController.tabBar.backgroundColor = UIColor(named: "colorController")
        
        window?.rootViewController = tabBarController
        
        tabBarController.viewControllers = controllers

       

        self.tarbarIconUpdates(tabBarController)
        
           window = UIWindow(frame: UIScreen.main.bounds)
        if Utility.shared.isfromOfflineNotification || Utility.shared.isfromNotificationHost || Utility.shared.isfromAppDelegateMessageBackground || Utility.shared.isfromAppdelegateMessageOffline || Utility.shared.isFromMessageListingPage_host || Utility.shared.isfromMessageShortcut{
            
            Utility.shared.isfromMessageShortcut = false
            tabBarController.selectedIndex = 3
        
        }else if Utility.shared.isfromBackroundBooking || Utility.shared.isfromOfflineBooking{
             tabBarController.selectedIndex = 2
        }else{
            tabBarController.selectedIndex = 0
        }
        
        if (IS_IPHONE_XR || IS_IPHONE_X || IS_IPHONE_XS_MAX) {
            tabBarController.tabBar.frame.size.height = 83

        }else{
            tabBarController.tabBar.frame.size.height = 53
            tabBarController.tabBar.frame.origin.y = UIScreen.main.bounds.height - 53
        }
        tabBarController.tabBar.layoutSubviews()
        

             var  menuButtonFrame = middleView.frame
        menuButtonFrame.origin.y = tabBarController.tabBar.frame.origin.y
        menuButtonFrame.origin.x = tabBarController.tabBar.bounds.width/2 - menuButtonFrame.size.width/2
        middleView.frame = menuButtonFrame
        
        middleView.backgroundColor = .clear
        middleView.layer.cornerRadius = menuButtonFrame.height/2
        
        
        if middleView.superview == nil{
            tabBarController.view.addSubview(middleView)
        }
        

               menuButtonFrame = middleButton.frame
        menuButtonFrame.origin.y =  tabBarController.tabBar.frame.origin.y - (middleButton.frame.size.height-20)
               menuButtonFrame.origin.x = tabBarController.tabBar.bounds.width/2 - menuButtonFrame.size.width/2
        middleButton.frame = menuButtonFrame
        middleButton.backgroundColor = Theme.Button_BG
        middleButton.layer.cornerRadius = menuButtonFrame.height/2
        
       
        
              
              let center = CGPoint (x: middleButton.frame.size.width / 2, y: middleButton.frame.size.height / 2)
              let circleRadius = middleButton.frame.size.width / 2
              let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(Double.pi * 2), endAngle: CGFloat(Double.pi), clockwise: true)
              
              semiCircleLayer.path = circlePath.cgPath
              semiCircleLayer.strokeColor = UIColor.clear.cgColor
              semiCircleLayer.fillColor = UIColor.clear.cgColor
              semiCircleLayer.lineWidth = 8
              semiCircleLayer.shadowColor = UIColor.red.cgColor
              semiCircleLayer.shadowRadius = 8.0
        semiCircleLayer.shadowOpacity = 0.5
              semiCircleLayer.shadowPath = circlePath.cgPath.copy(strokingWithWidth:5, lineCap: .round, lineJoin: .miter, miterLimit: 0)

              semiCircleLayer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        middleButton.layer.addSublayer(semiCircleLayer)
        
      
        

        middleButton.setImage(UIImage(named: "updatedTabbarTrip"), for: .normal)
        middleButton.addTarget(self, action: #selector(goToTripsPage), for: .touchUpInside)
   
        let newValue = tabBarController.tabBar.frame.size.height
        let newYValue = tabBarController.tabBar.frame.origin.y
        window?.rootViewController = tabBarController
        if middleButton.superview == nil{
            window?.rootViewController?.view.addSubview(middleButton)
        }
        window?.makeKeyAndVisible()
        

    }
    
    
    func showALert(title: String){
        let alertController = UIAlertController(title: "Title", message: title, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                            UIAlertAction in
                            
                        }
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    @objc func goToTripsPage(){
        if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let welcomeObj = WelcomePageVC()
            appDelegate.setInitialViewController(initialView: welcomeObj)
        }else{
            self.tabBarController.selectedIndex = 2
        }
        
    }
    func tarbarIconUpdates(_ tabbarController: UITabBarController?)
    {
       
        for item: UITabBarItem in (tabbarController?.tabBar.items)! {
            let appearance = UITabBarItem.appearance()
            let attributes = [NSAttributedString.Key.font:UIFont(name:APP_FONT_MEDIUM, size: 12)]
            appearance.setTitleTextAttributes(attributes, for:.normal)
            item.title = tabNameArray[item.tag] as? String
            if item.tag == 2{
                item.image = UIImage()
                item.selectedImage = UIImage()
            }else{
                item.image = ((tabImageArray[item.tag]) as! UIImage)
                item.selectedImage = ((tabImageArray[item.tag]) as! UIImage)
            }
           
            if(!IS_IPHONE_XR)
            {
            item.titlePositionAdjustment.vertical = item.titlePositionAdjustment.vertical-5
            }
        }
    }
    func addingElementsToObjects(){
        
        tabImage_RedArray.removeAllObjects()
        tabImageArray.removeAllObjects()
        tabNameArray.removeAllObjects()
        tabNameArray.add("\((Utility.shared.getLanguage()?.value(forKey:"list_upper"))!)")
        tabNameArray.add("\((Utility.shared.getLanguage()?.value(forKey:"calendar_upper"))!)")
        tabNameArray.add("\((Utility.shared.getLanguage()?.value(forKey:"progress_upper"))!)")
        tabNameArray.add("\((Utility.shared.getLanguage()?.value(forKey:"tabinbox"))!)")
        tabNameArray.add("\((Utility.shared.getLanguage()?.value(forKey:"tabprofile"))!)")
        
        
        tabImageArray = [#imageLiteral(resourceName: "home-25-2"),#imageLiteral(resourceName: "calendar-25-2"),#imageLiteral(resourceName: "tabtrip"),#imageLiteral(resourceName: "tabchat"),#imageLiteral(resourceName: "tabprofile")]
        tabImage_RedArray = [#imageLiteral(resourceName: "tablisting_red"),#imageLiteral(resourceName: "tabcalendar_red"),#imageLiteral(resourceName: "tabtrip_red"),#imageLiteral(resourceName: "tabchat_red"),#imageLiteral(resourceName: "tabprofile_red")]

        
    }
    
    func GuesttarbarIconUpdates(_ tabbarController: UITabBarController?)
    {
        for item: UITabBarItem in (tabbarController?.tabBar.items)! {
            item.title = tabNameArray[item.tag] as? String
            if item.tag == 2{
                item.image = UIImage()
                item.selectedImage = UIImage()
            }else{
                item.image = ((tabImageArray[item.tag]) as! UIImage)
                item.selectedImage = ((tabImage_RedArray[item.tag]) as! UIImage)
            }
            
            if(!IS_IPHONE_XR)
            {
                item.titlePositionAdjustment.vertical = item.titlePositionAdjustment.vertical-5
            }
        }
    }
   
    
     func minimalCustomizationPresentationExample() {
         
        }
 

}
