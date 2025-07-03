
import UIKit
import Apollo
import Lottie
import SkeletonView
import SwiftMessages
import MessageUI

class HostProgressVC: UIViewController,UITableViewDelegate,UITableViewDataSource, SkeletonTableViewDataSource,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var reservationTitleLbl: UILabel!
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
    @IBOutlet weak var headerLineView: UIView!
    
    var lottieView: LottieAnimationView!
    var getallreservationquery = [GetAllReservationQuery.Data.GetAllReservation.Result]()
    var getpreviousReservationquery = [GetAllReservationQuery.Data.GetAllReservation.Result]()
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    var getReservationArray = GetReservationQueryy.Data.GetReservation.Result()
    var getReservationArrayyy = GetReservationQueryy.Data.GetReservation()
    var getReservation_currencyArray = GetReservationQueryy.Data.GetReservation()
    var checkinDate = String()
    var checkoutDate = String()
    
    var totalListcount:Int = 0
    var PageIndex : Int = 1
    var previoustotalListcount:Int = 0
    var previousPageIndex : Int = 1
    var isupcomingTable:Bool = true
    var previousEnabled:Bool = false
    var isSkeletable:Bool = true
    var menuOptionNameArray = [String]()
    var menuOprionImageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        lottieView = LottieAnimationView.init(name:"animation")
        upcomingTable.estimatedRowHeight = 50
        previousTable.estimatedRowHeight = 50
        self.initialsetup()
        self.lottieAnimation()
        self.view.backgroundColor =   UIColor(named: "colorController")
        previousTable.backgroundColor = UIColor(named: "colorController")
        upcomingTable.backgroundColor = UIColor(named: "colorController")
        reservationTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "My_Reservation") ?? "My reservations")"
        reservationTitleLbl.textColor = UIColor(named: "Title_Header")
        reservationTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        reservationTitleLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerLineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if previousEnabled == false{
            self.previousTable.isHidden = true
            self.upcomingTable.isHidden = false
            upcomingLabel.isHidden = false
            previousLabel.isHidden = true
            self.getallreservationquery.removeAll()
            PageIndex = 1
            self.getTripsAPICall()
        } else {
            self.previousTable.isHidden = false
            self.upcomingTable.isHidden = true
            upcomingLabel.isHidden = true
            previousLabel.isHidden = false
            self.getpreviousReservationquery.removeAll()
            previousPageIndex = 1
            self.previousTripsAPICall()
        }
    }
    
    func initialsetup() {
        upcomingBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        previousBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        startLabel.font = UIFont(name: APP_FONT, size: 14)
        startLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        previousLabel.isHidden = true
        upcomingLabel.isHidden = false
        upcomingLabel.backgroundColor = Theme.PRIMARY_COLOR
        previousLabel.backgroundColor = UIColor.clear
        previousBtn.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        upcomingBtn.setTitleColor( UIColor(named: "Title_Header"), for: .normal)
        previousTable.register(UINib(nibName: "TripsCell", bundle: nil), forCellReuseIdentifier: "TripsCell")
        upcomingTable.register(UINib(nibName: "TripsCell", bundle: nil), forCellReuseIdentifier: "TripsCell")
        previousTable.register(UINib(nibName: "nolistTripsCell", bundle: nil), forCellReuseIdentifier: "nolistTripsCell")
        upcomingTable.register(UINib(nibName: "nolistTripsCell", bundle: nil), forCellReuseIdentifier: "nolistTripsCell")
        self.isSkeletable = true
        upcomingTable.updateAnimatedGradientSkeleton()
        previousTable.updateAnimatedGradientSkeleton()
        previousTable.isSkeletonable = false
        upcomingTable.isSkeletonable = false
        previousTable.hideSkeleton()
        upcomingTable.isSkeletonable = true
        upcomingTable.showAnimatedGradientSkeleton()
        self.WhereView.isHidden = true
        self.offlineView.isHidden = true
        self.startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"noupcoming"))!)"
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        upcomingBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"upcoming"))!)", for: .normal)
        previousBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"previous"))!)", for: .normal)
    }
    
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = true
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        self.offlineView.isHidden = true
    }
    
    @IBAction func preiousBtnTapped(_ sender: Any) {
        self.lottieAnimation()
        previousEnabled = true
        isupcomingTable = false
        upcomingBtn.isUserInteractionEnabled = true
        previousBtn.isUserInteractionEnabled = false
        previousBtn.setTitleColor( UIColor(named: "Title_Header"), for: .normal)
        upcomingBtn.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        previousLabel.isHidden = false
        upcomingLabel.isHidden = true
        upcomingLabel.backgroundColor = UIColor.clear
        previousLabel.backgroundColor = Theme.PRIMARY_COLOR
        self.upcomingTable.isHidden = true
        self.previousTable.isHidden = false
        
        if(getpreviousReservationquery.count == 0) {
            previousPageIndex = 1
            previousTable.isSkeletonable = true
            previousTable.showAnimatedGradientSkeleton()
            self.previousTripsAPICall()
            previousTable.reloadData()
        }
    }
    
    @IBAction func upcomingBtnTapped(_ sender: Any) {
        self.lottieAnimation()
        previousEnabled = false
        isupcomingTable = true
        upcomingLabel.backgroundColor = Theme.PRIMARY_COLOR
        previousLabel.backgroundColor =  UIColor.clear
        self.upcomingTable.isHidden = false
        previousBtn.isUserInteractionEnabled = true
        previousLabel.isHidden = true
        
        if(offlineView.isHidden) {
            if(getallreservationquery.count>0) {
                self.WhereView.isHidden = true
                self.upcomingTable.isHidden = false
            } else {
                self.lottieView.isHidden = true
                self.WhereView.isHidden = false
                self.upcomingTable.isHidden = true
                self.startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"noupcoming"))!)"
            }
            self.isSkeletable = false
        } else {
            self.isSkeletable = true
            upcomingTable.isSkeletonable = false
            upcomingTable.updateAnimatedGradientSkeleton()
            upcomingTable.isSkeletonable = true
            upcomingTable.showAnimatedGradientSkeleton()
        }
        
        self.upcomingTable.reloadData()
        upcomingBtn.setTitleColor( UIColor(named: "Title_Header"), for: .normal)
        previousBtn.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        self.previousTable.isHidden = true
        upcomingLabel.isHidden = false
    }
    
    @objc func autoscroll(){
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            self.lottieAnimation()
            self.GetDefaultSettingAPICall()
            self.offlineView.isHidden = true
            self.getallreservationquery.removeAll()
            self.getpreviousReservationquery.removeAll()
            if(isupcomingTable) {
                self.getTripsAPICall()
            } else {
                self.previousTripsAPICall()
            }
        }
    }
    
    func getTripsAPICall() {
        if Utility().isConnectedToNetwork(){
            let getallreservationQuery = GetAllReservationQuery(userType: "host", currentPage:PageIndex, dateFilter: "upcoming")
            apollo_headerClient.fetch(query:getallreservationQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.getAllReservation?.result) != nil else{
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
                        self.upcomingTable.isHidden = true
                        self.WhereView.isHidden = false
                    }
                    else{
                        self.upcomingTable.isHidden = false
                        self.WhereView.isHidden = true
                    }
                    return
                }
                self.totalListcount = (result?.data?.getAllReservation?.count != nil ? ((result?.data?.getAllReservation?.count)!) : 0)
                self.getallreservationquery.append(contentsOf: ((result?.data?.getAllReservation?.result)!) as! [GetAllReservationQuery.Data.GetAllReservation.Result])
                self.isSkeletable = false
                self.upcomingTable.hideSkeleton()
                self.upcomingTable.isHidden = false
                self.lottieView.isHidden = true
                self.upcomingTable?.reloadData()
            }
        } else {
            self.view.addSubview(offlineView)
            upcomingTable.updateAnimatedGradientSkeleton()
            upcomingTable.isSkeletonable = true
            upcomingTable.showAnimatedGradientSkeleton()
            self.isSkeletable = true
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
    
    func previousTripsAPICall() {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            let getallreservationQuery = GetAllReservationQuery(userType: "host", currentPage:previousPageIndex, dateFilter: "previous")
            apollo_headerClient.fetch(query:getallreservationQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                if(result?.data?.getAllReservation?.status == 200) {
                    self.previoustotalListcount = (result?.data?.getAllReservation?.count != nil ? (result?.data?.getAllReservation?.count!)! : 0)
                    self.getpreviousReservationquery.append(contentsOf: ((result?.data?.getAllReservation?.result)!) as! [GetAllReservationQuery.Data.GetAllReservation.Result])
                    
                    if(self.upcomingLabel.isHidden == false && self.getallreservationquery.count == 0) {
                        self.WhereView.isHidden = false
                        self.startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"noprevious"))!)"
                    } else {
                        self.WhereView.isHidden = true
                    }
                    self.isSkeletable = false
                    self.previousTable.hideSkeleton()
                    self.previousTable?.reloadData()
                } else {
                    if(self.getpreviousReservationquery.count == 0 && self.previousEnabled == true) {
                        self.isSkeletable = false
                        self.previousTable.hideSkeleton()
                        self.upcomingTable.isHidden = true
                        self.previousTable.isHidden = true
                        self.lottieView.isHidden = true
                        self.WhereView.isHidden = false
                        self.startLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"noprevious"))!)"
                    }
                }
            }
        } else {
            self.view.addSubview(offlineView)
            self.previousTable.bringSubviewToFront(offlineView)
            previousTable.updateAnimatedGradientSkeleton()
            previousTable.isSkeletonable = true
            self.isSkeletable = true
            previousTable.showAnimatedGradientSkeleton()
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
        if(tableView == upcomingTable) {
            if(getallreservationquery.count > 0) {
                return getallreservationquery.count
            }
            return 0
        } else {
            if(getpreviousReservationquery.count > 0) {
                return getpreviousReservationquery.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == upcomingTable) {
            if((getallreservationquery.count > 0) && (getallreservationquery[indexPath.row].listData != nil)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type: getallreservationquery[indexPath.row].reservationState != nil ? getallreservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getallreservationquery[indexPath.row].reservationState != nil ? getallreservationquery[indexPath.row].reservationState!.firstUppercased : "")
                
                cell.listTitleLable.text = getallreservationquery[indexPath.row].listData?.title ?? ""
                cell.titleBtn.tag = indexPath.row
                cell.titleBtn.addTarget(self, action: #selector(listBtnTapped(_:)), for: .touchUpInside)
                
                let str = cell.listTitleLable.text
                if str!.count > 35{
                    cell.heightConstraints.constant = 50
                }
                else {
                    cell.heightConstraints.constant = 25
                }
                if(getallreservationquery[indexPath.row].guestData?.fullPhoneNumber != nil && getallreservationquery[indexPath.row].guestData?.fullPhoneNumber != "" && ((getallreservationquery[indexPath.row].reservationState! == "approved") || (getallreservationquery[indexPath.row].reservationState! == "completed"))) {
                    cell.btnPhoneno.isHidden = false
                    cell.btnPhoneno.setTitle(getallreservationquery[indexPath.row].guestData?.fullPhoneNumber, for:.normal)
                    cell.phoneNoHeight.constant = 21
                    cell.phoneTop.constant = 5
                } else {
                    cell.phoneNoHeight.constant = 0
                    cell.phoneTop.constant = 0
                    cell.btnPhoneno.isHidden = true
                }
                if(getallreservationquery[indexPath.row].guestUser?.email != nil && getallreservationquery[indexPath.row].guestUser?.email != "") {
                    cell.btnEmail.isHidden = false
                    cell.emailHeightConstant.constant = 21
                    if cell.btnPhoneno.isHidden {
                        cell.dateTop.constant = 3
                    } else {
                        cell.dateTop.constant = 5
                    }
                    cell.btnEmail.setTitle(getallreservationquery[indexPath.row].guestUser?.email, for:.normal)
                    
                } else {
                    cell.btnEmail.isHidden = true
                    cell.dateTop.constant = 0
                    cell.emailHeightConstant.constant = 0
                    
                }
                cell.addressLAbel.text = "\(getallreservationquery[indexPath.row].listData?.street != nil ? ((getallreservationquery[indexPath.row].listData?.street!)!) : ""),\(getallreservationquery[indexPath.row].listData?.city != nil ? ((getallreservationquery[indexPath.row].listData?.city!)!) : ""), \(getallreservationquery[indexPath.row].listData?.state != nil ? ((getallreservationquery[indexPath.row].listData?.state!)!) : ""), \(getallreservationquery[indexPath.row].listData?.country != nil ? ((getallreservationquery[indexPath.row].listData?.country!)!) : "") \(getallreservationquery[indexPath.row].listData?.zipcode != nil ? ((getallreservationquery[indexPath.row].listData?.zipcode!)!) : "")"
                
                let inday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                checkinDate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                let outday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                checkoutDate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                cell.dateLabel.text = "(\(checkinDate) - \(checkoutDate))"
                cell.nameLabel.text = getallreservationquery[indexPath.row].guestData?.firstName ?? ""
                
                if let hostImg = getallreservationquery[indexPath.row].guestData?.picture{
                    cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(hostImg)"), placeholderImage: #imageLiteral(resourceName: "unknown"), completed: nil)
                    cell.userImg.contentMode = .scaleAspectFill
                } else {
                    cell.userImg.image = #imageLiteral(resourceName: "unknown")
                }
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = getallreservationquery[indexPath.row].currency!
                    let total = Double(getallreservationquery[indexPath.row].total!) - Double(getallreservationquery[indexPath.row].hostServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                    
                } else {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                    let from_currency = getallreservationquery[indexPath.row].currency!
                    let total = Double(getallreservationquery[indexPath.row].total!) - Double(getallreservationquery[indexPath.row].hostServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                }
                cell.moreBtn.tag = indexPath.row
                cell.moreBtn.addTarget(self, action: #selector(moreBtnTapped), for: .touchUpInside)
                cell.btnPhoneno.tag = indexPath.row
                cell.btnEmail.tag = indexPath.row
                cell.btnEmail.addTarget(self, action: #selector(emailBtnTapped), for: .touchUpInside)
                cell.btnPhoneno.addTarget(self, action: #selector(phoneBtnTapped), for: .touchUpInside)
                return cell
                
            } else if((getallreservationquery.count > 0) && (getallreservationquery[indexPath.row].listData == nil)) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nolistTripsCell", for: indexPath)as! nolistTripsCell
                if(getallreservationquery.count > 0) {
                    cell.selectionStyle = .none
                    let inday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                    let indate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkIn!)
                    let outday = getdayValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                    let outdate = getdateValue(timestamp: getallreservationquery[indexPath.row].checkOut!)
                    cell.dateLabel.text = "(\(indate) - \(outdate))"
                    cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type:getallreservationquery[indexPath.row].reservationState != nil ? getallreservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                    cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getallreservationquery[indexPath.row].reservationState!.firstUppercased)
                    cell.contactSupportBtn.tag = indexPath.row
                    cell.contactSupportBtn.addTarget(self, action: #selector(contactsupprtBtnTapped), for: .touchUpInside)
                    cell.nolistLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)"
                    cell.nolistLabel.textColor  = Theme.Button_BG
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                return cell
            }
        } else {
            if((getpreviousReservationquery.count > 0) && (getpreviousReservationquery[indexPath.row].listData != nil)) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                if let hostImg = getpreviousReservationquery[indexPath.row].guestData?.picture{
                    cell.userImg.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(hostImg)"), placeholderImage: #imageLiteral(resourceName: "unknown"), completed: nil)
                    cell.userImg.contentMode = .scaleAspectFill
                } else {
                    cell.userImg.image = #imageLiteral(resourceName: "unknown")
                }
                cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type:getpreviousReservationquery[indexPath.row].reservationState != nil ? getpreviousReservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getpreviousReservationquery[indexPath.row].reservationState != nil ? getpreviousReservationquery[indexPath.row].reservationState!.firstUppercased : "")
                if(getpreviousReservationquery[indexPath.row].guestData?.fullPhoneNumber != nil && getpreviousReservationquery[indexPath.row].guestData?.fullPhoneNumber != ""  &&
                   ((getpreviousReservationquery[indexPath.row].reservationState! == "approved") || (getpreviousReservationquery[indexPath.row].reservationState! == "completed"))) {
                    
                    cell.btnPhoneno.isHidden  = false
                    cell.phoneNoHeight.constant = 21
                    
                    cell.phoneTop.constant = 5
                    cell.btnPhoneno.setTitle(getpreviousReservationquery[indexPath.row].guestData?.fullPhoneNumber, for:.normal)
                } else {
                    cell.phoneNoHeight.constant = 0
                    cell.phoneTop.constant = 0
                    cell.btnPhoneno.isHidden = true
                }
                
                if(getpreviousReservationquery[indexPath.row].guestUser?.email != nil && getpreviousReservationquery[indexPath.row].guestUser?.email != "") {
                    cell.btnEmail.isHidden = false
                    cell.btnEmail.setTitle(getpreviousReservationquery[indexPath.row].guestUser?.email, for:.normal)
                    if cell.btnPhoneno.isHidden {
                        cell.dateTop.constant = 3
                    } else {
                        cell.dateTop.constant = 5
                    }
                    cell.emailHeightConstant.constant = 21
                } else {
                    cell.btnEmail.isHidden = true
                    cell.dateTop.constant = 0
                    cell.emailHeightConstant.constant = 0
                }
                cell.listTitleLable.text = getpreviousReservationquery[indexPath.row].listData?.title ?? ""
                let str = cell.listTitleLable.text
                if str!.count > 35{
                    cell.heightConstraints.constant = 50
                } else {
                    cell.heightConstraints.constant = 25
                }
                cell.titleBtn.tag = indexPath.row
                cell.titleBtn.addTarget(self, action: #selector(listpreviousBtnTapped(_:)), for: .touchUpInside)
                
                cell.addressLAbel.text = "\(getpreviousReservationquery[indexPath.row].listData?.street ?? ""),\((getpreviousReservationquery[indexPath.row].listData?.city != nil ? ((getpreviousReservationquery[indexPath.row].listData?.city!)!) : "")),\((getpreviousReservationquery[indexPath.row].listData?.state != nil ? ((getpreviousReservationquery[indexPath.row].listData?.state!)!) : "")),\((getpreviousReservationquery[indexPath.row].listData?.country != nil ? ((getpreviousReservationquery[indexPath.row].listData?.country!)!) : "")),\((getpreviousReservationquery[indexPath.row].listData?.zipcode != nil ? ((getpreviousReservationquery[indexPath.row].listData?.zipcode!)!) : ""))"
                
                let inday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                let indate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                let outday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                let outdate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                cell.dateLabel.text = "(\(indate) - \(outdate))"
                cell.nameLabel.text = getpreviousReservationquery[indexPath.row].guestData?.firstName ?? ""
                
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = getpreviousReservationquery[indexPath.row].currency!
                    let total = Double(getpreviousReservationquery[indexPath.row].total!) - Double(getpreviousReservationquery[indexPath.row].hostServiceFee!)
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:total)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    cell.priceLabel.text = "\(currencysymbol!)\(restricted_price!.clean)"
                } else {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                    let from_currency = getpreviousReservationquery[indexPath.row].currency!
                    let total = Double(getpreviousReservationquery[indexPath.row].total!) - Double(getpreviousReservationquery[indexPath.row].hostServiceFee!)
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
                if  Utility.shared.isreceiptAccepted == true{}
                return cell
            } else if((getpreviousReservationquery.count > 0) && (getpreviousReservationquery[indexPath.row].listData == nil)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "nolistTripsCell", for: indexPath)as! nolistTripsCell
                if(getpreviousReservationquery.count > 0) {
                    cell.selectionStyle = .none
                    let inday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                    let indate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkIn!)
                    let outday = getdayValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                    let outdate = getdateValue(timestamp: getpreviousReservationquery[indexPath.row].checkOut!)
                    cell.dateLabel.text = "(\(indate) - \(outdate))"
                    cell.approvedLabel.text = "   \(Utility.shared.getbookingtype(type:getpreviousReservationquery[indexPath.row].reservationState != nil ? getpreviousReservationquery[indexPath.row].reservationState! : "") ?? "")" + "   "
                    cell.approvedLabel.backgroundColor = Utility.shared.getcolorcode(type: getpreviousReservationquery[indexPath.row].reservationState!.firstUppercased)
                    cell.contactSupportBtn.tag = indexPath.row
                    cell.contactSupportBtn.addTarget(self, action: #selector(previouscontactsupprtBtnTapped), for: .touchUpInside)
                    cell.nolistLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nolist"))!)"
                    cell.nolistLabel.textColor  = Theme.Button_BG
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath)as! TripsCell
                cell.selectionStyle = .none
                cell.addressLAbel.numberOfLines = 2
                cell.listTitleLable.numberOfLines = 2
                return cell
            }
        }
    }
    
    @objc func phoneBtnTapped(_ sender: UIButton){
        if(getallreservationquery.count > sender.tag){
            let phoneno = "\(getallreservationquery[sender.tag].guestData?.fullPhoneNumber ?? "")"
            if let url = URL(string: "tel://\(phoneno)") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func emailBtnTapped(_ sender: UIButton) {
        if(getallreservationquery.count > sender.tag) {
            let receip = "\(getallreservationquery[sender.tag].guestUser?.email ?? "")"
            let toRecipents = [receip]
            if MFMailComposeViewController.canSendMail() {
                let mc: MFMailComposeViewController = MFMailComposeViewController()
                mc.mailComposeDelegate = self
                mc.setToRecipients(toRecipents)
                self.present(mc, animated: true, completion: nil)
            } else {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"mailalert"))!)")
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
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
    
    @objc func previousemailBtnTapped(_ sender: UIButton) {
        let receip = "\(getpreviousReservationquery[sender.tag].guestUser?.email ?? "")"
        let toRecipents = [receip]
        if MFMailComposeViewController.canSendMail() {
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setToRecipients(toRecipents)
            self.present(mc, animated: true, completion: nil)
        } else {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"mailalert"))!)")
        }
    }
    
    @objc func previousphoneBtnTapped(_ sender: UIButton) {
        let phoneno = "\(getpreviousReservationquery[sender.tag].guestData?.fullPhoneNumber ?? "")"
        if let url = URL(string: "tel://\(phoneno)") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func moreBtnTapped(_ sender: UIButton) {
        if(getallreservationquery.count > sender.tag) {
            if((getallreservationquery[sender.tag].reservationState! == "pending") && ((getallreservationquery[sender.tag].listData?.bookingType == "request") || (getallreservationquery[sender.tag].listData?.bookingType == "instant"))){
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\(Utility.shared.getLanguage()?.value(forKey:"approve") ?? "Approve")","\(Utility.shared.getLanguage()?.value(forKey:"decline") ?? "Decline")"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "approve"),#imageLiteral(resourceName: "decline")]
            } else if((getallreservationquery[sender.tag].listData != nil) && (getallreservationquery[sender.tag].reservationState! == "approved")) {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)","\(Utility.shared.getLanguage()?.value(forKey: "cancel") ?? "Cancel")"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt"),#imageLiteral(resourceName: "Cancel")]
            } else if ( (getallreservationquery[sender.tag].reservationState! == "expired")) {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            } else if ((getallreservationquery[sender.tag].reservationState! == "declined") || (getallreservationquery[sender.tag].reservationState! == "cancelled") ) {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message")]
            } else if (getallreservationquery[sender.tag].reservationState! == "completed"){
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            } else {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Cancel"),#imageLiteral(resourceName: "Receipt")]
            }
            
            let configuration = FTConfiguration()
            configuration.backgoundTintColor = UIColor(named: "colorController")!
            configuration.menuSeparatorColor = UIColor(named: "colorController")!
            configuration.textColor = UIColor(named: "Title_Header")!
            configuration.cornerRadius = 5
            configuration.menuWidth = 120
            configuration.menuIconSize = 15.0
            configuration.borderColor = Theme.descriptionBorder_Color
            FTPopOverMenu.showForSender(sender: sender,
                                        with: menuOptionNameArray, menuImageArray: menuOprionImageArray,
                                        config: configuration,
                                        done: { (selectedIndex) in
                
                if self.menuOptionNameArray.count == 2{
                    if selectedIndex == 0{
                        self.messageBtnTapped(sender)
                    }else{
                        self.ReceiptBtnTapped(sender)
                    }
                }else{
                    if(selectedIndex == 0){
                        self.messageBtnTapped(sender)
                    }else if(selectedIndex == 1){
                        if self.menuOptionNameArray[1] == "\(Utility.shared.getLanguage()?.value(forKey:"approve") ?? "Approve")"{
                            self.approvedBtnTapped(sender)
                        }else{
                            self.ReceiptBtnTapped(sender)
                        }
                    }else{
                        if self.menuOptionNameArray[2] == "\(Utility.shared.getLanguage()?.value(forKey:"decline") ?? "Decline")"{
                            self.declineBtnTapped(sender)
                        }else{
                            self.cancelBtnTapped(sender)
                            
                        }
                    }
                }
            }, cancel: {
            })
        }
    }
    
    @objc func previousmoreBtnTapped(_ sender: UIButton) {
        if(getpreviousReservationquery.count > 0) {
            if((getpreviousReservationquery[sender.tag].reservationState! == "pending") && ((getpreviousReservationquery[sender.tag].listData?.bookingType == "request") || (getpreviousReservationquery[sender.tag].listData?.bookingType == "instant"))) {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\(Utility.shared.getLanguage()?.value(forKey:"approve") ?? "Approve")","\(Utility.shared.getLanguage()?.value(forKey:"decline") ?? "Decline")"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "approve"),#imageLiteral(resourceName: "decline")]
            } else if((getpreviousReservationquery[sender.tag].listData != nil) && (getpreviousReservationquery[sender.tag].reservationState! == "approved")) {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)","\(Utility.shared.getLanguage()?.value(forKey: "cancel") ?? "Cancel")"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt"),#imageLiteral(resourceName: "Cancel")]
            } else if ((getpreviousReservationquery[sender.tag].reservationState! == "expired")) {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            } else if ((getpreviousReservationquery[sender.tag].reservationState! == "declined") || (getpreviousReservationquery[sender.tag].reservationState! == "cancelled") ) {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message")]
            } else if ((getpreviousReservationquery[sender.tag].reservationState! == "completed")) {
                menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"message"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Receipt")]
            } else {
                menuOptionNameArray = ["\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")","\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)","\((Utility.shared.getLanguage()?.value(forKey:"viewreceipt"))!)"]
                menuOprionImageArray = [#imageLiteral(resourceName: "Message"),#imageLiteral(resourceName: "Cancel"),#imageLiteral(resourceName: "Receipt")]
            }
            let configuration = FTConfiguration()
            configuration.backgoundTintColor = UIColor(named: "colorController")!
            configuration.menuSeparatorColor = UIColor(named: "colorController")!
            configuration.textColor = UIColor(named: "Title_Header")!
            configuration.cornerRadius = 5
            configuration.menuWidth = 120
            configuration.menuIconSize = 15.0
            configuration.borderColor = Theme.descriptionBorder_Color
            FTPopOverMenu.showForSender(sender: sender,
                                        with: menuOptionNameArray, menuImageArray: menuOprionImageArray,
                                        config: configuration,
                                        done: { (selectedIndex) in
                if self.menuOptionNameArray.count == 2{
                    if selectedIndex == 0{
                        self.messagePreviousBtnTapped(sender)
                    }else{
                        self.ReceiptPreviousBtnTapped(sender)
                    }
                } else {
                    if(selectedIndex == 0){
                        self.messagePreviousBtnTapped(sender)
                    } else if(selectedIndex == 1) {
                        if self.menuOptionNameArray[1] == "\(Utility.shared.getLanguage()?.value(forKey:"approve") ?? "Approve")"{
                        }else{
                            self.previouscancelBtnTapped(sender)
                        }
                    }else{
                        if self.menuOptionNameArray[2] == "\(Utility.shared.getLanguage()?.value(forKey:"decline") ?? "Decline")"{
                        }else{
                            self.ReceiptPreviousBtnTapped(sender)
                        }
                    }
                }
            },cancel: {
            })
        }
    }
    
    @objc func contactsupprtBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork() {
            if(getallreservationquery.count > 0) {
                let contactSupportObj = ContactusVC()
                contactSupportObj.Listid = getallreservationquery[sender.tag].listId != nil ? getallreservationquery[sender.tag].listId! : 0
                contactSupportObj.reservationid = getallreservationquery[sender.tag].id != nil ? getallreservationquery[sender.tag].id! : 0
                contactSupportObj.modalPresentationStyle = .overFullScreen
                self.present(contactSupportObj, animated:false, completion: nil) }
        } else {
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
    
    @objc func previouscontactsupprtBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork() {
            if(getpreviousReservationquery.count > 0) {
                let contactSupportObj = ContactusVC()
                contactSupportObj.Listid = getpreviousReservationquery[sender.tag].listId != nil ? getpreviousReservationquery[sender.tag].listId! : 0
                contactSupportObj.reservationid = getpreviousReservationquery[sender.tag].id != nil ? getpreviousReservationquery[sender.tag].id! : 0
                contactSupportObj.modalPresentationStyle = .overFullScreen
                self.present(contactSupportObj, animated: false, completion: nil) }
        } else {
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
    
    @objc func cancelBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if(getallreservationquery.count > 0) {
                let cancelObj = TripsCancelVC()
                cancelObj.listID = getallreservationquery[sender.tag].listId != nil ? getallreservationquery[sender.tag].listId! : 0
                cancelObj.profileId = getallreservationquery[sender.tag].guestData?.profileId ?? 0
                var currency = String()
                
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                    currency = Utility.shared.getPreferredCurrency()!
                } else {
                    currency = Utility.shared.currencyvalue_from_API_base
                }
                cancelObj.checkinDate =  getdateValue(timestamp: getallreservationquery[sender.tag].checkIn!)
                cancelObj.checkoutDate = getdateValue(timestamp: getallreservationquery[sender.tag].checkOut!)
                cancelObj.getcancellationAPICall(reservationId: getallreservationquery[sender.tag].id!, userType: "host", currency: currency)
                Utility.shared.host_cancel_isfromCancel = true
                cancelObj.modalPresentationStyle = .fullScreen
                self.present(cancelObj, animated: true, completion: nil)
            }
        } else {
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
    
    @objc func previouscancelBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if(getpreviousReservationquery.count > 0) {
                let cancelObj = TripsCancelVC()
                cancelObj.listID = getpreviousReservationquery[sender.tag].listId != nil ? getpreviousReservationquery[sender.tag].listId! : 0
                cancelObj.profileId = getpreviousReservationquery[sender.tag].guestData?.profileId ?? 0
                var currency = String()
                Utility.shared.host_cancel_isfromCancel = true
                
                if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                {
                    currency = Utility.shared.getPreferredCurrency()!
                }
                else{
                    currency = Utility.shared.currencyvalue_from_API_base
                }
                cancelObj.checkinDate = checkinDate
                cancelObj.checkoutDate = checkoutDate
                cancelObj.getcancellationAPICall(reservationId:getpreviousReservationquery[sender.tag].id!, userType: "host", currency: currency)
                cancelObj.modalPresentationStyle = .fullScreen
                self.present(cancelObj, animated: true, completion: nil) }
        } else {
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
    
    @objc func ReceiptPreviousBtnTapped(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        if(getpreviousReservationquery.count > 0) {
            self.createReservationAPICall(reservationid:getpreviousReservationquery[sender.tag].id!, senderBtn: sender)
        }
    }
    
    @objc func ReceiptBtnTapped(_ sender: UIButton) {
        sender.isMultipleTouchEnabled = false
        sender.isExclusiveTouch = true
        sender.isUserInteractionEnabled = false
        if(getallreservationquery.count > 0) {
            self.createReservationAPICall(reservationid:getallreservationquery[sender.tag].id!, senderBtn: sender)
        }
    }
    
    func createReservationAPICall(reservationid:Int, senderBtn: UIButton) {
        if Utility().isConnectedToNetwork(){
            var currency = String()
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                currency = Utility.shared.getPreferredCurrency()!
            } else {
                currency = Utility.shared.currencyvalue_from_API_base
            }
            let createReservationquery = GetReservationQueryy(reservationId: reservationid,convertCurrency:currency)
            apollo_headerClient.fetch(query: createReservationquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.getReservation?.results) != nil else{
                    self.view.makeToast(result?.data?.getReservation?.errorMessage)
                    senderBtn.isUserInteractionEnabled = true
                    return
                }
                self.getReservationArrayyy = (result?.data?.getReservation)!
                self.getReservationArray = (result?.data?.getReservation?.results)!
                self.getReservation_currencyArray = (result?.data?.getReservation!)!
                if #available(iOS 11.0, *) {
                    let receiptPageObj = ReceiptVC()
                    Utility.shared.host_isfrom_hostRecipt = true
                    receiptPageObj.getReservation_currencyArray = self.getReservation_currencyArray
                    receiptPageObj.getReservationArrayyy = self.getReservationArrayyy
                    receiptPageObj.getReservationArray = self.getReservationArray
                    receiptPageObj.modalPresentationStyle = .overFullScreen
                    senderBtn.isUserInteractionEnabled = true
                    self.view.window?.rootViewController?.present(receiptPageObj, animated:false, completion: nil)
                } else {
                    senderBtn.isUserInteractionEnabled = true
                }
            }
        } else {
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
        if(getallreservationquery.count > 0) {
            let viewListing = UpdatedViewListing()
            viewListing.listID = getallreservationquery[sender.tag].listId ?? 0
            Utility.shared.unpublish_preview_check = true
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    
    @objc func listpreviousBtnTapped(_ sender: UIButton){
        if(getpreviousReservationquery.count > 0) {
            let viewListing = UpdatedViewListing()
            viewListing.listID = getpreviousReservationquery[sender.tag].listId ?? 0
            Utility.shared.unpublish_preview_check = true
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    
    func getdateValue(timestamp:String) -> String {
        if(Int(timestamp) != nil ) {
            let timestamValue = Int(timestamp)!/1000
            let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            if(Utility.shared.isRTLLanguage()) {
                dateFormatter.locale = NSLocale(localeIdentifier:"en") as Locale
            } else {
                dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
            }
            let date = dateFormatter.string(from:showDate)
            return date
        } else {
            return Utility.shared.getdateformatter(date: timestamp)
        }
    }
    
    func getapprovedateValue(timestamp:String) -> String {
        if(Int(timestamp) != nil ) {
            let timestamValue = Int(timestamp)!/1000
            let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if(Utility.shared.isRTLLanguage()) {
                dateFormatter.locale = NSLocale(localeIdentifier:"en") as Locale
            } else {
                dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
            }
            let date = dateFormatter.string(from: showDate)
            return date } else {return Utility.shared.getdateformatter(date: timestamp)}
    }
    
    func getdayValue(timestamp:String) -> String {
        if(Int(timestamp) != nil ) {
            let timestamValue = Int(timestamp)!/1000
            let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "EEE"
            if(Utility.shared.isRTLLanguage()) {
                dateFormatter1.locale = NSLocale(localeIdentifier:"en") as Locale
            }
            else {
                dateFormatter1.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
            }
            let day = dateFormatter1.string(from: showDate)
            return day } else {
                
                return Utility.shared.getdateformatter1(date: timestamp)
            }
    }
    
    @objc func messageBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if(getallreservationquery.count > 0) {
                let InboxListingObj = InboxListingVC()
                Utility.shared.ListID = "\(getallreservationquery[sender.tag].listId != nil ? getallreservationquery[sender.tag].listId! : 0)"
                Utility.shared.host_message_isfromHost = true
                InboxListingObj.threadId = (getallreservationquery[sender.tag].messageData?.id != nil ? (getallreservationquery[sender.tag].messageData?.id!)! : 0)
                InboxListingObj.getmessageListquery.removeAll()
                InboxListingObj.getMessageListAPICall(threadId:(getallreservationquery[sender.tag].messageData?.id)!)
                InboxListingObj.modalPresentationStyle = .fullScreen
                self.present(InboxListingObj, animated: true, completion: nil)
            }
        } else {
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
    @objc func messagePreviousBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork() {
            if(getpreviousReservationquery.count > 0) {
                let InboxListingObj = InboxListingVC()
                Utility.shared.ListID = "\(getpreviousReservationquery[sender.tag].listId != nil ? getpreviousReservationquery[sender.tag].listId! : 0)"
                InboxListingObj.threadId = (getpreviousReservationquery[sender.tag].messageData?.id != nil ? (getpreviousReservationquery[sender.tag].messageData?.id!)! : 0)
                InboxListingObj.getMessageListAPICall(threadId:(getpreviousReservationquery[sender.tag].messageData?.id)!)
                InboxListingObj.modalPresentationStyle = .fullScreen
                self.present(InboxListingObj, animated: true, completion: nil)
            }
        } else {
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if Utility().isConnectedToNetwork(){
            if(isupcomingTable) {
                let totalPages = (self.totalListcount/10)
                let height = scrollView.frame.size.height
                let contentYoffset = scrollView.contentOffset.y
                let distanceFromBottom = scrollView.contentSize.height - contentYoffset
                if((self.upcomingTable.contentOffset.y + self.upcomingTable.bounds.height) >= self.upcomingTable.contentSize.height) {
                    if(totalPages >= PageIndex){
                        self.PageIndex = self.PageIndex + 1
                        self.getTripsAPICall()
                        
                    }
                }
            } else {
                let totalPages = (self.previoustotalListcount/10)
                let height = scrollView.frame.size.height
                let contentYoffset = scrollView.contentOffset.y
                let distanceFromBottom = scrollView.contentSize.height - contentYoffset
                if((self.previousTable.contentOffset.y + self.previousTable.bounds.height) >= self.previousTable.contentSize.height) {
                    if(totalPages >= previousPageIndex){
                        self.previousPageIndex = self.previousPageIndex + 1
                        self.previousTripsAPICall()
                        
                    }
                }
            }
        } else {
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
    
    @objc func approvedBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if(getallreservationquery.count > 0) {
                self.approveDeclineAPICall(threadid:(getallreservationquery[sender.tag].messageData?.id!)!, content: "", type:"approved", startDate:self.getapprovedateValue(timestamp:getallreservationquery[sender.tag].checkIn!) , endDate:self.getapprovedateValue(timestamp:getallreservationquery[sender.tag].checkOut!), personCapacity:getallreservationquery[sender.tag].guests!, reservationId: getallreservationquery[sender.tag].id!, actionType: "approved")
            }
        } else {
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
    
    @objc func declineBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if(getallreservationquery.count > 0) {
                self.approveDeclineAPICall(threadid:(getallreservationquery[sender.tag].messageData?.id!)!, content: "", type:"declined", startDate:self.getapprovedateValue(timestamp:getallreservationquery[sender.tag].checkIn!), endDate:self.getapprovedateValue(timestamp:getallreservationquery[sender.tag].checkOut!), personCapacity:getallreservationquery[sender.tag].guests!, reservationId: getallreservationquery[sender.tag].id!, actionType: "declined")
            }
        } else {
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
    
    func approveDeclineAPICall(threadid:Int,content:String,type:String,startDate:String,endDate:String,personCapacity:Int,reservationId:Int,actionType:String) {
        
        if Utility().isConnectedToNetwork(){
            let reservationstatusMutation = ReservationStatusMutation(threadId: threadid, content: content, type: type, startDate: startDate, endDate: endDate, personCapacity: personCapacity, reservationId: reservationId, actionType: actionType)
            apollo_headerClient.perform(mutation: reservationstatusMutation){(result,error) in
                
                if(result?.data?.reservationStatus?.status == 200) {
                    self.getallreservationquery.removeAll()
                    self.PageIndex = 1
                    self.previousPageIndex = 1
                    self.getTripsAPICall()
                } else {
                    self.view.makeToast(result?.data?.reservationStatus?.errorMessage != nil ? result?.data?.reservationStatus?.errorMessage! : "")
                }
            }
        } else {
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
    
    func GetDefaultSettingAPICall(){
        if(Utility.shared.getCurrentUserToken() != nil) {
            apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
            let mostlistingquery = GetDefaultSettingQuery()
            apollo_headerClient.fetch(query: mostlistingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.currency?.result) != nil else {
                    return
                }
                Utility.shared.currencyvalue_from_API_base = (result?.data?.currency?.result?.base != nil ? (result?.data?.currency?.result?.base)! : "")
                let currency_value = result?.data?.currency?.result?.rates
                Utility.shared.currency_Dict = self.convertToDictionary(text: currency_value!)! as NSDictionary
                
            }
        }
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


