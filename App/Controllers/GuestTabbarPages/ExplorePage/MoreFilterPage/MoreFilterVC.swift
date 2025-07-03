

import UIKit
import Lottie
import RangeSeekSlider
import Apollo
import SwiftMessages

protocol MoreFilterVCDelegate {
    
    func passSelectedBedscount(priceRange: Int)
    func passSelectedBathRoomscount(priceRange: Int)
    func passSelectedBedRoomscount(priceRange: Int)
    func passSelectedguestcount(priceRange: Int)
    func passSelectedPriceRange(priceRange:NSMutableArray)

    
    func passSelectedfacilities(priceRange:NSMutableArray)
    func passSelectedhouserule(priceRange:NSMutableArray)
    func passSelectedamenities(priceRange:NSMutableArray)
    func passSelectedhometype(priceRange:NSMutableArray)
    
}


protocol ApicallingDelegate {
    func apicalling()
}

class MoreFilterVC: UIViewController,UITableViewDelegate,UITableViewDataSource,RangeSeekSliderDelegate,AirbnbDatePickerDelegate {
    
    
 
    
    @IBOutlet weak var fitertitleLabel: UILabel!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var topView: UIView!
    
    @IBOutlet var seemoreBtn: UIButton!
    @IBOutlet var closeBtn: UIButton!
    
    @IBOutlet var filterTV: UITableView!
    @IBOutlet var clearBtn: UIButton!
    
    var isFilterEnable:Bool = false
    var numberofguest = Int()
    @IBOutlet var lineView: UIView!
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
  
    var filterDelegate:MoreFilterVCDelegate?
    var isclearfilter:Bool = false
    
    var oldVal = NSMutableArray()
    
    var priceRangeArrayVal = NSMutableArray()
    var oldhouseRule = NSMutableArray()
    var oldfacilitiesRule = NSMutableArray()
    var oldaminitiesArray = NSMutableArray()
    var oldhometypeArray = NSMutableArray()
    var didsaveCurrentpage:Bool = false
    var oldguestcount = Int()
    var oldbedRoomcount = Int()
    var oldbedscount = Int()
    var oldbathroomscount = Int()
    var clearTapped:Bool = false
    var apicallingDelegate: ApicallingDelegate!
  
    var dateFormatter: DateFormatter {
        get {
            let f = DateFormatter()
            f.dateFormat = "MMM d, YYYY"
            if(Utility.shared.getAppLanguageCode() != nil)
            {
                if(Utility.shared.isRTLLanguage()) {
                    f.locale = NSLocale(localeIdentifier:"en") as Locale
                }
                else {
                    f.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
                }
            }
            return f
        }
    }
    
    var dateFormatterDate: DateFormatter {
        get {
            let f = DateFormatter()
            f.dateFormat = "d"
            if(Utility.shared.getAppLanguageCode() != nil)
            {
                f.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
            }
            return f
        }
    }
    
    var dateFormatterDateMonth: DateFormatter {
        get {
            let f = DateFormatter()
            f.dateFormat = "MMM d"
            if(Utility.shared.getAppLanguageCode() != nil)
            {
                if(Utility.shared.isRTLLanguage()) {
                    f.locale = NSLocale(localeIdentifier:"en") as Locale
                }
                else {
                    f.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
                }
            }
            return f
        }
    }
    
    var homeTypeArray = NSArray()
    var amenitiesTitleArray = NSArray()
    var FacilitiesTitleArray = NSArray()
    var houseRulesArray = NSArray()
    var isShowmoreClicked:Bool = false
    var isfacilitiesmoreClicked:Bool = false
    var ishousemoreClicked:Bool = false
    var isHomeTypeClicked:Bool = false
    var count = Int()
    var minCount = Int()
    var maxCount = Int()
    var minsliderValue = String()
    var maxsliderValue = String()
    var getsearchPriceArray = GetDefaultSettingQuery.Data.GetSearchSetting.Result()
    var RoomsFilterArray = [GetDefaultSettingQuery.Data.GetListingSettingsCommon.Result]()
    
    var lottieView: LottieAnimationView!
    
    var apollo_headerClient: ApolloClient!
    
    
    
    var roomtypeArray = NSMutableArray()
    var amenitiesArray = NSMutableArray()
    var facilitiesArray = NSMutableArray()
    var housingRulesArray = NSMutableArray()
    var priceRangeArray = NSMutableArray()
    var instantBook = String()
    var bedrooms_count = Int()
    var beds_count = Int()
    var bathroom_count = Int()
    var TotalFilterCount : Int = 0
    var isSwitchEnable:Bool = false
    
    var minvalue = Int()
    var maxValue = Int()
    
    var isClearTap = false
    
    var delegate: searchPageProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkApolloStatus()
      
        self.initialSetup()
        self.registerCells()
        if(RoomsFilterArray.count == 0)
        {
            self.lottieAnimation()
            self.FilterAPICall()
        }
     
        
        filterTV.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        filterTV.estimatedSectionFooterHeight = 0
        filterTV.sectionFooterHeight = 0
        
        
    }
    func checkApolloStatus()
    {
        if((Utility.shared.getCurrentUserToken()) != nil)
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
    func registerCells(){
        filterTV.register(UINib(nibName: "DateCell", bundle: nil), forCellReuseIdentifier: "DateCell")
        filterTV.register(UINib(nibName: "RoomsCell", bundle: nil), forCellReuseIdentifier: "RoomsCell")
        filterTV.register(UINib(nibName: "InstantBookCell", bundle: nil), forCellReuseIdentifier: "InstantBookCell")
        filterTV.register(UINib(nibName: "PriceRangeCell", bundle: nil), forCellReuseIdentifier: "PriceRangeCell")
        filterTV.register(UINib(nibName: "AmenitiesCell", bundle: nil), forCellReuseIdentifier: "AmenitiesCell")
        filterTV.register(UINib(nibName: "FacilitiesCell", bundle: nil), forCellReuseIdentifier: "FacilitiesCell")
        filterTV.register(UINib(nibName: "HouseRulesCell", bundle: nil), forCellReuseIdentifier: "HouseRulesCell")
        
        
        self.filterTV.separatorStyle = .none
    }
    
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.filterTV.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    
    
    @objc func autoscrolling()
    {
        self.lottieView.play()
    }
    
    func initialSetup(){
        oldVal.removeAllObjects()
        oldhouseRule = NSMutableArray()
        oldfacilitiesRule = NSMutableArray()
        oldaminitiesArray = NSMutableArray()
        

        Utility.shared.beds_count = oldbedscount
        Utility.shared.bathroom_count = oldbathroomscount
        Utility.shared.bedrooms_count = oldbedRoomcount
        
        if self.housingRulesArray.count > 0 {
            for value in housingRulesArray {
                oldhouseRule.add(value)
            }
        }
        
        if self.facilitiesArray.count > 0 {
            for value in  facilitiesArray {
                oldfacilitiesRule.add(value)
            }
        }
        
        if self.amenitiesArray.count > 0 {
            for value in amenitiesArray {
                oldaminitiesArray.add(value)
            }
        }
        
        
        if self.priceRangeArrayVal.count > 0 {
            if  Utility.shared.clear == true {
                Utility.shared.clear = false
                priceRangeArrayVal.removeAllObjects()
            } else {
                for value in priceRangeArrayVal {
                    oldVal.add(value)
                   
                }
            }
        }
        
        seemoreBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        fitertitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        
        
        filterTV.separatorColor =  UIColor.green
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        if IS_IPHONE_XR
        {
            self.topView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-40, height: 80)
            filterTV.frame = CGRect(x: 0, y: 85, width: FULLWIDTH-40, height: FULLHEIGHT-380)
            
        }
        
        self.view.backgroundColor = UIColor(named: "colorController")
        filterTV.backgroundColor = UIColor(named: "colorController")
        isSwitchEnable = Utility.shared.isSwitchEnable
        seemoreBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"seeresults"))!)", for: .normal)
        clearBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"clearall"))!)", for: .normal)
        clearBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 14)
        fitertitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"filters"))!)"
        
        fitertitleLabel.textColor = .white
        
        
    }
    
    func FilterAPICall()
    {
        if Utility().isConnectedToNetwork(){
            let priceRangequery = GetDefaultSettingQuery()
            apollo_headerClient.fetch(query: priceRangequery){(result,error) in
               
                guard (result?.data?.getSearchSettings?.results) != nil else{
                    if (result?.data?.getSearchSettings?.status == 400) {
                        self.view.makeToast(result?.data?.getSearchSettings?.errorMessage)
                    }
                    return
                }
                self.getsearchPriceArray = ((result?.data?.getSearchSettings?.results)!)
                guard (result?.data?.getListingSettingsCommon?.results) != nil else{
                    return
                }
                self.RoomsFilterArray = ((result?.data?.getListingSettingsCommon?.results)!) as! [GetDefaultSettingQuery.Data.GetListingSettingsCommon.Result]
                
                self.filterTV.reloadData()
                self.lottieView.isHidden = true
                
            }
        }
        
    }
    
    @IBAction func clearBtnTapped(_ sender: Any) {
        if(RoomsFilterArray.count > 0){
            isClearTap = true
            self.lottieAnimation()
            Utility.shared.instantBook = ""
            Utility.shared.amenitiesArray.removeAllObjects()
            Utility.shared.facilitiesArray.removeAllObjects()
            Utility.shared.houseRulesArray.removeAllObjects()
            self.priceRangeArrayVal.removeAllObjects()
            
            oldVal.removeAllObjects()
            oldhouseRule.removeAllObjects()
            oldfacilitiesRule.removeAllObjects()
            oldaminitiesArray.removeAllObjects()
            oldhouseRule.removeAllObjects()
            Utility.shared.isPriceApplied = false
            oldhouseRule.removeAllObjects()
            oldfacilitiesRule.removeAllObjects()
            oldaminitiesArray.removeAllObjects()
            oldhouseRule.removeAllObjects()
            
            Utility.shared.showGuestCount = false
            Utility.shared.showbedRoomCount = false
            Utility.shared.showbathCount = false
            Utility.shared.showbedCount = false
            
            facilitiesArray.removeAllObjects()
            roomtypeArray.removeAllObjects()
            amenitiesArray.removeAllObjects()
            priceRangeArray.removeAllObjects()
            housingRulesArray.removeAllObjects()
            
            Utility.shared.beds_count = 0
            Utility.shared.bedrooms_count = 0
            Utility.shared.bathroom_count = 0
            Utility.shared.TotalFilterCount = 0
            Utility.shared.filterCount = 1
            if Utility.shared.locationfromSearch == "" || Utility.shared.locationfromSearch == nil {
                Utility.shared.locationfromSearch = nil
            }
            Utility.shared.currentIndex = -1
            if(isSwitchEnable)
            {
                isSwitchEnable = false
                Utility.shared.isSwitchEnable = false
            }
            Utility.shared.selectedstartDate = ""
            Utility.shared.selectedEndDate = ""
            selectedStartDate = nil
            selectedEndDate = nil
            let indexPaths = IndexPath(item: 0, section: 3)
            filterTV.reloadRows(at: [indexPaths], with: .none)
            filterTV.reloadData()
            self.lottieView.isHidden = true
        }
    }
    
    
    
    @IBAction func closeBtnTapped(_ sender: Any) {
      
        if Utility.shared.TotalFilterCount == 0 {
            isClearTap = true
        }
        
        if isClearTap {
            if !isFilterEnable ||  Utility.shared.TotalFilterCount == 0 {
              
                if RoomsFilterArray.count > 0 {
                    Utility.shared.isSwitchEnable = false
                    Utility.shared.isDateApplied = false
                    Utility.shared.instantBook = ""
                    Utility.shared.selectedstartDate = ""
                    Utility.shared.selectedEndDate_filter = ""
                    Utility.shared.selectedstartDate_filter = ""
                    Utility.shared.selectedEndDate = ""
                    Utility.shared.selectedstartDate = ""
                    Utility.shared.selectedstartDate_filter = ""
                    Utility.shared.amenitiesArray.removeAllObjects()
                    
                    Utility.shared.facilitiesArray.removeAllObjects()
                    Utility.shared.houseRulesArray.removeAllObjects()
                    Utility.shared.beds_count = 0
                    Utility.shared.bedrooms_count = 0
                    Utility.shared.bathroom_count = 0
                    Utility.shared.filterCount = 1
                    Utility.shared.min_filter_guest_count = 1
                    
                    oldhouseRule.removeAllObjects()
                    oldfacilitiesRule.removeAllObjects()
                    oldaminitiesArray.removeAllObjects()
                    oldhometypeArray.removeAllObjects()
                    
                    
                    self.priceRangeArrayVal.removeAllObjects()
                    
                    Utility.shared.showGuestCount = false
                    Utility.shared.showbedRoomCount = false
                    Utility.shared.showbathCount = false
                    Utility.shared.showbedCount = false
                    
                    Utility.shared.TotalFilterCount = 1
                    filterTV.reloadData()
                    
                    if(Utility.shared.isSwitchEnable) {
                        Utility.shared.isSwitchEnable = false
                    }
                    
                    AirbnbDatePickerViewController().handleClearInput()
                    Utility.shared.TotalFilterCount = 1
                }
            }
            
            if Utility.shared.roomtypeArray.count > 0 {
                Utility.shared.TotalFilterCount = 1
            }
            
            if Utility.shared.selectedstartDate == "" || Utility.shared.selectedEndDate == ""{
                Utility.shared.selectedstartDate_filter = ""
                Utility.shared.selectedEndDate_filter = ""
                Utility.shared.isUnderline = false
                Utility.shared.TotalFilterCount = 0
                if Utility.shared.filterCount > 2 {
                } else {
                   
                    if Utility.shared.locationfromSearch == "" || Utility.shared.locationfromSearch == nil {
                        Utility.shared.locationfromSearch = nil
                    }
                }
            }
            
            if Utility.shared.selectedstartDate == ""  &&  Utility.shared.isclearfilter == true{
                Utility.shared.TotalFilterCount = 0
            }
            
            if oldVal.count > 0 {
                var priceRangeArrayValCopy = NSMutableArray()
                for value in oldVal {
                    priceRangeArrayValCopy.add(value)
                }
                filterDelegate?.passSelectedPriceRange(priceRange: priceRangeArrayValCopy)
               
            }
            
            filterDelegate?.passSelectedhouserule(priceRange: oldhouseRule)
            filterDelegate?.passSelectedfacilities(priceRange: oldfacilitiesRule)
            filterDelegate?.passSelectedamenities(priceRange: oldaminitiesArray)
            filterDelegate?.passSelectedhometype(priceRange: oldhometypeArray)
            filterDelegate?.passSelectedguestcount(priceRange: Utility.shared.oldguestcount)
            filterDelegate?.passSelectedBedRoomscount(priceRange: Utility.shared.oldbedroomcount )
            filterDelegate?.passSelectedBathRoomscount(priceRange: Utility.shared.oldbathroomcount )
            filterDelegate?.passSelectedBedscount(priceRange: Utility.shared.oldbedscount)
            
            if !clearTapped {
                Utility.shared.isfromdetailpage = true
                Utility.shared.isFromListing = true
                Utility.shared.showClearResult = false
            }else {
                Utility.shared.isfromdetailpage = true
                Utility.shared.isFromListing = false
                Utility.shared.showClearResult = true
            }
            
            delegate?.callSearchAPI()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func seeMoreTapped(_ sender: Any) {
        Utility.shared.isfromMoreFilter = true
        Utility.shared.isDateApplied = false
        
       
        if priceRangeArrayVal.count > 0 {
            let priceRangeArrayValCopy = NSMutableArray()
            Utility.shared.currentIndex = 0
            for value in priceRangeArrayVal {
                priceRangeArrayValCopy.add(value)
            }
            filterDelegate?.passSelectedPriceRange(priceRange: priceRangeArrayValCopy)
           
        }
        
        

        filterDelegate?.passSelectedhouserule(priceRange: housingRulesArray)
        filterDelegate?.passSelectedfacilities(priceRange: facilitiesArray)
        filterDelegate?.passSelectedamenities(priceRange: amenitiesArray)
        
        filterDelegate?.passSelectedguestcount(priceRange: Utility.shared.filterCount)
        filterDelegate?.passSelectedBedRoomscount(priceRange: Utility.shared.bedrooms_count)
        filterDelegate?.passSelectedBathRoomscount(priceRange: Utility.shared.bathroom_count)
        filterDelegate?.passSelectedBedscount(priceRange: Utility.shared.beds_count)
        
        Utility.shared.amenitiesArray = amenitiesArray
        Utility.shared.facilitiesArray = facilitiesArray
        Utility.shared.houseRulesArray =  housingRulesArray
        Utility.shared.isSwitchEnable =  isSwitchEnable
        Utility.shared.selectedEndDate_filter = ""
        Utility.shared.selectedstartDate_filter = ""
    
        
        if(selectedStartDate != nil && selectedEndDate != nil) {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            Utility.shared.selectedstartDate_filter = (dateFormatterGet.string(from: selectedStartDate!))
            Utility.shared.selectedEndDate_filter = (dateFormatterGet.string(from: selectedEndDate!))
        }else{
            Utility.shared.selectedstartDate_filter = ""
            Utility.shared.selectedEndDate_filter = ""
        }
        
        Utility.shared.TotalFilterCount = Utility.shared.amenitiesArray.count + Utility.shared.houseRulesArray.count + Utility.shared.facilitiesArray.count
        
        if(Utility.shared.selectedstartDate_filter != nil && Utility.shared.selectedEndDate_filter != nil && Utility.shared.selectedstartDate_filter != "" && Utility.shared.selectedEndDate_filter != ""){
            Utility.shared.isDateApplied = true
            Utility.shared.TotalFilterCount += 1
        }else{
            Utility.shared.isDateApplied = false
        }
        
        if(Utility.shared.filterCount != 1 && Utility.shared.showGuestCount ){
            numberofguest = Utility.shared.filterCount
            Utility.shared.oldguestcount = Utility.shared.filterCount
            Utility.shared.TotalFilterCount += 1
            Utility.shared.showGuestCount = true
        }else{
            Utility.shared.showGuestCount = false
        }
        if(Utility.shared.isSwitchEnable){
            
            Utility.shared.TotalFilterCount += 1
        }
        
        if(Utility.shared.bedrooms_count > 0 && Utility.shared.showbedRoomCount){
            Utility.shared.TotalFilterCount += 1
            Utility.shared.oldbedroomcount = Utility.shared.bedrooms_count
            Utility.shared.showbedRoomCount = true
        }else{
            Utility.shared.showbedRoomCount = false
        }
        
        if(Utility.shared.bathroom_count > 0 && Utility.shared.showbathCount){
            Utility.shared.TotalFilterCount += 1
            Utility.shared.showbathCount = true
            Utility.shared.oldbathroomcount =  Utility.shared.bathroom_count
        }else{
            Utility.shared.showbathCount = false
        }
        
        if(Utility.shared.beds_count > 0 && Utility.shared.showbedCount){
            Utility.shared.TotalFilterCount += 1
            Utility.shared.showbedCount = true
            Utility.shared.oldbedscount = Utility.shared.beds_count
        }else{
            Utility.shared.showbedCount = false
        }
        
     
        if(priceRangeArrayVal.count != 0){
            Utility.shared.TotalFilterCount += 1
            Utility.shared.isPriceApplied = true
        }else {
            Utility.shared.isPriceApplied = false
        }
      
        if(Utility.shared.TotalFilterCount == 0) {
            if(Utility.shared.locationfromSearch == "" || Utility.shared.locationfromSearch == "empty") {
                Utility.shared.locationfromSearch = nil
            }
        }
        
        if(selectedStartDate != nil && selectedEndDate != nil) &&  Utility.shared.TotalFilterCount == 1 {
            Utility.shared.isclearfilter  = true
        }else{
            Utility.shared.isclearfilter  = false
        }
        
        delegate?.callSearchAPI()

        if(Utility.shared.isfromfloatmap_Page) {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if(RoomsFilterArray.count > 0)
        {
            return 9
        }
        else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            
            return 1
            
        }
        if(section == 1)
        {
            
            return 1
            
        }
        if(section == 2)
        {
            if(RoomsFilterArray.count > 0)
            {
                return 1
            }
            return 0
        }
        else if(section == 3){
            if(((getsearchPriceArray.minPrice) != nil)&&((getsearchPriceArray.maxPrice) != nil))
            {
                if(priceRangeArrayVal.count != 0){
                    return 1
                }
                return 1
            }
            return 0
        }
        else if(section == 4){
            if(RoomsFilterArray.count > 0)
            {
                return 3
            }
            return 0
        }
        else if(section == 5){
            if(RoomsFilterArray.count>0 && RoomsFilterArray[9].listSettings!.count != 0){
                if(isShowmoreClicked){
                    return RoomsFilterArray[9].listSettings!.count
                }
                
                return ((RoomsFilterArray[9].listSettings?.count ?? 0) > 2) ? 2 : (RoomsFilterArray[9].listSettings?.count ?? 0)
            }
            return 0
            
        }
        else if(section == 6){
            if(RoomsFilterArray.count>0 && RoomsFilterArray[11].listSettings!.count != 0){
                if(isfacilitiesmoreClicked){
                    return RoomsFilterArray[11].listSettings!.count
                }
                return ((RoomsFilterArray[11].listSettings?.count ?? 0) > 2) ? 2 : (RoomsFilterArray[11].listSettings?.count ?? 0)
            }
            return 0
        }
        else if(section == 7)
        {
            if(RoomsFilterArray.count>0 && RoomsFilterArray[13].listSettings!.count != 0){
                if(ishousemoreClicked){
                    return RoomsFilterArray[13].listSettings!.count
                }
                return ((RoomsFilterArray[9].listSettings?.count ?? 0) > 2) ? 2 : (RoomsFilterArray[9].listSettings?.count ?? 0)
            }
            return 0
        }
        return 0
    }
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
        if(section == 1){
            return "\((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
        }
        else if(section == 3){
            return "\((Utility.shared.getLanguage()?.value(forKey:"pricerange"))!)"
        }
        else if(section == 4){
            return "\((Utility.shared.getLanguage()?.value(forKey:"roomsandbeds"))!)"
        }
        else if(section == 5){
            return  "\((Utility.shared.getLanguage()?.value(forKey:"amenities"))!)"
        }
        else if(section == 6){
            return "\((Utility.shared.getLanguage()?.value(forKey:"userspace"))!)"
        }
        else if(section == 7){
            return "\((Utility.shared.getLanguage()?.value(forKey:"houserules"))!)"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor =   UIColor(named: "colorController")
        if (section != 8) {
            let lineLabel = UILabel(frame: CGRect(x:15, y:0, width:FULLWIDTH-30, height: 1.0))
            lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
            headerView.addSubview(lineLabel)
        }else{
            
        }
        
        let headerLabel = UILabel(frame: CGRect(x: 20, y:10, width:
                                                    tableView.bounds.size.width-40, height: 40))
        headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size:16)
        headerLabel.textColor =  UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
      
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if((section==2) || (section==0)){
            return 0
        }
        return 50
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        
        if(section == 5){
            if(!isShowmoreClicked){
                return  "\((Utility.shared.getLanguage()?.value(forKey:"showmore")) ?? "Show more")"
            }
            return "\((Utility.shared.getLanguage()?.value(forKey:"showless")) ?? "Show Less")"
        }
        else if(section == 6){
            if(!isfacilitiesmoreClicked){
                return "\((Utility.shared.getLanguage()?.value(forKey:"showmore")) ?? "Show more")"
            }
            return "\((Utility.shared.getLanguage()?.value(forKey:"showless")) ?? "Show Less")"
        }
        else if(section == 7){
            if(!ishousemoreClicked){
                return "\((Utility.shared.getLanguage()?.value(forKey:"showmore")) ?? "Show more")"
            }
            else{
                return "\((Utility.shared.getLanguage()?.value(forKey:"showless")) ?? "Show Less")"
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView()
       
        if((section==5 && (RoomsFilterArray[9].listSettings?.count ?? 0) > 2)||(section==6 &&  (RoomsFilterArray[11].listSettings?.count ?? 0) > 2)||(section==7 &&  (RoomsFilterArray[13].listSettings?.count ?? 0) > 2))
        {
            let showmore = UIButton()
            let overlaybtn = UIButton()
            let downArrow = UIImageView()
            let footerText  = (self.tableView(tableView, titleForFooterInSection: section))
            
            downArrow.tintColor = Theme.PRIMARY_COLOR
            showmore.frame = CGRect(x:20, y:0, width:80, height:45)
            downArrow.frame = CGRect(x:showmore.frame.size.width+18, y:20.5, width:9, height: 6)
            overlaybtn.frame = CGRect(x:20, y:0, width:showmore.frame.size.width + downArrow.frame.size.width, height:35)
            overlaybtn.setTitle("", for: .normal)
            if(footerText == "\((Utility.shared.getLanguage()?.value(forKey:"showmore")) ?? "Show more")") {
                downArrow.image = UIImage(#imageLiteral(resourceName: "downarrow-green"))
            }
            else {
                downArrow.image = UIImage(#imageLiteral(resourceName: "upArrow"))
            }
            if Utility.shared.isRTLLanguage(){
                if(section==5){
                    showmore.frame = CGRect(x:FULLWIDTH-90, y:0, width:tableView.bounds.size.width, height:45)
                    overlaybtn.frame = CGRect(x:FULLWIDTH-90, y:0, width:showmore.frame.size.width + downArrow.frame.size.width, height:35)
                }
                if (section==6) {
                    showmore.frame = CGRect(x:FULLWIDTH-90, y:0, width:tableView.bounds.size.width, height:45)
                    overlaybtn.frame = CGRect(x:FULLWIDTH-90, y:0, width:showmore.frame.size.width + downArrow.frame.size.width, height:35)
                }
                if (section==7) {
                    showmore.frame = CGRect(x:FULLWIDTH-90, y:0, width:tableView.bounds.size.width, height:45)
                    overlaybtn.frame = CGRect(x:FULLWIDTH-90, y:0, width:showmore.frame.size.width + downArrow.frame.size.width, height:35)
                }
                downArrow.frame = CGRect(x:showmore.frame.origin.x - 35 + 20, y:20, width: 9, height: 6)
            }
            showmore.backgroundColor = UIColor(named: "colorController")
            showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
            showmore.titleLabel?.font =  UIFont(name: APP_FONT, size:14)
            showmore.contentHorizontalAlignment = .left
            showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
            overlaybtn.tag = section
            overlaybtn.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
            
            footerView.addSubview(showmore)
            footerView.addSubview(downArrow)
            footerView.addSubview(overlaybtn)
        }
        
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if((section==5)||(section==6)||(section==7)){
            return 50
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0)
        {
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 1)
        {
            return 50
        }
        else if(indexPath.section == 2)
        {
            return 95
        }
        else if(indexPath.section==3){
            return 120
        }else if (indexPath.section == 5){
            return UITableView.automaticDimension
        }
        else if(indexPath.section == 4){
            return 70
        }
        
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath)as! DateCell
            cell.dateView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
            cell.selectionStyle = .none
            cell.dateBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
            if Utility.shared.selectedstartDate == "" && Utility.shared.selectedEndDate == "" {
                cell.dateLabel.text = " \(Utility.shared.getLanguage()?.value(forKey:"seldate") ?? "")"
                
            } else {
                if Utility.shared.TotalFilterCount > 0 && !didsaveCurrentpage{
                    didsaveCurrentpage = false
                    if Utility.shared.isDateApplied {
                        let calendar = Calendar.current
                        let sampleDateFormat = DateFormatter()
                        sampleDateFormat.locale = Locale(identifier: "en_US_POSIX")
                        
                        sampleDateFormat.dateFormat = "yyyy-MM-dd"
                        let firstDate = sampleDateFormat.date(from: Utility.shared.selectedstartDate)
                        let secondDate = sampleDateFormat.date(from: Utility.shared.selectedEndDate)
                        
                        
                        if firstDate == secondDate {
                            self.selectedStartDate = firstDate
                            self.selectedEndDate = secondDate
                            cell.dateLabel.text = "  \(dateFormatter.string(from: selectedStartDate!))"
                            
                        }
                        else {
                            self.selectedStartDate = firstDate
                            self.selectedEndDate = secondDate
                            cell.dateLabel.text = "  \(dateFormatter.string(from: selectedStartDate!)) - \(dateFormatter.string(from: selectedEndDate!))"
                        }
                    }else{
                        cell.dateLabel.text = " \(Utility.shared.getLanguage()?.value(forKey:"seldate") ?? "")"
                    }
                } else {
                    didsaveCurrentpage = false
                    let calendar = Calendar.current
                    let sampleDateFormat = DateFormatter()
                    sampleDateFormat.locale = Locale(identifier: "en_US_POSIX")
                    
                    sampleDateFormat.dateFormat = "yyyy-MM-dd"
                    let firstDate = sampleDateFormat.date(from: Utility.shared.selectedstartDate)
                    let secondDate = sampleDateFormat.date(from: Utility.shared.selectedEndDate)
                    
                    
                    if firstDate == secondDate {
                        self.selectedStartDate = firstDate
                        self.selectedEndDate = secondDate
                        cell.dateLabel.text = "  \(dateFormatter.string(from: selectedStartDate!))"
                        
                    }
                    else {
                        self.selectedStartDate = firstDate
                        self.selectedEndDate = secondDate
                        cell.dateLabel.text = "  \(dateFormatter.string(from: selectedStartDate!)) - \(dateFormatter.string(from: selectedEndDate!))"
                    }
                }
            }
            cell.dateBtn.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
            
            return cell
            
        } else if(indexPath.section == 1){
            count = 0
            minCount = 0
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath)as! RoomsCell
            cell.roomsTitleLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            if(indexPath.row == 0){
                cell.roomsTitleLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey:"Addguest") ?? "Add guest")"
             
                if(!Utility.shared.showGuestCount) {
                    Utility.shared.filterCount = Utility.shared.min_filter_guest_count
                    cell.countshowLabel.text =  String(Utility.shared.min_filter_guest_count)
                }
                else {
                  
                    cell.countshowLabel.text =  String(Utility.shared.filterCount)
                }
            }
            
            if cell.countshowLabel.text == String(Utility.shared.min_filter_guest_count){
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
            }else{
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1.0
            }
            
            if cell.countshowLabel.text == String(Utility.shared.maximum_guest_count){
                cell.plusBtn.isEnabled = false
                cell.plusBtn.alpha = 0.5
            } else {
                cell.plusBtn.isEnabled = true
                cell.plusBtn.alpha = 1.0
            }
            
            cell.plusBtn.layer.cornerRadius = cell.plusBtn.frame.size.width/2
            cell.plusBtn.layer.borderWidth = 1.0
            cell.plusBtn.tag = indexPath.section
            cell.minusBtn.tag = indexPath.section
            
            cell.plusBtn.removeTarget(self, action: #selector(plusBtnTappedFilter), for: .touchUpInside)
            cell.plusBtn.addTarget(self, action: #selector(plusBtnTappedFilter), for: .touchUpInside)
            cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.minusBtn.layer.cornerRadius = cell.minusBtn.frame.size.width/2
            cell.minusBtn.layer.borderWidth = 1.0
            cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.minusBtn.removeTarget(self, action: #selector(minusBtnTappedFilter), for: .touchUpInside)
            cell.minusBtn.addTarget(self, action: #selector(minusBtnTappedFilter), for: .touchUpInside)
            cell.tag = indexPath.section+8000
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.dashView.backgroundColor = UIColor.green
          
            return cell
            
        }
        
        else if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstantBookCell", for: indexPath)as! InstantBookCell
            cell.instantbookLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"instantbook"))!)"
            cell.DecsriptionLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"booktext")) ?? "")"
            cell.DecsriptionLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            cell.tag = indexPath.row+8000
            
           
            if(isSwitchEnable){
                if(Utility.shared.isRTLLanguage()) {
                    cell.lotSwitch.transform = CGAffineTransform(scaleX: -1, y: 1)
                }
                cell.lotSwitch.isOn = true
                cell.lotSwitch.isSelected = true
                Utility.shared.isSwitchEnable = true
            }
            else{
                cell.lotSwitch.isOn = false
                cell.lotSwitch.isSelected = true
                cell.lotSwitch.isEnabled = true
                Utility.shared.isSwitchEnable = false
                
            }
            
          
            cell.lotSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
           
            return cell
        }
        else if(indexPath.section == 3) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PriceRangeCell", for: indexPath)as! PriceRangeCell
            cell.sliderView.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
            cell.tag = 9000
            cell.priceshowLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
        
            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "") {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                let from_currency = (getsearchPriceArray.priceRangeCurrency!)
                let currency_amount = CGFloat(getsearchPriceArray.minPrice != nil ? getsearchPriceArray.minPrice! : 0)
                let max_currency_amount = CGFloat(getsearchPriceArray.maxPrice!)
                let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:Double(currency_amount))
                
                let price_value1 = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:Double(max_currency_amount))
                let restricted_price =  Double(String(format: "%.2f",price_value))
                if(priceRangeArrayVal.count != 0){
                    if Utility.shared.isPriceApplied && Utility.shared.TotalFilterCount > 0{
                        cell.sliderView.minValue = CGFloat(restricted_price!)
                        cell.sliderView.maxValue = CGFloat(price_value1)
                        self.minvalue = Int(restricted_price!)
                        self.maxValue = Int(price_value1)
                        cell.sliderView.selectedMinValue = priceRangeArrayVal[0] as! CGFloat
                        cell.sliderView.selectedMaxValue = priceRangeArrayVal[1] as! CGFloat
                        cell.priceshowLabel.text = "\(currencysymbol!)\(priceRangeArrayVal[0] as! Int) - \(currencysymbol!)\(priceRangeArrayVal[1] as! Int)"
                    }
                    
                    else{
                        cell.sliderView.minValue = CGFloat(restricted_price!)
                        cell.sliderView.maxValue = CGFloat(price_value1)
                        self.minvalue = Int(restricted_price!)
                        self.maxValue = Int(price_value1)
                        cell.sliderView.selectedMinValue = CGFloat(restricted_price!)
                        cell.sliderView.selectedMaxValue = CGFloat(price_value1)
                        cell.sliderView.selectedMinValue = CGFloat(restricted_price!)
                        cell.sliderView.selectedMaxValue = CGFloat(price_value1)
                        cell.priceshowLabel.text = "\(currencysymbol!)\(Int(restricted_price!)) - \(currencysymbol!)\(Int(price_value1))"
                    }
                }else{
                    cell.sliderView.minValue = CGFloat(restricted_price!)
                    cell.sliderView.maxValue = CGFloat(price_value1)
                    self.minvalue = Int(restricted_price!)
                  
                    self.maxValue = Int(price_value1)
                    cell.sliderView.selectedMinValue = CGFloat(restricted_price!)
                    cell.sliderView.selectedMaxValue = CGFloat(price_value1)
                    cell.sliderView.selectedMinValue = CGFloat(restricted_price!)
                    cell.sliderView.selectedMaxValue = CGFloat(price_value1)
                    cell.priceshowLabel.text = "\(currencysymbol!)\(Int(restricted_price!)) - \(currencysymbol!)\(Int(price_value1))"
                }
                cell.sliderView.numberFormatter.positivePrefix = Utility.shared.getSymbol(forCurrencyCode: (Utility.shared.getPreferredCurrency()!))
                
            } else{
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                let from_currency = (getsearchPriceArray.priceRangeCurrency!)
                let currency_amount = CGFloat(getsearchPriceArray.minPrice != nil ? getsearchPriceArray.minPrice! : 0)
              
                let max_currency_amount = CGFloat(getsearchPriceArray.maxPrice!)
                let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate:Utility.shared.currency_Dict, amount:Double(currency_amount))
                let restricted_price =  Double(String(format: "%.2f",price_value))
                let price_value1 = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate:Utility.shared.currency_Dict, amount:Double(max_currency_amount))
                if(priceRangeArrayVal.count != 0){
                    if Utility.shared.isPriceApplied && Utility.shared.TotalFilterCount > 0{
                        cell.sliderView.minValue = CGFloat(price_value)
                        cell.sliderView.maxValue = CGFloat(price_value1)
                        cell.sliderView.selectedMinValue = priceRangeArrayVal[0] as! CGFloat
                        cell.sliderView.selectedMaxValue = priceRangeArrayVal[1] as! CGFloat
                        self.minvalue = Int(restricted_price!)
                        self.maxValue = Int(price_value1)
                        cell.priceshowLabel.text = "\(currencysymbol!)\(priceRangeArrayVal[0] as! Int) - \(currencysymbol!)\(priceRangeArrayVal[1] as! Int)"
                    }else{
                        cell.sliderView.minValue = CGFloat(restricted_price!)
                        cell.sliderView.maxValue = CGFloat(price_value1)
                        cell.sliderView.selectedMinValue = CGFloat(restricted_price!)
                        cell.sliderView.selectedMaxValue = CGFloat(price_value1)
                        self.minvalue = Int(restricted_price!)
                        self.maxValue = Int(price_value1)
                        cell.priceshowLabel.text = "\(currencysymbol!)\(Int(restricted_price!)) - \(currencysymbol!)\(Int(price_value1))"
                        
                    }
                }else{
                    cell.sliderView.minValue = CGFloat(restricted_price!)
                    cell.sliderView.maxValue = CGFloat(price_value1)
                    self.minvalue = Int(restricted_price!)
                   
                    self.maxValue = Int(price_value1)
                    cell.sliderView.selectedMinValue = CGFloat(restricted_price!)
                    cell.sliderView.selectedMaxValue = CGFloat(price_value1)
                    cell.priceshowLabel.text = "\(currencysymbol!)\(Int(restricted_price!)) - \(currencysymbol!)\(Int(price_value1))"
                }
                cell.sliderView.numberFormatter.positivePrefix = Utility.shared.getSymbol(forCurrencyCode: (Utility.shared.currencyvalue_from_API_base))
            }
            
            
            cell.sliderView.delegate = self
            
            cell.sliderView.numberFormatter.maximumFractionDigits = 2
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.sliderView.numberFormatter.numberStyle = .currency
            cell.sliderView.minLabelFont = UIFont.boldSystemFont(ofSize:14)
            cell.sliderView.maxLabelFont = UIFont.boldSystemFont(ofSize:14)
          
            return cell
        }
        else if(indexPath.section == 4){
            count = 0
            minCount = 0
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath)as! RoomsCell
            cell.roomsTitleLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            if(indexPath.row == 0){
                cell.roomsTitleLabel.text = RoomsFilterArray[4].typeLabel
                
                if(!Utility.shared.showbedRoomCount) {
                    
                    
                    Utility.shared.bedrooms_count = Utility.shared.min_filter_bedroom_count
                    cell.countshowLabel.text =  String(Utility.shared.min_filter_bedroom_count)
                }
                else {
                    cell.countshowLabel.text =  String(Utility.shared.bedrooms_count)
                }
                
                if cell.countshowLabel.text == String(Utility.shared.min_filter_bedroom_count){
                    cell.minusBtn.isEnabled = false
                    cell.minusBtn.alpha = 0.5
                }else{
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1.0
                }
                
                if cell.countshowLabel.text == String(RoomsFilterArray[4].listSettings![0]!.endValue!){
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.alpha = 0.5
                }else{
                    cell.plusBtn.isEnabled = true
                    cell.plusBtn.alpha = 1.0
                }
              
            }
            else if(indexPath.row == 1){
                
                if(!Utility.shared.showbedCount) {
                  
                    Utility.shared.beds_count = Utility.shared.min_filter_bed_count
                    cell.countshowLabel.text =  String(Utility.shared.min_filter_bed_count)
                }
                else {
                    cell.countshowLabel.text =  String(Utility.shared.beds_count)
                }
                
                if cell.countshowLabel.text == String(Utility.shared.min_filter_bed_count){
                    cell.minusBtn.isEnabled = false
                    cell.minusBtn.alpha = 0.5
                }else{
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1.0
                }
                
                if cell.countshowLabel.text == String(RoomsFilterArray[5].listSettings![0]!.endValue!){
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.alpha = 0.5
                }else{
                    cell.plusBtn.isEnabled = true
                    cell.plusBtn.alpha = 1.0
                }
                
                cell.roomsTitleLabel.text = RoomsFilterArray[5].typeLabel
              
            }
            else{
                
                cell.roomsTitleLabel.text = RoomsFilterArray[7].typeLabel
                cell.countshowLabel.text =  String(Utility.shared.bathroom_count)
                
                if(!Utility.shared.showbathCount) {
                   
                    Utility.shared.bathroom_count = Utility.shared.min_filter_bath_count
                    cell.countshowLabel.text =  String(Utility.shared.min_filter_bath_count)
                }
                else {
                    cell.countshowLabel.text =  String(Utility.shared.bathroom_count)
                }
                
                if cell.countshowLabel.text == String(Utility.shared.min_filter_bath_count){
                    cell.minusBtn.isEnabled = false
                    cell.minusBtn.alpha = 0.5
                }else{
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1.0
                }
                
                if cell.countshowLabel.text == String(RoomsFilterArray[7].listSettings![0]!.endValue!){
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.alpha = 0.5
                }else{
                    cell.plusBtn.isEnabled = true
                    cell.plusBtn.alpha = 1.0
                }
            }
            
            
            cell.plusBtn.layer.cornerRadius = cell.plusBtn.frame.size.width/2
            cell.plusBtn.layer.borderWidth = 1.0
            cell.plusBtn.tag = indexPath.row
            cell.minusBtn.tag = indexPath.row
            
            cell.plusBtn.removeTarget(self, action: #selector(plusBtnTapped), for: .touchUpInside)
            cell.plusBtn.addTarget(self, action: #selector(plusBtnTapped), for: .touchUpInside)
            cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.minusBtn.layer.cornerRadius = cell.minusBtn.frame.size.width/2
            cell.minusBtn.layer.borderWidth = 1.0
            cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.minusBtn.removeTarget(self, action: #selector(minusBtnTapped), for: .touchUpInside)
            cell.minusBtn.addTarget(self, action: #selector(minusBtnTapped), for: .touchUpInside)
            cell.tag = indexPath.row+6000
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            return cell
            
        }
        else if(indexPath.section == 5){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenitiesCell", for: indexPath)as! AmenitiesCell
            cell.amenitieslistTile.font = UIFont(name: APP_FONT, size: 14)
            cell.amenitieslistTile.textColor  =  UIColor(named: "searchPlaces_TextColor")
            cell.checkBtn.borderWidth = 1.5
            cell.amenitieslistTile.text = RoomsFilterArray[9].listSettings![indexPath.row]?.itemName
            cell.tag = indexPath.row+3000
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lineView.isHidden = true
            if(cell.amenitieslistTile.text!.count > 25)
            {
                cell.amenitieslistTile.frame = CGRect(x: 20, y: 5, width:250, height:70)
                cell.amenitieslistTile.numberOfLines = 2
                
            }
            else {
                cell.amenitieslistTile.frame = CGRect(x: 20, y:25, width:250, height:26)
                cell.amenitieslistTile.numberOfLines = 2
            }
            
            if let image = RoomsFilterArray[9].listSettings![indexPath.row]?.image{
                cell.amenitiesImgIcon.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: image))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                    cell.amenitiesImgIcon.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.amenitiesImgIcon.image = UIImage(named: "amenitiesImage")
            }
            cell.amenitiesImgIcon.tintColor = UIColor(named: "Title_Header")
            if(amenitiesArray.contains(RoomsFilterArray[9].listSettings![indexPath.row]?.id as Any))
            {
                
                cell.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell.checkBtn.tintColor = Theme.PRIMARY_COLOR
            }
            else{
                cell.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
            cell.checkBtn.tag = indexPath.row
            cell.checkBtn.isUserInteractionEnabled = false
            cell.checkBtn.addTarget(self, action: #selector(amenitiescheckBtnTapped(_:)), for: .touchUpInside)
            return cell
            
        }
        else if(indexPath.section == 6){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FacilitiesCell", for: indexPath)as! FacilitiesCell
            cell.amenitieslistTile.textColor  =  UIColor(named: "searchPlaces_TextColor")
            cell.amenitieslistTile.text = RoomsFilterArray[11].listSettings![indexPath.row]?.itemName
            cell.tag = indexPath.row+4000
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if(cell.amenitieslistTile.text!.count > 25)
            {
                cell.amenitieslistTile.frame = CGRect(x: 20, y: 5, width:250, height:60)
                cell.amenitieslistTile.numberOfLines = 2
                
            }
            else {
                cell.amenitieslistTile.frame = CGRect(x: 20, y:25, width:250, height:26)
                cell.amenitieslistTile.numberOfLines = 2
            }
            
            if let image = RoomsFilterArray[11].listSettings![indexPath.row]?.image{
                cell.facilitiesImgIcon.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: image))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                    cell.facilitiesImgIcon.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.facilitiesImgIcon.image = UIImage(named: "amenitiesImage")
            }
                cell.facilitiesImgIcon.tintColor = UIColor(named: "Title_Header")
            
            if(facilitiesArray.contains(RoomsFilterArray[11].listSettings![indexPath.row]?.id as Any))
            {
                cell.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell.checkBtn.tintColor = Theme.PRIMARY_COLOR
            }
            else{
                cell.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
            cell.checkBtn.tag = indexPath.row
            cell.checkBtn.isUserInteractionEnabled = false
            cell.checkBtn.addTarget(self, action: #selector(facilitiescheckBtnTapped(_:)), for: .touchUpInside)
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HouseRulesCell", for: indexPath)as! HouseRulesCell
            cell.amenitieslistTile.textColor  =  UIColor(named: "searchPlaces_TextColor")
            cell.amenitieslistTile.text = RoomsFilterArray[13].listSettings![indexPath.row]?.itemName
            cell.tag = indexPath.row+5000
            
            if(cell.amenitieslistTile.text!.count > 25)
            {
                cell.amenitieslistTile.frame = CGRect(x: 20, y: 5, width:250, height:60)
                cell.amenitieslistTile.numberOfLines = 2
                
            }
            else {
                cell.amenitieslistTile.frame = CGRect(x: 20, y:25, width:250, height:26)
                cell.amenitieslistTile.numberOfLines = 2
            }
            if(housingRulesArray.contains(RoomsFilterArray[13].listSettings![indexPath.row]?.id as Any))
            {
                cell.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell.checkBtn.tintColor = Theme.PRIMARY_COLOR
            }
            else{
                cell.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
            cell.checkBtn.tag = indexPath.row
            cell.checkBtn.isUserInteractionEnabled = false
            cell.checkBtn.addTarget(self, action: #selector(houseRulescheckBtnTapped(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.section == 0) {
            Utility.shared.isfromcheckingPage = false
            let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
            datePickerViewController.isFromFilter = true
            datePickerViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: datePickerViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
        
        else if((indexPath.section == 1) || (indexPath.section == 2) || (indexPath.section == 3) || (indexPath.section == 4))
        {
          
        }
    
        else if(indexPath.section == 5){
            let cell = view.viewWithTag(indexPath.row + 3000) as? AmenitiesCell
            if(amenitiesArray.contains(RoomsFilterArray[9].listSettings![indexPath.row]?.id as Any))
            {
                amenitiesArray.remove(RoomsFilterArray[9].listSettings![indexPath.row]?.id as Any)
               
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
            else{
                
                
                amenitiesArray.add(RoomsFilterArray[9].listSettings![indexPath.row]?.id as Any)
                
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
            }
            let indexPath = IndexPath(row:indexPath.row, section: 5)
            filterTV.reloadRows(at: [indexPath], with: .none)
        }
        else if(indexPath.section == 6){
            let cell = view.viewWithTag(indexPath.row + 4000) as? FacilitiesCell
          
            if(facilitiesArray.contains(RoomsFilterArray[11].listSettings![indexPath.row]?.id as Any))
            {
                facilitiesArray.remove(RoomsFilterArray[11].listSettings![indexPath.row]?.id as Any)
               
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
            else{
                
                
                facilitiesArray.add(RoomsFilterArray[11].listSettings![indexPath.row]?.id as Any)
                
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
            }
            let indexPath = IndexPath(row:indexPath.row, section: 6)
            filterTV.reloadRows(at: [indexPath], with: .none)
        }
        else {
            
            let cell = view.viewWithTag(indexPath.row + 5000) as? HouseRulesCell
          
            if(housingRulesArray.contains(RoomsFilterArray[13].listSettings![indexPath.row]?.id as Any))
            {
                housingRulesArray.remove(RoomsFilterArray[13].listSettings![indexPath.row]?.id as Any)
               
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            }
            else{
                
                
                housingRulesArray.add(RoomsFilterArray[13].listSettings![indexPath.row]?.id as Any)
                
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
                cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
            }
            let indexPath = IndexPath(row:indexPath.row, section: indexPath.section)
            filterTV.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    @objc func showDatePicker() {
        Utility.shared.isfromcheckingPage = false
        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
        datePickerViewController.isFromFilter = true
        
        datePickerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    func datePickerController(_ datePickerController: AirbnbDatePickerViewController, didSaveStartDate startDate: Date?, endDate: Date?) {
        
        didsaveCurrentpage = true
        selectedStartDate = startDate
        selectedEndDate = endDate
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        
        if(startDate != nil && endDate != nil){
            Utility.shared.selectedstartDate = (dateFormatterGet.string(from: startDate!))
            Utility.shared.selectedEndDate = (dateFormatterGet.string(from: endDate!))
        }
        else if(startDate != nil){
            Utility.shared.selectedstartDate = (dateFormatterGet.string(from: startDate!))
            Utility.shared.selectedEndDate = (dateFormatterGet.string(from: startDate!))
        }
        else
        {
            Utility.shared.selectedstartDate = ""
            Utility.shared.selectedEndDate = ""
        }
        
        if selectedStartDate == nil && selectedEndDate == nil {
            
        } else {
            
            
        }
        
        self.filterTV.reloadData()
    }
    
    
    @objc func amenitiescheckBtnTapped(_ sender: UIButton)
    {
        
        let cell = view.viewWithTag(sender.tag + 3000) as? AmenitiesCell
      
        if(amenitiesArray.contains(RoomsFilterArray[9].listSettings![sender.tag]?.id as Any))
        {
            amenitiesArray.remove(RoomsFilterArray[9].listSettings![sender.tag]?.id as Any)
           
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
        else{
            
            amenitiesArray.add(RoomsFilterArray[9].listSettings![sender.tag]?.id as Any)
            
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        }
        let indexPath = IndexPath(row:sender.tag, section: 5)
        filterTV.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc func facilitiescheckBtnTapped(_ sender: UIButton)
    {
        let cell = view.viewWithTag(sender.tag + 4000) as? FacilitiesCell
      
        if(facilitiesArray.contains(RoomsFilterArray[11].listSettings![sender.tag]?.id as Any))
        {
            facilitiesArray.remove(RoomsFilterArray[11].listSettings![sender.tag]?.id as Any)
          
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
        else{
            
            facilitiesArray.add(RoomsFilterArray[11].listSettings![sender.tag]?.id as Any)
            
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        }
        
    }
    
    @objc func houseRulescheckBtnTapped(_ sender: UIButton)
    {
        let cell = view.viewWithTag(sender.tag + 5000) as? HouseRulesCell
       
        if(housingRulesArray.contains(RoomsFilterArray[13].listSettings![sender.tag]?.id as Any))
        {
            housingRulesArray.remove(RoomsFilterArray[13].listSettings![sender.tag]?.id as Any)
           
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        }
        else{
            
            
            housingRulesArray.add(RoomsFilterArray[13].listSettings![sender.tag]?.id as Any)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        }
        
    }
    @objc func addBtnTapped(_ sender: UIButton){
        let btnsendtag: UIButton = sender
        
        if(btnsendtag.tag == 5){
            if(isShowmoreClicked){
                isShowmoreClicked = false
            }
            else {
                isShowmoreClicked = true
                
            }
        }
        else if(btnsendtag.tag == 6){
            if(isfacilitiesmoreClicked){
                isfacilitiesmoreClicked = false
            }
            else {
                isfacilitiesmoreClicked = true
                
            }
        }
        else if(btnsendtag.tag == 7)
        {
            if(ishousemoreClicked){
                ishousemoreClicked = false
            }
            else {
                ishousemoreClicked = true
                
            }
        }
        
        
        
        filterTV.reloadSections([btnsendtag.tag], with: .fade)
       
        
    }
    
    @objc func switchToggled(_ sender:UISwitch) {
        
        
        let cell = view.viewWithTag(sender.tag + 8000) as! InstantBookCell
        
        cell.lotSwitch.setOn(!sender.isOn, animated: false)
        if(cell.lotSwitch.isOn){
            cell.lotSwitch.isOn = false
            isSwitchEnable = false
        }
        else{
            cell.lotSwitch.isOn = true
            isSwitchEnable = true
        }
        
    
        
    }
    
    @objc func plusBtnTapped(_ sender: UIButton){
        
        if(sender.tag == (sender.tag + 6001)) {
            let cell = view.viewWithTag(sender.tag + 6000) as! RoomsCell
            count = Int(cell.countshowLabel.text!)!
            count += 1
            if(sender.tag == 0){
                Utility.shared.showbedRoomCount = true
                maxCount = RoomsFilterArray[4].listSettings![0]!.endValue!
            }
            else if(sender.tag == 1)
            {
                Utility.shared.showbedCount = true
                maxCount = RoomsFilterArray[5].listSettings![0]!.endValue!
            }
            else if(sender.tag == (sender.tag + 6001)){
                maxCount = Utility.shared.maximum_guest_count
            }
            else{
                Utility.shared.showbathCount = true
                maxCount = RoomsFilterArray[7].listSettings![0]!.endValue!
            }
            
            if count < maxCount {
                if((count >= minCount) && (count <= maxCount)){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    if(sender.tag == 0){
                        Utility.shared.bedrooms_count = count
                    }
                    else if(sender.tag == 1)
                    {
                        Utility.shared.beds_count = count
                    }
                    else if(sender.tag == (sender.tag + 6001)) {
                        Utility.shared.filterCount = count
                    }
                    else{
                        Utility.shared.bathroom_count = count
                    }
                    
                }
                cell.plusBtn.isEnabled = true
                cell.plusBtn.alpha = 1
                cell.countshowLabel.text = String(count)
                if(sender.tag == 0){
                    Utility.shared.bedrooms_count = count
                }
                else if(sender.tag == 1)
                {
                    Utility.shared.beds_count = count
                }
                else if(sender.tag == (sender.tag + 6001)) {
                    Utility.shared.filterCount = count
                }
                else{
                    Utility.shared.bathroom_count = count
                }
                
                
            }
            else {
                if((count >= minCount) && (count <= maxCount)){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    
                    if(sender.tag == 0){
                        Utility.shared.bedrooms_count = count
                    }
                    else if(sender.tag == 1)
                    {
                        Utility.shared.beds_count = count
                    }
                    else if(sender.tag == (sender.tag + 6001)) {
                        Utility.shared.filterCount = count
                    }
                    else{
                        Utility.shared.bathroom_count = count
                    }
                }
                
                cell.plusBtn.isEnabled = false
                cell.plusBtn.alpha = 0.5
            }
            
        }
        
        else {
            let cell = view.viewWithTag(sender.tag + 6000) as! RoomsCell
            count = Int(cell.countshowLabel.text!)!
            count += 1
            if(sender.tag == 0){
                Utility.shared.showbedRoomCount = true
                maxCount = RoomsFilterArray[4].listSettings![0]!.endValue!
            }
            else if(sender.tag == 1)
            {
                Utility.shared.showbedCount = true
                maxCount = RoomsFilterArray[5].listSettings![0]!.endValue!
            }
            else if(sender.tag == (sender.tag + 6001)){
                maxCount = Utility.shared.maximum_guest_count
            }
            else{
                Utility.shared.showbathCount = true
                maxCount = RoomsFilterArray[7].listSettings![0]!.endValue!
            }
            
            if count < maxCount {
                if((count >= minCount) && (count <= maxCount)){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    if(sender.tag == 0){
                        Utility.shared.bedrooms_count = count
                    }
                    else if(sender.tag == 1)
                    {
                        Utility.shared.beds_count = count
                    }
                    else if(sender.tag == (sender.tag + 6001)) {
                        Utility.shared.filterCount = count
                    }
                    else{
                        Utility.shared.bathroom_count = count
                    }
                    
                }
                cell.plusBtn.isEnabled = true
                cell.plusBtn.alpha = 1
                cell.countshowLabel.text = String(count)
                if(sender.tag == 0){
                    Utility.shared.bedrooms_count = count
                }
                else if(sender.tag == 1)
                {
                    Utility.shared.beds_count = count
                }
                else if(sender.tag == (sender.tag + 6001)) {
                    Utility.shared.filterCount = count
                }
                else{
                    Utility.shared.bathroom_count = count
                }
                
                
            }
            else {
                if((count >= minCount) && (count <= maxCount)){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    
                    if(sender.tag == 0){
                        Utility.shared.bedrooms_count = count
                    }
                    else if(sender.tag == 1)
                    {
                        Utility.shared.beds_count = count
                    }
                    else if(sender.tag == (sender.tag + 6001)) {
                        Utility.shared.filterCount = count
                    }
                    else{
                        Utility.shared.bathroom_count = count
                    }
                }
                
                cell.plusBtn.isEnabled = false
                cell.plusBtn.alpha = 0.5
            }
        }
      
    }
    @objc func minusBtnTapped(_ sender: UIButton){
        if(sender.tag == (sender.tag + 6001)) {
            let cell = view.viewWithTag(sender.tag + 6000) as! RoomsCell
            count = Int(cell.countshowLabel.text!)!
            count -= 1
            cell.plusBtn.isEnabled = true
            cell.plusBtn.alpha = 1
            if(sender.tag == 0){
                maxCount = 0
            }
            else if(sender.tag == 1)
            {
                maxCount = 0
            }
         
            else{
                maxCount = 0
            }
            
            if count > maxCount {
                if(count <= maxCount){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    if(sender.tag == 0){
                        Utility.shared.bedrooms_count = count
                    }
                    else if(sender.tag == 1)
                    {
                        Utility.shared.beds_count = count
                    }
                    else if(sender.tag == (sender.tag + 6001)) {
                        Utility.shared.filterCount = count
                    }
                    else{
                        Utility.shared.bathroom_count = count
                    }
                }
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1
                cell.countshowLabel.text = String(count)
                if(sender.tag == 0){
                    Utility.shared.bedrooms_count = count
                }
                else if(sender.tag == 1)
                {
                    Utility.shared.beds_count = count
                }
                else if(sender.tag == (sender.tag + 6001)) {
                    Utility.shared.filterCount = count
                }
                else{
                    Utility.shared.bathroom_count = count
                }
            }
            
            else {
                
                cell.countshowLabel.text = String(count)
                if(sender.tag == 0){
                    Utility.shared.bedrooms_count = count
                }
                else if(sender.tag == 1)
                {
                    Utility.shared.beds_count = count
                }
                else if(sender.tag == (sender.tag + 6001)) {
                    Utility.shared.filterCount = count
                }
                else{
                    Utility.shared.bathroom_count = count
                }
                
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
            }
        }
        
        else {
            let cell = view.viewWithTag(sender.tag + 6000) as! RoomsCell
            count = Int(cell.countshowLabel.text!)!
            count -= 1
            cell.plusBtn.isEnabled = true
            cell.plusBtn.alpha = 1
            if(sender.tag == 0){
                maxCount = 0
            }
            else if(sender.tag == 1)
            {
                maxCount = 0
            }
            else if(sender.tag == (sender.tag + 6001)) {
                maxCount = Utility.shared.min_filter_guest_count
            }
            else{
                maxCount = 0
            }
            
            if count > maxCount {
                if(count <= maxCount){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    if(sender.tag == 0){
                        Utility.shared.bedrooms_count = count
                    }
                    else if(sender.tag == 1)
                    {
                        Utility.shared.beds_count = count
                    }
                    else if(sender.tag == (sender.tag + 6001)) {
                        Utility.shared.filterCount = count
                    }
                    else{
                        Utility.shared.bathroom_count = count
                    }
                }
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1
                cell.countshowLabel.text = String(count)
                if(sender.tag == 0){
                    Utility.shared.bedrooms_count = count
                }
                else if(sender.tag == 1)
                {
                    Utility.shared.beds_count = count
                }
                else if(sender.tag == (sender.tag + 6001)) {
                    Utility.shared.filterCount = count
                }
                else{
                    Utility.shared.bathroom_count = count
                }
            }
            
            else {
                cell.countshowLabel.text = String(count)
                if(sender.tag == 0){
                    Utility.shared.bedrooms_count = count
                }
                else if(sender.tag == 1)
                {
                    Utility.shared.beds_count = count
                }
                else if(sender.tag == (sender.tag + 6001)) {
                    Utility.shared.filterCount = count
                }
                else{
                    Utility.shared.bathroom_count = count
                }
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
            }
        }
       
    }
    
    
    
    @objc func plusBtnTappedFilter(_ sender: UIButton){
        
        if(sender.tag == 1) {
            let cell = view.viewWithTag(sender.tag + 8000) as! RoomsCell
            count = Int(cell.countshowLabel.text!)!
            count += 1
            Utility.shared.showGuestCount = true
            maxCount = Utility.shared.maximum_guest_count
            
            if count < maxCount {
                if((count >= minCount) && (count <= maxCount)){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    
                    Utility.shared.filterCount = count
                    
                }
                cell.plusBtn.isEnabled = true
                cell.plusBtn.alpha = 1
                cell.countshowLabel.text = String(count)
                
                Utility.shared.filterCount = count
                
                
            }
            else {
                if((count >= minCount) && (count <= maxCount)){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    
                    
                    Utility.shared.filterCount = count
                    
                }
                
                cell.plusBtn.isEnabled = false
                cell.plusBtn.alpha = 0.5
            }
            
        }
       
    }
    @objc func minusBtnTappedFilter(_ sender: UIButton){
        if(sender.tag == 1) {
            let cell = view.viewWithTag(sender.tag + 8000) as! RoomsCell
            count = Int(cell.countshowLabel.text!)!
            count -= 1
            cell.plusBtn.isEnabled = true
            cell.plusBtn.alpha = 1
            
            maxCount = Utility.shared.min_filter_guest_count
            
            
            if count > maxCount {
                if(count <= maxCount){
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.alpha = 1
                    cell.countshowLabel.text = String(count)
                    
                    Utility.shared.filterCount = count
                    
                }
                cell.minusBtn.isEnabled = true
                cell.minusBtn.alpha = 1
                cell.countshowLabel.text = String(count)
                
                Utility.shared.filterCount = count
                
            }
            
            else {
                
                cell.countshowLabel.text = String(count)
                
                
                Utility.shared.filterCount = count
                
                cell.minusBtn.isEnabled = false
                cell.minusBtn.alpha = 0.5
            }
        }
        
        
       
    }
    @objc func sliderValueChanged(_ sender: Any) {
       
        
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        priceRangeArrayVal.removeAllObjects()
        let cell = view.viewWithTag(9000) as! PriceRangeCell
        var symbol = ""
        if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
        {
            symbol = Utility.shared.getSymbol(forCurrencyCode: (Utility.shared.getPreferredCurrency()!))!
        }else{
            symbol = Utility.shared.getSymbol(forCurrencyCode: (Utility.shared.currencyvalue_from_API_base))!
        }
        let minimumvalue = Int(minValue)
        let maximumvalue = Int(maxValue)
     
        cell.priceshowLabel.text = "\(symbol)\(Int(minimumvalue)) - \(symbol)\(Int(maximumvalue))"
        
        if(minimumvalue > self.minvalue || maximumvalue < self.maxValue) {
            priceRangeArrayVal.add(minimumvalue)
            priceRangeArrayVal.add(maximumvalue)
        }
      
    }
    
  
    
}

@IBDesignable

class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
    
    @IBInspectable var onthumbTintImage: UIImage? {
        didSet {
            self.layer.cornerRadius = 16
            self.thumbTintColor = UIColor(patternImage: onthumbTintImage!)
            self.onImage = onthumbTintImage
            self.layer.masksToBounds = true
          
        }
    }
    
    
}

