

import UIKit
import Cosmos
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import SKPhotoBrowser
import Apollo
import Lottie
import SDWebImage
import ISPageControl

protocol GuestDetailVCDelegate: class {
    func removeWhishlistAPICall()
}


class GuestDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SKPhotoBrowserDelegate,AirbnbDatePickerDelegate,RequestbookVCDelegate,ContacthostVCDelegate,WhishlistPageVCProtocol{
    func passgetBillingArray(getbillingArray: GetBillingCalculationQueryy.Data.GetBillingCalculation.Result) {
       
    }
    
    
    func didupdateWhishlistStatus(status: Bool) {
        viewListingArray.wishListStatus = status
        self.detailTable.reloadSections(IndexSet(integer: 0), with:.none)
       
    }
    
    
    
    func passbillingArray(getbillingarray: GetBillingCalculationQueryy.Data.GetBillingCalculation.Result) {
        
    }
    
    func passCurrencyvaluefromAPI(currency: String) {
        
    }
    func passSelectedStartDate(selectedstartDate:Date){
        self.selectedStartDate = selectedstartDate
        
    }
    func passSelectedEndDate(selectedenddate:Date){
        self.selectedEndDate = selectedenddate
    }
    

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var infoclose: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var itemNavigationView: UIImageView!
    @IBOutlet weak var PriceLabel: UILabel!
    @IBOutlet weak var chkAvailabiltyBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var detailTable: UITableView!
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var hostedLabel: UILabel!
    @IBOutlet weak var customcountryLabel: UILabel!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var entireLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var moreBtnImage: UIImageView!
    
    @IBOutlet weak var wecantLabel: UILabel!
    @IBOutlet weak var uhohLabel: UILabel!
    @IBOutlet weak var retry_label: UILabel!
    @IBOutlet weak var Error_View: UIView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var retry_button: UIButton!
    
    @IBOutlet weak var offlineView: UIView!
 
    var sectionTitleArray = NSArray()
    var amenitiesArray = NSMutableArray()
    var userSpaceArray = NSMutableArray()
    var usersafetyArray = NSMutableArray()
    var homeImageArray = NSMutableArray()
    var homeTitleArray = NSMutableArray()
    var homePriceArray = NSMutableArray()
    var pageNumber : Int = 0
    var checkArray = NSMutableArray()
    var checkleftSideArray = NSMutableArray()
    var explorecollectionView: UICollectionView?
    var filteredImageArray = NSMutableArray()
    var images = [SKPhotoProtocol]()
    var lottieView: LottieAnimationView!
    var listID: Int!
    var reviewDate = String()
    
    var headerview = UIView()
    var BackImg = UIImageView()
    var heartImg = UIImageView()
    var shareImg = UIImageView()
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    var currencyvalue_from_API_base = String()
    var currency_Dict = NSDictionary()
    var alphaval = Float()
    var pageindexForImageScrolled = Int()
    
    var apollo_headerClient: ApolloClient!
    
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    var similarlistingArray = [GetSimilarListingQuery.Data.GetSimilarListing.Result]()
    var propertyReviewArray = [GetPropertyReviewsQuery.Data.GetPropertyReview.Result]()
    var propertyReviewsCount = 0
    var reviewTitle = ""
    var reiewListingArray = [UserReviewsQuery.Data.UserReview.Result]()
    var getreviewArray = [GetReviewsListQuery.Data.GetReview.Result]()
    var getbillingArray = GetBillingCalculationQueryy.Data.GetBillingCalculation.Result()
    var delegate:GuestDetailVCDelegate?
  
    var Pagecontrol:ISPageControl!
    var isamenityTapped:Bool = false
    var isuserspaceTapped:Bool = false
    var isusersafetyamenityTapped:Bool = false
    var lastContentOffset: CGFloat = 0
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.checkApolloStatus()
        detailTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if(Utility.shared.isRTLLanguage()){
            backBtn.rotateImageViewofBtn()
            backBtn.transform = backBtn.transform.rotated(by: .pi)
        }
        self.initialSetup()
        self.lottieAnimation()
        self.registerCells()
        self.viewDetailAPICall(listid:listID)
        self.view.addSubview(navigationView)
        self.Error_View.isHidden = true
        
        if(((Utility.shared.getCurrentUserToken()) != nil) && Utility.shared.selectedstartDate_filter != nil && Utility.shared.selectedEndDate_filter != nil && Utility.shared.selectedstartDate_filter != "" && Utility.shared.selectedEndDate_filter != "")
        {
            self.billingListAPICall(startDate: Utility.shared.selectedstartDate_filter, endDate: Utility.shared.selectedEndDate_filter)
        }
       
        retry_button.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        retry_label.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        PriceLabel.font = UIFont(name: APP_FONT, size: 13)
        chkAvailabiltyBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        
        ratingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
    }
   
    override func viewWillAppear(_ animated: Bool) {
        
    }
    @IBAction func infocloseBtnTapped(_ sender: Any) {
        self.infoView.isHidden = true
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
            moreBtnImage.isHidden = false
            moreBtn.isHidden = false
            
        }
        else{
            apollo_headerClient = ApolloClient(url: URL(string:graphQLEndpoint)!)
            moreBtnImage.isHidden = true
            moreBtn.isHidden = true
            
        }
    }
    
    func APIMethodCall(listId:Int, status:Bool) {
        
    }
    @IBAction func moreBtnTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
        
            let firstAction: UIAlertAction = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"reportlisting"))!)", style: .default) { action -> Void in
                
                self.dismiss(animated:true, completion:{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"reportalert"))!)")
                })
                
            }
            
            let cancelAction: UIAlertAction = UIAlertAction(title:"\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", style: .cancel) { action -> Void in }
            
           
            actionSheetController.addAction(firstAction)
            actionSheetController.addAction(cancelAction)
           
            present(actionSheetController,animated: true, completion: nil)
            
        }
        else
        {
            self.offlineView.isHidden = false
            self.bottomView.isHidden = true
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    @IBAction func checkAvailabilityTapped(_ sender: Any) {
        let btnsendtag: UIButton = sender as! UIButton
        if(viewListingArray.userId != nil)
        {
            if(Utility.shared.getCurrentUserID() != nil && ("\(Utility.shared.getCurrentUserID()!)" == "\(viewListingArray.userId!)"))
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"ownbookalert"))!)")
            }
            else if(viewListingArray.listingData?.maxDaysNotice == "unavailable")
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"listunavailablebook"))!)")
            }
            else{
                
                if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"checkavailability"))!)")
                {
                    Utility.shared.blocked_date_month.removeAllObjects()
                    
                    
                    for i in viewListingArray.blockedDates!
                    {
                        let timestamp = i?.blockedDates
                        let timestamValue =  Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                        let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-LL-yyyy"
                        let dateFormatter1 = DateFormatter()
                        dateFormatter1.dateFormat = "LL"
                        let date = "\(dateFormatter.string(from: newTime))"
                        if(i?.calendarStatus != "available")
                        {
                            Utility.shared.blocked_date_month.add("\(date)")
                        }
                        Utility.shared.blockedDates.add(dateFormatter.string(from: newTime))
                    }
                    if let minstay = (viewListingArray.listingData?.minNight!) {
                        Utility.shared.minimumstay = minstay }
                    Utility.shared.isfromcheckingPage = true
                    
                    Utility.shared.maximum_days_notice = Utility.shared.maximum_notice_period(maximumnoticeperiod: (viewListingArray.listingData?.maxDaysNotice!)!)!
                    let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
                    datePickerViewController.delegate = self
                    datePickerViewController.isFromFilter = false
                    datePickerViewController.viewListingArray = viewListingArray
                    let navigationController = UINavigationController(rootViewController: datePickerViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
                else{
                    if Utility().isConnectedToNetwork(){
                        if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
                        {
                            let welcomeObj = WelcomePageVC()
                            welcomeObj.modalPresentationStyle = .fullScreen
                            self.present(welcomeObj, animated:false, completion: nil)
                            
                        }
                        else
                        {
                            if(getbillingArray.checkIn != nil)
                            {
                                let bookobj = RequestbookVC()
                                
                                Utility.shared.booking_message = ""
                                bookobj.viewListingArray = viewListingArray
                                bookobj.currency_Dict = currency_Dict
                                bookobj.selectedStartDate = selectedStartDate
                                bookobj.selectedEndDate = selectedEndDate
                                bookobj.currencyvalue_from_API_base = currencyvalue_from_API_base
                                if(bookobj.getbillingArray.checkIn == nil){
                                    
                                    bookobj.getbillingArray = getbillingArray
                                }
                                bookobj.delegate = self
                                bookobj.modalPresentationStyle = .fullScreen
                                self.present(bookobj, animated: true, completion: nil)
                            }
                        }
                    }
                    else
                    {
                        self.offlineView.isHidden = false
                        self.bottomView.isHidden = true
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
                            offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                        }else{
                            offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
            
        }
        
    }
    
    
    func initialSetup()
    {
        
        
        retry_label.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        chkAvailabiltyBtn.backgroundColor = Theme.SECONDARY_COLOR
        retry_button.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        retry_label.textColor = Theme.PRIMARY_COLOR
        retry_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        self.infoView.isHidden = true
        self.infoclose.setImage(#imageLiteral(resourceName: "close-black").withRenderingMode(.alwaysTemplate), for: .normal)
        self.infoclose.tintColor = UIColor.lightGray
        self.offlineView.isHidden = true
        if IS_IPHONE_XR || IS_IPHONE_XS_MAX || IS_IPHONE_PLUS {
            navigationView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-35, height: 80)
            itemNavigationView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH-35, height: 80)
            detailTable.frame = CGRect(x: 0, y:0, width: FULLWIDTH-35, height:FULLHEIGHT-80)
        }
        else if IS_IPHONE_5{
            navigationView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH+55, height: 80)
            itemNavigationView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH+55, height:80)
            detailTable.frame = CGRect(x: 0, y:0, width: FULLWIDTH+55, height:FULLHEIGHT-80)
        }
        else
        {
            navigationView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 80)
            itemNavigationView.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 80)
            detailTable.frame = CGRect(x: 0, y:0, width: FULLWIDTH, height:FULLHEIGHT-80)
        }
        
        let shadowSize : CGFloat = 3.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: self.bottomView.frame.size.width+40 + shadowSize,
                                                   height: self.bottomView.frame.size.height+40 + shadowSize))
        
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.bottomView.layer.shadowOpacity = 0.3
        self.bottomView.layer.shadowPath = shadowPath.cgPath
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        chkAvailabiltyBtn.layer.cornerRadius = 5.0
        checkArray = ["\((Utility.shared.getLanguage()?.value(forKey:"checkintime"))!)","\((Utility.shared.getLanguage()?.value(forKey:"checkouttime"))!)","\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)","\((Utility.shared.getLanguage()?.value(forKey:"availability"))!)","\((Utility.shared.getLanguage()?.value(forKey:"contacthost"))!)"]
        
        checkleftSideArray = ["\((Utility.shared.getLanguage()?.value(forKey:"checkintime"))!)","\((Utility.shared.getLanguage()?.value(forKey:"checkouttime"))!)","\((Utility.shared.getLanguage()?.value(forKey:"houserules"))!)","\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)","\((Utility.shared.getLanguage()?.value(forKey:"availability"))!)","\((Utility.shared.getLanguage()?.value(forKey:"contacthost"))!)"]
        chkAvailabiltyBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"checkavailability"))!)", for: .normal)
        ratingView.settings.filledColor = Theme.PRIMARY_COLOR
        ratingView.settings.filledBorderColor = Theme.PRIMARY_COLOR
        
    }
    
    
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.detailTable.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
    func registerCells(){
        detailTable.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        detailTable.register(UINib(nibName: "AmenityDetailCell", bundle: nil), forCellReuseIdentifier: "AmenityDetailCell")
        detailTable.register(UINib(nibName: "MapCell", bundle: nil), forCellReuseIdentifier: "MapCell")
        detailTable.register(UINib(nibName: "CheckingCell", bundle: nil), forCellReuseIdentifier: "CheckingCell")
        detailTable.register(UINib(nibName: "HeaderDetailCell", bundle: nil), forCellReuseIdentifier: "HeaderDetailCell")
        detailTable.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        detailTable.register(UINib(nibName: "UpdatedReviewCells", bundle: nil), forCellReuseIdentifier: "updatedreviewCells")
    }
    
    func viewDetailAPICall(listid:Int)
    {
        if Utility().isConnectedToNetwork(){
            var viewListQuery = ViewListingDetailsQueryy(listId:listid)
            
            if(Utility.shared.unpublish_preview_check)
            {
                viewListQuery = ViewListingDetailsQueryy(listId: listid, preview: true)
                
            }
            else
            {
                viewListQuery = ViewListingDetailsQueryy(listId:listid)
            }
            apollo_headerClient.fetch(query: viewListQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                
                guard (result?.data?.viewListing?.status) == 200 else{
                  
                    self.navigationView.backgroundColor = .white
                    
                    self.BackImg.frame = CGRect(x:10, y: 12, width:18, height:18)
                    self.BackImg.image = #imageLiteral(resourceName: "back_white")
                    
                    self.BackImg.backgroundColor = UIColor.clear
                    self.backBtn.backgroundColor = UIColor.clear
                
                    self.backBtn.addSubview(self.BackImg)
                    self.navigationView.addSubview(self.backBtn)
                    self.moreBtnImage.isHidden = true
                    self.BackImg.image = self.BackImg.image?.withRenderingMode(.alwaysTemplate)
                    if(Utility.shared.isRTLLanguage()) {
                        self.BackImg.performRTLTransform()
                    }
                    self.BackImg.tintColor =  UIColor(named: "Title_Header")
                    self.likeBtn.isHidden = true
                    self.shareBtn.isHidden = true
                    self.moreBtn.isHidden = true
                    self.Error_View.isHidden = false
                    self.lottieView.isHidden = true
                    self.bottomView.isHidden = true
                  
                    return
                }
                
                if result?.data?.viewListing?.status == 200 {
                    self.viewListingArray = (result?.data?.viewListing?.results)!
                    if(self.viewListingArray.listingData != nil)
                    {
                        if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                            let from_currency = (self.viewListingArray.listingData?.currency!)
                            let currency_amount = (self.viewListingArray.listingData?.basePrice != nil ? (self.viewListingArray.listingData?.basePrice?.clean) : "0")
                            let price_value = Utility.shared.getCurrencyRate(basecurrency:self.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:Double(currency_amount!) as! Double)
                            let restricted_price =  Double(String(format: "%.2f",price_value))
                            self.PriceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) \((Utility.shared.getLanguage()?.value(forKey:"pernight"))!)"
                        }
                        else
                        {
                            let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API_base)
                            let from_currency = (self.viewListingArray.listingData?.currency!)
                            let currency_amount = (self.viewListingArray.listingData?.basePrice != nil ? (self.viewListingArray.listingData?.basePrice?.clean) : "0")
                            let price_value = Utility.shared.getCurrencyRate(basecurrency:self.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:self.currencyvalue_from_API_base, CurrencyRate:Utility.shared.currency_Dict, amount:Double(currency_amount!) as! Double)
                            let restricted_price =  Double(String(format: "%.2f",price_value))
                            self.PriceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) \((Utility.shared.getLanguage()?.value(forKey:"pernight"))!)"
                        }
                        if let val = (self.viewListingArray.listingData?.cancellation?.policyName!)
                        {
                            Utility.shared.cancelpolicy = val
                        }
                        if let value = (self.viewListingArray.listingData?.cancellation?.policyContent!)
                        {
                            Utility.shared.cancelpolicy_content = value
                        }
                        
                    }else{
                        self.navigationView.backgroundColor = .white
                        self.BackImg.frame = CGRect(x:10, y: 12, width:18, height:18)
                        self.BackImg.image = #imageLiteral(resourceName: "back_white")
                        if(Utility.shared.isRTLLanguage()) {
                            self.BackImg.performRTLTransform()
                        }
                        self.BackImg.backgroundColor = UIColor.clear
                        self.backBtn.backgroundColor = UIColor.clear
                      
                        self.backBtn.addSubview(self.BackImg)
                        self.navigationView.addSubview(self.backBtn)
                        self.moreBtnImage.isHidden = true
                        self.BackImg.image = self.BackImg.image?.withRenderingMode(.alwaysTemplate)
                        self.BackImg.tintColor =  UIColor(named: "Title_Header")
                        self.likeBtn.isHidden = true
                        self.shareBtn.isHidden = true
                        self.moreBtn.isHidden = true
                        self.Error_View.isHidden = false
                        self.lottieView.isHidden = true
                        self.bottomView.isHidden = true
                        
                    }
                    
                    let value1 = Float(self.viewListingArray.reviewsCount ?? 0)
                    let value2 = Float(self.viewListingArray.reviewsStarRating ?? 0)
                    if(value2 != 0.0){
                        let reviewcount = (value2/value1)
                        self.ratingView.rating = (Double(String(format: "%.f",reviewcount)) ?? 0.0)
                        
                    }
                    else{
                        
                        self.ratingView.rating = 0
                    }
                    
                    self.reviewcountAPICall(profileid: ((self.viewListingArray.user?.profile?.profileId!)!))
                    self.getreviewAPICall(listId: listid, hostId: "\(self.viewListingArray.userId!)")
                    self.similarListingAPICall(lat:self.viewListingArray.lat!, lng: self.viewListingArray.lng!, lisId: self.viewListingArray.id!)
                    self.getPropertyReviewsAPICall(lisId: self.viewListingArray.id ?? 0)
                    self.lottieView.isHidden = true
                    if((Utility.shared.getCurrentUserID() != nil) && ("\(self.viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                    {
                        self.moreBtn.isHidden = true
                        self.moreBtnImage.isHidden = true
                        self.shareBtn.frame = self.moreBtn.frame
                    }
                    else
                    {
                        self.moreBtn.isHidden = false
                        self.moreBtnImage.isHidden = false
                    }
                    
                    if(Utility.shared.getCurrentUserID() != nil && ("\(Utility.shared.getCurrentUserID()!)" == "\(self.viewListingArray.userId!)"))
                    {
                        self.likeBtn.isHidden = true
                        self.heartImg.isHidden = true
                    }
                    else
                    {
                        self.likeBtn.isHidden = false
                        self.heartImg.isHidden = false
                        
                    }
                }else{
                    
                    self.navigationView.backgroundColor = .white
                    self.BackImg.frame = CGRect(x:10, y: 12, width:18, height:18)
                    self.BackImg.image = #imageLiteral(resourceName: "back_white")
                    self.BackImg.backgroundColor = UIColor.clear
                    self.backBtn.backgroundColor = UIColor.clear
                  
                    self.backBtn.addSubview(self.BackImg)
                    self.navigationView.addSubview(self.backBtn)
                    self.moreBtnImage.isHidden = true
                    self.BackImg.image = self.BackImg.image?.withRenderingMode(.alwaysTemplate)
                    self.BackImg.tintColor =  UIColor(named: "Title_Header")
                    self.likeBtn.isHidden = true
                    self.shareBtn.isHidden = true
                    self.moreBtn.isHidden = true
                    self.Error_View.isHidden = false
                    self.lottieView.isHidden = true
                    self.bottomView.isHidden = true
                    if(Utility.shared.isRTLLanguage()) {
                        self.BackImg.performRTLTransform()
                    }
                    
                }
                
                
            }
            
            
            
        }
        else
        {
            self.lottieView.isHidden = true
            self.offlineView.isHidden = false
            self.bottomView.isHidden = true
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
            
        
        }
    }
    
    func similarListingAPICall(lat:Double,lng:Double,lisId:Int)
    {
        let similarlistingquery = GetSimilarListingQuery(lat: lat, lng: lng, listId: lisId)
        apollo_headerClient.fetch(query: similarlistingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getSimilarListing?.results) != nil else{
              
                return
            }
            self.similarlistingArray = ((result?.data?.getSimilarListing?.results)!) as! [GetSimilarListingQuery.Data.GetSimilarListing.Result]
            self.detailTable.reloadData()
        }
    }
    func getPropertyReviewsAPICall(lisId:Int){
        self.propertyReviewArray.removeAll()
        let propertyReviewsQuery = GetPropertyReviewsQuery(currentPage: 1, listId: listID)
        apollo_headerClient.fetch(query: propertyReviewsQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getPropertyReviews?.results) != nil else{
                
                return
            }
            self.propertyReviewsCount = result?.data?.getPropertyReviews?.count ?? 0
            self.propertyReviewArray = ((result?.data?.getPropertyReviews?.results)!) as! [GetPropertyReviewsQuery.Data.GetPropertyReview.Result]
            self.detailTable.reloadData()
        }
    }
    @objc func propertyReviewsReadALLBtnTapped(sender: UIButton){
        self.goToAllReviewPage(value: false, index: 0)
    }
    
    func goToAllReviewPage(value: Bool,index: Int){
        if Utility.shared.isConnectedToNetwork(){
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
               
            }else{
                let reviewpageObj = ReviewShowVC()
                reviewpageObj.profileID = self.listID ?? 0
                reviewpageObj.isForProfileReviews = false
                reviewpageObj.isMoveToCell = value
                reviewpageObj.moveToIndex = index
                reviewpageObj.reviewcount = self.propertyReviewsCount
                reviewpageObj.reviewTitle = reviewTitle
                reviewpageObj.modalPresentationStyle = .fullScreen
                self.present(reviewpageObj, animated: false, completion: nil)
            }
        }
        
    }
    
    func billingListAPICall(startDate:String,endDate:String)
    {
        var currency = String()
        if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
        {
            currency = Utility.shared.getPreferredCurrency() != nil ? Utility.shared.getPreferredCurrency()! : self.currencyvalue_from_API_base
            
        }
        else{
            currency = self.currencyvalue_from_API_base
        }
        
        let billingListquery = GetBillingCalculationQueryy(listId:listID, startDate: startDate, endDate: endDate, guests: Utility.shared.guestCountToBeSend, visitors: 0, pets: 0, infants: 0 , convertCurrency:currency)
        apollo_headerClient.fetch(query: billingListquery){(result,error) in
            guard (result?.data?.getBillingCalculation?.result) != nil else{
              
                if(result?.data?.getBillingCalculation?.errorMessage != nil)
                {
                    self.infoView.isHidden = false
                    self.infoView.frame.origin.y = self.bottomView.frame.origin.y-60
                    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!) \((result?.data?.getBillingCalculation?.errorMessage!)!)")
                    attributedString.setColor(color:  UIColor(named: "Title_Header")!, forText:"\((result?.data?.getBillingCalculation?.errorMessage!)!)")
                    attributedString.setColor(color:Theme.SECONDARY_COLOR, forText:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!)")
                    self.infoLabel.attributedText = attributedString
                }
               
                return
            }
            
            self.getbillingArray = (result?.data?.getBillingCalculation?.result)!
            Utility.shared.guestCountToBeSend = self.getbillingArray.guests ?? Utility.shared.guestCountToBeSend
            
            
        }
        
    }
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
              
            }
            else
            {
                let pageObj = ShareProductVC()
                pageObj.viewListingArray = viewListingArray
                pageObj.modalPresentationStyle = .fullScreen
                self.present(pageObj, animated: true, completion: nil)
            }
        }
        else
        {
            self.offlineView.isHidden = false
            self.bottomView.isHidden = true
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
        
        
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        Utility.shared.booking_message = ""
        delegate?.removeWhishlistAPICall()
    
        self.dismiss(animated:true, completion: nil)
        
    }
    @IBAction func likeBtnTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
              
            }
            else
            {
                if viewListingArray.id != nil {
                    let headerView = WhishlistPageVC()
                    headerView.listID = viewListingArray.id!
                    headerView.listimage = viewListingArray.listPhotoName!
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: true, completion: nil)
                    
                }
            }
        }
        else
        {
            self.offlineView.isHidden = false
            self.bottomView.isHidden = true
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if(viewListingArray.listingPhotos != nil)
        {
            return 10
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        
        if(section == 4){
            if(viewListingArray.userAmenities!.count > 4)
            {
                if(!isamenityTapped){
                    return  "\((Utility.shared.getLanguage()?.value(forKey:"showallamenities"))!)"
                }
                return "\((Utility.shared.getLanguage()?.value(forKey:"closeallamenities"))!)"
                
                
            }
            else
            {
                return ""
            }
        }
        else if(section == 5){
            if(viewListingArray.userSpaces!.count > 4)
            {
                
                if(!isuserspaceTapped){
                    return  "\((Utility.shared.getLanguage()?.value(forKey: "showshare"))!)"
                }
                return "\((Utility.shared.getLanguage()?.value(forKey: "closeshare"))!)"
            }
            else
            
            {
                return  ""
            }
        }
        else if(section == 6){
            if(viewListingArray.userSafetyAmenities!.count > 4)
            {
                if(viewListingArray.userSafetyAmenities!.count > 0)
                {
                    if(!isusersafetyamenityTapped){
                        
                        return  "\((Utility.shared.getLanguage()?.value(forKey: "showallsafety"))!)"
                    }
                    
                    return "\((Utility.shared.getLanguage()?.value(forKey: "closeallsafety"))!)"
                }
                else
                {
                    return ""
                }
            }
            else
            {
                return ""
            }
        }
        
        
        
        return ""
    }
    
    @objc func addBtnTapped(_ sender: UIButton){
        let btnsendtag: UIButton = sender
        
        if(btnsendtag.tag == 4){
            if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"closeallamenities"))!)"){
                isamenityTapped = false
            }
            else {
                isamenityTapped = true
                
            }
            detailTable.reloadData()
        }
        else if(btnsendtag.tag == 5){
            if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey: "closeshare"))!)"){
                isuserspaceTapped = false
            }
            else {
                isuserspaceTapped = true
                
            }
            detailTable.reloadData()
        }
        else if(btnsendtag.tag == 6)
        {
            if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey: "closeallsafety"))!)"){
                isusersafetyamenityTapped = false
            }
            else {
                isusersafetyamenityTapped = true
                
            }
            detailTable.reloadData()
        }
     
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.white
        
        if((section == 4 && (viewListingArray.userAmenities!.count > 4)) || (section == 5 && (viewListingArray.userSpaces!.count > 4)) || (section == 6 && (viewListingArray.userSafetyAmenities!.count > 4))) {
            let showmore = UIButton()
            showmore.frame = CGRect(x:15, y:0, width:tableView.bounds.size.width-40, height:45)
            showmore.backgroundColor = UIColor.white
            showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
            showmore.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
            if(Utility.shared.isRTLLanguage()) {
                showmore.contentHorizontalAlignment = .right
            }else {
                showmore.contentHorizontalAlignment = .left }
            showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
            showmore.tag = section
            showmore.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
            footerView.addSubview(showmore)
            
            return footerView
        }else{
            footerView.backgroundColor = UIColor.white
            return footerView}
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if((section==4) || (section==5) || (section==6)) {
            
            if((section == 4) && (viewListingArray.userAmenities!.count > 4)) {
                return 50
                
            }
            else if((section == 5) && (viewListingArray.userSpaces!.count > 4)) {
                return 50
                
            }
            
            else if((section == 6) && (viewListingArray.userSafetyAmenities!.count > 4)) {
                return 50
                
            }
            else{
                
                return .leastNormalMagnitude
            }
        }
        else{
            return .leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return 1
        }
        else if(section == 1){
            return 1
        }
        else if(section == 2){
            return 1
        }
        else if(section == 3){
            if viewListingArray.listingData != nil{
                if(viewListingArray.listingData!.minNight! > 0 && viewListingArray.listingData!.maxNight! > 0)
                {
                    return 2
                }else if viewListingArray.listingData!.minNight! == 0 && viewListingArray.listingData!.maxNight! > 0{
                    
                    
                    return 1
                    
                }
                return 0
            }
            return 0
            
        }
        else if(section == 4){
            if(viewListingArray.userAmenities!.count > 0)
            {
                if(isamenityTapped)
                {
                    return viewListingArray.userAmenities!.count
                }
                else
                {
                    
                    if(viewListingArray.userAmenities!.count > 4)
                    {
                        return 4
                    }
                    else
                    {
                        return viewListingArray.userAmenities!.count
                    }
                }
            }else
            {
                return 0
            }
            
        }
        else if(section == 5){
            if(viewListingArray.userSpaces!.count > 0)
            {
                if(isuserspaceTapped)
                {
                    return viewListingArray.userSpaces!.count
                }
                else
                {
                    
                    if(viewListingArray.userSpaces!.count > 4)
                    {
                        return 4
                    }
                    else
                    {
                        return viewListingArray.userSpaces!.count
                    }
                }
            }else
            {
                return 0
            }
            
        }
        else if(section == 6){
            
            if(viewListingArray.userSafetyAmenities!.count > 0)
            {
                if(isusersafetyamenityTapped)
                {
                    return viewListingArray.userSafetyAmenities!.count
                }
                else
                {
                    
                    if(viewListingArray.userSafetyAmenities!.count > 4)
                    {
                        return 4
                    }
                    else
                    {
                        return viewListingArray.userSafetyAmenities!.count
                    }
                }
            }else
            {
                return 0
            }
            
            
        }
        else if(section == 7){
            return 1
        }
        else if(section == 8){
            if(viewListingArray.reviewsCount == 0)
            {
                if(viewListingArray.houseRules?.count == 0)
                {
                    if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                    {
                        return 4
                    }
                    return 5
                }
                else {
                    if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                    {
                        return 5
                    }
                    return 6
                }
                
            }
            else {
                if(viewListingArray.houseRules?.count == 0)
                {
                    if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                    {
                        return 5
                    }
                    return 6
                }
                else{
                    if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                    {
                        return 6
                    }
                    return 7
                }
            }
            
        }
        else if(section == 9){
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
        if(section == 3){
            if(viewListingArray.listingData!.minNight! >= 0 && viewListingArray.listingData!.maxNight! > 0)
            {
                return "\((Utility.shared.getLanguage()?.value(forKey:"minmaxnights"))!)"
            }
            else{
                return ""
            }
        }
        if(section == 4){
            if(viewListingArray.userAmenities!.count > 0){
                return "\((Utility.shared.getLanguage()?.value(forKey:"amenities"))!)"}
            else{
                return ""
            }
        }
        else if(section == 5 ){
            if(viewListingArray.userSpaces!.count > 0){
                return "\((Utility.shared.getLanguage()?.value(forKey:"userspace"))!)"
            }else{
                return ""
            }
        }
        else if(section == 6){
            if(viewListingArray.userSafetyAmenities!.count > 0){
                return "\((Utility.shared.getLanguage()?.value(forKey:"usersafety"))!)"
            }else{
                return ""
            }
        }
        
        return ""
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if((section == 3 && (viewListingArray.listingData!.minNight! >= 0 && viewListingArray.listingData!.maxNight! > 0)) || (section == 4 && (viewListingArray.userAmenities!.count > 0)) || (section == 5 && (viewListingArray.userSpaces!.count > 0)) || (section == 6 && (viewListingArray.userSafetyAmenities!.count > 0))){
            let headerView = UIView()
            headerView.backgroundColor = UIColor.white
            
            let lineLabel = UILabel(frame: CGRect(x:15, y: 0, width:
                                                    FULLWIDTH-30, height: 1.0))
            lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
            headerView.addSubview(lineLabel)
            
            let headerLabel = UILabel(frame: CGRect(x:15, y:10, width:
                                                        FULLWIDTH-30, height: 40))
            headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size:19)
            headerLabel.textColor =  UIColor(named: "Title_Header")
            headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
         
            headerView.addSubview(headerLabel)
            
            return headerView
        }
        else{
            let headerView = UIView()
            
            return headerView
            
        }
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if((section == 0)||(section == 1) || (section == 2) || (section == 7) || (section == 8) || (section == 9)) {
            return .leastNormalMagnitude
        }
        else if(section == 3)
        {
            
            if(viewListingArray.listingData!.minNight! >= 0 && viewListingArray.listingData!.maxNight! > 0)
            {
                return 40
            }
            return .leastNormalMagnitude
            
            if viewListingArray.listingData != nil{
                if(viewListingArray.listingData!.minNight! >= 0 && viewListingArray.listingData!.maxNight! > 0)
                {
                    return 40
                }
                return .leastNormalMagnitude
            }
            
        }
        else if(section == 4)
        {
            if(viewListingArray.userAmenities!.count == 0)
            {
                return .leastNormalMagnitude
            }
            return 40
        }
        else if(section == 5)
        {
            if(viewListingArray.userSpaces!.count == 0)
            {
                return .leastNormalMagnitude
            }
            return 40
        }
        else if(section == 6)
        {
            if(viewListingArray.userSafetyAmenities!.count == 0)
            {
                return .leastNormalMagnitude
            }
            return 40
        }
        
        
        return 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if((indexPath.section == 3) || (indexPath.section == 4) || (indexPath.section == 5) || (indexPath.section == 6))
        {
            return 50
        }
        else if(indexPath.section == 0){
            return 280
        }
        else if(indexPath.section == 1 ){
            return UITableView.automaticDimension
            if(viewListingArray.title!.count<=19)
            {
                return 160
            }
            return 215
        }
        else if(indexPath.section == 2){
            return UITableView.automaticDimension
            
            if(viewListingArray.description?.count ?? 0 <= 30){
                return 175
            }
            
            return 230
        }
        else if(indexPath.section == 7){
            return 350
        }
        else if(indexPath.section == 8)
        {
            if(viewListingArray.reviewsCount == 0)
            {
                if(viewListingArray.houseRules?.count == 0)
                {
                    if(indexPath.row == 4)
                    {
                        if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                        {
                            return .leastNormalMagnitude
                        }
                        
                        return 70
                    }
                    else
                    {
                        return 70
                    }
                }
                else
                {
                    if(indexPath.row == 5)
                    {
                        if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                        {
                            return .leastNormalMagnitude
                        }
                        return 70
                    }
                    else
                    {
                        return 70
                    }
                    
                }
                
            }
            else {
                if(indexPath.row == 2)
                {
                    return UITableView.automaticDimension
                }
                if(viewListingArray.houseRules?.count == 0)
                {
                    if(indexPath.row == 5)
                    {
                        if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                        {
                            return .leastNormalMagnitude
                        }
                        return 70
                    }
                    else
                    {
                        return 70
                    }
                }
                else
                {
                    if(indexPath.row == 6)
                    {
                        if((Utility.shared.getCurrentUserID() != nil) && ("\(viewListingArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))"))
                        {
                            return .leastNormalMagnitude
                        }
                        return 70
                    }
                    else
                    {
                        return 70
                    }
                    
                }
                
            }
        }
        
        else if(indexPath.section == 9){
            if(similarlistingArray.count > 0)
            {
                return 320
            }
            return 0
        }
        return 80
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == detailTable {
            if (self.lastContentOffset < scrollView.contentOffset.y) {
                alphaval = Float((200-scrollView.contentOffset.y)/100)
              
                navigationView.backgroundColor = UIColor.white
                self.BackImg.image = self.BackImg.image?.withRenderingMode(.alwaysTemplate)
                self.BackImg.tintColor =  UIColor(named: "Title_Header")
                if(viewListingArray.wishListStatus == true)
                {
                    self.heartImg.image = #imageLiteral(resourceName: "like").withRenderingMode(.alwaysOriginal)
                }
                else
                {
                    self.heartImg.image = #imageLiteral(resourceName: "Heart").withRenderingMode(.alwaysTemplate)
                    self.heartImg.tintColor =  UIColor(named: "Title_Header")
                }
                self.moreBtnImage.image = self.moreBtnImage.image?.withRenderingMode(.alwaysTemplate)
                self.moreBtnImage.tintColor =  UIColor(named: "Title_Header")
                self.shareImg.image = self.shareImg.image?.withRenderingMode(.alwaysTemplate)
                self.shareImg.tintColor =  UIColor(named: "Title_Header")
            } else {
                navigationView.backgroundColor = UIColor.clear
                
             
                if(viewListingArray.wishListStatus == false)
                {
                    self.heartImg.image = #imageLiteral(resourceName: "Heart").withRenderingMode(.alwaysOriginal)
                }
                else{
                    self.heartImg.image = #imageLiteral(resourceName: "like").withRenderingMode(.alwaysOriginal)
                    
                }
                self.moreBtnImage.image = #imageLiteral(resourceName: "show-more.png").withRenderingMode(.alwaysOriginal)
                self.shareImg.image = #imageLiteral(resourceName: "share.png").withRenderingMode(.alwaysOriginal)
                
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cellIdentifier"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        for subView in (cell?.contentView.subviews)!
        {
            subView.removeFromSuperview()
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.backgroundColor = UIColor.white
        cell!.tag = 2000+indexPath.row
        let contentview = UIView()
        if(indexPath.section == 0){
            
            contentview.frame = CGRect(x: 0, y: 0, width:FULLWIDTH, height: 280)
            
            navigationView.backgroundColor = UIColor.clear
            
            
            BackImg.frame = CGRect(x:10, y: 12, width:18, height:18)
            self.BackImg.image = #imageLiteral(resourceName: "back_white")
            BackImg.backgroundColor = UIColor.clear
            backBtn.backgroundColor = UIColor.clear
           
            backBtn.addSubview(BackImg)
            navigationView.addSubview(backBtn)
            
            
            heartImg.frame = CGRect(x: 0, y:15, width: 20, height: 20)
           
            if(viewListingArray.wishListStatus == false)
            {
                self.heartImg.image = #imageLiteral(resourceName: "Heart")
            }
            else{
                self.heartImg.image = #imageLiteral(resourceName: "like")
            }
            likeBtn.backgroundColor = UIColor.clear
            heartImg.backgroundColor = UIColor.clear
            likeBtn.addSubview(heartImg)
            navigationView.addSubview(likeBtn)
            
            
            shareImg.frame = CGRect(x: 0, y: 15, width: 20, height: 20)
            shareImg.image = #imageLiteral(resourceName: "share")
            shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
            shareBtn.backgroundColor = UIColor.clear
            shareImg.backgroundColor = UIColor.clear
            shareBtn.addSubview(shareImg)
            navigationView.addSubview(shareBtn)
            
            
            let imageScroller = ImageScroller()
            imageScroller.frame = CGRect(x: 0, y: 0, width:FULLWIDTH, height: 280)
            imageScroller.delegate = self
            imageScroller.isAutoScrollEnabled = false
            imageScroller.scrollTimeInterval = 2.0
            imageScroller.scrollView.bounces = false
            
            
            
            
            
            
            
            
            let array = viewListingArray.listingPhotos
            
            for j in array!
            {
                if(viewListingArray.listPhotoName == viewListingArray.listingPhotos?[0]?.name)
                {
                    if(filteredImageArray.contains("\(IMAGE_LISTING_MEDIUM)\(j?.name ?? "0")" as Any))
                    {
                      
                    }
                    else
                    {
                        self.filteredImageArray.add("\(IMAGE_LISTING_MEDIUM)\(j?.name ?? "0")" as Any)
                    }
                }
                else
                {
                    
                    if(filteredImageArray.contains("\(IMAGE_LISTING_MEDIUM)\(j?.name ?? "0")" as Any))
                    {
                       
                    }
                    else
                    {
                        self.filteredImageArray.add("\(IMAGE_LISTING_MEDIUM)\(j?.name ?? "0")" as Any)
                    }
                }
                
            }
            if(self.filteredImageArray != nil){
                imageScroller.setupScrollerWithImages(images:self.filteredImageArray as! [String])
                Pagecontrol = ISPageControl(frame: CGRect(x: FULLWIDTH/2-110, y:230, width: 200, height: 30), numberOfPages: self.filteredImageArray.count)
                Pagecontrol.radius = 5
                Pagecontrol.padding = 8
                Pagecontrol.inactiveTintColor = UIColor(named: "Review_Page_Line_Color")!
                Pagecontrol.currentPageTintColor = Theme.PRIMARY_COLOR
                Pagecontrol.inactiveTransparency = 1
             
                Pagecontrol.tag = indexPath.row
                
                if(self.filteredImageArray.count > 1){
                    imageScroller.addSubview(Pagecontrol)
                }
                let swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(pageChanged(_:)))
                swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                swipeRight.numberOfTouchesRequired = 1
                imageScroller.tag = indexPath.row
                imageScroller.addGestureRecognizer(swipeRight)
                self.setupTestData()
                
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageScrollerTapped))
            tap.numberOfTapsRequired = 1
            tap.view?.tag = pageNumber
            imageScroller.addGestureRecognizer(tap)
            
            contentview.addSubview(imageScroller)
            cell?.contentView.addSubview(contentview)
            cell!.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell!
          
            
        }
        if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderDetailCell", for: indexPath)as! HeaderDetailCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let roomtype = viewListingArray.roomType {
                cell.entireLabel.text = roomtype } else {
                    cell.entireLabel.text = ""
                }
            if let title =  viewListingArray.title {
                cell.itemTitleLabel.text = title.condensingWhitespace() }
            
            cell.customcountryLabel.text = "\(viewListingArray.city != nil  ? viewListingArray.city! : ""), \(viewListingArray.state != nil ? viewListingArray.state! : ""), \(viewListingArray.country != nil ? viewListingArray.country! : "")"
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if(viewListingArray.user?.profile?.picture != nil)
            {
                let profImage = viewListingArray.user?.profile?.picture!
                cell.profileImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(String(describing: profImage!))"),placeholderImage: #imageLiteral(resourceName: "unknown"))
            }
            else
            {
                cell.profileImage.image = #imageLiteral(resourceName: "unknown")
            }
            if let name = viewListingArray.user?.profile?.firstName {
               
                cell.hostedLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"hostedby"))!) \(name)"
            }
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2
            cell.profileImage.clipsToBounds = true
            
            cell.backBtn.addTarget(self, action: #selector(backBtnTapped(_:)), for: .touchUpInside)
        
            cell.profileImg.layer.cornerRadius = cell.profileImg.frame.size.width/2
            cell.profileImg.clipsToBounds = true
            cell.profileImg.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
            return cell
            
        }
        else if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath)as! DescriptionCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            cell.descriptionLabel.text = viewListingArray.description?.condensingWhitespace()
         
            if(viewListingArray.personCapacity == 1)
            {
                cell.guestLabel.text = "\(viewListingArray.personCapacity!) \((Utility.shared.getLanguage()?.value(forKey:"guestsmall"))!)"
            }
            else{
                if let personCapacity = (viewListingArray.personCapacity) {
                    cell.guestLabel.text = "\(personCapacity) \((Utility.shared.getLanguage()?.value(forKey:"guestssmall"))!)" }
            }
            if let beds = viewListingArray.beds
            {
                if beds > 1{
                    cell.bedLabel.text = "\(beds) \((Utility.shared.getLanguage()?.value(forKey:"beds")) ?? "beds")"
                }else{
                    cell.bedLabel.text = "\(beds) \((Utility.shared.getLanguage()?.value(forKey:"bed"))!)"
                }
            }
            if let bedroom = viewListingArray.bedrooms
            {
                cell.bedroomLabel.text = "\(bedroom) \((Utility.shared.getLanguage()?.value(forKey:"bedroom"))!)\(bedroom != "1" ? "s" : "")"
                
                if bedroom != "1" {
                    cell.bedroomLabel.text = "\(bedroom) \((Utility.shared.getLanguage()?.value(forKey:"bedrooms")) ?? "bedrooms")"
                }else{
                    cell.bedroomLabel.text = "\(bedroom) \((Utility.shared.getLanguage()?.value(forKey:"bedroom"))!)"
                }
            }
            if let bathroom = viewListingArray.bathrooms {
           
                if bathroom > 1 {
                    cell.privateBathLabel.text = "\(bathroom) \((Utility.shared.getLanguage()?.value(forKey:"privatebaths")) ?? "private baths")"
                }else{
                    cell.privateBathLabel.text = "\(bathroom) \((Utility.shared.getLanguage()?.value(forKey:"privatebath"))!)"
                }
            }
            
            
            
            
            if(cell.descriptionLabel?.text?.count ?? 0 <= 30){
              
                cell.readmoreBtn.isHidden = true
            }
            else if(cell.descriptionLabel?.text?.count ?? 0 > 35  && cell.descriptionLabel?.text?.count ?? 0 < 110){
            
                cell.readmoreBtn.isHidden = true
            }
            else{
             
                if Utility.shared.isRTLLanguage()
                {
                    cell.readmoreBtn.contentHorizontalAlignment = .right
                }
                else{
                    cell.readmoreBtn.contentHorizontalAlignment = .left
                }
                cell.readmoreBtn.isHidden = false
            }
          
            cell.readmoreBtn.addTarget(self, action: #selector(readmoreTapped), for: .touchUpInside)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else if(indexPath.section == 3){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
            if(indexPath.row == 0)
            {
                if((viewListingArray.listingData?.minNight) != nil) && viewListingArray.listingData?.minNight != 0  {
                    if (viewListingArray.listingData?.minNight!)! > 1{
                        cell.amenityLabel.text = "\((viewListingArray.listingData?.minNight!)!) \((Utility.shared.getLanguage()?.value(forKey:"minnights")) ?? "min Nights")"
                    }else{
                        cell.amenityLabel.text = "\((viewListingArray.listingData?.minNight!)!) \((Utility.shared.getLanguage()?.value(forKey:"minnight"))!)"
                    }
                }
                else  if((viewListingArray.listingData?.maxNight) != nil) && viewListingArray.listingData?.maxNight != 0  {
                  
                    if ((viewListingArray.listingData?.maxNight!)!) > 1 {
                        cell.amenityLabel.text = "\((viewListingArray.listingData?.maxNight)!) \((Utility.shared.getLanguage()?.value(forKey:"maxnights")) ?? "max Nights")"
                    }else{
                        cell.amenityLabel.text = "\((viewListingArray.listingData?.maxNight)!) \((Utility.shared.getLanguage()?.value(forKey:"maxnight"))!)"
                    }
                }
            }
            
            else if(indexPath.row == 1)
            {
                if((viewListingArray.listingData?.maxNight) != nil) && viewListingArray.listingData?.maxNight != 0  {
                    if ((viewListingArray.listingData?.maxNight!)!) > 1 {
                        cell.amenityLabel.text = "\((viewListingArray.listingData?.maxNight)!) \((Utility.shared.getLanguage()?.value(forKey:"maxnights")) ?? "max Nights")"
                    }else{
                        cell.amenityLabel.text = "\((viewListingArray.listingData?.maxNight)!) \((Utility.shared.getLanguage()?.value(forKey:"maxnight"))!)"
                    }
                }
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else if(indexPath.section == 4){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemname = viewListingArray.userAmenities![indexPath.row]?.itemName {
                cell.amenityLabel.text = itemname }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else if(indexPath.section == 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
          
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemname = viewListingArray.userSpaces![indexPath.row]?.itemName {
                cell.amenityLabel.text = itemname
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else if(indexPath.section == 6){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = viewListingArray.userSafetyAmenities![indexPath.row]?.itemName {
                cell.amenityLabel.text = itemName }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
        else if(indexPath.section == 7){
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell", for: indexPath) as! MapCell
            cell.centerCircleView.frame = CGRect(x: cell.mapView.frame.size.width/2-75, y:cell.mapView.frame.size.height-250, width: 150, height: 150)
            cell.centerCircleView.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.centerCircleView.layer.borderWidth = 1.5
            cell.centerCircleView.layer.cornerRadius = 75
            cell.centerCircleView.clipsToBounds = true
            cell.mapMarkerView.layer.cornerRadius = 5.0
            cell.mapMarkerView.clipsToBounds = true
            let shadowSize : CGFloat = 3.0
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                       y: -shadowSize / 2,
                                                       width: cell.mapMarkerView.frame.size.width + shadowSize,
                                                       height: cell.mapMarkerView.frame.size.height + shadowSize))
            
            cell.mapMarkerView.layer.masksToBounds = false
            cell.mapMarkerView.layer.shadowColor = Theme.TextLightColor.cgColor
            cell.mapMarkerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            cell.mapMarkerView.layer.shadowOpacity = 0.3
            cell.mapMarkerView.layer.shadowPath = shadowPath.cgPath
            let lat = "\(viewListingArray.lat!)"
            let long = "\(viewListingArray.lng!)"
            cell.mapView .addSubview(cell.centerCircleView)
            
            let staticMapUrl: String = "https://maps.googleapis.com/maps/api/staticmap?key=\(GOOGLE_API_KEY)&center=\(lat),\(long)&\("zoom=15&size=\(2 * Int(cell.mapView.frame.size.width))x\(2 * Int(cell.mapView.frame.size.height))")&sensor=true&language=en"
            cell.centerCircleView.backgroundColor = UIColor(red: 0.0/255.0, green: 132.0/255.0, blue: 135.0/255.0, alpha:0.3)
            let mapUrl: NSURL = NSURL(string: staticMapUrl)!
            cell.mapView.sd_setImage(with: mapUrl as URL, placeholderImage: UIImage(named: "palceholder"))
            cell.mapLabel.text = "\(viewListingArray.city != nil ? viewListingArray.city! : ""), \(viewListingArray.state != nil ? viewListingArray.state! : "" ), \(viewListingArray.country != nil ? viewListingArray.country! : "") \((Utility.shared.getLanguage()?.value(forKey:"exactlocation"))!)"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        }
        else if(indexPath.section == 8) {
            
            if(viewListingArray.reviewsCount == 0)
            {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                if(viewListingArray.houseRules?.count == 0)
                {
                    cell.checkLabel.text = (checkArray[indexPath.row] as! String)
                    
                    if(indexPath.row == 0)
                    {
                        if(viewListingArray.listingData?.checkInStart == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInStart!
                        }
                        else
                        {
                            if let checkinstart = (viewListingArray.listingData?.checkInStart)
                            {
                                cell.flexLabel.text = self.conversionRailwaytime(time:checkinstart)
                            }
                        }
                        return cell
                    }
                    else if(indexPath.row == 1)
                    {
                        if(viewListingArray.listingData?.checkInEnd == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInEnd!
                        }
                        else
                        {
                            if(viewListingArray.listingData?.checkInEnd != nil)
                            {
                                cell.flexLabel.text = self.conversionRailwaytime(time: (viewListingArray.listingData?.checkInEnd!)!)
                            }
                        }
                        
                        return cell
                    }
                    else if(indexPath.row == 2)
                    {
                        
                        if let policyname = viewListingArray.listingData?.cancellation?.policyName! {
                            cell.flexLabel.text = policyname }
                        return cell
                    }
                    else if(indexPath.row == 3)
                    {
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"check"))!)"
                        return cell
                    }
                    else if(indexPath.row == 4)
                    {
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"message"))!)"
                        return cell
                    }
                }
                else{
                    cell.checkLabel.text = (checkleftSideArray[indexPath.row] as! String)
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    if(indexPath.row == 0)
                    {
                        if(viewListingArray.listingData?.checkInStart == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInStart!
                        }
                        else
                        {
                            if(viewListingArray.listingData?.checkInStart != nil)
                            {
                                cell.flexLabel.text = self.conversionRailwaytime(time: (viewListingArray.listingData?.checkInStart!)!)
                            }
                            else
                            {
                                cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)"
                            }
                        }
                        return cell
                    }
                    else if(indexPath.row == 1)
                    {
                        if(viewListingArray.listingData?.checkInEnd == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInEnd!
                        }
                        else
                        {
                            if(viewListingArray.listingData?.checkInStart != nil)
                            {
                                cell.flexLabel.text = self.conversionRailwaytime(time: (viewListingArray.listingData?.checkInEnd!)!)
                            }
                            else
                            {
                                cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"flexible"))!)"
                            }
                        }
                        return cell
                    }
                    else if(indexPath.row == 2)
                    {
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"read"))!)"
                        return cell
                    }
                    else if(indexPath.row == 3)
                    {
                        
                        if let policyname = viewListingArray.listingData?.cancellation?.policyName! {
                            cell.flexLabel.text = policyname }
                        return cell
                    }
                    else if(indexPath.row == 4)
                    {
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"check"))!)"
                        return cell
                    }
                    else if(indexPath.row == 5)
                    {
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"message"))!)"
                        return cell
                    }
                    
                }
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            }
            else{
                
                if(viewListingArray.houseRules?.count == 0)
                {
                    
                    if(indexPath.row == 0)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"checkintime"))!)"
                        if(viewListingArray.listingData?.checkInStart == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInStart!
                        }
                        else
                        {
                            cell.flexLabel.text = self.conversionRailwaytime(time: (viewListingArray.listingData?.checkInStart!)!)
                        }
                        return cell
                    }
                    else if(indexPath.row == 1)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"checkouttime"))!)"
                        if(viewListingArray.listingData?.checkInEnd == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInEnd!
                        }
                        else
                        {
                            if let checkInEnd = (viewListingArray.listingData?.checkInEnd!) {
                                cell.flexLabel.text = self.conversionRailwaytime(time: checkInEnd) }
                        }
                        return cell
                    }
                    else if indexPath.row == 2{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "updatedreviewCells", for: indexPath) as! UpdatedReviewCells
                        cell.selectionStyle = .none
                        
                        let flowLayout = UICollectionViewFlowLayout()
                        
                        flowLayout.scrollDirection = .horizontal
                        
                        cell.collectionView.collectionViewLayout = flowLayout
                        cell.collectionView.delegate = self
                        cell.collectionView.dataSource = self
                        cell.collectionView.register(UINib(nibName: "reviewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "reviewCollection")
                        DispatchQueue.main.async {
                            cell.collectionView.reloadData()
                        }
                        
                        
                        let value1 = Double(self.viewListingArray.reviewsCount ?? 0)
                        let value2 = Double(self.viewListingArray.reviewsStarRating ?? 0)
                        var reviewcount = 0
                        if(value2 != 0.0){
                            reviewcount = Int(round(value2/value1))
                        }
                        else{
                            reviewcount = 0
                        }
                        
                        let totalReviews = self.propertyReviewsCount
                        
                        cell.ratingTitle.text = "\(reviewcount) / \(Utility.shared.getLanguage()?.value(forKey: "reviews") ?? "Reviews") (\(totalReviews))"
                        self.reviewTitle = cell.ratingTitle.text ?? ""
                        cell.showAllReviewsBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Show_all") ?? "Show all") \(totalReviews) \(Utility.shared.getLanguage()?.value(forKey: "reviewssmall") ?? "reviews")", for: .normal)
                        
                        if self.propertyReviewsCount > 1{
                            cell.showAllReviewsBtn.isHidden = false
                            cell.showAllBtnHeightConstraint.constant = 45
                            cell.showAllReviewsBtn.addTarget(self, action: #selector(propertyReviewsReadALLBtnTapped), for: .touchUpInside)
                        }else{
                            cell.showAllReviewsBtn.isHidden = true
                            cell.showAllBtnHeightConstraint.constant = 0
                        }
                        
                        
                        return cell
                    }
                    
                    else if(indexPath.row == 3)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"
                        if let policyname =  viewListingArray.listingData?.cancellation?.policyName {
                            cell.flexLabel.text = policyname }
                        return cell
                    }
                    else if(indexPath.row == 4)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"availability"))!)"
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"check"))!)"
                        return cell
                    }
                    else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        
                        cell.checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"contacthost"))!)"
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"message"))!)"
                        return cell
                    }
                }
                else {
                    if(indexPath.row == 0)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"checkintime"))!)"
                        if(viewListingArray.listingData?.checkInStart == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInStart!
                        }
                        else
                        {
                            if let checkinstart = viewListingArray.listingData?.checkInStart {
                                cell.flexLabel.text = self.conversionRailwaytime(time:checkinstart) }
                        }
                        return cell
                    }
                    else if(indexPath.row == 1)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"checkouttime"))!)"
                        if(viewListingArray.listingData?.checkInEnd == "Flexible")
                        {
                            cell.flexLabel.text = viewListingArray.listingData?.checkInEnd!
                        }
                        else
                        {
                            if let checkInEnd = viewListingArray.listingData?.checkInEnd {
                                cell.flexLabel.text = self.conversionRailwaytime(time: checkInEnd) }
                        }
                        return cell
                    }
                    else if(indexPath.row == 2) {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "updatedreviewCells", for: indexPath) as! UpdatedReviewCells
                        cell.selectionStyle = .none
                        
                        let flowLayout = UICollectionViewFlowLayout()
                        
                        flowLayout.scrollDirection = .horizontal
                        
                        cell.collectionView.collectionViewLayout = flowLayout
                        cell.collectionView.delegate = self
                        cell.collectionView.dataSource = self
                        cell.collectionView.register(UINib(nibName: "reviewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "reviewCollection")
                        DispatchQueue.main.async {
                            cell.collectionView.reloadData()
                        }
                        
                        let value1 = Double(self.viewListingArray.reviewsCount ?? 0)
                        let value2 = Double(self.viewListingArray.reviewsStarRating ?? 0)
                        var reviewcount = 0
                        if(value2 != 0.0){
                            reviewcount = Int(round(value2/value1))
                        }
                        else{
                            reviewcount = 0
                        }
                        
                        let totalReviews = self.propertyReviewsCount
                        cell.ratingTitle.text = "\(reviewcount) / \(Utility.shared.getLanguage()?.value(forKey: "reviews") ?? "Reviews") (\(totalReviews))"
                        self.reviewTitle = cell.ratingTitle.text ?? ""
                        cell.showAllReviewsBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Show_all") ?? "Show all") \(totalReviews) \(Utility.shared.getLanguage()?.value(forKey: "reviewssmall") ?? "reviews")", for: .normal)
                        
                        if self.propertyReviewsCount > 1{
                            cell.showAllReviewsBtn.isHidden = false
                            cell.showAllBtnHeightConstraint.constant = 45
                            cell.showAllReviewsBtn.addTarget(self, action: #selector(propertyReviewsReadALLBtnTapped), for: .touchUpInside)
                        }else{
                            cell.showAllReviewsBtn.isHidden = true
                            cell.showAllBtnHeightConstraint.constant = 0
                        }
                        
                        return cell
                    }
                  
                    else if(indexPath.row == 3)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"houserules"))!)"
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"read"))!)"
                        return cell
                    }
                    else if(indexPath.row == 4)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"cancellationPolicy"))!)"
                        if let policyname = viewListingArray.listingData?.cancellation?.policyName {
                            cell.flexLabel.text =  policyname }
                        return cell
                    }
                    else if(indexPath.row == 5)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text =  "\((Utility.shared.getLanguage()?.value(forKey:"availability"))!)"
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"check"))!)"
                        return cell
                    }
                    else{
                       
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell", for: indexPath) as! CheckingCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.flexLabel.textColor = Theme.PRIMARY_COLOR
                        cell.checkLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"contacthost"))!)"
                        cell.flexLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"message"))!)"
                        return cell
                       
                    }
                }
                
            }
            
            
            
        }
        else {
            contentview.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 320)
            contentview.backgroundColor = UIColor.white
            let titleLabel = UILabel()
            titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"similarlsiting"))!)"
            titleLabel.frame = CGRect(x:15, y: 5, width: FULLWIDTH - 40, height: 40)
            titleLabel.tintColor =  UIColor(named: "Title_Header")
            titleLabel.textColor =  UIColor(named: "Title_Header")
            titleLabel.font =  UIFont(name: APP_FONT_MEDIUM, size:25)
            contentview.addSubview(titleLabel)
            
            
            let layout = UICollectionViewFlowLayout()
            
            explorecollectionView = UICollectionView(frame: CGRect(x:15, y: 50, width: FULLWIDTH-30, height:270), collectionViewLayout: layout)
            
            explorecollectionView?.tag = indexPath.row
            layout.scrollDirection = .horizontal
            explorecollectionView?.dataSource = self
            explorecollectionView?.delegate = self
            explorecollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
            explorecollectionView?.backgroundColor = UIColor.white
            explorecollectionView?.showsHorizontalScrollIndicator = false
            if let aView = explorecollectionView {
                contentview.addSubview(aView)
            }
            explorecollectionView?.register(UINib(nibName: "FloatCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FloatCollectionCell")
            
            DispatchQueue.main.async {
                self.explorecollectionView?.reloadData()
            }
            cell?.contentView.addSubview(contentview)
            return cell!
        }
        
        
        
    }
    
    @objc func profileTapped()
    {
        if Utility().isConnectedToNetwork(){
            if(((Utility.shared.getCurrentUserToken()) != nil) && (Utility.shared.getCurrentUserToken() != ""))
            {
                let editprofileobj = HostProfileViewPage()
                
                editprofileobj.reiewListingArray = reiewListingArray
                editprofileobj.profileid = ((viewListingArray.user?.profile?.profileId!)!)
                editprofileobj.profilename = (viewListingArray.user?.profile?.firstName!)!
                editprofileobj.showprofileAPICall(profileid:(viewListingArray.user?.profile?.profileId!)!)
                editprofileobj.modalPresentationStyle = .fullScreen
                self.present(editprofileobj, animated: true, completion: nil)
            }
        }
        else
        {
            self.offlineView.isHidden = false
            self.bottomView.isHidden = true
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
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 7){
            let mapPageObj = MapPageVC()
            mapPageObj.mapArray = viewListingArray
            mapPageObj.modalPresentationStyle = .fullScreen
            self.present(mapPageObj, animated: true, completion: nil)
            
            
        }
        else if(indexPath.section == 8)
        {
            
            if(viewListingArray.reviewsCount == 0)
            {
                if(viewListingArray.houseRules?.count == 0)
                {
                    if(indexPath.row == 2)
                    {
                        let cancellationObj = CancellationVC()
                        if let policy = viewListingArray.listingData?.cancellation?.policyName {
                            Utility.shared.cancelpolicy = policy
                            cancellationObj.cancelpolicy = policy }
                        if((viewListingArray.listingData?.cancellation?.policyContent!) != nil)
                        {
                            
                            cancellationObj.cancelpolicy_content = (viewListingArray.listingData?.cancellation?.policyContent!)!
                        }
                        cancellationObj.modalPresentationStyle = .fullScreen
                        self.present(cancellationObj, animated: true, completion: nil)
                    }
                    if(indexPath.row == 3)
                    {
                        Utility.shared.blocked_date_month.removeAllObjects()
                        for i in viewListingArray.blockedDates!
                        {
                            let timestamp = i?.blockedDates
                            let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-LL-yyyy"
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateFormat = "LL"
                           
                            let date = "\(dateFormatter.string(from: newTime))"
                            if(i?.calendarStatus != "available")
                            {
                                Utility.shared.blocked_date_month.add("\(date)")
                            }
                            Utility.shared.blockedDates.add(dateFormatter.string(from: newTime))
                        }
                        if let minNight = (viewListingArray.listingData?.minNight!) {
                            Utility.shared.minimumstay = minNight }
                        Utility.shared.isfromcheckingPage = true
                        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
                        datePickerViewController.delegate = self
                        datePickerViewController.isFromFilter = false
                        datePickerViewController.viewListingArray = viewListingArray
                        let navigationController = UINavigationController(rootViewController: datePickerViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    if(indexPath.row == 4)
                    {
                        if Utility().isConnectedToNetwork(){
                            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
                            {
                                let welcomeObj = WelcomePageVC()
                                welcomeObj.modalPresentationStyle = .fullScreen
                                self.present(welcomeObj, animated:false, completion: nil)
                               
                            }
                            else
                            {
                                let contactpageObj = ContacthostVC()
                                contactpageObj.currency_Dict = currency_Dict
                                contactpageObj.viewListingArray = viewListingArray
                                contactpageObj.currencyvalue_from_API_base = currencyvalue_from_API_base
                                Utility.shared.booking_message = ""
                                contactpageObj.selectedStartDate = selectedStartDate
                                
                                contactpageObj.selectedEndDate = selectedEndDate
                                
                                contactpageObj.getbillingArray = getbillingArray
                                contactpageObj.delegate = self
                                contactpageObj.modalPresentationStyle = .fullScreen
                                self.present(contactpageObj, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            self.offlineView.isHidden = false
                            self.bottomView.isHidden = true
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
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                            }else{
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                            }
                        }
                    }
                }
                else{
                    if(indexPath.row == 2)
                    {
                        let houserulesObj = HouseRulesVC()
                        houserulesObj.houserulesArray = self.viewListingArray.houseRules! as! [ViewListingDetailsQueryy.Data.ViewListing.Result.HouseRule]
                        houserulesObj.modalPresentationStyle = .fullScreen
                        self.present(houserulesObj, animated: true, completion: nil)
                    }
                    
                    else if(indexPath.row == 3)
                    {
                        let cancellationObj = CancellationVC()
                        if let policy = (viewListingArray.listingData?.cancellation?.policyName!) {
                            Utility.shared.cancelpolicy = policy
                            cancellationObj.cancelpolicy = policy }
                        if((viewListingArray.listingData?.cancellation?.policyContent!) != nil)
                        {
                            
                            cancellationObj.cancelpolicy_content = (viewListingArray.listingData?.cancellation?.policyContent!)!
                        }
                        cancellationObj.modalPresentationStyle = .fullScreen
                        self.present(cancellationObj, animated: true, completion: nil)
                    }
                    if(indexPath.row == 4)
                    {
                        Utility.shared.blocked_date_month.removeAllObjects()
                        for i in viewListingArray.blockedDates!
                        {
                            let timestamp = i?.blockedDates
                            let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-LL-yyyy"
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateFormat = "LL"
                            let newdate = Calendar.current.date(byAdding: .day, value: 0, to: newTime)
                            let date = "\(dateFormatter.string(from: newTime))"
                            let newDate = "\(dateFormatter.string(from: newdate!))"
                            if(i?.calendarStatus != "available")
                            {
                                Utility.shared.blocked_date_month.add("\(date)")
                            }
                            Utility.shared.blockedDates.add(dateFormatter.string(from: newTime))
                        }
                        if let minstay = (viewListingArray.listingData?.minNight!) {
                            Utility.shared.minimumstay = minstay }
                        Utility.shared.isfromcheckingPage = true
                        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
                        datePickerViewController.delegate = self
                        datePickerViewController.isFromFilter = false
                        datePickerViewController.viewListingArray = viewListingArray
                        let navigationController = UINavigationController(rootViewController: datePickerViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    if(indexPath.row == 5)
                    {
                        if Utility().isConnectedToNetwork(){
                            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
                            {
                                let welcomeObj = WelcomePageVC()
                                welcomeObj.modalPresentationStyle = .fullScreen
                                self.present(welcomeObj, animated:false, completion: nil)
                             
                            }
                            else
                            {
                                let contactpageObj = ContacthostVC()
                                contactpageObj.currency_Dict = currency_Dict
                                contactpageObj.viewListingArray = viewListingArray
                                contactpageObj.currencyvalue_from_API_base = currencyvalue_from_API_base
                                Utility.shared.booking_message = ""
                                contactpageObj.selectedStartDate = selectedStartDate
                                contactpageObj.selectedEndDate = selectedEndDate
                                contactpageObj.getbillingArray = getbillingArray
                                contactpageObj.delegate = self
                                contactpageObj.modalPresentationStyle = .fullScreen
                                self.present(contactpageObj, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            self.offlineView.isHidden = false
                            self.bottomView.isHidden = true
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
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                            }else{
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                            }
                            
                        }
                    }
                }
                
            }
            else
            {
                if(viewListingArray.houseRules?.count == 0)
                {
                    if(indexPath.row == 3)
                    {
                        let cancellationObj = CancellationVC()
                        cancellationObj.cancelpolicy = (viewListingArray.listingData?.cancellation?.policyName!)!
                        Utility.shared.cancelpolicy = (viewListingArray.listingData?.cancellation?.policyName!)!
                        if((viewListingArray.listingData?.cancellation?.policyContent!) != nil)
                        {
                            
                            cancellationObj.cancelpolicy_content = (viewListingArray.listingData?.cancellation?.policyContent!)!
                        }
                        cancellationObj.modalPresentationStyle = .fullScreen
                        self.present(cancellationObj, animated: true, completion: nil)
                    }
                    else if(indexPath.row == 4)
                    {
                        Utility.shared.blocked_date_month.removeAllObjects()
                        for i in viewListingArray.blockedDates!
                        {
                            let timestamp = i?.blockedDates
                            let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-LL-yyyy"
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateFormat = "LL"
                            
                            let date = "\(dateFormatter.string(from: newTime))"
                            if(i?.calendarStatus != "available")
                            {
                                Utility.shared.blocked_date_month.add("\(date)")
                            }
                            Utility.shared.blockedDates.add(dateFormatter.string(from: newTime))
                        }
                        if let minstay = (viewListingArray.listingData?.minNight!) {
                            Utility.shared.minimumstay = minstay}
                        Utility.shared.isfromcheckingPage = true
                        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
                        datePickerViewController.delegate = self
                        datePickerViewController.isFromFilter = false
                        datePickerViewController.viewListingArray = viewListingArray
                        let navigationController = UINavigationController(rootViewController: datePickerViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    if(indexPath.row == 5)
                    {
                        if Utility().isConnectedToNetwork(){
                            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
                            {
                                let welcomeObj = WelcomePageVC()
                                welcomeObj.modalPresentationStyle = .fullScreen
                                self.present(welcomeObj, animated:false, completion: nil)
                               
                            }
                            else
                            {
                                let contactpageObj = ContacthostVC()
                                contactpageObj.currency_Dict = currency_Dict
                                contactpageObj.viewListingArray = viewListingArray
                                contactpageObj.currencyvalue_from_API_base = currencyvalue_from_API_base
                                Utility.shared.booking_message = ""
                                contactpageObj.selectedStartDate = selectedStartDate
                                contactpageObj.selectedEndDate = selectedEndDate
                                contactpageObj.getbillingArray = getbillingArray
                                contactpageObj.delegate = self
                                contactpageObj.modalPresentationStyle = .fullScreen
                                self.present(contactpageObj, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            self.offlineView.isHidden = false
                            self.bottomView.isHidden = true
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
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                            }else{
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                            }
                        }
                    }
                }
                else{
                    if(indexPath.row == 3)
                    {
                        let houserulesObj = HouseRulesVC()
                        houserulesObj.houserulesArray = self.viewListingArray.houseRules! as! [ViewListingDetailsQueryy.Data.ViewListing.Result.HouseRule]
                        houserulesObj.modalPresentationStyle = .fullScreen
                        self.present(houserulesObj, animated: true, completion: nil)
                    }
                    
                    if(indexPath.row == 4)
                    {
                        let cancellationObj = CancellationVC()
                        if let policy = (viewListingArray.listingData?.cancellation?.policyName!) {
                            Utility.shared.cancelpolicy = policy
                            cancellationObj.cancelpolicy = policy }
                        if((viewListingArray.listingData?.cancellation?.policyContent!) != nil)
                        {
                            
                            cancellationObj.cancelpolicy_content = (viewListingArray.listingData?.cancellation?.policyContent!)!
                        }
                        cancellationObj.modalPresentationStyle = .fullScreen
                        self.present(cancellationObj, animated: true, completion: nil)
                    }
                    if(indexPath.row == 5)
                    {
                        Utility.shared.blocked_date_month.removeAllObjects()
                        for i in viewListingArray.blockedDates!
                        {
                            let timestamp = i?.blockedDates
                            let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                            let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-LL-yyyy"
                            let dateFormatter1 = DateFormatter()
                            dateFormatter1.dateFormat = "LL"
                           
                            let date = "\(dateFormatter.string(from: newTime))"
                            if(i?.calendarStatus != "available")
                            {
                                Utility.shared.blocked_date_month.add("\(date)")
                            }
                            Utility.shared.blockedDates.add(dateFormatter.string(from: newTime))
                        }
                        if let minstay = (viewListingArray.listingData?.minNight!) {
                            Utility.shared.minimumstay = minstay
                        }
                        Utility.shared.isfromcheckingPage = true
                        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: selectedStartDate, dateTo: selectedEndDate)
                        datePickerViewController.delegate = self
                        datePickerViewController.isFromFilter = false
                        datePickerViewController.viewListingArray = viewListingArray
                        let navigationController = UINavigationController(rootViewController: datePickerViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    if(indexPath.row == 6)
                    {
                        if Utility().isConnectedToNetwork(){
                            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
                            {
                                let welcomeObj = WelcomePageVC()
                                welcomeObj.modalPresentationStyle = .fullScreen
                                self.present(welcomeObj, animated:false, completion: nil)
                               
                            }
                            else
                            {
                                let contactpageObj = ContacthostVC()
                                contactpageObj.currency_Dict = currency_Dict
                                contactpageObj.viewListingArray = viewListingArray
                                contactpageObj.currencyvalue_from_API_base = currencyvalue_from_API_base
                                Utility.shared.booking_message = ""
                                contactpageObj.selectedStartDate = selectedStartDate
                                contactpageObj.selectedEndDate = selectedEndDate
                                contactpageObj.getbillingArray = getbillingArray
                                contactpageObj.delegate = self
                                contactpageObj.modalPresentationStyle = .fullScreen
                                self.present(contactpageObj, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            self.offlineView.isHidden = false
                            self.bottomView.isHidden = true
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
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
                            }else{
                                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
                            }
                        }
                        
                    }
                    
                }
            }
            
        }
        
    }
    @objc func imageScrollerTapped(_ sender: UITapGestureRecognizer) {
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: Pagecontrol.currentPage)
        browser.delegate = self
        
        present(browser, animated: true, completion: {})
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieAnimation()
            offlineView.isHidden = true
            self.bottomView.isHidden = false
            self.viewDetailAPICall(listid:listID)
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            if(selectedStartDate != nil && selectedEndDate != nil)
            {
                billingListAPICall(startDate: fmt.string(from: selectedStartDate!), endDate: fmt.string(from: selectedEndDate!))
            }
        }
    }
    
    func createLocalPhotos() -> [SKPhotoProtocol] {
        return (0..<filteredImageArray.count).map { (i: Int) -> SKPhotoProtocol in
            let photo = SKPhoto.photoWithImageURL(filteredImageArray[i] as! String)
            
            return photo
        }
    }
    
    func setupTestData() {
        images = createLocalPhotos()
    }
    
    @objc func pageChanged(_ sender: UISwipeGestureRecognizer) {
        
        pageNumber = sender.view!.tag
        pageindexForImageScrolled = pageNumber
    }
    
    @objc func readmoreTapped()
    {
        let readmoreObj = ReadmoreVC()
        readmoreObj.ReadmoreText = self.viewListingArray.description!
        readmoreObj.modalPresentationStyle = .fullScreen
        self.present(readmoreObj, animated: true, completion: nil)
        
    }
    
    @objc func reviewreadmoreTapped(value:String)
    {
        let readmoreObj = ReadmoreVC()
        readmoreObj.ReadmoreText = value
        readmoreObj.modalPresentationStyle = .fullScreen
        self.present(readmoreObj, animated: true, completion: nil)
        
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == explorecollectionView ? CGSize(width:FULLWIDTH/2+60, height:270) : CGSize(width: 290, height: 180)
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == explorecollectionView{
            if(similarlistingArray.count > 0)
            {
                return similarlistingArray.count
            }
            return 0
        }else{
            return self.propertyReviewArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == explorecollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FloatCollectionCell", for: indexPath)as! FloatCollectionCell
            if let roomtype = similarlistingArray[indexPath.row].roomType
            {
                cell.entirehomeLabel.text = roomtype
            }else
            {
                cell.entirehomeLabel.text = ""
            }
            cell.entireHomeWidthConstraint.constant = cell.entirehomeLabel.intrinsicContentSize.width
            if let profImage = similarlistingArray[indexPath.row].listPhotoName {
                
                cell.homeImage.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(String(describing: profImage))"),placeholderImage: #imageLiteral(resourceName: "ItemTransparentImg")) } else {
                    cell.homeImage.image = #imageLiteral(resourceName: "ItemTransparentImg")
                }
            
            cell.tag = indexPath.item+1000
            cell.selectedItem.tag = indexPath.item
            cell.selectedItem.backgroundColor = .white
            
            cell.titleLabel.text = similarlistingArray[indexPath.row].title!.condensingWhitespace()
            if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                let from_currency = self.similarlistingArray[indexPath.row].listingData?.currency
                let currency_amount = self.similarlistingArray[indexPath.row].listingData?.basePrice != nil ? self.similarlistingArray[indexPath.row].listingData?.basePrice! : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency:currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.priceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) \((Utility.shared.getLanguage()?.value(forKey:"pernight"))!)"
            }
            else
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API_base)
                let from_currency = self.similarlistingArray[indexPath.row].listingData?.currency
                let currency_amount = self.similarlistingArray[indexPath.row].listingData?.basePrice != nil ? self.similarlistingArray[indexPath.row].listingData?.basePrice! : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency:currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:currencyvalue_from_API_base, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.priceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) \((Utility.shared.getLanguage()?.value(forKey:"pernight"))!)"
            }
            if(similarlistingArray[indexPath.row].bookingType != nil && ("\(similarlistingArray[indexPath.row].bookingType!)" == "instant"))
            {
                cell.instantView.isHidden = false
            }
            else{
                cell.instantView.isHidden = true
                
            }
         
            if("\(similarlistingArray[indexPath.row].wishListStatus!)" == "false"){
                cell.likeBtn.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
                
            }
            else {
                cell.likeBtn.setImage(#imageLiteral(resourceName: "like"), for:.normal)
            }
            cell.likeBtn.tag = indexPath.row
            cell.likeBtn.addTarget(self, action: #selector(whishlistBtnTapped), for: .touchUpInside)
            let value1 = Float(similarlistingArray[indexPath.row].reviewsCount ?? 0)
            let value2 = Float(similarlistingArray[indexPath.row].reviewsStarRating ?? 0)
            if(value2 != 0.0){
                let reviewcount = (value2/value1)
                cell.ratingView.rating = Double(Int(reviewcount))
            }
            else{
                cell.ratingView.rating = 0
            }
            if(similarlistingArray[indexPath.row].isListOwner == false)
            {
                cell.likeBtn.isHidden = false
            }
            else
            {
                cell.likeBtn.isHidden = false
                
            }
            
            
            cell.homeImage.layer.cornerRadius = 4.0
            cell.homeImage.layer.masksToBounds = true
            
            
            if(cell.titleLabel?.text?.count ?? 0 <= 29){
            }
            
            if Utility.shared.isRTLLanguage(){
                cell.ratingView.semanticContentAttribute = .forceRightToLeft
            }else{
                cell.ratingView.semanticContentAttribute = .forceLeftToRight
            }
            
            return cell
        }else{
            let cell : reviewCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCollection", for: indexPath) as! reviewCollectionCell
            
            if !(self.propertyReviewArray[indexPath.row].isAdmin ?? true){
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                ]
                
                let attributedString = NSMutableAttributedString(string: " \(Utility.shared.getLanguage()?.value(forKey: "review") ?? "Review")" , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributedString2 = NSMutableAttributedString(string: "\(self.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.firstName ?? "")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                let attributes3 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributedString3 = NSMutableAttributedString(string: "'s", attributes: attributes3 as [NSAttributedString.Key : Any])
                
                attributedString2.append(attributedString3)
                attributedString2.append(attributedString)
                
                cell.titleLabel.attributedText = attributedString2
                cell.titleLabel.isHidden = false
                cell.starRationgTopConstraint.constant = 5
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileTabbed))
                cell.titleLabel.tag = indexPath.row
                cell.titleLabel.addGestureRecognizer(tapGesture)
                cell.titleLabel.isUserInteractionEnabled = true
                
                
                let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImgTabbed))
                cell.imgView.tag = indexPath.row
                cell.imgView.addGestureRecognizer(tapImageGesture)
                cell.imgView.isUserInteractionEnabled = true
                
            }else{
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                ]
                
                let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "Verifiedby") ?? "Verified by") \(Utility.shared.getLanguage()?.value(forKey: "appname") ?? "RentALL")" , attributes: attributes as [NSAttributedString.Key : Any])
                
                cell.titleLabel.attributedText = attributedString
                cell.titleLabel.isHidden = false
                cell.starRationgTopConstraint.constant = 5
                cell.imgView.isUserInteractionEnabled = false
                cell.titleLabel.isUserInteractionEnabled = false
            }
          
            let reviewContent = self.propertyReviewArray[indexPath.row].reviewContent ?? ""
            let str = reviewContent.replacingOccurrences(of: "\\s+", with: " " , options: .regularExpression)
            
            if str.count > 120{
                let to = str.index(str.startIndex, offsetBy: 105, limitedBy: str.endIndex)
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                    NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                ]
                
                let attributedString = NSMutableAttributedString(string: "\(str.substring(to: to!))..." , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "readmore") ?? "Read More")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                attributedString.append(attributedString2)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                cell.reviewContentLabel.tag = indexPath.row
                cell.reviewContentLabel.addGestureRecognizer(tapGesture)
                cell.reviewContentLabel.isUserInteractionEnabled = true
                
                cell.reviewContentLabel.attributedText = attributedString
                
            }else{
                cell.reviewContentLabel.isUserInteractionEnabled = true
                cell.reviewContentLabel.text = str
            }
            
            cell.imgView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
            
            
            
            
            cell.starRatingView.rating = self.propertyReviewArray[indexPath.row].rating ?? 0.0
            cell.reviewDateLabel.text = self.reviewstimestampconvert(timestamp:self.propertyReviewArray[indexPath.row].createdAt ?? "")
            
            cell.readMoreBtn.isHidden = true
            
            return cell
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let a = (sender.view as? UILabel)?.text else { return }
        
        self.goToAllReviewPage(value: true, index: (sender.view as? UILabel)?.tag ?? 0)
    }
    
    @objc func handleProfileTabbed(sender: UITapGestureRecognizer) {
        guard let a = (sender.view as? UILabel)?.text else { return }
        
        self.goToReviewersProfilePage(tag: (sender.view as? UILabel)?.tag ?? 0)
      
    }
    
    
    @objc func handleProfileImgTabbed(sender: UITapGestureRecognizer) {
        
        self.goToReviewersProfilePage(tag: (sender.view as? UIImageView)?.tag ?? 0)
      
    }
    
    func goToReviewersProfilePage(tag: Int){
        let editprofileobj = HostProfileViewPage()
        editprofileobj.profileid = (propertyReviewArray[tag].authorData?.fragments.profileFields.profileId!)!
        editprofileobj.profilename = (propertyReviewArray[tag].authorData?.fragments.profileFields.firstName!)!
        editprofileobj.showprofileAPICall(profileid:propertyReviewArray[tag].authorData?.fragments.profileFields.profileId ?? 0)
        editprofileobj.modalPresentationStyle = .fullScreen
        self.present(editprofileobj, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == explorecollectionView{
            let viewListing = UpdatedViewListing()
            viewListing.listID = similarlistingArray[indexPath.row].id ?? 0
            Utility.shared.unpublish_preview_check = false
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    
    
    func timestampconvert(timestamp:String)
    {
        let timestamValue = Int(timestamp)!/1000
        let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        self.reviewDate = dateFormatter.string(from: newTime)
    }
    
    func reviewstimestampconvert(timestamp:String) -> String
    {
        let timestamValue = Int(timestamp)!/1000
        let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, yyyy"
        
        return dateFormatter.string(from: newTime)
    }
    
    func reviewcountAPICall(profileid:Int)
    {
        let reviewListquery = UserReviewsQuery(ownerType: "others", currentPage: 1, profileId: profileid)
        
        apollo_headerClient.fetch(query: reviewListquery){(result,error) in
            
            
            guard (result?.data?.userReviews?.results) != nil else{
               
                return
            }
            self.reiewListingArray = (result?.data?.userReviews?.results)! as! [UserReviewsQuery.Data.UserReview.Result]
         
        }
        
    }
    
    func getreviewAPICall(listId:Int,hostId:String){
        
        let getreviewquery = GetReviewsListQuery(listId: listId, currentPage: 1, hostId: hostId)
        apollo_headerClient.fetch(query: getreviewquery){(result,error) in
            if(result?.data?.getReviews?.status == 200){
                self.getreviewArray = (result?.data?.getReviews?.results!)! as! [GetReviewsListQuery.Data.GetReview.Result]
                if(self.getreviewArray.count > 0){
                    self.timestampconvert(timestamp:self.getreviewArray[0].createdAt!)
                }
            }
        }
    }
    
    
    @objc func whishlistBtnTapped(_ sender: UIButton!)
    {
        if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
        {
            let welcomeObj = WelcomePageVC()
            welcomeObj.modalPresentationStyle = .fullScreen
            self.present(welcomeObj, animated:false, completion: nil)
         
        }
        else
        {
            let headerView = WhishlistPageVC()
            headerView.listID = similarlistingArray[sender.tag].id!
            headerView.listimage = similarlistingArray[sender.tag].listPhotoName!
            headerView.delegate = self
            headerView.modalPresentationStyle = .overFullScreen
            self.present(headerView, animated: true, completion: nil)
        }
    }
    func datePickerController(_ datePickerController: AirbnbDatePickerViewController, didSaveStartDate startDate: Date?, endDate: Date?) {
        if(startDate != nil)
        {
           
            selectedStartDate = startDate
            selectedEndDate = endDate
            
            
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            if(startDate != nil && endDate != nil){
              
            }
            
            if selectedStartDate == nil && selectedEndDate == nil {
                chkAvailabiltyBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"checkavailability"))!)", for: .normal)
            } else {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                billingListAPICall(startDate: fmt.string(from: startDate!), endDate: fmt.string(from: endDate!))
                if(viewListingArray.bookingType != nil && viewListingArray.bookingType! == "instant")
                {
                    chkAvailabiltyBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"book"))!)", for: .normal)
                }
                else
                {
                    chkAvailabiltyBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"requestbook"))!)", for: .normal)
                }
            }
        }
        else
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selectdate"))!)")
        }
    }
    
  
    func conversionRailwaytime(time:String) -> String
    {
        var dateAsString = time
        var strArr = time.split{$0 == ":"}.map(String.init)
        let hour = Int(strArr[0])!
        if(hour > 12 && hour != 24 && hour != 25 && hour != 26){
            dateAsString = "\(Int(dateAsString)!-12)" + " " +  "PM"
        }
        else if(hour == 25)
        {
            dateAsString = "1 AM"
        }
        else if(hour == 26)
        {
            dateAsString = "2 AM"
        }
        else if(hour == 12)
        {
            dateAsString = "12 PM"
        }
        else if(hour == 24)
        {
            dateAsString = "12 AM"
        }
        else{
            let trimmedString = dateAsString.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
            dateAsString = trimmedString +  " " +  "AM"
        }
        return dateAsString
    }
    
  
    
}
extension GuestDetailVC : ImageScrollerDelegate{
    
    
    
    
    func pageChanged(index: Int, indexpath: Int) {
        
        Pagecontrol.currentPage = index
        
        
    }
}
extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
extension String {
    func condensingWhitespace() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}


