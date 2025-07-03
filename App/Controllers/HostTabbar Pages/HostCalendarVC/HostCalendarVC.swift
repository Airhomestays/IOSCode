

import UIKit
import Apollo
import Lottie
import SwiftMessages

class HostCalendarVC: UIViewController,WWCalendarTimeSelectorProtocol,CalendarListingVCProtocol,AvailabilityHostVCDelegate,CalendarDetailVCDelegate{
    

    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var nocalendardesLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var calendardetailsBtn: UIButton!
    @IBOutlet weak var nextimage: UIImageView!
    @IBOutlet weak var calendarDetailView: UIView!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var downarrowImg: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var entireLabel: UILabel!
    
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var listtitleLabel: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var calendarStatusView: UIView!
    @IBOutlet weak var entirehomeview: UIView!
    
    @IBOutlet weak var specialPriceView: UIImageView!
    @IBOutlet weak var availableView: UIImageView!
    @IBOutlet weak var notavailableView: UIImageView!
    @IBOutlet weak var bookedView: UIImageView!
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bookedLbl: UILabel!
    @IBOutlet weak var notAvailableLbl: UILabel!
    @IBOutlet weak var availableLbl: UILabel!
    @IBOutlet weak var specialPriceLbl: UILabel!
    
    fileprivate var singleDate: Date = Date()
    fileprivate var multipleDates: [Date] = []
    var listId = Int()
    var new_titleArray = [String:String]()
    
    var image_list = String()
    var title_list = String()
    var entireTitle_Value = String()
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editIconImg: UIImageView!
    @IBOutlet weak var editLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    
    
    var manageListingArray = [ManageListingsQuery.Data.ManageListing.Result]()
    var inprogress_List_Array = [ManageListingsQuery.Data.ManageListing.Result]()
    var completed_List_Array = [ManageListingsQuery.Data.ManageListing.Result]()
    var getListingSpecialPrice_Array = [GetListingSpecialPriceQuery.Data.GetListingSpecialPrice.Result]()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    open weak var delegate: WWCalendarTimeSelectorProtocol?
    
    open var optionCurrentDateRange: WWCalendarTimeSelectorDateRange = WWCalendarTimeSelectorDateRange()
    
    var lottieView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.view.backgroundColor =  UIColor(named: "colorController")
        noDataView.backgroundColor = UIColor(named: "colorController")
        calendarView.backgroundColor = UIColor(named: "colorController")
        
        topView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        self.lottieAnimation()
        self.editView.isHidden = false
        self.editBtn.isHidden = false
        self.editLbl.isHidden = false
        self.editIconImg.isHidden = false
        
        self.listtitleLabel.textColor = UIColor(named: "Title_Header")
        self.listtitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.listtitleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14.0)

        self.entireLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.entireLabel.font = UIFont(name: APP_FONT, size: 12.0)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if(!Utility.shared.isfrom_availability_calendar) {

            self.initialSetup()
            self.manageListingAPICall()
            Utility.shared.host_selected_Array.removeAllObjects()
        } else {
            Utility.shared.isfrom_availability_calendar = false
            Utility.shared.isfrom_availability_calendar_date = true
        }
        
        let string = "\((Utility.shared.getLanguage()?.value(forKey:"calendardetails"))!)"
        let attributeString = NSMutableAttributedString(string: "\((Utility.shared.getLanguage()?.value(forKey:"calendardetails"))!)")
        
        attributeString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(0, string.count))
        
        calendardetailsBtn.titleLabel?.attributedText = attributeString
        
        calendardetailsBtn.setAttributedTitle(attributeString, for: .normal)
        calendardetailsBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        calendardetailsBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        calendardetailsBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 14.0)
        calendardetailsBtn.layer.cornerRadius = calendardetailsBtn.frame.size.height/2
        calendardetailsBtn.clipsToBounds = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func initialSetup() {
        specialPriceView.layer.borderWidth = 1.0
        specialPriceView.layer.borderColor = Theme.TextBorderColor.cgColor
        availableView.layer.borderWidth = 1.0
        availableView.layer.borderColor  = Theme.TextBorderColor.cgColor
        notavailableView.layer.borderWidth = 1.0
        notavailableView.layer.borderColor = Theme.TextBorderColor.cgColor
        bookedView.layer.borderWidth = 1.0
        bookedView.layer.borderColor = Theme.TextBorderColor.cgColor
        editView.backgroundColor = Theme.PRIMARY_COLOR
        editView.layer.cornerRadius = editView.frame.size.height/2
        editView.layer.masksToBounds = true
        
        
        nocalendardesLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        calendarLabel.textColor =   UIColor(named: "Title_Header")
        
        listImage.layer.cornerRadius = 10.0
        listImage.layer.masksToBounds = true
        
        entireLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.noDataView.isHidden = true
        self.topView.isHidden = true
        self.calendarView.isHidden = true
        self.editView.isHidden = true
        self.editBtn.isHidden = true
        self.editLbl.isHidden = true
        self.editIconImg.isHidden = true
        self.offlineView.isHidden = true
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        editLbl.font = UIFont(name: APP_FONT, size: 14)
        editLbl.text = "\(Utility.shared.getLanguage()?.value(forKey:"edit") ?? "Edit")"
        editLbl.textColor = UIColor.white
        editLbl.textAlignment = .center
        
        nocalendardesLabel.font = UIFont(name: APP_FONT, size: 14)
        calendarLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 26)
        
        self.view.addSubview(self.lottieView)
        self.view.sendSubviewToBack(self.lottieView)
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        editBtn.setTitle("", for:.normal)
        calendarLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"calendar"))!)"
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        nocalendardesLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"calendar_description"))!)"
        
        bookedLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "booked") ?? "Booked")"
        bookedLbl.textColor = UIColor(named: "Title_Header")
        bookedLbl.font = UIFont(name: APP_FONT, size: 12.0)
        bookedLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        notAvailableLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "notavailable") ?? "Not Available")"
        notAvailableLbl.textColor = UIColor(named: "Title_Header")
        notAvailableLbl.font = UIFont(name: APP_FONT, size: 12.0)
        notAvailableLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        availableLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "available") ?? "Available")"
        availableLbl.textColor = UIColor(named: "Title_Header")
        availableLbl.font = UIFont(name: APP_FONT, size: 12.0)
        availableLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        specialPriceLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "Special_Price") ?? "Special Price")"
        specialPriceLbl.textColor = UIColor(named: "Title_Header")
        specialPriceLbl.font = UIFont(name: APP_FONT, size: 12.0)
        specialPriceLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    @objc func calendarViewCall(){
        let selector =  UIStoryboard.init(name: "WWCalendarTimeSelector", bundle:nil).instantiateViewController(withIdentifier:"Calendar") as? WWCalendarTimeSelector
        selector?.delegate = self
        selector?.optionCurrentDate = singleDate
        multipleDates = (selector?.optionCurrentDateRange.array)!
        selector?.optionCurrentDateRange.setStartDate(multipleDates.first ?? singleDate)
        selector?.optionCurrentDateRange.setEndDate(multipleDates.last ?? singleDate)
        selector?.optionSelectionType = WWCalendarTimeSelectorSelection.range
        selector?.optionShowTopContainer = false
        Utility.shared.isTodayEnable = false
        calendarView.addSubview(selector!.view)
        selector!.view.frame = CGRect(x:-30, y:self.calendarView.frame.origin.y-180, width: self.calendarView.frame.size.width+60, height: self.calendarView.frame.size.height)
        calendarView.bringSubviewToFront(editView)
        selector?.view.addSubview(lottieView)
        selector?.view.sendSubviewToBack(lottieView)
        self.lottieView.isHidden = true
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView.play()
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.editView.isHidden = false
            self.editBtn.isHidden = false
            self.editLbl.isHidden = false
            self.editIconImg.isHidden = false
            self.calendardetailsBtn.isHidden = false
            self.calendarView.isHidden = false
            self.topView.isHidden = false
            self.offlineView.isHidden = true
            if(!(self.manageListingArray.count > 0)) {
                self.lottieAnimation()
                self.manageListingAPICall()
            }
        }
    }
    @IBAction func calendarDetailBtnTapped(_ sender: Any) {
        let calendarDetailObj = CalendarDetailVC()
        calendarDetailObj.delegate = self
        calendarDetailObj.listId = self.listId
        if(new_titleArray["listImage"] != nil) {
            calendarDetailObj.listImage = "\(new_titleArray["listImage"]!)"
            calendarDetailObj.title_val = "\(new_titleArray["title"]!)"
            calendarDetailObj.entireTitle = "\(new_titleArray["entireTitle"]!)"
        } else {
            if self.completed_List_Array.count > 0 {
                calendarDetailObj.listImage = self.completed_List_Array[0].listPhotoName != nil ? self.completed_List_Array[0].listPhotoName! : ""
                calendarDetailObj.title_val = self.completed_List_Array[0].title != nil ? self.completed_List_Array[0].title! : ""
                calendarDetailObj.entireTitle = self.completed_List_Array[0].settingsData![0]?.listsettings != nil ?  (self.completed_List_Array[0].settingsData![0]?.listsettings?.itemName!)! : ""
            }
        }
        calendarDetailObj.delegate = self
        calendarDetailObj.modalPresentationStyle = .fullScreen
        self.present(calendarDetailObj, animated: true, completion: nil)
    }
    func manageListingAPICall() {
        
        if Utility().isConnectedToNetwork(){
            let manageListingquery = ManageListingsQuery()
            apollo_headerClient.fetch(query: manageListingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.manageListings?.results) != nil else{
                    self.noDataView.isHidden = false
                    self.lottieView.isHidden = true
                    return
                }
                self.lottieView.isHidden = true
                self.manageListingArray = ((result?.data?.manageListings?.results)!) as! [ManageListingsQuery.Data.ManageListing.Result]
                self.completed_List_Array.removeAll()
                self.inprogress_List_Array.removeAll()
                for i in self.manageListingArray {
                    if(i.isReady == false) {
                        self.inprogress_List_Array.append(i)
                    } else {
                        self.completed_List_Array.append(i)
                    }
                }
                if(self.completed_List_Array.count > 0) {
                    self.noDataView.isHidden = true
                    self.topView.isHidden = false
                    self.calendarView.isHidden = false
                    
                    self.editView.isHidden = true
                    self.editBtn.isHidden = true
                    self.editLbl.isHidden = true
                    self.editIconImg.isHidden = true
                    self.listId = self.completed_List_Array[0].id!
                    self.listtitleLabel.text = self.completed_List_Array[0].title != nil ? self.completed_List_Array[0].title! : ""
                    
                    if(self.completed_List_Array[0].settingsData![0]?.listsettings != nil && self.completed_List_Array[0].settingsData![0]?.listsettings?.itemName != nil) {
                        self.entireLabel.text = self.completed_List_Array[0].settingsData![0]?.listsettings?.itemName!
                    } else {
                        self.entireLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"entireplace"))!)"
                    }
                    if(self.completed_List_Array[0].listPhotoName != nil) {
                        let listimage = self.completed_List_Array[0].listPhotoName!
                        self.listImage.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                        self.listImage.contentMode = .scaleAspectFill
                    } else {
                        self.listImage.image = #imageLiteral(resourceName: "camera-50")
                    }
                    self.listId = self.completed_List_Array[0].id != nil ? self.completed_List_Array[0].id! : 0
                    self.BlockedlistAPICall(listId: self.completed_List_Array[0].id != nil ? self.completed_List_Array[0].id! : 0)
                } else {
                    self.noDataView.isHidden = false
                    self.lottieView.isHidden = true
                    self.topView.isHidden = true
                    self.editView.isHidden = true
                    self.editBtn.isHidden = true
                    self.editLbl.isHidden = true
                    self.editIconImg.isHidden = true
                    
                    self.calendarView.isHidden = true
                }
                
            }
        } else {
            self.lottieView.isHidden = true
            self.editView.isHidden = true
            self.editBtn.isHidden = true
            self.editLbl.isHidden = true
            self.editIconImg.isHidden = true
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
            if IS_IPHONE_XR || IS_IPHONE_X {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: self.offlineView.frame.size.width, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: self.offlineView.frame.size.width, height: 55)
            }
        }
    }
    func APICall(listImage:String,title:String,entireTitle:String,listId:Int) {
        if(listImage != nil) {
            
            self.listImage.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listImage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            self.listImage.contentMode = .scaleAspectFill
        } else {
            self.listImage.image = #imageLiteral(resourceName: "camera-50")
        }
        if(title != nil) {
            self.listtitleLabel.text = title
        }
        if(entireTitle != nil) {
            self.entireLabel.text = entireTitle
        }
        self.lottieView.isHidden = true
        
        new_titleArray.updateValue(listImage, forKey: "listImage")
        new_titleArray.updateValue(title, forKey: "title")
        new_titleArray.updateValue(entireTitle, forKey: "entireTitle")
        self.listId = listId
        let selector =  UIStoryboard.init(name: "WWCalendarTimeSelector", bundle:nil).instantiateViewController(withIdentifier:"Calendar") as? WWCalendarTimeSelector
        selector?.delegate = self
        self.WWCalendarTimeSelectorCancel(selector!, dates: Utility.shared.calendar_Date_Array)
        
    }
    
    func WWCalendarTimeSelectorCancel(_ selector: WWCalendarTimeSelector, dates: [Date])
    {
        Utility.shared.calendar_Date_Array.removeAll()
    }
    
    func WWCalendarTimeSelectorDidDismiss(_ selector: WWCalendarTimeSelector)
    {}
    
    func BlockedlistAPICall(listId:Int) {
        self.lottieAnimation()
        if Utility().isConnectedToNetwork(){
            let getListingSpecialPricequery = GetListingSpecialPriceQuery(listId: listId)
            apollo_headerClient.fetch(query: getListingSpecialPricequery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                guard (result?.data?.getListingSpecialPrice?.results) != nil else{
                    self.noDataView.isHidden = false
                    self.lottieView.isHidden = true
                    return
                }
                self.getListingSpecialPrice_Array = (result?.data?.getListingSpecialPrice?.results)! as! [GetListingSpecialPriceQuery.Data.GetListingSpecialPrice.Result]
                Utility.shared.host_blockedDates_Array.removeAllObjects()
                Utility.shared.host_bookedPricing_Array.removeAllObjects()
                Utility.shared.host_specialPricing_Array.removeAllObjects()
                Utility.shared.host_specialPrice_value_Array.removeAllObjects()
                Utility.shared.host_specialDay_Array.removeAllObjects()
                Utility.shared.host_currency_Array.removeAllObjects()
                Utility.shared.hosr_blockDay_Array.removeAllObjects()
                Utility.shared.host_bookDay_Array.removeAllObjects()
                for i in self.getListingSpecialPrice_Array{
                    if(Int(i.blockedDates!) != nil) {
                        let timestamp = i.blockedDates
                        let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                        let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MMM YYYY"
                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        let dateFormatter1 = DateFormatter()
                        dateFormatter1.dateFormat = "EEEE"
                        dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
                        let date1 = "\(dateFormatter1.string(from: newTime))"
                        
                        let date = "\(dateFormatter.string(from: newTime))"
                        
                        
                        if(i.calendarStatus == "blocked" || (newTime < Date() && !Calendar.current.isDateInToday(newTime))) {
                            if(i.reservationId != nil)
                            {
                                Utility.shared.host_bookedPricing_Array.add("\(date)")
                                Utility.shared.host_bookDay_Array.add("\(date1)")
                            }else {
                                Utility.shared.host_blockedDates_Array.add("\(date)")
                                Utility.shared.hosr_blockDay_Array.add("\(date1)")
                            }
                        } else if(i.calendarStatus == "available" && i.isSpecialPrice != nil) {
                            var Dict = [String:Any]()
                            Dict.updateValue("\(date)", forKey: "Date")
                            Dict.updateValue(i.isSpecialPrice!, forKey: "SpecialPrice")
                            Dict.updateValue(i.listCurrency, forKey: "Currency")
                            Utility.shared.host_specialPrice_Array.append(Dict)
                            if(i.listCurrency != nil)
                            {
                                Utility.shared.host_currency_Array.add(i.listCurrency!)
                            }
                            else{
                                Utility.shared.host_currency_Array.add(Utility.shared.currencyvalue_from_API_base)
                            }
                            Utility.shared.host_specialPricing_Array.add("\(date)")
                            Utility.shared.host_specialDay_Array.add("\(date1)")
                            Utility.shared.host_specialPrice_value_Array.add(i.isSpecialPrice!)
                        }
                    }
                }
                
                self.calendarViewCall()
                
                
            }
        } else {
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
    @IBAction func nextBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Utility.shared.calendar_Date_Array.count > 0) {
                
                let selector =  UIStoryboard.init(name: "WWCalendarTimeSelector", bundle:nil).instantiateViewController(withIdentifier:"Calendar") as? WWCalendarTimeSelector
                
                
                self.WWCalendarTimeSelectorDone(selector!,dates:Utility.shared.calendar_Date_Array)
            } else {
                
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selectdates"))!)")
            }
        } else {
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
    
    @IBAction func downArrowBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            
            let headerView = CalendarListingVC()
            headerView.deleagte = self
            headerView.modalPresentationStyle = .overFullScreen
            self.present(headerView, animated: true, completion: nil)
        } else {
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
    
    
    func WWCalendarTimeSelectorShouldSelectDate(_ selector: WWCalendarTimeSelector, date: Date) -> Bool {
        
        self.editView.isHidden = false
        self.editBtn.isHidden = false
        self.editLbl.isHidden = false
        self.editIconImg.isHidden = false
       
        let curDate = Date().beginningOfDay
        let newdate = Calendar.current.date(byAdding: .day, value: 1, to: curDate)
        let fmt = DateFormatter()
        fmt.dateFormat = "dd MMM YYYY"
        if (date < curDate){
            return false
        } else if (fmt.string(from: date) == fmt.string(from: curDate)){
            Utility.shared.isTodayEnable = true
            return true
        } else if(Utility.shared.host_bookedPricing_Array.contains(fmt.string(from: date))) {
            return false
        } else if(Utility.shared.host_bookedPricing_Array.contains(fmt.string(from: date))) {
            return false
        } else {
            return true
        }
    }
    
    
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, dates: [Date]) {
        Utility.shared.host_selected_dates_Array.removeAllObjects()
        let array_dates = NSMutableArray()
        var booked_Selected:Bool = false
        for i in dates {
            let current_date = ("\(i.stringFromFormatEnglish("yyyy-MM-dd"))")
            Utility.shared.host_selected_dates_Array.add(current_date)
            let date_Value = ("\(i.stringFromFormat("dd MMM yyyy"))")
            array_dates.add(date_Value)
            if(Utility.shared.host_bookedPricing_Array.contains(date_Value)) {
                booked_Selected = true
            }
        }
        
        
        if(!booked_Selected) {
            if let date = dates.first {
                singleDate = date
                editView.isHidden = false
                self.editBtn.isHidden = false
                self.editLbl.isHidden = false
                self.editIconImg.isHidden = false
                
                let availabilityHostObj = AvailabilityHostVC()
                availabilityHostObj.delegate = self
                
                let startdate = dates.first
                let endDate = dates.last
                
                availabilityHostObj.startDate = "\(startdate!.stringFromFormat("dd MMM yyyy"))"
                availabilityHostObj.endDate = "\(endDate!.stringFromFormat("dd MMM yyyy"))"
                availabilityHostObj.listId = self.listId
                availabilityHostObj.currency = self.completed_List_Array[0].listingData?.currency ?? ""
                if(new_titleArray["listImage"] != nil) {
                    availabilityHostObj.listImage = "\(new_titleArray["listImage"]!)"
                    availabilityHostObj.title_val = "\(new_titleArray["title"]!)"
                    availabilityHostObj.entireTitle = "\(new_titleArray["entireTitle"]!)"
                } else {
                    availabilityHostObj.listImage = self.completed_List_Array[0].listPhotoName!
                    availabilityHostObj.title_val = self.completed_List_Array[0].title!
                    availabilityHostObj.entireTitle = self.completed_List_Array[0].settingsData![0]?.listsettings != nil ? (self.completed_List_Array[0].settingsData![0]?.listsettings?.itemName!)! : ""
                }
                availabilityHostObj.delegate = self
                availabilityHostObj.modalPresentationStyle = .fullScreen
                self.present(availabilityHostObj, animated: true, completion: nil)
            }
            multipleDates = dates
        } else {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"thosedates"))!)")
        }
    }
}

