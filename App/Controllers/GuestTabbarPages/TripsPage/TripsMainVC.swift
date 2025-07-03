
import UIKit
import Lottie
import Apollo
import SwiftMessages
import SkeletonView
import MessageUI
class TripsMainVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate, SkeletonTableViewDataSource,MFMailComposeViewControllerDelegate{
    
    
    @IBOutlet weak var myTripsTitleLabel: UILabel!
    @IBOutlet weak var headerLineView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var upcomingTable: UITableView!
    @IBOutlet weak var previousTable: UITableView!
    @IBOutlet weak var exploreBtn: UIButton!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var wheretoLabel: UILabel!
    @IBOutlet weak var WhereView: UIView!
    @IBOutlet weak var previousLabel: UILabel!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    var totalListcount:Int = 0
    var PageIndex : Int = 1
    var previoustotalListcount:Int = 0
    var previousPageIndex : Int = 1
    var isupcomingTable:Bool = true
    var checkinDate = String()
    var checkoutDate = String()
    
    @IBOutlet var contactsView: UIView!
    
    
    var getReservationArray = GetReservationQueryy.Data.GetReservation.Result()
    var apollo_headerClient:ApolloClient!
    var getallreservationquery = [GetAllReservationQuery.Data.GetAllReservation.Result]()
    var getpreviousReservationquery = [GetAllReservationQuery.Data.GetAllReservation.Result]()
     var lottieView: LottieAnimationView!
    var getReservation_currencyArray = GetReservationQueryy.Data.GetReservation()
    var previousEnabled = Bool()
    var menuOptionNameArray = [String]()
    var menuOprionImageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor = UIColor(named: "colorController")
        previousTable.backgroundColor = UIColor(named: "colorController")
        upcomingTable.backgroundColor = UIColor(named: "colorController")
        previousEnabled = false
        self.checkApolloStatus()
        self.initialsetup()
        self.lottieAnimation()
        lottieView = LottieAnimationView.init(name:"animation")
        
        startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"startplanningfirst"))!)"

        myTripsTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "My_Trips") ?? "My trips")"
        myTripsTitleLabel.textColor = UIColor(named: "Title_Header")
        myTripsTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        myTripsTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        headerLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        upcomingTable.estimatedRowHeight = 50
        previousTable.estimatedRowHeight = 50
    }
    @IBAction func exploreBtnTapped(_ sender: Any) {
        
        Utility.shared.setTab(index: 0)
        CustomTabbar().tabBarController?.selectedIndex = 0
        self.tabBarController?.selectedIndex = 0

        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if previousEnabled == false && upcomingBtn.isUserInteractionEnabled == true{
            self.previousTable.isHidden = true
            self.upcomingTable.isHidden = false
            upcomingLabel.isHidden = false
            previousLabel.isHidden = true
            PageIndex = 1
            self.getallreservationquery.removeAll()
            self.getTripsAPICall()
        }else{
            self.previousTable.isHidden = false
            self.upcomingTable.isHidden = true
            upcomingLabel.isHidden = true
            previousLabel.isHidden = false
            previousPageIndex = 1
            self.getpreviousReservationquery.removeAll()
            self.previousTripsAPICall()
        }

        
       
        Utility.shared.isfromcancelPAge = false
        Utility.shared.phoneBtnTapped = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    func checkApolloStatus()
    {
        if((Utility.shared.getCurrentUserToken()) != nil && (Utility.shared.getCurrentUserToken() != ""))
        {
            apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
        }
        else{
            apollo_headerClient = ApolloClient(url: URL(string:graphQLEndpoint)!)
        }
        
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = true
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-10, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
    
    }
    @objc func autoscroll(){
    
    }
    
    @IBAction func upcomingTapped(_ sender: Any) {
        self.lottieAnimation()
        previousEnabled = false
        isupcomingTable = true
        startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"startplanningfirst"))!)"
        self.upcomingTable.isHidden = false

       previousBtn.isUserInteractionEnabled = true
        previousLabel.isHidden = true
        upcomingLabel.backgroundColor = Theme.PRIMARY_COLOR
        previousLabel.backgroundColor = Theme.tripsTabDisabledColor

        if(getallreservationquery.count>0)
        {
            self.WhereView.isHidden = true
            self.upcomingTable.isHidden = false
            
        }
        else
        {
            self.lottieView.isHidden = true
            self.WhereView.isHidden = false
            self.wheretoLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"Guest_Upcoming_Empty") ?? "No upcoming trips found")"
            self.upcomingTable.isHidden = true
            
        }
        self.upcomingTable.reloadData()
        upcomingBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        previousBtn.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        self.previousTable.isHidden = true
        upcomingLabel.isHidden = false
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        isupcomingTable = false
        previousEnabled = true
        previousBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        upcomingBtn.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
      
        previousBtn.isUserInteractionEnabled = false
        previousLabel.isHidden = false
        upcomingLabel.isHidden = true
        upcomingLabel.backgroundColor = Theme.tripsTabDisabledColor
        previousLabel.backgroundColor = Theme.PRIMARY_COLOR
        self.lottieAnimation()
        self.upcomingTable.isHidden = true
        self.previousTable.isHidden = false
        startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"startplanning"))!)"
  
        if(getpreviousReservationquery.count == 0)
        {
            previousTable.isSkeletonable = true
            previousTable.showAnimatedGradientSkeleton()
        previousPageIndex = 1
        self.previousTripsAPICall()
        
         previousTable.reloadData()
        }
        
      
        
    }
    func initialsetup()
    {
        exploreBtn.layer.cornerRadius = exploreBtn.frame.size.height/2
    exploreBtn.layer.masksToBounds = true
    exploreBtn.layer.borderWidth = 1.0
    exploreBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
    previousLabel.isHidden = true
    upcomingLabel.isHidden = false
        upcomingLabel.backgroundColor = Theme.PRIMARY_COLOR
        previousLabel.backgroundColor = Theme.tripsTabDisabledColor
        
        previousBtn.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        
    upcomingBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
    previousTable.register(UINib(nibName: "TripsCell", bundle: nil), forCellReuseIdentifier: "TripsCell")
    upcomingTable.register(UINib(nibName: "TripsCell", bundle: nil), forCellReuseIdentifier: "TripsCell")
        previousTable.register(UINib(nibName: "nolistTripsCell", bundle: nil), forCellReuseIdentifier: "nolistTripsCell")
        upcomingTable.register(UINib(nibName: "nolistTripsCell", bundle: nil), forCellReuseIdentifier: "nolistTripsCell")
        
        previousTable.isSkeletonable = false
        upcomingTable.isSkeletonable = false
        
        previousTable.hideSkeleton()
        upcomingTable.hideSkeleton()
        
        
        
       
        upcomingTable.isSkeletonable = true
        upcomingTable.showAnimatedGradientSkeleton()
    self.WhereView.isHidden = true
    self.offlineView.isHidden = true
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        upcomingBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"upcomingtrips"))!)", for: .normal)
        previousBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"previoustrips"))!)", for: .normal)
        startLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        exploreBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"exploretrips"))!)", for:.normal)
        
        exploreBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        wheretoLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey:"Guest_Upcoming_Empty") ?? "No upcoming trips found")"
        wheretoLabel.textColor = UIColor(named: "Title_Header")
    self.previousTable.isHidden = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        startLabel.font = UIFont(name: APP_FONT, size: 14)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        wheretoLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14)
        upcomingBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
         previousBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
         exploreBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
    }
    func getTripsAPICall()
    {
         if Utility().isConnectedToNetwork(){
        let getallreservationQuery = GetAllReservationQuery(userType:GUEST, currentPage:PageIndex, dateFilter: "upcoming")
    apollo_headerClient.fetch(query:getallreservationQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            if(result?.data?.getAllReservation?.status == 200)
            {
                self.totalListcount = (result?.data?.getAllReservation?.count != nil ? (result?.data?.getAllReservation?.count!)! : 0)

            self.getallreservationquery.append(contentsOf: ((result?.data?.getAllReservation?.result)!) as! [GetAllReservationQuery.Data.GetAllReservation.Result])
            self.WhereView.isHidden = true
            self.upcomingTable.isHidden = false
             self.lottieView.isHidden = true
                self.upcomingTable?.hideSkeleton()
            self.upcomingTable?.reloadData()
            }
            else
            {
                if result?.data?.getAllReservation?.status == 500{
                    let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message:result?.data?.getAllReservation?.errorMessage, preferredStyle: .alert)
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
                }
                if(self.getallreservationquery.count == 0)
                {
                    self.lottieView.isHidden = true
                self.upcomingTable.isHidden = true
                self.WhereView.isHidden = false
                    self.wheretoLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"Guest_Upcoming_Empty") ?? "No upcoming trips found")"
                }
            }
            
    }
        }
         else{
             self.WhereView.isHidden = true
             self.upcomingTable.isHidden = false
            self.view.addSubview(offlineView)
            self.upcomingTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
            
        }
        
    }

    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        self.lottieAnimation()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.GetDefaultSettingAPICall()
        self.offlineView.isHidden = true
            self.getallreservationquery.removeAll()
            self.getpreviousReservationquery.removeAll()
            if(isupcomingTable)
            {
        self.getTripsAPICall()
            }
            else
            {
        self.previousTripsAPICall()
            }
        }
    }
    
    func previousTripsAPICall()
    {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            let getallreservationQuery = GetAllReservationQuery(userType:GUEST, currentPage:previousPageIndex, dateFilter: "previous")
            
            apollo_headerClient.fetch(query:getallreservationQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                if(result?.data?.getAllReservation?.status == 200)
                {
                    self.previoustotalListcount = (result?.data?.getAllReservation?.count)!

                    self.getpreviousReservationquery.append(contentsOf: ((result?.data?.getAllReservation?.result)!) as! [GetAllReservationQuery.Data.GetAllReservation.Result])

                    if(self.upcomingLabel.isHidden == false && self.getallreservationquery.count == 0)
                    {
                       self.WhereView.isHidden = false
                        self.wheretoLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey:"Guest_Previous_Empty") ?? "No previous trips found")"
                    }
                    else
                    {
                     self.WhereView.isHidden = true
                    }
                    self.previousTable?.hideSkeleton()
                    self.previousTable?.reloadData()
                }
                else
                {
                    if(self.getpreviousReservationquery.count == 0 && self.previousEnabled == true)
                    {
                    self.upcomingTable.isHidden = true
                    self.previousTable.isHidden = true
                    self.lottieView.isHidden = true
                    self.WhereView.isHidden = false
                        self.wheretoLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey:"Guest_Previous_Empty") ?? "No previous trips found")"
                    }
                }
                
            }
        }
        else{
           
            previousTable.isSkeletonable = true
            previousTable.showAnimatedGradientSkeleton()
            upcomingTable.isSkeletonable = true
            upcomingTable.showAnimatedGradientSkeleton()

            self.view.addSubview(offlineView)
            self.previousTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == upcomingTable)
        {
            return getallreservationquery.count
        }
        else{
            return getpreviousReservationquery.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func istodayDay() -> String
       {
           let date = Date()
           let formatter = DateFormatter()
           formatter.timeZone = TimeZone(abbreviation: "UTC")
           formatter.dateFormat = "mm/dd/yyyy"

           let result = formatter.string(from: date)
           return result

       }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == upcomingTable)
        {
         
           var Currentdate = String()
            if((getallreservationquery.count > 0) && (getallreservationquery[indexPath.row].listData != nil))
             {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type: getallreservationquery[indexPath.row].reservationState != nil ? getallreservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getallreservationquery[indexPath.row].reservationState != nil ? getallreservationquery[indexPath.row].reservationState!.firstUppercased : "")
                
                
                if let hostImg = getallreservationquery[indexPath.row].hostData?.picture{
                    cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(hostImg)"), placeholderImage: #imageLiteral(resourceName: "unknown"), completed: nil)
                }
                else {
                    cell.userImg.image = #imageLiteral(resourceName: "unknown")
                }
                cell.listTitleLable.text = getallreservationquery[indexPath.row].listData?.title ?? ""
                let str = cell.listTitleLable.text
                if str!.count > 25{
                    cell.heightConstraints.constant = 50
                }
                else {
                    cell.heightConstraints.constant = 25
                }
                cell.titleBtn.tag = indexPath.row
                cell.titleBtn.addTarget(self, action: #selector(listBtnTapped(_:)), for: .touchUpInside)
                
                cell.addressLAbel.text = "\(getallreservationquery[indexPath.row].listData?.street != nil ? ((getallreservationquery[indexPath.row].listData?.street!)!) : ""),\(getallreservationquery[indexPath.row].listData?.city != nil ? ((getallreservationquery[indexPath.row].listData?.city!)!) : ""), \(getallreservationquery[indexPath.row].listData?.state != nil ? ((getallreservationquery[indexPath.row].listData?.state!)!) : ""), \(getallreservationquery[indexPath.row].listData?.country != nil ? ((getallreservationquery[indexPath.row].listData?.country!)!) : "") \(getallreservationquery[indexPath.row].listData?.zipcode != nil ? ((getallreservationquery[indexPath.row].listData?.zipcode!)!) : "")"
                
                let inday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                checkinDate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                let outday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                checkoutDate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                cell.dateLabel.text = "(\(checkinDate) - \(checkoutDate))"
                     Currentdate = checkoutDate
                
                cell.nameLabel.text = getallreservationquery[indexPath.row].hostData?.firstName ?? ""

                if(getallreservationquery[indexPath.row].hostData?.fullPhoneNumber != nil && getallreservationquery[indexPath.row].hostData?.fullPhoneNumber != ""  && ((getallreservationquery[indexPath.row].reservationState! == "approved") || (getallreservationquery[indexPath.row].reservationState! == "completed"))) {
                    cell.btnPhoneno.isHidden = false
                    cell.phoneNoHeight.constant = 21
                    cell.phoneTop.constant = 5
                cell.btnPhoneno.setTitle(getallreservationquery[indexPath.row].hostData?.fullPhoneNumber ?? "", for:.normal)
                }
                else {
                    cell.phoneNoHeight.constant = 0
                    cell.phoneTop.constant = 0
                    cell.btnPhoneno.isHidden = true
                }
                
                
                if(getallreservationquery[indexPath.row].hostUser?.email != nil && getallreservationquery[indexPath.row].hostUser?.email != "") {
                    cell.btnEmail.isHidden = false
                cell.btnEmail.setTitle(getallreservationquery[indexPath.row].hostUser?.email, for:.normal)
                    
                    if cell.btnPhoneno.isHidden {
                        cell.dateTop.constant = 3
                    }
                    else {
                        cell.dateTop.constant = 5
                    }
                    cell.emailHeightConstant.constant = 21
                  
                    
                }
                else {
                    cell.btnEmail.isHidden = true
                    cell.dateTop.constant = 0
                    cell.emailHeightConstant.constant = 0
                }
                
                
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = getallreservationquery[indexPath.row].currency!
                    let total = Double(getallreservationquery[indexPath.row].total!) + Double(getallreservationquery[indexPath.row].guestServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                    
                }
                else
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                    let from_currency = getallreservationquery[indexPath.row].currency!
                    let total = Double(getallreservationquery[indexPath.row].total!) + Double(getallreservationquery[indexPath.row].guestServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                }
                
                cell.btnPhoneno.tag = indexPath.row
                cell.btnEmail.tag = indexPath.row
                cell.moreBtn.tag = indexPath.row
                cell.moreBtn.addTarget(self, action: #selector(moreBtnTapped), for: .touchUpInside)
                cell.btnEmail.addTarget(self, action: #selector(emailBtnTapped), for: .touchUpInside)
                cell.btnPhoneno.addTarget(self, action: #selector(phoneBtnTapped), for: .touchUpInside)

                return cell
             }
            else  if((getallreservationquery.count > 0) && (getallreservationquery[indexPath.row].listData == nil))
            {
        
                 let cell = tableView.dequeueReusableCell(withIdentifier: "nolistTripsCell", for: indexPath)as! nolistTripsCell
            if(getallreservationquery.count > 0)
                    {
                cell.selectionStyle = .none
                
                cell.nolistLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)"
                
                cell.nolistLabel.textColor  = Theme.Button_BG
                let inday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                let indate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                let outday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                let outdate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                cell.dateLabel.text = "(\(indate) - \(outdate))"
                
                cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type: getallreservationquery[indexPath.row].reservationState != nil ? getallreservationquery[indexPath.row].reservationState! : "") ?? "   ")" + "   "
                    
                cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getallreservationquery[indexPath.row].reservationState!.firstUppercased)
                cell.approvedLabel.textColor = .white
                
                cell.contactSupportBtn.tag = indexPath.row
                cell.contactSupportBtn.addTarget(self, action: #selector(contactsupprtBtnTapped), for: .touchUpInside)
                
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                return cell
            }
        }
        else
        {
            if((getpreviousReservationquery.count > 0) && (getpreviousReservationquery[indexPath.row].listData != nil))
            {

            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                if let hostImg = getpreviousReservationquery[indexPath.row].hostData?.picture{
                    cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(hostImg)"), placeholderImage: #imageLiteral(resourceName: "unknown"), completed: nil)
                }
                else {
                    cell.userImg.image = #imageLiteral(resourceName: "unknown")
                }
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type:getpreviousReservationquery[indexPath.row].reservationState != nil ? getpreviousReservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getpreviousReservationquery[indexPath.row].reservationState != nil ? getpreviousReservationquery[indexPath.row].reservationState!.firstUppercased : "")
                
                cell.listTitleLable.text = getpreviousReservationquery[indexPath.row].listData?.title ?? ""
                cell.titleBtn.tag = indexPath.row
                cell.titleBtn.addTarget(self, action: #selector(listpreviousBtnTapped(_:)), for: .touchUpInside)
                let str = cell.listTitleLable.text
                if str!.count > 25{
                    cell.heightConstraints.constant = 50
                }
                else {
                    cell.heightConstraints.constant = 25
                }
                
                if(getpreviousReservationquery[indexPath.row].hostData?.fullPhoneNumber != nil && getpreviousReservationquery[indexPath.row].hostData?.fullPhoneNumber != "" && ((getpreviousReservationquery[indexPath.row].reservationState! == "approved") || (getpreviousReservationquery[indexPath.row].reservationState! == "completed"))) {
                    
                    cell.btnPhoneno.isHidden = false
                cell.btnPhoneno.setTitle(getpreviousReservationquery[indexPath.row].hostData?.fullPhoneNumber, for:.normal)
                    cell.phoneNoHeight.constant = 21
                    cell.phoneTop.constant = 5
                }
                else {
                    cell.phoneNoHeight.constant = 0
                    cell.phoneTop.constant = 0
                    cell.btnPhoneno.isHidden = true
                }
                
                
               
    
            
                
                if(getpreviousReservationquery[indexPath.row].hostUser?.email != nil && getpreviousReservationquery[indexPath.row].hostUser?.email != "") {
                    cell.btnEmail.isHidden = false
                    cell.emailHeightConstant.constant = 21
                    if cell.btnPhoneno.isHidden {
                        cell.dateTop.constant = 3
                    }
                    else {
                        cell.dateTop.constant = 5
                    }
                cell.btnEmail.setTitle(getpreviousReservationquery[indexPath.row].hostUser?.email, for:.normal)
                    
                }
                else {
                    cell.btnEmail.isHidden = true
                    cell.dateTop.constant = 0
                    cell.emailHeightConstant.constant = 0
                   
                }
                
                
                
                cell.addressLAbel.text = "\(getpreviousReservationquery[indexPath.row].listData?.street ?? ""),\((getpreviousReservationquery[indexPath.row].listData?.city != nil ? ((getpreviousReservationquery[indexPath.row].listData?.city!)!) : "")),\((getpreviousReservationquery[indexPath.row].listData?.state != nil ? ((getpreviousReservationquery[indexPath.row].listData?.state!)!) : "")),\((getpreviousReservationquery[indexPath.row].listData?.country != nil ? ((getpreviousReservationquery[indexPath.row].listData?.country!)!) : "")),\((getpreviousReservationquery[indexPath.row].listData?.zipcode != nil ? ((getpreviousReservationquery[indexPath.row].listData?.zipcode!)!) : ""))"
                
                let inday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                let indate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                let outday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                let outdate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                cell.dateLabel.text = "(\(indate) - \(outdate))"
                
                
                cell.nameLabel.text = getpreviousReservationquery[indexPath.row].hostData?.firstName ?? ""
                
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = getpreviousReservationquery[indexPath.row].currency!
                    let total = Double(getpreviousReservationquery[indexPath.row].total!) + Double(getpreviousReservationquery[indexPath.row].guestServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                     cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                   
                }
                else
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                    let from_currency = getpreviousReservationquery[indexPath.row].currency!
                    let total = Double(getpreviousReservationquery[indexPath.row].total!) + Double(getpreviousReservationquery[indexPath.row].guestServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                }
    
                cell.moreBtn.tag = indexPath.row
                cell.moreBtn.addTarget(self, action: #selector(previousmoreBtnTapped(_:)), for: .touchUpInside)
                cell.btnPhoneno.tag = indexPath.row
                cell.btnEmail.tag = indexPath.row
               
             
                cell.btnEmail.addTarget(self, action: #selector(previousemailBtnTapped), for: .touchUpInside)
                cell.btnPhoneno.addTarget(self, action: #selector(previousphoneBtnTapped), for: .touchUpInside)
                if  Utility.shared.isreceiptAccepted == true{
                }
                return cell
            }
            else  if((getpreviousReservationquery.count > 0) && (getpreviousReservationquery[indexPath.row].listData == nil))
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nolistTripsCell", for: indexPath)as! nolistTripsCell

                if(getpreviousReservationquery.count > 0)
                {
                cell.selectionStyle = .none
                    cell.nolistLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)"
                    cell.nolistLabel.textColor  = Theme.Button_BG
                let inday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                let indate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                let outday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                let outdate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                    cell.dateLabel.text = "(\(indate) - \(outdate))"
                    
                    cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type:getpreviousReservationquery[indexPath.row].reservationState != nil ? getpreviousReservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getpreviousReservationquery[indexPath.row].reservationState!.firstUppercased)
                    
                cell.contactSupportBtn.tag = indexPath.row
                cell.contactSupportBtn.addTarget(self, action: #selector(previouscontactsupprtBtnTapped), for: .touchUpInside)
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                    cell.selectionStyle = .none
                    
                    cell.addressLAbel.numberOfLines = 2
                    cell.listTitleLable.numberOfLines = 2
                return cell
            }
        }
    }
    
    @objc func phoneBtnTapped(_ sender: UIButton)
    {
        
        if(getallreservationquery.count > sender.tag && Utility.shared.phoneBtnTapped == false)
        {
            let phoneno = "\(getallreservationquery[sender.tag].hostData?.fullPhoneNumber ?? "")"
            
            if let url = URL(string: "tel://\(phoneno)") {
                Utility.shared.phoneBtnTapped = true
                UIApplication.shared.openURL(url)
            }
             
        }
        
    }

    
    @objc func emailBtnTapped(_ sender: UIButton)
    {
        if(getallreservationquery.count > sender.tag)
        {
            let receip = "\(getallreservationquery[sender.tag].hostUser?.email ?? "")"
             let toRecipents = [receip]
            if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
           
          
            
             mc.setToRecipients(toRecipents)
            
            self.present(mc, animated: true, completion: nil)
            }
            else
            {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"mailalert"))!)")
               
               
            }
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        switch result {
        case MFMailComposeResult.cancelled:
          
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved:
           
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.sent:
          
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"emailalert"))!)")
            controller.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed: break
          
        default:
            break
        }
    
    }
    @objc func previousemailBtnTapped(_ sender: UIButton)
    {
        let receip = "\(getpreviousReservationquery[sender.tag].hostUser?.email ?? "")"
         let toRecipents = [receip]
        if MFMailComposeViewController.canSendMail() {
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
       
      
        
         mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
        }
        else
        {
        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"mailalert"))!)")
           
           
        }
    }
    @objc func previousphoneBtnTapped(_ sender: UIButton)
    {
        
        
        
        
        let phoneno = "\(getpreviousReservationquery[sender.tag].hostData?.fullPhoneNumber ?? "")"
        if #available(iOS 10, *) {
            
            if let url = URL(string: "tel://\(phoneno)") {
                UIApplication.shared.open(url)
            }
            
        } else {
            if let url = URL(string: "tel://\(phoneno)") {
                UIApplication.shared.openURL(url)
            }
        }
 
        
    }
    
    @objc func moreBtnTapped(_ sender: UIButton)
    {
        if(getallreservationquery.count > sender.tag)
        {
            
            if((getallreservationquery[sender.tag].reservationState! == "cancelled") || (getallreservationquery[sender.tag].reservationState! == "expired"))
            {
           
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            }
            else if (getallreservationquery[sender.tag].reservationState! == "declined") {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            }
            else if((getallreservationquery[sender.tag].reservationState! == "pending") &&  ((getallreservationquery[sender.tag].listData?.bookingType! == "request") || (getallreservationquery[sender.tag].listData?.bookingType! == "instant")))
            {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            }
            else if ((getallreservationquery[sender.tag].reservationState! == "completed"))
                {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
                
                }
            else
            {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"View_Itinerary"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)","\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Itinery"),#imageLiteral(resourceName: "Receipt"),#imageLiteral(resourceName: "Cancel")]
                
                
            }
            
            let configuration = FTConfiguration()
            configuration.backgoundTintColor = UIColor(named: "colorController")!
            configuration.menuSeparatorColor = UIColor(named: "colorController")!
            configuration.textColor = UIColor(named: "Title_Header")!
            configuration.cornerRadius = 5
            configuration.menuWidth = 130
            configuration.menuIconSize = 15.0
            configuration.borderColor = Theme.descriptionBorder_Color
            
            FTPopOverMenu.showForSender(sender: sender,
                                        with: menuOptionNameArray, menuImageArray: menuOprionImageArray,
                                        config: configuration,
                                        done: { (selectedIndex) in
               
                if(self.menuOptionNameArray.count == 2)
                {
                    if(selectedIndex == 0)
                    {
                        self.messageBtnTapped(sender)
                       
                    }
                    else
                    {
                        if(self.menuOptionNameArray[1] == "\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)")
                        {

                            self.cancelBtnTapped(sender)
                        }
                        else
                        {
                            self.ReceiptBtnTapped(sender)
                        }

                    }
                }
                else if(self.menuOptionNameArray.count == 1)
                 {
                     if(selectedIndex == 0)
                     {

                         self.ReceiptPreviousBtnTapped(sender)
                     }
                     else
                     {
                         self.ReceiptPreviousBtnTapped(sender)
                         
                     }
                 }
                else if(self.menuOptionNameArray.count == 4)
                {
                    if(selectedIndex == 0)
                    {
                        self.messageBtnTapped(sender)
                    }
                    else  if(selectedIndex == 1){
                       
                        self.IteneraryBtnTapped(sender)
                    }
                    else  if(selectedIndex == 2){
                        self.ReceiptBtnTapped(sender)
                       
                    }
                    else
                    {
                        self.cancelBtnTapped(sender)

                    }
                }


            },
                                        cancel: {
               
            })
        }
    }
    
    @objc func previousmoreBtnTapped(_ sender: UIButton)
    {
        if getpreviousReservationquery.count > sender.tag {
            
            if((getpreviousReservationquery[sender.tag].reservationState! == "cancelled")  || (getpreviousReservationquery[sender.tag].reservationState! == "expired"))
            {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
             
            }
            else if (getpreviousReservationquery[sender.tag].reservationState! == "declined") {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            }
            else if((getpreviousReservationquery[sender.tag].reservationState! == "pending") &&  (getpreviousReservationquery[sender.tag].listData?.bookingType! == "request"))
            {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            
            }
            else if(getpreviousReservationquery[sender.tag].reservationState! == "approved")
            {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"View_Itinerary"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Itinery"),#imageLiteral(resourceName: "Receipt")]
              
            }
            else if ((getpreviousReservationquery[sender.tag].reservationState! == "completed"))
            {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)",]
                
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
                
            }
            else
            {
                
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"View_Itinerary"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)","\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Itinery"),#imageLiteral(resourceName: "Receipt"),#imageLiteral(resourceName: "Cancel")]
            }
            
            
            let configuration = FTConfiguration()
            configuration.backgoundTintColor = UIColor(named: "colorController")!
            configuration.menuSeparatorColor = UIColor(named: "colorController")!
            configuration.textColor = UIColor(named: "Title_Header")!
            configuration.cornerRadius = 5
            configuration.menuWidth = 130
            configuration.menuIconSize = 15.0
            configuration.borderColor = Theme.descriptionBorder_Color
            
            FTPopOverMenu.showForSender(sender: sender,
                                        with: menuOptionNameArray, menuImageArray: menuOprionImageArray,
                                        config: configuration,
                                        done: { (selectedIndex) in
              
                if(self.menuOptionNameArray.count == 2)
                {
                    if(selectedIndex == 0)
                    {
                        
                        self.messagePreviousBtnTapped(sender)
                    }
                    else
                    {
                        self.ReceiptPreviousBtnTapped(sender)
                        
                    }
                }
                else if(self.menuOptionNameArray.count == 1)
                {
                    if(selectedIndex == 0)
                    {
                        
                        self.ReceiptPreviousBtnTapped(sender)
                    }
                    else
                    {
                        self.ReceiptPreviousBtnTapped(sender)
                        
                    }
                }
                else if(self.menuOptionNameArray.count == 4)
                {
                    if(selectedIndex == 0)
                    {
                        self.messagePreviousBtnTapped(sender)
                        
                    }
                    else  if(selectedIndex == 1){
                        self.IteneraryPreviousBtnTapped(sender)
                    }
                    else  if(selectedIndex == 2){
                        self.ReceiptPreviousBtnTapped(sender)
                        
                    }
                    else
                    {
                        self.previouscancelBtnTapped(sender)
                        
                    }
                }
                
            },
           cancel: {
              
            })
        }
    }
    
    
    @objc func contactsupprtBtnTapped(_ sender: UIButton){
         if Utility().isConnectedToNetwork(){
        let contactSupportObj = ContactusVC()
        if(getallreservationquery.count>0)
        {
            contactSupportObj.Listid = getallreservationquery[sender.tag].listId != nil ? getallreservationquery[sender.tag].listId! : 0
            contactSupportObj.reservationid = getallreservationquery[sender.tag].id != nil ? getallreservationquery[sender.tag].id! : 0
            contactSupportObj.modalPresentationStyle = .overFullScreen
        self.present(contactSupportObj, animated:false, completion: nil)
            }
        }
         else{
            self.view.addSubview(offlineView)
            self.upcomingTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    @objc func previouscontactsupprtBtnTapped(_ sender: UIButton)
    {
        if Utility().isConnectedToNetwork(){
        let contactSupportObj = ContactusVC()
        if(getpreviousReservationquery.count > 0)
        {
            contactSupportObj.Listid = getpreviousReservationquery[sender.tag].listId != nil ? getpreviousReservationquery[sender.tag].listId! : 0
            contactSupportObj.reservationid = getpreviousReservationquery[sender.tag].id != nil ? getpreviousReservationquery[sender.tag].id! : 0
            contactSupportObj.modalPresentationStyle = .overFullScreen
        self.present(contactSupportObj, animated: false, completion: nil)
            }
        }
        else{
            self.view.addSubview(offlineView)
            self.previousTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    @objc func cancelBtnTapped(_ sender: UIButton)
    {
         if Utility().isConnectedToNetwork(){
            if(getallreservationquery.count > 0)
            {
            
        let cancelObj = TripsCancelVC()
        cancelObj.listID = getallreservationquery[sender.tag].listId!
        var currency = String()
        
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                {
        currency = Utility.shared.getPreferredCurrency()!
        }
        else{
          currency = Utility.shared.currencyvalue_from_API_base
        }
        cancelObj.checkinDate =  getdateValueCancel(timestamp: getallreservationquery[sender.tag].checkIn!)
        cancelObj.checkoutDate = getdateValueCancel(timestamp: getallreservationquery[sender.tag].checkOut!)
               
                cancelObj.profileId = getallreservationquery[sender.tag].hostData?.profileId ?? 0
        cancelObj.getcancellationAPICall(reservationId: getallreservationquery[sender.tag].id!, userType: GUEST, currency: currency)
        Utility.shared.host_cancel_isfromCancel = false
        cancelObj.modalPresentationStyle = .fullScreen
        self.present(cancelObj, animated: true, completion: nil)
            }
        }
         else{
            self.view.addSubview(offlineView)
            self.upcomingTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    @objc func previouscancelBtnTapped(_ sender: UIButton)
    {
        if Utility().isConnectedToNetwork(){
        
        let cancelObj = TripsCancelVC()
            cancelObj.listID = getpreviousReservationquery[sender.tag].listId != nil ? getpreviousReservationquery[sender.tag].listId! : 0
        var currency = String()
        
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
            currency = Utility.shared.getPreferredCurrency()!
        }
        else{
            currency = Utility.shared.currencyvalue_from_API_base
        }
        cancelObj.checkinDate = checkinDate
        cancelObj.checkoutDate = checkoutDate
            cancelObj.profileId = getpreviousReservationquery[sender.tag].hostData?.profileId ?? 0
            cancelObj.getcancellationAPICall(reservationId:getpreviousReservationquery[sender.tag].id != nil ? getpreviousReservationquery[sender.tag].id! : 0, userType:GUEST, currency: currency)
        Utility.shared.host_cancel_isfromCancel = false
        cancelObj.modalPresentationStyle = .fullScreen
        self.present(cancelObj, animated: true, completion: nil)
        }
        else{
            self.view.addSubview(offlineView)
            self.previousTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    @objc func ReceiptPreviousBtnTapped(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false

        if(getpreviousReservationquery.count > 0)
        {
            self.createReservationAPICall(reservationid:getpreviousReservationquery[sender.tag].id != nil ? getpreviousReservationquery[sender.tag].id! : 0, senderBtn: sender)
        }
    }
    
    @objc func ReceiptBtnTapped(_ sender: UIButton)
    {
        sender.isMultipleTouchEnabled = false
        sender.isExclusiveTouch = true
        sender.isUserInteractionEnabled = false
       if(getallreservationquery.count > 0)
       {
        self.createReservationAPICall(reservationid:getallreservationquery[sender.tag].id != nil ? getallreservationquery[sender.tag].id! : 0, senderBtn: sender)
        }
    }
    @objc func IteneraryPreviousBtnTapped(_ sender: UIButton)
    {
        Utility.shared.isfromTripsPage = true
        if(getpreviousReservationquery.count > 0)
        {
            self.getReservationAPICall(reservationid:getpreviousReservationquery[sender.tag].id != nil ? getpreviousReservationquery[sender.tag].id! : 0)
        }
    }
    
    @objc func IteneraryBtnTapped(_ sender: UIButton)
    {
        Utility.shared.isfromTripsPage = true
        if(getallreservationquery.count > 0)
        {
            self.getReservationAPICall(reservationid:getallreservationquery[sender.tag].id != nil ? getallreservationquery[sender.tag].id! : 0)
        }
    }
    @objc func messageBtnTapped(_ sender: UIButton)
    {
         if Utility().isConnectedToNetwork(){
        if(getallreservationquery.count > 0)
        {
        let InboxListingObj = InboxListingVC()
            Utility.shared.ListID = "\(getallreservationquery[sender.tag].listId != nil ? getallreservationquery[sender.tag].listId! : 0)"
            InboxListingObj.threadId = (getallreservationquery[sender.tag].messageData?.id != nil ? getallreservationquery[sender.tag].messageData?.id! : 0)!
        InboxListingObj.getmessageListquery.removeAll()
            InboxListingObj.getMessageListAPICall(threadId:(getallreservationquery[sender.tag].messageData?.id) != nil ? ((getallreservationquery[sender.tag].messageData?.id)!) : 0)
           InboxListingObj.modalPresentationStyle = .fullScreen
        self.present(InboxListingObj, animated: true, completion: nil)
        }
        }
         else{
            self.view.addSubview(offlineView)
            self.upcomingTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    @objc func messagePreviousBtnTapped(_ sender: UIButton)
    {
         if Utility().isConnectedToNetwork(){
        if(getpreviousReservationquery.count > 0)
        {
        let InboxListingObj = InboxListingVC()
            Utility.shared.ListID = "\(getpreviousReservationquery[sender.tag].listId != nil ? getpreviousReservationquery[sender.tag].listId! : 0)"
            InboxListingObj.threadId = (getpreviousReservationquery[sender.tag].messageData?.id) != nil ? ((getpreviousReservationquery[sender.tag].messageData?.id)!) : 0
            InboxListingObj.getMessageListAPICall(threadId:(getpreviousReservationquery[sender.tag].messageData?.id) != nil ?  ((getpreviousReservationquery[sender.tag].messageData?.id)!) : 0)
          InboxListingObj.modalPresentationStyle = .fullScreen
        self.present(InboxListingObj, animated: true, completion: nil)
            }
         }
        else{
            self.view.addSubview(offlineView)
            self.previousTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    
    func getdateValue(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
             dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = guestTripsDateFormat
        let date = dateFormatter.string(from: showDate)
            return date } else {
            return Utility.shared.getdateformatter(date: timestamp) }
    }
    func getdateValueCancel(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
             dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = itenararyReceiptDateFormat

        let date = dateFormatter.string(from: showDate)
            return date } else {
            return Utility.shared.getdateformatter(date: timestamp) }
    }
   
    func getdayValue(timestamp:String) -> String
    {
        if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter1 = DateFormatter()
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter1.dateFormat = "EEE"

        let day = dateFormatter1.string(from: showDate)
            return day } else {
            return Utility.shared.getdateformatter1(date: timestamp) }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if Utility().isConnectedToNetwork(){
        if(isupcomingTable)
        {
        let totalPages = (self.totalListcount/10)
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if((self.upcomingTable.contentOffset.y + self.upcomingTable.bounds.height) >= self.upcomingTable.contentSize.height)
        {
          
            if(totalPages >= PageIndex){
                self.PageIndex = self.PageIndex + 1
                self.getTripsAPICall()
                
            }
        }
        }
        else
        {
            let totalPages = (self.previoustotalListcount/10)
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if((self.previousTable.contentOffset.y + self.previousTable.bounds.height) >= self.previousTable.contentSize.height)
            {
                
                if(totalPages >= previousPageIndex){
                    self.previousPageIndex = self.previousPageIndex + 1
                    self.previousTripsAPICall()
                    
                }
            }
        }
        }
        else{
            self.upcomingTable.isHidden = true
            self.view.addSubview(offlineView)
            self.previousTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    
    func createReservationAPICall(reservationid:Int, senderBtn: UIButton)
    {
        if Utility().isConnectedToNetwork(){
            var currency = String()
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
            {
                currency = Utility.shared.getPreferredCurrency()!
            }
            else
            {
                currency = Utility.shared.currencyvalue_from_API_base
            }
        let createReservationquery = GetReservationQueryy(reservationId: reservationid,convertCurrency:currency)
        apollo_headerClient.fetch(query: createReservationquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getReservation?.results) != nil else{
               
                self.view.makeToast(result?.data?.getReservation?.errorMessage)
                senderBtn.isUserInteractionEnabled = true
                return
            }
            self.getReservationArray = (result?.data?.getReservation?.results)!
            self.getReservation_currencyArray = (result?.data?.getReservation!)!
            if #available(iOS 11.0, *) {
                let receiptPageObj = ReceiptVC()
                 Utility.shared.host_isfrom_hostRecipt = false
                receiptPageObj.getReservation_currencyArray = self.getReservation_currencyArray
                receiptPageObj.getReservationArray = self.getReservationArray
               receiptPageObj.modalPresentationStyle = .overFullScreen
                senderBtn.isUserInteractionEnabled = true
                self.view.window?.rootViewController?.present(receiptPageObj, animated:false, completion: nil)
              
            } else {
                senderBtn.isUserInteractionEnabled = true
            }
        }
        }
        else{
            self.view.addSubview(offlineView)
            self.upcomingTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-108, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    func getReservationAPICall(reservationid:Int)
    {
         if Utility().isConnectedToNetwork(){
             var currency = String()
             if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
             {
                 currency = Utility.shared.getPreferredCurrency()!
             }
             else
             {
                 currency = Utility.shared.currencyvalue_from_API_base
             }
         let createReservationquery = GetReservationQueryy(reservationId: reservationid,convertCurrency:currency)
         apollo_headerClient.fetch(query: createReservationquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
             guard (result?.data?.getReservation?.results) != nil else{
               
                 self.view.makeToast(result?.data?.getReservation?.errorMessage)
                
                 return
             }
            self.getReservationArray = (result?.data?.getReservation?.results)!
            self.getReservation_currencyArray = (result?.data?.getReservation!)!
            if #available(iOS 11.0, *) {
                let receiptPageObj = BookingItenaryVC()
                receiptPageObj.isFromReviewPage = false
                receiptPageObj.getReservation_currencyArray = self.getReservation_currencyArray
                receiptPageObj.getReservationArray = self.getReservationArray
                  receiptPageObj.modalPresentationStyle = .fullScreen
                self.present(receiptPageObj, animated: true, completion: nil)
            } else {
               
            }
        }
        }
         else{
             previousTable.isSkeletonable = true
             previousTable.showAnimatedGradientSkeleton()
             upcomingTable.isSkeletonable = true
             upcomingTable.showAnimatedGradientSkeleton()

            self.view.addSubview(offlineView)
            self.upcomingTable.bringSubviewToFront(offlineView)
            self.offlineView.isHidden = false
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
     @objc func listBtnTapped(_ sender: UIButton){
        if(getallreservationquery.count > 0)
        {
            let viewListing = UpdatedViewListing()
            viewListing.listID = getallreservationquery[sender.tag].listId ?? 0
            Utility.shared.unpublish_preview_check = false
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    @objc func listpreviousBtnTapped(_ sender: UIButton){
        if(getpreviousReservationquery.count > 0)
        {
            let viewListing = UpdatedViewListing()
            viewListing.listID = getpreviousReservationquery[sender.tag].listId ?? 0
            Utility.shared.unpublish_preview_check = false
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier{
       
        return "TripsCell"
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell = skeletonView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
        cell.addressLAbel.numberOfLines = 1
        cell.listTitleLable.numberOfLines = 1
        return cell
    }

}

