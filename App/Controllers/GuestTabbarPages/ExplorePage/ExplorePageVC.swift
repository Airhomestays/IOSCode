

import UIKit
import MaterialComponents.MaterialButtons
import Lottie
import Apollo
import Alamofire
import SwiftyJSON
import ISPageControl
import FirebaseCrashlytics
import SwiftMessages
import SkeletonView
import FlexiblePageControl

extension UIView {
    
    func addBottomShadow(withIsClear: Bool) {
        if !withIsClear {
            self.layer.shadowColor = UIColor.clear.cgColor
        } else {
            self.layer.shadowColor = UIColor.lightGray.cgColor
        }
        
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1))
        self.layer.shadowPath = shadowPath.cgPath
        
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1
    }
}

class ExplorePageVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,AirbnbDatePickerDelegate,AirbnbOccupantFilterControllerDelegate,UIScrollViewDelegate,WhishlistPageVCProtocol, SkeletonCollectionViewDataSource, ListVCProtocol,MoreFilterVCDelegate,FloatMapVCDelegate {
    
  
    func updateBedscount(priceRange: Int) {
        self.bedscount = priceRange
    }
    
    func updateBathRoomscount(priceRange: Int) {
        self.bathroomscount = priceRange
    }
    
    func updateBedRoomscount(priceRange: Int) {
        self.bedroomscount = priceRange
    }
    
    func updateguestcount(priceRange: Int) {
        self.guestcount = priceRange
    }
    
    func updatePriceRange(priceRange: NSMutableArray) {
        self.priceRangeArray = priceRange
    }
    
    func updatehometype(priceRange: NSMutableArray) {
        self.roomtypeArray = priceRange
    }
    
    func updateamenities(priceRange: NSMutableArray) {
        self.amenitiesArray = priceRange
    }
    
    func updatefacilities(priceRange: NSMutableArray) {
        self.facilitiesArray = priceRange
    }
    
    func UpdatehouseRule(priceRange: NSMutableArray) {
        self.houserulesArray = priceRange
    }
    
 
    func passSelectedBedscount(priceRange: Int) {
        bedscount = priceRange
    }
    
    func passSelectedBathRoomscount(priceRange: Int) {
        bathroomscount = priceRange
    }
    
    func passSelectedBedRoomscount(priceRange: Int) {
        bedroomscount = priceRange
    }
    
    func passSelectedguestcount(priceRange: Int) {
        self.guestcount = priceRange
    }
    
    func passSelectedPriceRange(priceRange: NSMutableArray) {
        self.priceRangeArray = priceRange
       
    }
    
    
    func passSelectedhometype(priceRange: NSMutableArray) {
        self.roomtypeArray = priceRange
    }
    
    func passSelectedamenities(priceRange: NSMutableArray) {
        self.amenitiesArray = priceRange
       
    }
    
    func passSelectedfacilities(priceRange: NSMutableArray) {
        self.facilitiesArray = priceRange
       
    }
    
    func passSelectedhouserule(priceRange: NSMutableArray) {
        self.houserulesArray = priceRange
       
    }
    
    func UpdateWhishlistCall(listId: Int, status: Bool) {
        self.lottieAnimation()
        if(isFilterEnable)
        {
            FilterArray.removeAll()
            PageIndex = 1
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
            })
            self.collectionViewFilterPage.reloadData()
            self.searchListingAPICall()
        }
        else
        {
            let whishlistQuery = GetAllWishListGroupQuery()
            apollo_headerClient.fetch(query: whishlistQuery,cachePolicy:.fetchIgnoringCacheData){ [self] (result,error) in
                guard (result?.data?.getAllWishListGroup?.results) != nil else{
                    
                    
                    return
                }
                self.whishlistarray = ((result?.data?.getAllWishListGroup?.results)!) as! [GetAllWishListGroupQuery.Data.GetAllWishListGroup.Result]
                if(self.whishlistarray.count>0)
                {
                    if(mostListingArray.count > 0) {
                        for index in 0...mostListingArray.count - 1 {
                            if(mostListingArray[index].id == listId) {
                                if(!mostListingArray[index].isListOwner!) {
                                    
                                    if(status != mostwishlist_Array[index] as! Bool) {
                                        for wishindex in 0...whishlistarray.count - 1 {
                                            if((whishlistarray[wishindex].wishListIds?.contains(listId))!)
                                            {
                                                mostwishlist_Array[index] = 1
                                                break
                                            }
                                            
                                            else {
                                                mostwishlist_Array[index] = 0
                                            }
                                        }
                                        let indexPath = IndexPath(row: index, section: 0)
                                        self.mostViewedCOllectionView.reloadItems(at: [indexPath])
                                    }
                                    else {
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                    if(recommendListingArray.count > 0) {
                        
                        for index in 0...recommendListingArray.count - 1 {
                            if(recommendListingArray[index].id == listId) {
                                if(!recommendListingArray[index].isListOwner!) {
                                    for wishindex in 0...whishlistarray.count - 1 {
                                        if((whishlistarray[wishindex].wishListIds?.contains(listId))!)
                                        {
                                            wishlistArray[index] = 1
                                            break
                                        }
                                        
                                        else {
                                            wishlistArray[index] = 0
                                        }
                                    }
                                    
                                    let indexPath = IndexPath(row: index, section: 0)
                                    self.recommendedCollectionView.reloadItems(at: [indexPath])
                                    
                                }
                            }
                            else {
                                
                            }
                        }
                    }
                }
                
                
                
            }
        }
    }
    
    
    
    
    func didupdateWhishlistStatus(status: Bool) {
        
    }
    @IBOutlet weak var topCollectionCvc: TopCollectionView!
    
    @IBOutlet weak var shadowVw: UIView!
  
    @IBOutlet weak var homeTypeCvc: UICollectionView!
    
    @IBOutlet var exploreTV: UITableView!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var exploreTitleLabel: UILabel!
    
    @IBOutlet var parentView: UIView!
    
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var newFilterBtn: UIButton!
    var lottieView: LottieAnimationView!
    
    @IBOutlet weak var NoListingFoundImage: UIImageView!
    @IBOutlet weak var NoListingFoundTitle: UILabel!
    @IBOutlet weak var searchBackBtn: UIButton!
    @IBOutlet weak var NoresultView: UIView!
    @IBOutlet var filterView: UIView!
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var NoViewNoresult: UILabel!
    @IBOutlet weak var noViewFirstText: UILabel!
    @IBOutlet weak var noViewSecondText: UILabel!
    @IBOutlet weak var NoViewthirdText: UILabel!
    @IBOutlet weak var retry_button: UIButton!
    @IBOutlet weak var error_label: UILabel!
    @IBOutlet weak var skeltonView: UIView!
    
    
   
    var houserulesArray = NSMutableArray()
    var facilitiesArray = NSMutableArray()
    var amenitiesArray = NSMutableArray()
    var roomtypeArray = NSMutableArray()
    var priceRangeArray = NSMutableArray()
    var guestcount = Int()
    var bedscount = Int()
    var bathroomscount = Int()
    var bedroomscount = Int()
    let lottieWholeView = UIView()

    var isPopularSelected = false
    var isSwitchEnable = false
    
    var isAnimation = false
    
    var isHeight = true
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet weak var shadowHgt: NSLayoutConstraint!
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewFilterPage: UICollectionView!
    
    var whishlistarray = [GetAllWishListGroupQuery.Data.GetAllWishListGroup.Result]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    var refreshControl = UIRefreshControl()
    var collectionRefreshControl = UIRefreshControl()
    @IBOutlet weak var popularListingTitle: UILabel!
    @IBOutlet weak var popularListTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var popularCollectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recommendedTitle: UILabel!
    @IBOutlet weak var recommendedTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    @IBOutlet weak var recommendedCollectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recommendedCollectionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var becomeAHostView: UIView!
    @IBOutlet weak var becomeAHostHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var becomeAHostTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hostSamepleImageView: UIImageView!
    @IBOutlet weak var hostTransparentImageView: UIImageView!
    @IBOutlet weak var hostTitleLabel: UILabel!
    @IBOutlet weak var hostBtn: UIButton!
    @IBOutlet weak var hostTransparentBtn: UIButton!
    
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mostViewedTitle: UILabel!
    @IBOutlet weak var mostViewedTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mostViewedCOllectionView: UICollectionView!
    @IBOutlet weak var mostViewedCOllectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mostViewedCollectionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var mostViewedPageControl: ISPageControl!
  
    
    @IBOutlet weak var recommendedPageControl: FlexiblePageControl!
    @IBOutlet weak var floatingMapView: UIView!
    @IBOutlet weak var mapImgView: UIImageView!
    @IBOutlet weak var mapTitle: UILabel!
    @IBOutlet weak var floatingMapBtn: UIButton!
    @IBOutlet weak var demoCollectionView: UICollectionView!
    
    
    var listID = Int()
    
    var PageIndex : Int = 1
    var recommendedTotalPage: Int = 1
    var mostViewedTotalPage: Int = 1
    var Pagecontrol:ISPageControl!
    
  
    var entirehomeArray = NSMutableArray()
    var homeImageArray = NSMutableArray()
    var homeTitleArray = NSMutableArray()
    var homePriceArray = NSMutableArray()
    var reviewcount_Array = NSMutableArray()
    var reviewStart_ratingArray = NSMutableArray()
    var wishlistArray = NSMutableArray()
    var mosthomeImageArray = NSMutableArray()
    var mosthomeTitleArray = NSMutableArray()
    var mosthomePriceArray = NSMutableArray()
    var mostreviewcount_Array = NSMutableArray()
    var most_entirehomeArray = NSMutableArray()
    var mostreviewStart_ratingArray = NSMutableArray()
    var mostwishlist_Array = NSMutableArray()
    var filteredImageArray = NSMutableArray()
    var filteredTitleArray = NSMutableArray()
    var filteredPriceArray = NSMutableArray()
    var filtered_reviewcountArray = NSMutableArray()
    var filtered_reviewstartArray = NSMutableArray()
    var filtered_entirehomeArray = NSMutableArray()
    var filtered_whishlistArray = NSMutableArray()
    var bookingTypeArray = NSMutableArray()
    var mostbookingTypeArray = NSMutableArray()
    let dateBtn = UIButton()
    let guestBtn = UIButton()
    let filterBtn = UIButton()
    public var selectedStartDate: Date?
    public var selectedEndDate: Date?
    
    var FilterData = SearchListingQueryy.Data.SearchListing.Result()
    var FilterArray = [SearchListingQueryy.Data.SearchListing.Result]()
    var recommendListingArray = [GetDefaultSettingQuery.Data.GetRecommend.Result]()
    var mostListingArray = [GetDefaultSettingQuery.Data.GetMostViewedListing.Result]()
    var currencyvalue_from_API = GetDefaultSettingQuery.Data.Currency.Result()
    var RoomsFilterArray = [GetDefaultSettingQuery.Data.GetListingSettingsCommon.Result]()
    var getsearchPriceArray = GetDefaultSettingQuery.Data.GetSearchSetting.Result()
    var getRoomTypeArray = [GetRoomTypeSettingsQuery.Data.GetRoomTypeSetting.Result?]()
    
    var populardestinationArray = [GetPopularLocationsQuery.Data.GetPopularLocation.Result]()
    var currency_Dict = NSDictionary()
    var adultCount: Int = 1
    var childrenCount: Int = 0
    var infantCount: Int = 0
    var hasPet: Bool = false
    var isWhishlist: Bool = false
    var isFilterEnable:Bool = false
    var isAnimationCompleted:Bool = false
    var totalListcount:Int = 0
    var explorecollectionView: UICollectionView?
    
    var progressVw = UIView()
    
    var dateFormatter: DateFormatter {
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
    var selectedstartDate_filter = String()
    var selectedEndDate_filter = String()
    var guest_filter = Int()
    var lastContentOffset: CGFloat = 0
    var apollo_headerClient:ApolloClient!
    var _performingAnimation = false
    var _performingPopularAnimation = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.collectionViewFilterPage.isHidden = true
        self.lottieAnimation()
        self.lottieAnimationView()
        self.configureFilterCollectionView()
        self.checkApolloStatus()
        self.profileAPICall()
        self.getFilterFunc()
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWishlist(notification:)), name: Notification.Name("Whishlishdelete"), object: nil)
      
        
        parentView.backgroundColor = UIColor(named: "colorController")
        self.view.backgroundColor = UIColor(named: "colorController")
        self.demoCollectionView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
        self.skeltonView.backgroundColor = UIColor(named: "colorController")
        self.demoCollectionView.backgroundColor = UIColor(named: "colorController")
        if Utility.shared.getAppTheme() == "dark" {
            self.topCollectionCvc.backgroundColor = UIColor(named: "becomeAHostStep_Color")
            self.bottomView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        } else {
            self.topCollectionCvc.backgroundColor = UIColor(named: "colorController")
            self.bottomView.backgroundColor = UIColor(named: "colorController")
        }
        
        self.initialSetup()
        self.configFloatingBtn()
        self.floatingMapView.isHidden = true
        
        if(Utility.shared.isRTLLanguage()){
            topCollectionCvc.semanticContentAttribute = .forceRightToLeft
        }else{
            topCollectionCvc.semanticContentAttribute = .forceLeftToRight
        }
        
        if Utility.shared.isSwitchEnable == false {
            self.setUpdatedView()
        }
       
        self.newFilterBtn.setImage(UIImage(named: "explore_filter"), for: .normal)
        
        topCollectionCvc.apiCall = { [unowned self] (array) in
           
            Utility.shared.roomtypeArray = array
            Utility.shared.TotalFilterCount += Int(0.5)
            
            self.PageIndex = 1
            self.FilterArray.removeAll()
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showSkeleton()
            })
            self.collectionViewFilterPage.reloadData()
            self.collectionViewFilterPage.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: false)
            self.searchListingAPICall()
        }
    }
    
    @objc func refreshWishlist(notification: NSNotification) {
        if isFilterEnable {
            self.searchListingAPICall()
        }
        else {
            self.popularAPICall()
            self.MostViewedListingAPICall()
        }
    }
    
    func profileAPICall() {
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
                    Utility.shared.EditProfileArray = ((result?.data?.userAccount?.result)!)
                    Utility.shared.userName  = "\(Utility.shared.ProfileAPIArray.firstName != nil ? Utility.shared.ProfileAPIArray.firstName! : "User")!"
                    
                    
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
    
    func setUpdatedView(){
        
        self.exploreTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Explore_Title") ?? "Explore the world! By Travelling")"

        Utility.shared.isSwitchEnable = false
        Utility.shared.filterCount = 1
        self.exploreTitleLabel.numberOfLines = 0
        self.exploreTitleLabel.lineBreakMode = .byWordWrapping
        self.exploreTitleLabel.textColor =  UIColor(named: "Title_Header")
        self.exploreTitleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24)
        self.exploreTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        self.locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.locationLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"losangeles") ?? "Where do you go?")"
        
        self.popularListingTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "populardest") ?? "Popular Locations")"
        self.popularListingTitle.textColor =  UIColor(named: "Title_Header")
        self.popularListingTitle.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        self.popularListingTitle.numberOfLines = 0
        self.popularListingTitle.lineBreakMode = .byWordWrapping
        
        self.popularCollectionView.delegate = self
        self.popularCollectionView.dataSource = self
        
        self.popularCollectionView.register(UINib(nibName: "popularcollectionCell", bundle: nil), forCellWithReuseIdentifier: "popularcollectionCell")
    
        self.popularCollectionView.showsHorizontalScrollIndicator = false
        
        self.popularCollectionView.reloadData()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        
        self.popularCollectionView.collectionViewLayout = layout
        
        
        self.recommendedTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "recommended") ?? "Recommended")"
        self.recommendedTitle.textColor =  UIColor(named: "Title_Header")
        self.recommendedTitle.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        self.recommendedTitle.numberOfLines = 0
        self.recommendedTitle.lineBreakMode = .byWordWrapping
        
        
        self.recommendedCollectionView.delegate = self
        self.recommendedCollectionView.dataSource = self
        self.recommendedCollectionView.register(UINib(nibName: "customUpdatedCell", bundle: nil), forCellWithReuseIdentifier: "CellcustomUpdated")
        self.recommendedCollectionView.showsHorizontalScrollIndicator = false
        
        self.homeTypeCvc.delegate = self
        self.homeTypeCvc.dataSource = self
        self.homeTypeCvc.register(UINib(nibName: "HomeTypeFilterCell", bundle: nil), forCellWithReuseIdentifier: "HomeTypeFilterCell")
        
        let layoutRecommended = UICollectionViewFlowLayout()
        layoutRecommended.scrollDirection = .horizontal
        layoutRecommended.minimumLineSpacing = 10
        layoutRecommended.minimumInteritemSpacing = 0
        
        self.recommendedCollectionView.collectionViewLayout = layoutRecommended
        
        
        self.mostViewedTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "mostviewed") ?? "Most viewed")"
        self.mostViewedTitle.textColor =  UIColor(named: "Title_Header")
        self.mostViewedTitle.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        self.mostViewedTitle.numberOfLines = 0
        self.mostViewedTitle.lineBreakMode = .byWordWrapping
        
        
        self.mostViewedCOllectionView.delegate = self
        self.mostViewedCOllectionView.dataSource = self
        self.mostViewedCOllectionView.register(UINib(nibName: "customUpdatedCell", bundle: nil), forCellWithReuseIdentifier: "CellcustomUpdated")
        self.mostViewedCOllectionView.showsHorizontalScrollIndicator = false
        
        let layoutMostViewed = UICollectionViewFlowLayout()
        layoutMostViewed.scrollDirection = .vertical
        layoutMostViewed.minimumLineSpacing = 10
        layoutMostViewed.minimumInteritemSpacing = 0
        
        self.mostViewedCOllectionView.collectionViewLayout = layoutMostViewed
        
        
        if (Utility.shared.isRTLLanguage()){
            self.scrollView.semanticContentAttribute = .forceRightToLeft
            self.mostViewedCOllectionView.semanticContentAttribute = .forceRightToLeft
        }else{
            self.scrollView.semanticContentAttribute = .forceLeftToRight
            self.mostViewedCOllectionView.semanticContentAttribute = .forceLeftToRight
        }
        
        
        mostViewedCOllectionView?.prepareSkeleton(completion: { [self] done in
            self.mostViewedCOllectionView?.isSkeletonable = true
            self.mostViewedCOllectionView.showSkeleton()
        })
        
        recommendedCollectionView?.prepareSkeleton(completion: { [self] done in
            self.recommendedCollectionView?.isSkeletonable = true
            self.recommendedCollectionView.showSkeleton()
        })
        
        popularCollectionView?.prepareSkeleton(completion: { [self] done in
            self.popularCollectionView?.isSkeletonable = true
            self.popularCollectionView.showSkeleton()
        })
        
        self.configureBecomeAHostView()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshCalled), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
        self.popularAPICall()
        self.MostViewedListingAPICall()
    }
    
    @objc func refreshCalled()
    {
        self.popularAPICall()
        self.MostViewedListingAPICall()
        self.refreshControl.endRefreshing()
    }
    
    @objc func collectionViewRefreshControl(){
        self.PageIndex = 1
        self.FilterArray.removeAll()
        collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
            self.collectionViewFilterPage?.isSkeletonable = true
            self.collectionViewFilterPage?.showSkeleton()
        })
        self.collectionViewFilterPage.reloadData()
        self.searchListingAPICall()
        self.collectionRefreshControl.endRefreshing()
    }
    
    func configureBecomeAHostView(){
        self.becomeAHostView.layer.cornerRadius = 15
        self.becomeAHostView.clipsToBounds = true
        
        self.becomeAHostView.showSkeleton()
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        let gradient = SkeletonGradient(baseColor: UIColor.lightGray)
        self.becomeAHostView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
        self.hostSamepleImageView.layer.cornerRadius = 20
        self.hostSamepleImageView.clipsToBounds = true
        
        self.hostTransparentImageView.layer.cornerRadius = 20
        self.hostTransparentImageView.clipsToBounds = true
        
        self.hostTitleLabel.backgroundColor = .clear
        self.hostTitleLabel.textColor = UIColor.white
        self.hostTitleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        
        self.hostBtn.layer.cornerRadius = self.hostBtn.frame.size.height / 2
        self.hostBtn.clipsToBounds = true
        self.hostBtn.setTitleColor(UIColor.white, for: .normal)
        self.hostBtn.backgroundColor = Theme.Button_BG
        self.hostBtn.titleLabel?.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16.0)
        self.hostTransparentBtn.setTitle("", for: .normal)
        self.hostBtn.addTarget(self, action: #selector(onClickBecomeAHostBtn), for: .touchUpInside)
    }
    
    @objc func onClickBecomeAHostBtn(sender: UIButton){
        
        if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
        {
            let welcomeObj = WelcomePageVC()
            welcomeObj.modalPresentationStyle = .fullScreen
            self.present(welcomeObj, animated:false, completion: nil)
        }else{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            Utility.shared.isfromGuestProfile = true
            
            
            Utility.shared.host_message_isfrommessage = true
            Utility.shared.host_message_isfromHost = true
            
            let SplashObj = SwitchTravelAndHostVC()
            
            if Utility.shared.isfromNotificationHost || Utility.shared.isfromOfflineNotification || Utility.shared.isfromBackroundBooking || Utility.shared.isfromOfflineBooking{
                Utility.shared.isfromHost = true
                Utility.shared.isfromNotificationHost = false
                Utility.shared.isfromOfflineNotification = false
                Utility.shared.isfromBackroundBooking = false
                Utility.shared.isfromOfflineBooking = false
                Utility.shared.isfromGuestProfile = false
            }else{
                Utility.shared.isfromHost = false
            }
            SplashObj.modalPresentationStyle = .fullScreen
            self.present(SplashObj, animated: false) {
            }        }
        
        
        
        
    }
    func configureFilterCollectionView(){
        self.collectionViewFilterPage.delegate = self
        self.collectionViewFilterPage.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        self.collectionViewFilterPage.collectionViewLayout = layout
        self.collectionRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionRefreshControl.addTarget(self, action: #selector(collectionViewRefreshControl), for: .valueChanged)
        self.collectionViewFilterPage.addSubview(collectionRefreshControl)
        self.collectionViewFilterPage.register(UINib(nibName: "UpdatedSearchCell", bundle: nil), forCellWithReuseIdentifier: "cellUpdatedSearch")
        self.demoCollectionView.register(UINib(nibName: "DemoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DemoCollectionViewCell")
        self.collectionViewFilterPage.register(UINib(nibName: "SearchCollectionViewHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchCollectionViewHeader")
        
        self.collectionViewFilterPage.backgroundColor = UIColor(named: "colorController")
        
        collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
            self.collectionViewFilterPage?.isSkeletonable = true
            self.collectionViewFilterPage?.showSkeleton()
        })
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
    override func viewWillAppear(_ animated: Bool) {
        self.popularCollectionView.isUserInteractionEnabled = true
        Utility.shared.priceRangeArray.removeAllObjects()
        self.checkForUpdate()
        self.locationLabel.textColor =  UIColor(named: "Title_Header")
        self.filterView.isHidden = true
        self.filterViewHeightConstraint.constant = self.filterView.isHidden ? 0 : 43
        newFilterBtn.backgroundColor =  UIColor(named: "colorController")
      
        if (Utility.shared.TotalFilterCount == 0) || (Utility.shared.TotalFilterCount == Int(0.5)) {
            
            newFilterBtn.setImage(#imageLiteral(resourceName: "explore_filter"), for: .normal)
        } else {
          
            self.newFilterBtn.backgroundColor = Theme.PRIMARY_COLOR
            newFilterBtn.setImage(#imageLiteral(resourceName: "filterblue"), for: .normal)
        }
        self.newFilterBtn.layer.cornerRadius = 10
        self.newFilterBtn.clipsToBounds = true
    }
    
    
    func checkForUpdate(){
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appVersionUpdate = GetApplicationVersionInfoQuery(appType: "iosVersion", version: currentVersion)
        
        
        apollo.fetch(query: appVersionUpdate){(result,error) in
            
            if result != nil{
                if (result?.data?.getApplicationVersionInfo?.status == 400){
                    
                    let deleteObj = ForceUpdateViewController()
                    deleteObj.descriptionString = result?.data?.getApplicationVersionInfo?.errorMessage ?? ""
                    deleteObj.appStoreURL = result?.data?.getApplicationVersionInfo?.result?.appStoreUrl ?? ""
                    deleteObj.modalPresentationStyle = .overFullScreen
                    self.present(deleteObj, animated: false, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction func onClickFilterBtn(_ sender: UIButton) {
        if Utility.shared.min_filter_guest_count == 0 {
            
        } else {
            let morefilterObj = MoreFilterVC()
            if isFilterEnable {
                morefilterObj.isFilterEnable = true
            }
            else {
                morefilterObj.isFilterEnable = false
            }
            morefilterObj.RoomsFilterArray = RoomsFilterArray
            morefilterObj.facilitiesArray = self.facilitiesArray
            morefilterObj.housingRulesArray  = self.houserulesArray
            
            morefilterObj.priceRangeArrayVal = self.priceRangeArray
           
            morefilterObj.amenitiesArray = self.amenitiesArray
            
            morefilterObj.roomtypeArray = roomtypeArray
            morefilterObj.filterDelegate = self
            morefilterObj.oldguestcount = guestcount
            morefilterObj.oldbedscount = bedscount
            morefilterObj.oldbathroomscount = bathroomscount
            morefilterObj.oldbedRoomcount = bedroomscount
            morefilterObj.filterDelegate = self
            
            morefilterObj.delegate = self
            morefilterObj.getsearchPriceArray = getsearchPriceArray
            Utility.shared.isfromfloatmap_Page = false
            morefilterObj.modalPresentationStyle = .fullScreen
            self.present(morefilterObj, animated: true, completion: nil)
        }
    }
    
    func APIMethodCall(listId:Int, status:Bool) {
        self.lottieAnimation()
        if(isFilterEnable)
        {
            FilterArray.removeAll()
            PageIndex = 1
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showSkeleton()
            })
            self.searchListingAPICall()
        }
        else
        {
            let whishlistQuery = GetAllWishListGroupQuery()
            apollo_headerClient.fetch(query: whishlistQuery,cachePolicy:.fetchIgnoringCacheData){ [self] (result,error) in
                guard (result?.data?.getAllWishListGroup?.results) != nil else{
                    
                    
                    return
                }
                self.whishlistarray = ((result?.data?.getAllWishListGroup?.results)!) as! [GetAllWishListGroupQuery.Data.GetAllWishListGroup.Result]
                if(self.whishlistarray.count>0)
                {
                    if(mostListingArray.count > 0) {
                        for index in 0...mostListingArray.count - 1 {
                            if(mostListingArray[index].id == listId) {
                                if(!mostListingArray[index].isListOwner!) {
                                    
                                    if(status != mostwishlist_Array[index] as! Bool) {
                                        for wishindex in 0...whishlistarray.count - 1 {
                                            if((whishlistarray[wishindex].wishListIds?.contains(listId))!)
                                            {
                                                mostwishlist_Array[index] = 1
                                                break
                                            }
                                            
                                            else {
                                                mostwishlist_Array[index] = 0
                                            }
                                        }
                                        let indexPath = IndexPath(row: index, section: 0)
                                        self.mostViewedCOllectionView.reloadItems(at: [indexPath])
                                    }
                                    else {
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                    if(recommendListingArray.count > 0) {
                        
                        for index in 0...recommendListingArray.count - 1 {
                            if(recommendListingArray[index].id == listId) {
                                if(!recommendListingArray[index].isListOwner!) {
                                    for wishindex in 0...whishlistarray.count - 1 {
                                        if((whishlistarray[wishindex].wishListIds?.contains(listId))!)
                                        {
                                            wishlistArray[index] = 1
                                            break
                                        }
                                        
                                        else {
                                            wishlistArray[index] = 0
                                        }
                                    }
                                    
                                    let indexPath = IndexPath(row: index, section: 0)
                                    self.recommendedCollectionView.reloadItems(at: [indexPath])
                                    
                                }
                            }
                            else {
                                
                            }
                        }
                    }
                }
                
                
                
            }
        }
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
        Timer.scheduledTimer(timeInterval:0.5, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    func initialSetup()
    {
     
        self.locationLabel.textColor =  UIColor(named: "Title_Header")
        headerView.backgroundColor = UIColor(named: "colorController")
        
        locationLabel.font = UIFont(name: APP_FONT, size: 14)
        
        NoViewNoresult.font = UIFont(name: APP_FONT_BOLD, size: 18)
        NoListingFoundTitle.font = UIFont(name: APP_FONT, size: 16)
        noViewSecondText.font = UIFont(name: APP_FONT, size: 14)
        NoViewthirdText.font = UIFont(name: APP_FONT, size: 14)
        noViewFirstText.font = UIFont(name: APP_FONT, size: 14)
        error_label.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retry_button.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        self.offlineView.isHidden = true
        self.NoresultView.isHidden = true
        self.scrollView.isHidden = false
        searchView.backgroundColor =  UIColor(named: "colorController")
        searchBtn.addTarget(self, action: #selector(searchBtnTapped), for: .touchUpInside)
        
        
        dateBtn.frame = CGRect(x:20, y: 10, width: 90, height: 33)
        dateBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"dates")) ?? "Dates")", for: .normal)
        dateBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"dates")) ?? "Dates")", for: .selected)
        dateBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
        dateBtn.setTitleColor(Theme.TextDarkColor, for: .selected)
        dateBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
       
        dateBtn.layer.borderColor = Theme.TextBorderColor.cgColor
        dateBtn.layer.borderWidth = 1
        dateBtn.layer.cornerRadius = 5.0
        dateBtn.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        dateBtn.layer.masksToBounds = true
        
        
        guestBtn.frame = CGRect(x:(self.dateBtn.frame.origin.x+self.dateBtn.frame.size.width + 10), y: 10, width:110, height: 33)
        guestBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)", for: .normal)
        guestBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)", for: .selected)
        guestBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
        guestBtn.setTitleColor(Theme.TextDarkColor, for: .selected)
        guestBtn.layer.borderColor = Theme.TextBorderColor.cgColor
        guestBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        guestBtn.layer.borderWidth = 1
        guestBtn.layer.cornerRadius = 5.0
        guestBtn.layer.masksToBounds = true
        guestBtn.addTarget(self, action: #selector(showOccupantFilter), for: .touchUpInside)
        filterView.addSubview(dateBtn)
        filterView.addSubview(guestBtn)
        
        filterBtn.frame = CGRect(x:220, y: 10, width: 70, height: 33)
        filterBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"filter"))!)", for: .normal)
        filterBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"filter"))!)", for: .selected)
        filterBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
        filterBtn.setTitleColor(Theme.TextDarkColor, for: .selected)
        filterBtn.layer.borderColor = Theme.TextBorderColor.cgColor
        filterBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        filterBtn.layer.borderWidth = 1
        filterBtn.layer.cornerRadius = 5.0
        filterBtn.layer.masksToBounds = true
        filterBtn.addTarget(self, action: #selector(moreFilter), for: .touchUpInside)
        filterView.addSubview(filterBtn)
        filterBtn.isHidden = true
        
        if Utility.shared.isRTLLanguage(){
            dateBtn.frame = CGRect(x:FULLWIDTH - (20+90), y: 10, width:90, height: 33)
            guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x-120), y: 10, width:110, height: 33)
            filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x-80), y: 10, width: 70, height: 33)
        }else{
            dateBtn.frame = CGRect(x:20, y: 10, width:90, height: 33)
            guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x+self.dateBtn.frame.size.width + 10), y: 10, width:110, height: 33)
            filterBtn.frame = CGRect(x:220, y: 10, width: 70, height: 33)
        }
        
        
        if(IS_IPHONE_XR || IS_IPHONE_X)
        {
            exploreTV.frame = CGRect(x: 0, y: headerView.frame.size.height+headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-400)
        }
        else if(IS_IPHONE_PLUS)
        {
            exploreTV.frame = CGRect(x: 0, y: headerView.frame.size.height+headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-230)
        }
        else if(IS_IPHONE_XS_MAX)
        {
            exploreTV.frame = CGRect(x: 0, y: headerView.frame.size.height+headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-400)
        }
        else if (IS_IPHONE_5)
        {
            exploreTV.frame = CGRect(x: 0, y: headerView.frame.size.height+headerView.frame.origin.y+25, width: FULLWIDTH+55, height:FULLHEIGHT-110)
        }
        
        else
        {
            exploreTV.frame = CGRect(x: 0, y: headerView.frame.size.height+headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-100)
        }
      
        explorecollectionView?.register(UINib(nibName: "ExploreCollectionFilterCell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectionFilterCell")
        explorecollectionView?.register(UINib(nibName: "popularcollectionCell", bundle: nil), forCellWithReuseIdentifier: "popularcollectionCell")
        explorecollectionView?.register(UINib(nibName: "ExploreCollectioncell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectioncell")
        
        self.explorecollectionView?.backgroundColor = UIColor(named: "colorController")
        
        popularCollectionView?.prepareSkeleton(completion: { done in
            self.view.showSkeleton()
        })
        popularCollectionView?.isSkeletonable = true
        
        
        mostViewedCOllectionView?.prepareSkeleton(completion: { done in
            self.view.showSkeleton()
        })
        mostViewedCOllectionView?.isSkeletonable = true
        
        recommendedCollectionView?.prepareSkeleton(completion: { done in
            self.view.showAnimatedSkeleton()
        })
        recommendedCollectionView?.isSkeletonable = true
        
        NoViewNoresult.text = "\((Utility.shared.getLanguage()?.value(forKey:"noresults"))!)"
        NoViewNoresult.textColor = UIColor(named: "Title_Header")
        NoListingFoundTitle.text = "\((Utility.shared.getLanguage()?.value(forKey:"NoListingFound")) ?? "No listing found")"
        noViewFirstText.text = "\((Utility.shared.getLanguage()?.value(forKey:"tryadjustingsearch"))!)"
        noViewSecondText.text = "\((Utility.shared.getLanguage()?.value(forKey:"changefiltersdates"))!)"
        NoViewthirdText.text = "\((Utility.shared.getLanguage()?.value(forKey:"specificaddresscity"))!)"
        error_label.textColor =  UIColor(named: "Title_Header")
        retry_button.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        error_label.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        
        retry_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
    }
    
    
    @objc func moreFilter()
    {
        let morefilterObj = MoreFilterVC()
        morefilterObj.RoomsFilterArray = RoomsFilterArray
        if isFilterEnable {
            morefilterObj.isFilterEnable = true
        }
        else {
            morefilterObj.isFilterEnable = false
        }
        morefilterObj.delegate = self
        morefilterObj.getsearchPriceArray = getsearchPriceArray
        Utility.shared.isfromfloatmap_Page = false
        morefilterObj.modalPresentationStyle = .fullScreen
        self.present(morefilterObj, animated: true, completion: nil)
      
        
    }
    
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int  {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if (skeletonView == popularCollectionView){
            return "popularcollectionCell"
        }
        
        if(skeletonView == collectionViewFilterPage) {
            return "cellUpdatedSearch"
        }
        
        if skeletonView == demoCollectionView {
            return "DemoCollectionViewCell"
        }
        return "CellcustomUpdated"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell?
    {
       
        if (skeletonView == popularCollectionView){
            let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: "popularcollectionCell", for: indexPath)as! popularcollectionCell
            SkeletonAppearance.default.tintColor = UIColor.lightGray
            cell.skeletonCornerRadius = 10
            return cell
        } else if (skeletonView == collectionViewFilterPage) {
            let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: "cellUpdatedSearch", for: indexPath)as! UpdatedSearchCell
            SkeletonAppearance.default.tintColor = UIColor.lightGray
            cell.skeletonCornerRadius = 10
            return cell
             
        } else if (skeletonView == demoCollectionView) {
            let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: "DemoCollectionViewCell", for: indexPath)as! DemoCollectionViewCell
            SkeletonAppearance.default.tintColor = UIColor.lightGray
            cell.skeletonCornerRadius = 10
            return cell
        }
        
        let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: "CellcustomUpdated", for: indexPath)as! customUpdatedCell
        return cell
    }

    func configFloatingBtn()  {
        
        self.floatingMapView.backgroundColor = UIColor(named: "filtercolor")
        self.floatingMapView.layer.cornerRadius = self.floatingMapView.frame.size.height/2
        self.floatingMapView.clipsToBounds = true
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(roundedRect:floatingMapView.bounds, cornerRadius:self.floatingMapView.layer.cornerRadius)
        self.floatingMapView.layer.masksToBounds = false
        self.floatingMapView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.floatingMapView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.floatingMapView.layer.shadowOpacity = 0.3
        self.floatingMapView.layer.shadowPath = shadowPath2.cgPath
        
        self.mapTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "Map") ?? "Map")"
        self.mapTitle.font = UIFont(name: APP_FONT, size: 14.0)
        self.mapTitle.textColor = UIColor.white
        
        self.floatingMapBtn.setTitle("", for: .normal)
        self.floatingMapBtn.setTitleColor(UIColor.clear, for: .normal)
        self.floatingMapBtn.backgroundColor = UIColor.clear
    }
    @IBAction func onClickFloatingBtn(_ sender: UIButton) {
        if(FilterArray.count > 0)
        {
            let mapFloatObj = FloatMapVC()
            mapFloatObj.delegate = self
            mapFloatObj.isUnderline = Utility.shared.isUnderline
            mapFloatObj.mapdelegate = self
            mapFloatObj.getsearchPriceArray = getsearchPriceArray
            mapFloatObj.RoomsFilterArray = RoomsFilterArray
            mapFloatObj.facilitiesArray = self.facilitiesArray
            mapFloatObj.houserulesArray = self.houserulesArray
            mapFloatObj.priceRangeArray = self.priceRangeArray
            mapFloatObj.amenitiesArray = self.amenitiesArray
            mapFloatObj.roomtypeArray = self.roomtypeArray
            mapFloatObj.guestcount = guestcount
            mapFloatObj.bedscount  = bedscount
            mapFloatObj.bathroomscount  = bathroomscount
            mapFloatObj.bedroomscount  = bedroomscount
            mapFloatObj.currencyvalue_from_API_base = Utility.shared.currencyvalue_from_API_base
            mapFloatObj.currency_Dict = Utility.shared.currency_Dict
            mapFloatObj.FloatSearchArray = FilterArray
            mapFloatObj.modalPresentationStyle = .fullScreen
            self.present(mapFloatObj, animated: true, completion: nil)
          
        }
    }
    
    @IBAction func searchBackBtnTapped(_ sender: Any) {
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            Utility.shared.filter = false
            if(isFilterEnable) {
                Utility.shared.clear = true
                Utility.shared.isDateApplied = false
                self.locationLabel.textColor =  UIColor(named: "Title_Header")
                self.searchBackBtn.backgroundColor =  UIColor(named: "viewBG")
                
                Utility.shared.instantBook = ""
                Utility.shared.currentIndex = -1
                self.topCollectionCvc.currentIndex = -1
                let index = IndexPath(row: 0, section: 0)
                self.topCollectionCvc.myCollectionView.scrollToItem(at: index, at: .left, animated: false)
                Utility.shared.roomtypeArray.removeAllObjects()
                Utility.shared.amenitiesArray.removeAllObjects()
                Utility.shared.priceRangeArray.removeAllObjects()
                Utility.shared.facilitiesArray.removeAllObjects()
                Utility.shared.houseRulesArray.removeAllObjects()
                Utility.shared.beds_count = 0
                Utility.shared.bedrooms_count = 0
                Utility.shared.bathroom_count = 0
                Utility.shared.filterCount = 1
                Utility.shared.showGuestCount = false
                Utility.shared.showbedRoomCount = false
                if(Utility.shared.isSwitchEnable)
                {
                    Utility.shared.isSwitchEnable = false
                }
                self.floatingMapView.isHidden = true
                selectedStartDate = nil
                selectedEndDate = nil
                adultCount = 1
                AirbnbDatePickerViewController().handleClearInput()
                Utility.shared.TotalFilterCount = 0
                self.NoresultView.isHidden = true
                self.scrollView.isHidden = false
                guest_filter = 0
                PageIndex = 1
                Utility.shared.selectedstartDate_filter = ""
                Utility.shared.selectedEndDate_filter = ""
                Utility.shared.isSwitchEnable = false
                Utility.shared.isUnderline = false
                self.locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                locationLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"losangeles"))!)"
                searchBackBtn.setImage(#imageLiteral(resourceName: "Magnyfy_glass"), for: .normal)
                headerView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
                self.locationLabel.textColor =  UIColor(named: "Title_Header")
                self.newFilterBtn.layer.shadowOpacity = 0.3
                self.searchView.layer.shadowOpacity = 0.2
                Utility.shared.locationfromSearch = ""
                dateBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"dates")) ?? "Dates")", for: .normal)
                dateBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
                dateBtn.backgroundColor = UIColor.white
                if Utility.shared.isRTLLanguage(){
                    dateBtn.frame = CGRect(x:FULLWIDTH - (20+90), y: 10, width:90, height: 33)
                    guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x-120), y: 10, width:110, height: 33)
                }else{
                    dateBtn.frame = CGRect(x:20, y: 10, width:90, height: 33)
                    guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x+self.dateBtn.frame.size.width + 10), y: 10, width:110, height: 33)
                }
                
                guestBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
                guestBtn.backgroundColor = UIColor.white
                guestBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"guest"))!)", for: .normal)
                self.exploreTV.isHidden = true
                self.collectionViewFilterPage?.isSkeletonable = false
                self.collectionViewFilterPage?.hideSkeleton()
                self.collectionViewFilterPage.isHidden = true
                
                isFilterEnable = false
                filterBtn.isHidden = true
                if(Utility.shared.searchLocationDict.count > 0) {
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
                    Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
                }
                
                filterBtn.backgroundColor = UIColor.white
                newFilterBtn.setImage(#imageLiteral(resourceName: "explore_filter"), for: .normal)
                self.newFilterBtn.backgroundColor = UIColor(named: "colorController")
                filterBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"filter"))!)", for: .normal)
                filterBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
                Utility.shared.selectedstartDate = ""
                Utility.shared.selectedEndDate = ""
                self.isHeight = true
                self.exploreTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Explore_Title") ?? "Explore the world! By Travelling")"
                
                self.exploreTitleLabel.isHidden = false
                self.topHeight.constant = 0
                self.shadowHgt.constant = 0
                self.shadowVw.addBottomShadow(withIsClear: false)
                self.popularAPICall()
                self.MostViewedListingAPICall()
            } else {
                let pageObj = SearchPageVC()
                PageIndex = 1
                pageObj.delegate = self
                Utility.shared.isfromExplorePage = true
                pageObj.modalPresentationStyle = .fullScreen
                self.present(pageObj, animated: true, completion: nil)
            }
        }
    }
    
    @objc func searchBtnTapped(_ sender: UIButton!) {
        
        
        let pageObj = SearchPageVC()
        PageIndex = 1
        pageObj.delegate = self
        Utility.shared.isfromExplorePage = true
        pageObj.modalPresentationStyle = .fullScreen
        self.present(pageObj, animated: true, completion: nil)
        
        
    }
    @IBAction func retyBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            
            if guest_filter != 0 || Utility.shared.selectedEndDate_filter != "" || Utility.shared.selectedstartDate_filter != "" || isFilterEnable == true{
                offlineView.isHidden = true
                collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                    self.collectionViewFilterPage?.isSkeletonable = true
                    self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
                })
                searchListingAPICall()
            }else{
                offlineView.isHidden = true
                self.exploreTV.isHidden = true
                isFilterEnable = false
                self.popularAPICall()
                self.MostViewedListingAPICall()
            }
            
            
        }
    }
}
extension ExplorePageVC:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int{
        var totalSection = 0
        if(!isAnimationCompleted) {
            return 3
        }
        if (populardestinationArray.count > 0){
            totalSection = totalSection + 1
        }
        
        if (mosthomeImageArray.count > 0){
            totalSection = totalSection + 1
        }
        
        if (homeImageArray.count > 0){
            totalSection = totalSection + 1
        }
        return totalSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
        if(!isFilterEnable){
            
            if(homeImageArray.count>0 || mosthomeImageArray.count>0 || populardestinationArray.count > 0){
                return 3
            }
            return 0
        }
        else if(isFilterEnable){
            if(FilterArray.count>0){
                
                return 1
            }
            
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        
        switch section{
        case 0:
            headerView.text = "Popular locations"
            break
        case 1:
            headerView.text = "Recommended"
            break
        case 2:
            headerView.text = ""
            break
        case 3:
            headerView.text = "Most Viewed"
            break
        default:
            headerView.text = ""
            break
        }
        
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section{
        case 0:
            return 50
        case 1:
            return 50
        case 2:
            return 20
        case 3:
            return 50
        default:
            return 20
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if(indexPath.row==0){
            if(populardestinationArray.count == 0)
            {
                if (homeImageArray.count == 0){
                    return 0
                }else{
                    return 200
                }
            }
            else
            {
                return 150
            }
        }
        
        else if(indexPath.row==1){
            if(homeImageArray.count % 2 == 0){
                if(homeImageArray.count == 0){
                    return 0
                }
                return (CGFloat(220 * (homeImageArray.count/2))+80)
            }
            return (CGFloat((220 * (homeImageArray.count/2))+280))
        }
        else if(indexPath.row == 2)
        {
            if(mosthomeImageArray.count % 2 == 0){
                return (CGFloat((220 * (mosthomeImageArray.count/2))+80))
            }
            return (CGFloat((220 * (mosthomeImageArray.count/2))+300))
        }
        return 0
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
        let contentview = UIView()
        if((indexPath.row==0)) {
            if(isFilterEnable){
                contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height:((400 * (FilterArray.count))))
                contentview.clipsToBounds = true
            }
            else{
                contentview.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height:220)
            }
          
            let titleLabel = UILabel()
            if(!isFilterEnable)
            {
                titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"populardest"))!)"
            }
            else
            {
                titleLabel.text = ""
            }
            titleLabel.frame = CGRect(x:20, y: 5, width: FULLWIDTH-40, height:30)
            titleLabel.tintColor =  UIColor(named: "Title_Header")
            titleLabel.textColor =  UIColor(named: "Title_Header")
            titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
            contentview.addSubview(titleLabel)
            let layout = UICollectionViewFlowLayout()
            
            if(isFilterEnable){
                explorecollectionView = UICollectionView(frame: CGRect(x:20, y:0, width: Int(FULLWIDTH-40), height: ((400 * (FilterArray.count)))), collectionViewLayout: layout)
            }
            else
            {
                explorecollectionView = UICollectionView(frame: CGRect(x:20, y:50, width: FULLWIDTH-30, height:150), collectionViewLayout: layout)
            }
            
            explorecollectionView?.tag = 0
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10.0
            layout.minimumInteritemSpacing = 10.0
            explorecollectionView?.dataSource = self
            explorecollectionView?.delegate = self
            explorecollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
          
            explorecollectionView?.showsHorizontalScrollIndicator = false
            if let aView = explorecollectionView {
                contentview.addSubview(aView)
            }
            if(isFilterEnable){
                explorecollectionView?.register(UINib(nibName: "ExploreCollectionFilterCell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectionFilterCell")
            }else{
                explorecollectionView?.register(UINib(nibName: "popularcollectionCell", bundle: nil), forCellWithReuseIdentifier: "popularcollectionCell")
            }
            self.explorecollectionView?.reloadData()
            cell?.contentView.addSubview(contentview)
            return cell!
        }
        
        else if((indexPath.row==1)) {
            if(isFilterEnable){
                contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height:((400 * (FilterArray.count))))
                contentview.clipsToBounds = true
            }
            else{
                if(homeImageArray.count % 2 == 0){
                    contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height:(220 * (homeImageArray.count/2))+50)
                }
                else{
                    contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height:((220 * (homeImageArray.count/2))+280))
                }
            }
           
            let titleLabel = UILabel()
            
            if(homeImageArray.count>0 && !isFilterEnable)
            {
                titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"recommended"))!)"
            }
            else
            {
                titleLabel.text = ""
            }
          
            titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
            titleLabel.frame = CGRect(x:20, y: 0, width: FULLWIDTH - 40, height: 40)
           
            contentview.addSubview(titleLabel)
            
            
            let layout = UICollectionViewFlowLayout()
            if(isFilterEnable){
                explorecollectionView = UICollectionView(frame: CGRect(x:20, y:0, width: Int(FULLWIDTH-40), height: ((400 * (FilterArray.count)))), collectionViewLayout: layout)
            }
            else{
                if(homeImageArray.count % 2 == 0){
                    explorecollectionView = UICollectionView(frame: CGRect(x:20, y:50, width: Int(FULLWIDTH-40), height:((220 * (homeImageArray.count/2)))), collectionViewLayout: layout)
                }
                else{
                    explorecollectionView = UICollectionView(frame: CGRect(x:20, y: 50, width: Int(FULLWIDTH-40), height:((220 * (homeImageArray.count/2))+220)), collectionViewLayout: layout)
                }
            }
            explorecollectionView?.tag = 1
            explorecollectionView?.isScrollEnabled = false
            
           
            explorecollectionView?.dataSource = self
            explorecollectionView?.delegate = self
            explorecollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
            
            if let aView = explorecollectionView {
                contentview.addSubview(aView)
            }
            if(isFilterEnable){
                explorecollectionView?.register(UINib(nibName: "ExploreCollectionFilterCell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectionFilterCell")
                
            }
            else{
                explorecollectionView?.register(UINib(nibName: "ExploreCollectioncell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectioncell")
            }
           
            self.explorecollectionView?.reloadData()
          
            
            cell?.contentView.addSubview(contentview)
            cell?.contentView.layer.cornerRadius = 5.0
            cell?.contentView.clipsToBounds = true
            
            return cell!
        } else{
            if(isFilterEnable){
                contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height:((400 * (FilterArray.count))))
                
            }
            else{
                if(mosthomeImageArray.count % 2 == 0){
                    contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height: ((220 * (mosthomeImageArray.count/2))+80))
                }
                else{
                    contentview.frame = CGRect(x: 0, y: 0, width: Int(FULLWIDTH), height:((220 * (mosthomeImageArray.count/2))+290))
                }
            }
          
            let titleLabel = UILabel()
            if(mosthomeImageArray.count > 0 && !isFilterEnable)
            {
                titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"mostviewed"))!)"
            }
            else
            {
                titleLabel.text = ""
            }
            titleLabel.frame = CGRect(x:20, y: 0, width: FULLWIDTH - 40, height: 40)
            titleLabel.tintColor =  UIColor(named: "Title_Header")
            titleLabel.textColor =  UIColor(named: "Title_Header")
            titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
            contentview.addSubview(titleLabel)
            
            
            let layout = UICollectionViewFlowLayout()
            if(isFilterEnable){
                explorecollectionView = UICollectionView(frame: CGRect(x:20, y:0, width: Int(FULLWIDTH-40), height: (400 * (FilterArray.count))), collectionViewLayout: layout)
            }
            else{
                if(mosthomeImageArray.count % 2 == 0){
                    explorecollectionView = UICollectionView(frame: CGRect(x:20, y:50, width: Int(FULLWIDTH-40), height: (220 * (mosthomeImageArray.count/2))), collectionViewLayout: layout)
                }
                else{
                    explorecollectionView = UICollectionView(frame: CGRect(x:20, y:50, width: Int(FULLWIDTH-40), height:((220 * (mosthomeImageArray.count/2))+220)), collectionViewLayout: layout)
                }
            }
            explorecollectionView?.tag = 2
            explorecollectionView?.isScrollEnabled = false
          
            explorecollectionView?.dataSource = self
            explorecollectionView?.delegate = self
            explorecollectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
         
            if let aView = explorecollectionView {
                contentview.addSubview(aView)
            }
            if(isFilterEnable){
                
                explorecollectionView?.register(UINib(nibName: "ExploreCollectionFilterCell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectionFilterCell")
                
            }
            else{
                explorecollectionView?.register(UINib(nibName: "ExploreCollectioncell", bundle: nil), forCellWithReuseIdentifier: "ExploreCollectioncell")
            }
           
            self.explorecollectionView?.reloadData()
            
            cell?.contentView.addSubview(contentview)
            cell?.contentView.layer.cornerRadius = 5.0
            cell?.contentView.clipsToBounds = true
            return cell!
        }
        
        
        
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (collectionView == self.collectionViewFilterPage && FilterArray.count > indexPath.row){
            let viewListing = UpdatedViewListing()
          //  viewListing.navigationControllerReference = self.navigationController
            Utility.shared.unpublish_preview_check = false
            viewListing.listID = FilterArray[indexPath.row].id ?? 0
            viewListing.delegate = self
            if let imageCell = collectionView.cellForItem(at: indexPath) as? UpdatedSearchCell {
                viewListing.cc_setZoomTransition(originalView:imageCell.contentView)
            }
            
//            let navigationVC = UINavigationController(rootViewController: viewListing)
//            navigationVC.isNavigationBarHidden = true
//            navigationVC.modalPresentationStyle = .fullScreen
            
            self.present(viewListing, animated: true, completion: nil)
        }else if (collectionView == self.popularCollectionView) {
            self.popularCollectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
               
                self.popularCollectionView.isUserInteractionEnabled = true
                Utility.shared.locationfromSearch = self.populardestinationArray[indexPath.row].locationAddress!
                self.locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                
                if Utility.shared.locationfromSearch == "empty" {
                    self.locationLabel.text = ""
                }
                else {
                    self.locationLabel.text = Utility.shared.locationfromSearch
                }
                self.isFilterEnable = true
                self.searchBackBtn.backgroundColor =  UIColor(named: "viewBG")
                self.searchBackBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                self.locationLabel.textColor =  UIColor(named: "Title_Header")
                self.headerView.backgroundColor =  UIColor(named: "becomeAHostStep_Color")
                self.collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                    self.collectionViewFilterPage?.isSkeletonable = true
                    self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
                })
                self.isPopularSelected = true
                self.PageIndex = 1
                if self.isPopularSelected {
                    self.isPopularSelected = false
                    let index = IndexPath(row: 0, section: 0)
                    self.topCollectionCvc.myCollectionView.scrollToItem(at: index, at: .left, animated: false)
                    self.topCollectionCvc.currentIndex = -1
                }
                Utility.shared.currentIndex = -1
                Utility.shared.roomtypeArray.removeAllObjects()
                self.lottieView.isHidden = false
                self.lottieWholeView.isHidden = false
                self.isHeight = false
                
                self.searchListingAPICall()
            })
        }else if (collectionView == self.recommendedCollectionView){
            
            let viewListing = UpdatedViewListing()
//            viewListing.navigationControllerReference = self.navigationController
            Utility.shared.unpublish_preview_check = false
            viewListing.listID = recommendListingArray[indexPath.row].id ?? 0
            viewListing.delegate = self
            
            if let imageCell = collectionView.cellForItem(at: indexPath) as? customUpdatedCell {
                viewListing.cc_setZoomTransition(originalView:imageCell.contentView)
            }
            
//            let navigationVC = UINavigationController(rootViewController: viewListing)
//            navigationVC.isNavigationBarHidden = true
//            navigationVC.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
            
        }else{
            let viewListing = UpdatedViewListing()
//            viewListing.navigationControllerReference = self.navigationController
            Utility.shared.unpublish_preview_check = false
            viewListing.listID = mostListingArray[indexPath.row].id ?? 0
            viewListing.delegate = self
            if let imageCell = collectionView.cellForItem(at: indexPath) as? customUpdatedCell {
              
                viewListing.cc_setZoomTransition(originalView:imageCell.contentView)
            }
            
//            let navigationVC = UINavigationController(rootViewController: viewListing)
//            navigationVC.isNavigationBarHidden = true
//            navigationVC.modalPresentationStyle = .fullScreen
            
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        

        self.view.clipsToBounds = true
        if guest_filter != 0 || Utility.shared.selectedEndDate_filter != "" || Utility.shared.selectedstartDate_filter != "" || isFilterEnable == true{
            self.searchView.layer.borderWidth = 1
            self.searchView.layer.borderColor = Theme.past_bg.cgColor
            self.searchView.layer.cornerRadius = 14
            self.exploreTV.isHidden = true
        }else{
            let shadowSize : CGFloat = 3.0
            let shadowPath = UIBezierPath(roundedRect: newFilterBtn.bounds, cornerRadius: 15)
            self.newFilterBtn.layer.masksToBounds = false
            self.newFilterBtn.layer.shadowColor = Theme.SearchShadowColor.cgColor
            self.newFilterBtn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.newFilterBtn.layer.shadowOpacity = 0.2
            self.newFilterBtn.layer.cornerRadius = 14
            self.newFilterBtn.layer.shadowPath = shadowPath.cgPath
            let shadowPath2 = UIBezierPath(roundedRect:searchView.bounds, cornerRadius: 15)
            self.searchView.layer.cornerRadius = 14
            self.searchView.clipsToBounds = true
            self.searchView.layer.masksToBounds = false
            self.searchView.layer.shadowColor = Theme.SearchShadowColor.cgColor
            self.searchView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.searchView.layer.shadowOpacity = 0.2
            self.searchView.layer.shadowPath = shadowPath2.cgPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == collectionViewFilterPage {
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchCollectionViewHeader", for: indexPath) as! SearchCollectionViewHeader
              
                headerView.onoffSwitch.addTarget(self, action: #selector(switchValue(_ :)), for: .valueChanged)
                return headerView
            }
            return UICollectionReusableView()
        }
        return UICollectionReusableView()
    }
    
    @objc func switchValue(_ sender: UISwitch) {
        if sender.isOn {
            isAnimation = true
            isSwitchEnable = true
            Utility.shared.isOneTotal = true
            searchListingAPICall()
            Utility.shared.isUnderline = true
            collectionViewFilterPage.reloadData()
        } else {
            isAnimation = false
            isSwitchEnable = false
            Utility.shared.isOneTotal = false
            Utility.shared.isUnderline = false
            collectionViewFilterPage.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       
        if !Utility.shared.selectedstartDate.isEmpty {
            if collectionView == collectionViewFilterPage {
                return CGSize(width: collectionView.bounds.width, height: 110)
            }
        } else {
            Utility.shared.isUnderline = false
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.popularCollectionView){
            return populardestinationArray.count
        }else if (collectionView == self.recommendedCollectionView){
            return homeImageArray.count
        }else if (collectionView == self.mostViewedCOllectionView){
            return mosthomeImageArray.count
        } else if collectionView == demoCollectionView {
            return 10
        }else {
            if(FilterArray.count>0 && collectionView == self.collectionViewFilterPage){
                return FilterArray.count
            }
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.popularCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularcollectionCell", for: indexPath)as! popularcollectionCell
            let listimage = populardestinationArray[indexPath.row].image!
            cell.popularImage.sd_setImage(with: URL(string: "\(POPULAR_LOCATION_IMAGE)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            cell.popularImage.contentMode = .scaleAspectFill
            cell.popularLabel.text = "\(populardestinationArray[indexPath.row].location!)"
            cell.popularLabel.textAlignment = .center
            cell.popularImage.layer.cornerRadius = 15.0
            cell.popularImage.layer.masksToBounds = true
            cell.shadowView.layer.cornerRadius = 15.0
            cell.shadowView.layer.masksToBounds = true
            
            return cell
        }else if (collectionView == self.recommendedCollectionView) {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellcustomUpdated", for: indexPath)as! customUpdatedCell
            cell.lineView.isHidden = true
            var listTypeString = ""
            if(Utility.shared.isRTLLanguage()) {
                if ((self.recommendListingArray[indexPath.row].beds ?? 0) > 1){
                    listTypeString =  "\(self.recommendListingArray[indexPath.row].beds ?? 0)" + " beds"
                }else if ((self.recommendListingArray[indexPath.row].beds ?? 0) == 1){
                    listTypeString = "\(self.recommendListingArray[indexPath.row].beds ?? 0)" + " bed"
                }
                
                listTypeString = listTypeString + " / " + "\(self.recommendListingArray[indexPath.row].roomType ?? "")"
            } else {
                listTypeString = "\(self.recommendListingArray[indexPath.row].roomType ?? "")"
                if ((self.recommendListingArray[indexPath.row].beds ?? 0) > 1){
                    listTypeString = listTypeString + " / " + "\(self.recommendListingArray[indexPath.row].beds ?? 0)" + " beds"
                }else if ((self.recommendListingArray[indexPath.row].beds ?? 0) == 1){
                    listTypeString = listTypeString + " / " + "\(self.recommendListingArray[indexPath.row].beds ?? 0)" + " bed"
                }
            }
            cell.listTypeLabel.text = listTypeString
            cell.listTypeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
            let listimage = homeImageArray[indexPath.row]
            cell.imageView.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            cell.imageView.contentMode = .scaleAspectFill
            cell.listTitleLabel.text = self.recommendListingArray[indexPath.row].title ?? ""
            
            cell.lightningImageView.isHidden = self.recommendListingArray[indexPath.row].bookingType != "instant"
            
            
            if("\(wishlistArray[indexPath.row])" == "0"){
                cell.heartBtn.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
            }else{
                cell.heartBtn.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            }
            cell.heartBtn.isHidden = false
            cell.heartBtn.tag = indexPath.row
            cell.heartBtn.addTarget(self, action: #selector(likeBtnTapped), for: .touchUpInside)
            
            
            if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "") {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                let from_currency = self.recommendListingArray[indexPath.row].listingData?.currency
                let currency_amount = self.recommendListingArray[indexPath.row].listingData?.basePrice != nil ? self.recommendListingArray[indexPath.row].listingData?.basePrice : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency:currencyvalue_from_API.base!, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.listPriceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 18),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                
                
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                if(Utility.shared.isRTLLanguage()) {
                    
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                    
                } else {
                    let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                }
                
                cell.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            } else {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API.base!)
                let from_currency = self.recommendListingArray[indexPath.row].listingData?.currency
                let currency_amount = self.recommendListingArray[indexPath.row].listingData?.basePrice != nil ? self.recommendListingArray[indexPath.row].listingData?.basePrice : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency:currencyvalue_from_API.base!, fromCurrency:from_currency!, toCurrency:self.currencyvalue_from_API.base!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.listPriceLabel.text = "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 18),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                
                
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                if(Utility.shared.isRTLLanguage()) {
                    
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                    
                } else {
                    let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                }
                cell.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            }
            
            let value1 = Float("\(reviewcount_Array[indexPath.row])") ?? 0.0
            let value2 = Float("\(reviewStart_ratingArray[indexPath.row])") ?? 0.0
            if(value2 != 0.0){
                let divideValue = value2/value1
                cell.ratingLabel.text = "\(Int(divideValue.rounded()))"
                cell.ratingView.isHidden = false
            }else{
                cell.ratingLabel.text = "0.0"
                cell.ratingView.isHidden = true
            }
            
            return cell
            
        } else if collectionView == demoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCollectionViewCell", for: indexPath)as! DemoCollectionViewCell
            return cell
        }else if (collectionView == mostViewedCOllectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellcustomUpdated", for: indexPath)as! customUpdatedCell
            cell.lineView.isHidden = true
            cell.heightConstant.constant = 225
            cell.leftConstant.constant = 10
            
            var listTypeString = ""
            if(Utility.shared.isRTLLanguage()) {
                if ((self.mostListingArray[indexPath.row].beds ?? 0) > 1){
                    listTypeString =  "\(self.mostListingArray[indexPath.row].beds ?? 0)" + " beds"
                }else if ((self.mostListingArray[indexPath.row].beds ?? 0) == 1){
                    listTypeString = "\(self.mostListingArray[indexPath.row].beds ?? 0)" + " bed"
                }
                
                listTypeString = listTypeString + " / " + "\(self.mostListingArray[indexPath.row].roomType ?? "")"
            }
            else {
                listTypeString = "\(self.mostListingArray[indexPath.row].roomType ?? "")"
                if ((self.mostListingArray[indexPath.row].beds ?? 0) > 1){
                    listTypeString = listTypeString + " / " + "\(self.mostListingArray[indexPath.row].beds ?? 0)" + " beds"
                }else if ((self.mostListingArray[indexPath.row].beds ?? 0) == 1){
                    listTypeString = listTypeString + " / " + "\(self.mostListingArray[indexPath.row].beds ?? 0)" + " bed"
                }
                
            }
            cell.listTypeLabel.text = listTypeString
            cell.listTypeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
            let listimage = mosthomeImageArray[indexPath.row]
            cell.imageView.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            cell.imageView.contentMode = .scaleAspectFill
            
            cell.listTitleLabel.text = self.mostListingArray[indexPath.row].title ?? ""
            
            cell.lightningImageView.isHidden = self.mostListingArray[indexPath.row].bookingType != "instant"
            
            
            if("\(mostwishlist_Array[indexPath.row])" == "0"){
                cell.heartBtn.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
            }else{
                cell.heartBtn.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            }
            cell.heartBtn.isHidden = false
            cell.heartBtn.tag = indexPath.row
            cell.heartBtn.addTarget(self, action: #selector(most_likeBtnTapped), for: .touchUpInside)
            
            
            if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
            {
                var currencysymbol = "$"
                if let symbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!) {
                    currencysymbol = symbol
                }
                else {
                    currencysymbol = "$"
                }
                let from_currency = self.mostListingArray[indexPath.row].listingData?.currency
                let currency_amount = self.mostListingArray[indexPath.row].listingData?.basePrice != nil ? self.mostListingArray[indexPath.row].listingData?.basePrice : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency:currencyvalue_from_API.base!, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.listPriceLabel.text = "\(currencysymbol)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 22),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                
                
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                if(Utility.shared.isRTLLanguage()) {
                    
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(currencysymbol)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                    
                }
                else {
                    let attributedString = NSMutableAttributedString(string: "\(currencysymbol)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                }
                cell.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            }
            else
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.currencyvalue_from_API.base!)
                
                
                let from_currency = self.mostListingArray[indexPath.row].listingData?.currency
                let currency_amount = self.mostListingArray[indexPath.row].listingData?.basePrice != nil ? self.mostListingArray[indexPath.row].listingData?.basePrice : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency:currencyvalue_from_API.base!, fromCurrency:from_currency!, toCurrency:self.currencyvalue_from_API.base!, CurrencyRate: Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.listPriceLabel.text = "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 22),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                
                
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                if(Utility.shared.isRTLLanguage()) {
                    
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                    
                }
                else {
                    let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "/ \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    cell.listPriceLabel.attributedText = attributedString
                }
                cell.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            }
            
            let value1 = Float("\(mostreviewcount_Array[indexPath.row])") ?? 0.0
            let value2 = Float("\(mostreviewStart_ratingArray[indexPath.row])") ?? 0.0
            if(value2 != 0.0){
                let dividedValue = value2/value1
                cell.ratingLabel.text = "\(Int(dividedValue.rounded()))"
                cell.ratingView.isHidden = false
            }else{
                cell.ratingLabel.text = "0.0"
                cell.ratingView.isHidden = true
            }
            
            return cell
        }else{
            if (collectionView == collectionViewFilterPage && FilterArray.count > indexPath.row) {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellUpdatedSearch", for: indexPath)as! UpdatedSearchCell
                
                var listTypeString = ""
                
                
                if(Utility.shared.isRTLLanguage()) {
                    
                    
                    if ((self.FilterArray[indexPath.row].beds ?? 0) > 1){
                        listTypeString =  "\(self.FilterArray[indexPath.row].beds ?? 0)" + " beds"
                    }else if ((self.FilterArray[indexPath.row].beds ?? 0) == 1){
                        listTypeString = "\(self.FilterArray[indexPath.row].beds ?? 0)" + " bed"
                    }
                    
                    listTypeString = listTypeString + " / " + "\(self.FilterArray[indexPath.row].roomType ?? "")"
                }
                else {
                    listTypeString = "\(self.FilterArray[indexPath.row].roomType ?? "")"
                    if ((self.FilterArray[indexPath.row].beds ?? 0) > 1){
                        listTypeString = listTypeString + " / " + "\(self.FilterArray[indexPath.row].beds ?? 0)" + " beds"
                    }else if ((self.FilterArray[indexPath.row].beds ?? 0) == 1){
                        listTypeString = listTypeString + " / " + "\(self.FilterArray[indexPath.row].beds ?? 0)" + " bed"
                    }
                    
                }
                cell.listTypeLabel.text = listTypeString
                cell.listTypeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
                
                cell.listTitleLabel.text = self.FilterArray[indexPath.row].title ?? ""
                cell.lblAddress.text = "\(self.FilterArray[indexPath.row].city ?? ""), \(self.FilterArray[indexPath.row].state ?? ""), \(self.FilterArray[indexPath.row].country ?? "")"
                cell.lightImg.isHidden = self.FilterArray[indexPath.row].bookingType != "instant"
                
                let array = FilterArray[indexPath.row].listingPhotos
                self.filteredImageArray.removeAllObjects()
                for j in array!
                {
                    self.filteredImageArray.add("\(IMAGE_LISTING_MEDIUM)\(j?.name ?? "0")" as Any)
                }
                cell.imgScrollerView.setupScrollerWithImages(images:self.filteredImageArray as! [String])
                let config = FlexiblePageControl.Config(
                    displayCount: self.filteredImageArray.count,
                    dotSize: 10,
                    dotSpace: 6,
                    smallDotSizeRatio: 0.5,
                    mediumDotSizeRatio: 0.7
                )
                cell.pageControllView.setConfig(config)
                cell.pageControllView.numberOfPages = self.filteredImageArray.count
                cell.pageControllView.tag = indexPath.item
                cell.imgScrollerView.tag = indexPath.row
                
                
                cell.tag = indexPath.row + 2000
                let tap = UITapGestureRecognizer(target: self, action: #selector(imageScrollerTapped))
                tap.numberOfTapsRequired = 1
                tap.view?.tag = indexPath.row
                cell.imgScrollerView.addGestureRecognizer(tap)
                
                cell.listPriceLabel.addTap {
                    if Utility.shared.isUnderline {
                        let priceVc = PriceBrokeDownVc()
                        priceVc.filterData = self.FilterArray[indexPath.row]
                        priceVc.modalPresentationStyle = .overCurrentContext
                        self.present(priceVc, animated: true)
                    }
                }
                
                if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "") {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = self.FilterArray[indexPath.row].listingData?.currency
                    let currency_amount = self.FilterArray[indexPath.row].listingData?.basePrice != nil ? self.FilterArray[indexPath.row].listingData?.basePrice : 0
                    
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 22),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    if(Utility.shared.isRTLLanguage()) {
                        let totPrice = FilterArray[indexPath.row].listingData?.oneTotalPrice
                        let price_value1 = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:(totPrice?.oneTotalPrice!)!)
                        let restricted_price1 =  Double(String(format: "%.2f",price_value1))
                        
                        if Utility.shared.isUnderline && !Utility.shared.selectedstartDate_filter.isEmpty {
                            let attributedString2 = NSMutableAttributedString(string: " \(currencysymbol!)\(restricted_price1!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"tot_before_tax") ?? "total before taxes")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
                            
                            cell.listPriceLabel.attributedText = attributedString
                            
                        } else {
                            let attributedString2 = NSMutableAttributedString(string: "/ \(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                            
                           
                            cell.listPriceLabel.attributedText = attributedString
                        }
                        
                        
                    } else {
                        
                        if Utility.shared.isUnderline && !Utility.shared.selectedstartDate_filter.isEmpty {
                            let totPrice = FilterArray[indexPath.row].listingData?.oneTotalPrice
                            let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:(totPrice?.oneTotalPrice!)!)
                            let restricted_price =  Double(String(format: "%.2f",price_value))
                            
                            let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"tot_before_tax") ?? "total before taxes")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                           
                            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
                            
                            cell.listPriceLabel.attributedText = attributedString
                        } else {
                            
                            let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            let attributedString2 = NSMutableAttributedString(string: "/ \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                           
                            cell.listPriceLabel.attributedText = attributedString
                        }
                    }
                    cell.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                    
                    
                } else {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:Utility.shared.currencyvalue_from_API_base)
                    let from_currency = self.FilterArray[indexPath.row].listingData?.currency
                    let currency_amount = self.FilterArray[indexPath.row].listingData?.basePrice != nil ? self.FilterArray[indexPath.row].listingData?.basePrice! : 0
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency:Utility.shared.currencyvalue_from_API_base, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    
                    
                    
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 22),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    
                    
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    
                    if(Utility.shared.isRTLLanguage()) {
                        
                        if Utility.shared.isUnderline && !Utility.shared.selectedstartDate_filter.isEmpty {
                            let totPrice = FilterArray[indexPath.row].listingData?.oneTotalPrice
                            let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency: Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:(totPrice?.oneTotalPrice!)!)
                            let restricted_price =  Double(String(format: "%.2f",price_value))
                            let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            
                            let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"tot_before_tax") ?? "total before taxes")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
                            
                            cell.listPriceLabel.attributedText = attributedString
                        } else {
                            
                            let attributes2 = [
                                NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                                NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title"),
                            ]
                            let attributedString2 = NSMutableAttributedString(string: "/ \(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                            if Utility.shared.isUnderline {
                                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
                            }
                            cell.listPriceLabel.attributedText = attributedString
                        }
                        
                        
                    }
                    else {
                        if Utility.shared.isUnderline && !Utility.shared.selectedstartDate_filter.isEmpty {
                            let totPrice = FilterArray[indexPath.row].listingData?.oneTotalPrice
                            let price_value = Utility.shared.getCurrencyRate(basecurrency:Utility.shared.currencyvalue_from_API_base, fromCurrency:from_currency!, toCurrency: Utility.shared.currencyvalue_from_API_base, CurrencyRate: Utility.shared.currency_Dict, amount:(totPrice?.oneTotalPrice!)!)
                            let restricted_price =  Double(String(format: "%.2f",price_value))
                            let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            
                            let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey:"tot_before_tax") ?? "total before taxes")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            attributedString.append(attributedString2)
                            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                            cell.listPriceLabel.attributedText = attributedString
                        } else {
                            let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                            let attributes2 = [
                                NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                                NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                            ]
                            
                            let attributedString2 = NSMutableAttributedString(string: "/ \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                            
                            attributedString.append(attributedString2)
                            if self.FilterArray[indexPath.row].bookingType == "instant" {
                                let attributes: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.systemFont(ofSize: 9.0)
                                ]
                                let attributedString3 = NSMutableAttributedString(string: "⚡️" , attributes: attributes)
                                attributedString.append(attributedString3)
                            }
                            if Utility.shared.isUnderline {
                                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
                            }
                            
                            cell.listPriceLabel.attributedText = attributedString
                        }
                    }
                    
                    cell.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                }
              
                let value1 = Float(FilterArray[indexPath.row].reviewsCount ?? 0)
                let value2 = Float(FilterArray[indexPath.row].reviewsStarRating ?? 0)
                if(value2 != 0.0){
                    let dividedValue = value2/value1
                    cell.ratingCount.text = "\(Int(dividedValue.rounded()))"
                    cell.ratingView.isHidden = false
                }else{
                    cell.ratingCount.text = "0.0"
                    cell.ratingView.isHidden = true
                }
                
                
                if(FilterArray[indexPath.row].wishListStatus ?? false){
                    cell.likeBtn.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                }else{
                    cell.likeBtn.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
                }
                cell.likeBtn.isHidden = false
                cell.likeBtn.tag = indexPath.row
                cell.likeBtn.addTarget(self, action: #selector(filter_likeBtnTapped), for: .touchUpInside)
                
                
                
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCollectionFilterCell", for: indexPath)as! ExploreCollectionFilterCell
                
                return cell
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? ExploreCollectioncell {
                cell.transform = .init(scaleX: 0.90, y: 0.90)
               
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? ExploreCollectioncell {
                
                cell.transform = .identity
              
            }
        }
    }
    
    
    @objc func imageScrollerTapped(_ sender: UITapGestureRecognizer) {
        if(FilterArray.count > 0)
        {
            let viewListing = UpdatedViewListing()
//            viewListing.navigationControllerReference = self.navigationController
            Utility.shared.unpublish_preview_check = false
            viewListing.listID = FilterArray[sender.view!.tag].id ?? 0
            viewListing.delegate = self
            if let imageCell = self.collectionViewFilterPage.cellForItem(at: IndexPath(row: sender.view?.tag ?? 0, section: 0)) as? UpdatedSearchCell {
              
                viewListing.cc_setZoomTransition(originalView:imageCell.contentView)
            }
            
            let navigationVC = UINavigationController(rootViewController: viewListing)
            navigationVC.isNavigationBarHidden = true
            navigationVC.modalPresentationStyle = .fullScreen
            
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (collectionView == self.popularCollectionView){
            return CGSize(width: 125, height: 180)
        }else if (collectionView == self.recommendedCollectionView){
            return CGSize(width: 280, height:280)
        }else if (collectionView == self.mostViewedCOllectionView){
            return CGSize(width:FULLWIDTH-30, height: 340)
        } else if collectionView == collectionViewFilterPage {
            return CGSize(width:FULLWIDTH-30, height: 325 + 25)
        } else {
            return CGSize(width:FULLWIDTH-30, height: 340)
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
        
        
        selectedStartDate = startDate
        selectedEndDate = endDate
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        if(startDate != nil && endDate != nil){
            Utility.shared.selectedstartDate_filter = (dateFormatterGet.string(from: startDate!))
            Utility.shared.selectedEndDate_filter = (dateFormatterGet.string(from: endDate!))
        }
        else
        {
            Utility.shared.selectedstartDate_filter = ""
            Utility.shared.selectedEndDate_filter = ""
        }
        
        if selectedStartDate == nil && selectedEndDate == nil {
            dateBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"dates")) ?? "Dates")", for: .normal)
            dateBtn.setTitleColor(Theme.TextDarkColor, for: .normal)
            dateBtn.backgroundColor = UIColor.white
            
            if Utility.shared.isRTLLanguage(){
                guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x-120), y: 10, width:110, height: 33)
                filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x-80), y: 10, width: 70, height: 33)
            }else{
                guestBtn.frame = CGRect(x:(self.dateBtn.frame.origin.x+self.dateBtn.frame.size.width + 10), y: 10, width:110, height: 33)
                filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x+self.guestBtn.frame.size.width + 10), y: 10, width: 70, height: 33)
            }
        } else {
            self.lottieAnimation()
            dateBtn.setTitle("\(dateFormatter.string(from: startDate!)) - \(dateFormatter.string(from: endDate!))", for: .normal)
            dateBtn.frame = CGRect(x:20, y: 10, width: 130, height: 33)
            dateBtn.backgroundColor = Theme.PRIMARY_COLOR
            dateBtn.setTitleColor(UIColor.white, for: .normal)
          
            guestBtn.frame = CGRect(x:(self.dateBtn.frame.origin.x+self.dateBtn.frame.size.width + 10), y: 10, width:110, height: 33)
            filterBtn.isHidden = false
            
            
            if Utility.shared.isRTLLanguage(){
                dateBtn.frame = CGRect(x:FULLWIDTH - (40+115), y: 10, width:135, height: 33)
                guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x-120), y: 10, width:110, height: 33)
                filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x-80), y: 10, width: 70, height: 33)
            }else{
                dateBtn.frame = CGRect(x:20, y: 10, width:130, height: 33)
                guestBtn.frame = CGRect(x: (self.dateBtn.frame.origin.x+self.dateBtn.frame.size.width + 10), y: 10, width:110, height: 33)
                filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x+self.guestBtn.frame.size.width + 10), y: 10, width: 70, height: 33)
            }
            
            self.isFilterEnable = true
            self.PageIndex = 1
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
            })
            self.searchListingAPICall()
            
        }
    }
    @objc func likeBtnTapped(_ sender: UIButton!)
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
                if recommendListingArray.count > 0 {
                    let headerView = WhishlistPageVC()
                    headerView.listID = recommendListingArray[sender.tag].id!
                    headerView.listimage = recommendListingArray[sender.tag].listPhotoName!
                    headerView.senderID = sender.tag
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: false, completion: nil)
                }
            }
        }
        else
        {
            self.exploreTV.isHidden = true
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
    @objc func most_likeBtnTapped(_ sender: UIButton!)
    {
        if Utility().isConnectedToNetwork(){
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
                
            }
            else{
                if(mostListingArray.count > 0) {
                    let headerView = WhishlistPageVC()
                    headerView.listID = mostListingArray[sender.tag].id!
                    headerView.listimage = mostListingArray[sender.tag].listPhotoName!
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: false, completion: nil)
                    
                }
            }
        }
        else{
            self.exploreTV.isHidden = true
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
    @objc func filter_likeBtnTapped(_ sender: UIButton!)
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
                let headerView = WhishlistPageVC()
                if(FilterArray.count > 0)
                {
                    headerView.listID = FilterArray[sender.tag].id!
                    headerView.listimage = FilterArray[sender.tag].listPhotoName!
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: false, completion: nil)
                }
            }
        }
        else
        {
            self.exploreTV.isHidden = true
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
    
 
    @objc func showOccupantFilter() {
        Utility.shared.isfromcheckingPage = false
        let occupantController = AirbnbOccupantFilterController(adultCount: adultCount, childrenCount: childrenCount, infantCount: infantCount, hasPet: hasPet, additionalGuestCount: 0, infantCountt: 0, petCountt: 0, visitorCountt: 0)
        occupantController.delegate = self
        let navigationController = UINavigationController(rootViewController: occupantController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    func occupantFilterController(_ occupantFilterController: AirbnbOccupantFilterController, didSaveAdult adult: Int, children: Int, infant: Int, pet: Bool, guestBase: Int, infantLimit: Int, petLimit: Int, visitorLimit: Int) {
        self.lottieAnimation()
        self.adultCount = adult
        self.childrenCount = children
        self.infantCount = infant
        self.hasPet = pet
        self.guest_filter = adult
        
        let human = adult + children
        Utility.shared.guestCountToBeSend = human
        let infant = "\(infant > 0 ? (infant.description + " infant" + (infant > 1 ? "s" : "")) : "")"
        let pet = "\(pet ? "pets" : "")"
        
        var value = String()
        if(human > 1)
        {
            value = "\(human) \((Utility.shared.getLanguage()?.value(forKey:"guests"))!)"
        }
        else
        {
            value = "\(human) \((Utility.shared.getLanguage()?.value(forKey:"guest"))!)"
        }
        guestBtn.backgroundColor = Theme.PRIMARY_COLOR
        guestBtn.setTitleColor(UIColor.white, for: .normal)
       
        filterBtn.isHidden = false
        if Utility.shared.isRTLLanguage(){
            filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x-80), y: 10, width: 70, height: 33)
        }else{
            filterBtn.frame = CGRect(x:(self.guestBtn.frame.origin.x+self.guestBtn.frame.size.width + 10), y: 10, width: 70, height: 33)
        }
        guestBtn.setTitle(value, for: .normal)
        
        self.isFilterEnable = true
        self.PageIndex = 1
        collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
            self.collectionViewFilterPage?.isSkeletonable = true
            self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
        })
        self.searchListingAPICall()
        
    }
    
 
    
    func popularAPICall() {
        
        if Utility().isConnectedToNetwork(){
            let mostlistingquery = GetPopularLocationsQuery()
          
            apollo_headerClient.fetch(query: mostlistingquery,cachePolicy:.fetchIgnoringCacheData){ [self](result,error) in
                self.popularCollectionView.isSkeletonable = false
                self.popularCollectionView.hideSkeleton()
               
                guard let mostListingValue = result?.data?.getPopularLocations?.results else {
                  
                    self.popularListingTitle.text = ""
                    self.popularListingTitle.isHidden = true
                    self.popularCollectionView.isHidden = true
                    self.popularListTitleTopConstraint.constant = 0
                    self.popularCollectionTopConstraint.constant = 0
                    self.popularCollectionHeightConstraint.constant = 0
                    return
                }
                self.populardestinationArray = (result?.data?.getPopularLocations?.results) as! [GetPopularLocationsQuery.Data.GetPopularLocation.Result]
                
                if self.populardestinationArray.count > 0{
                    self.popularListingTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "populardest") ?? "Popular Locations")"
                    self.popularListingTitle.isHidden = false
                    self.popularCollectionView.isHidden = false
                    self.popularListTitleTopConstraint.constant = 20
                    self.popularCollectionTopConstraint.constant = 15
                    self.popularCollectionHeightConstraint.constant = 200
                }else{
                    self.popularListingTitle.text = ""
                    self.popularListingTitle.isHidden = true
                    self.popularCollectionView.isHidden = true
                    self.popularListTitleTopConstraint.constant = 0
                    self.popularCollectionTopConstraint.constant = 0
                    self.popularCollectionHeightConstraint.constant = 0
                }
                
                self.popularCollectionView.reloadData()
                self.popularCollectionView.isSkeletonable = false
                self.popularCollectionView.hideSkeleton()
              
                self.popularCollectionView.performBatchUpdates(nil, completion: {
                    (result) in
                    if(Utility.shared.isRTLLanguage()){
                        if (self.populardestinationArray.count > 0){
                            self.popularCollectionView.scrollToItem(at:IndexPath(item:0, section: 0), at: .right, animated: true)
                        }
                        
                        
                    }
                    
                    
                })
                
                
            }
        }
        else {
            popularCollectionView?.prepareSkeleton(completion: { [self] done in
                self.popularCollectionView?.isSkeletonable = true
                self.popularCollectionView.showSkeleton()
            })
            
        }
    }
    
    
    func MostViewedListingAPICall() {
        self.collectionViewFilterPage.isHidden = true
        self.collectionViewFilterPage?.isSkeletonable = false
        self.collectionViewFilterPage?.hideSkeleton()
        self.searchViewTopConstraint.constant = 20
        if Utility().isConnectedToNetwork(){
            self.exploreTV.isHidden = true
            self.offlineView.isHidden = true
            self.getImageBannerFromAdmin()
          
            Utility.shared.selectedstartDate = ""
            Utility.shared.selectedEndDate = ""
            
            let mostlistingquery = GetDefaultSettingQuery()
            apollo_headerClient.fetch(query: mostlistingquery,cachePolicy:.fetchIgnoringCacheData){ [self](result,error) in
               
                self.scrollView.isHidden = false
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                self.exploreTitleLabel.isHidden = false
                self.exploreTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Explore_Title") ?? "Explore the world! By Travelling")"
                self.headerView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
                self.PageIndex = 0
                self.shadowHgt.constant = 0
                self.topHeight.constant = 0
                self.shadowVw.addBottomShadow(withIsClear: false)
                guard let recommendeListingValue = result?.data?.getRecommend?.results else{
                   
                    if result?.data?.getRecommend?.status == 500{
                        let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message:result?.data?.getMostViewedListing?.errorMessage, preferredStyle: .alert)
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
                    
                    return
                }
                self.searchBackBtn.backgroundColor =  UIColor(named: "viewBG")
                self.searchBackBtn.setImage(#imageLiteral(resourceName: "Magnyfy_glass"), for: .normal)
                self.locationLabel.textColor =  UIColor(named: "Title_Header")
                self.newFilterBtn.layer.shadowOpacity = 0.3
                self.searchView.layer.shadowOpacity = 0.2
                
                self.isAnimationCompleted = true
                self.popularCollectionView.isSkeletonable = false
                self.recommendedCollectionView.isSkeletonable = false
                self.mostViewedCOllectionView.isSkeletonable = false
                self.popularCollectionView.hideSkeleton()
                self.recommendedCollectionView.hideSkeleton()
                self.mostViewedCOllectionView.hideSkeleton()
                self.homeTitleArray.removeAllObjects()
                self.homePriceArray.removeAllObjects()
                self.homeImageArray.removeAllObjects()
                self.bookingTypeArray.removeAllObjects()
                self.reviewcount_Array.removeAllObjects()
                self.reviewStart_ratingArray.removeAllObjects()
                self.entirehomeArray.removeAllObjects()
                self.wishlistArray.removeAllObjects()
                self.recommendListingArray = ((result?.data?.getRecommend?.results)!) as! [GetDefaultSettingQuery.Data.GetRecommend.Result]
                if self.recommendListingArray.count > 0{
                    self.recommendedTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "recommended") ?? "Recommended")"
                    self.recommendedTitle.isHidden = false
                    self.recommendedCollectionView.isHidden = false
                    self.recommendedCollectionHeightConstraint.constant = 300
                    
                    self.recommendedTotalPage  = (self.recommendListingArray.count - 1)
                    recommendedPageControl.pageIndicatorTintColor = UIColor(named: "Review_Page_Line_Color")!
                    recommendedPageControl.currentPageIndicatorTintColor = Theme.Button_BG
                    recommendedPageControl.numberOfPages = self.recommendedTotalPage
                    recommendedPageControl.setCurrentPage(at: 0)
                    let config = FlexiblePageControl.Config(
                        displayCount: self.recommendedTotalPage,
                        dotSize: 8,
                        dotSpace: 4,
                        smallDotSizeRatio: 0.5,
                        mediumDotSizeRatio: 0.7
                    )
                    
                    recommendedPageControl.setConfig(config)
                    self.recommendedCollectionView.reloadData()
                }else{
                    self.recommendedTitle.text = ""
                    self.recommendedTitle.isHidden = true
                    self.recommendedCollectionView.isHidden = true
                    self.recommendedCollectionHeightConstraint.constant = 0
                }
                for i in recommendeListingValue {
                    self.homeTitleArray.add(i?.title as Any)
                    self.homeImageArray.add(i?.listPhotoName as Any)
                    self.homePriceArray.add(i?.listingData?.basePrice as Any)
                    self.reviewcount_Array.add(i?.reviewsCount as Any)
                    self.reviewStart_ratingArray.add(i?.reviewsStarRating as Any)
                    self.entirehomeArray.add(i?.roomType as Any)
                    self.wishlistArray.add(i?.wishListStatus as Any)
                    self.bookingTypeArray.add(i?.bookingType as Any)
                    
                }
                
                
          
                guard (result?.data?.currency?.result) != nil else {
                   
                    return
                }
                self.currencyvalue_from_API = (result?.data?.currency?.result)!
                Utility.shared.currencyvalue_from_API_base = (result?.data?.currency?.result?.base)!
                let currency_value = result?.data?.currency?.result?.rates
                self.currency_Dict = self.convertToDictionary(text: currency_value!)! as NSDictionary
                Utility.shared.currency_Dict = self.convertToDictionary(text: currency_value!)! as NSDictionary
                
             
                guard let mostListingValue = result?.data?.getMostViewedListing?.results else {
                   
                    return
                }
                self.mosthomeImageArray.removeAllObjects()
                self.mosthomeTitleArray.removeAllObjects()
                self.mosthomePriceArray.removeAllObjects()
                self.mostreviewcount_Array.removeAllObjects()
                self.mostreviewStart_ratingArray.removeAllObjects()
                self.most_entirehomeArray.removeAllObjects()
                self.mostwishlist_Array.removeAllObjects()
                self.mostbookingTypeArray.removeAllObjects()
                
                self.mostListingArray = ((result?.data?.getMostViewedListing?.results)!) as! [GetDefaultSettingQuery.Data.GetMostViewedListing.Result]
                
                
                
                for i in mostListingValue {
                    self.mosthomeTitleArray.add(i?.title as Any)
                    self.mosthomePriceArray.add(i?.listingData?.basePrice as Any)
                    self.mosthomeImageArray.add(i?.listPhotoName as Any)
                    self.mostreviewcount_Array.add(i?.reviewsCount as Any)
                    self.mostreviewStart_ratingArray.add(i?.reviewsStarRating as Any)
                    self.most_entirehomeArray.add(i?.roomType as Any)
                    self.mostwishlist_Array.add(i?.wishListStatus as Any)
                    self.mostbookingTypeArray.add(i?.bookingType as Any)
                    
                }
                
                
                if self.mostListingArray.count > 0{
                    self.mostViewedTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "mostviewed") ?? "Most viewed")"
                    self.mostViewedTitle.isHidden = false
                    self.mostViewedCOllectionView.isHidden = false
                    self.mostViewedCOllectionHeightConstraint.constant = 200
                    self.mostViewedTitleTopConstraint.constant = 30
                    self.mostViewedCollectionTopConstraint.constant = 20
                    
                    
                    self.mostViewedTotalPage  = self.mostListingArray.count
                    mostViewedPageControl.inactiveTintColor = UIColor(named: "Review_Page_Line_Color")!
                    mostViewedPageControl.currentPageTintColor = Theme.Button_BG
                    self.mostViewedPageControl.radius = 4
                    self.mostViewedPageControl.padding = 6
                    mostViewedPageControl.numberOfPages = 0
                    
                    
                    mostViewedPageControl.currentPage = 0
                    self.mostViewedCOllectionView.reloadData()
                    let height = self.mostViewedCOllectionView.collectionViewLayout.collectionViewContentSize.height
                    self.mostViewedCOllectionHeightConstraint.constant = height
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                    
                }else{
                    self.mostViewedTitle.text = ""
                    self.mostViewedTitle.isHidden = true
                    self.mostViewedCOllectionView.isHidden = true
                    self.mostViewedTitleTopConstraint.constant = 0
                    self.mostViewedCollectionTopConstraint.constant = 0
                    self.mostViewedCOllectionHeightConstraint.constant = 0
                }
                
                guard (result?.data?.getListingSettingsCommon?.results) != nil else{
                    return
                }
                self.RoomsFilterArray = ((result?.data?.getListingSettingsCommon?.results)!) as! [GetDefaultSettingQuery.Data.GetListingSettingsCommon.Result]
                if let endval = (self.RoomsFilterArray[1].listSettings?[0]?.endValue) {
                    Utility.shared.maximum_guest_count = endval
                }
                if let startVal = (self.RoomsFilterArray[1].listSettings?[0]?.startValue) {
                    Utility.shared.min_filter_guest_count = startVal
                    Utility.shared.showbedRoomCount = false
                }
                
                if let startVal = (self.RoomsFilterArray[4].listSettings?[0]?.startValue) {
                    Utility.shared.min_filter_bedroom_count = 0
                    
                    
                    Utility.shared.showbedRoomCount = false
                }
                if let startVal = (self.RoomsFilterArray[5].listSettings?[0]?.startValue) {
                    Utility.shared.min_filter_bed_count = 0
                    
                    
                    Utility.shared.showbedCount = false
                }
                if let startVal = (self.RoomsFilterArray[7].listSettings?[0]?.startValue) {
                    Utility.shared.min_filter_bath_count = 0
                    
                    
                    Utility.shared.showbathCount = false
                }
                
                self.getsearchPriceArray = ((result?.data?.getSearchSettings?.results)!)
                self.isAnimationCompleted = true
                self.popularCollectionView.hideSkeleton()
                self.popularCollectionView.isSkeletonable = false
                if((result?.data?.getRecommend?.results?.count == 0) && (result?.data?.getMostViewedListing?.results?.count == 0)) {
                    self.exploreTV.isHidden = true
                    self.NoresultView.isHidden = false
                    self.lottieAnimationView()
                    self.scrollView.isHidden = true
                    
                    self.NoViewNoresult.isHidden = true
                    self.noViewFirstText.isHidden = true
                    self.noViewSecondText.isHidden = true
                    self.NoViewthirdText.isHidden = true
                    self.NoListingFoundImage.isHidden = false
                    self.NoListingFoundTitle.isHidden = false
                    self.floatingMapView.isHidden = true
                    self.NoresultView.frame = CGRect(x: 0, y: self.headerView.frame.size.height+self.headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-110)
                }
                else
                {
                    self.exploreTV.isHidden = true
                    self.NoresultView.isHidden = true
                    self.scrollView.isHidden = false
                }
                self.floatingMapView.isHidden = true
            }
        }
        
        else{
            self.exploreTV.isHidden = true
            self.popularCollectionView.showAnimatedSkeleton()
            self.recommendedCollectionView.showAnimatedSkeleton()
            self.mostViewedCOllectionView.showAnimatedSkeleton()
            
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showSkeleton()
            })
            
            self.offlineView.isHidden = false
            self.scrollView.isHidden = false
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
            } else {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-110, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    func getImageBannerFromAdmin(){
        let getImageBanner = GetImageBannerQuery()
        apollo_headerClient.fetch(query: getImageBanner,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            if let response = result{
                self.becomeAHostView.isHidden = false
                self.becomeAHostTopConstraint.constant = 20
                self.becomeAHostHeightConstraint.constant = 285
                self.becomeAHostView.isSkeletonable = false
                self.becomeAHostView.hideSkeleton()
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 24.0),
                    NSAttributedString.Key.foregroundColor: Theme.Button_BG
                ]
                let attributedString = NSMutableAttributedString(string: "\(response.data?.getImageBanner?.result?.title ?? "") "  , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 24.0),
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ]
                let attributedString2 = NSMutableAttributedString(string: "\(response.data?.getImageBanner?.result?.description ?? "")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                attributedString.append(attributedString2)
                
                self.hostTitleLabel.attributedText = attributedString
                
                
                self.hostBtn.setTitle(response.data?.getImageBanner?.result?.buttonLabel ?? "Host", for: .normal)
                if let imageBanner = response.data?.getImageBanner?.result?.image{
                    self.hostSamepleImageView.sd_setImage(with: URL(string: "\(Banner_URL)\(imageBanner)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                }
                if Utility.shared.isRTLLanguage(){
                    self.hostTransparentImageView.performRTLTransform()
                }
            }else{
                self.becomeAHostView.isHidden = true
                self.becomeAHostTopConstraint.constant = 0
                self.becomeAHostHeightConstraint.constant = 0
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
    
    func searchListingAPICall(){
        
        if Utility().isConnectedToNetwork(){
            
            if isAnimation {
                if FilterArray.isEmpty {
                    self.skeltonView.isHidden = false
                    demoCollectionView?.prepareSkeleton(completion: { [self] done in
                        self.demoCollectionView?.isSkeletonable = true
                        self.demoCollectionView?.showAnimatedSkeleton()
                    })
                } else {
                    self.demoCollectionView?.isSkeletonable = false
                    self.demoCollectionView?.hideSkeleton()
                    self.collectionViewFilterPage.isHidden =  false
                }
                
                
            } else {
                self.skeltonView.isHidden = false
                demoCollectionView?.prepareSkeleton(completion: { [self] done in
                    self.demoCollectionView?.isSkeletonable = true
                    self.demoCollectionView?.showAnimatedSkeleton()
                })
            }
           
            self.exploreTV.isHidden = true
            self.lottieView.isHidden = true
            self.lottieWholeView.isHidden = true
            self.offlineView.isHidden = true
            self.NoresultView.isHidden = true
           
          
            self.headerView.backgroundColor = UIColor(named: "cell_bg")
            self.searchView.layer.borderWidth = 1
            self.searchView.layer.borderColor = Theme.past_bg.cgColor
            self.newFilterBtn.layer.borderWidth = 1
            self.newFilterBtn.layer.borderColor = Theme.past_bg.cgColor
            self.exploreTitleLabel.text = ""
            self.exploreTitleLabel.isHidden = true
            self.shadowVw.addBottomShadow(withIsClear: true)
            self.topHeight.constant = 85
            self.shadowHgt.constant = 2
            var searchListingquery = SearchListingQueryy()
            
            var lat = Double()
            var lon = Double()
            var bookingtype = String()
            
            
            if((Utility.shared.searchLocationDict.value(forKey: "lat") != nil) && (Utility.shared.searchLocationDict.value(forKey: "lon") != nil))
            {
                lat  = Utility.shared.searchLocationDict.value(forKey: "lat") as! Double
                lon  = Utility.shared.searchLocationDict.value(forKey: "lon") as! Double
            }
            else{
                lat = 0.0
                lon = 0.0
            }
            Utility.shared.houseRulesArray = self.houserulesArray
            
            if(Utility.shared.filterCount != 0)
            {
                guest_filter = Utility.shared.filterCount
            }
            
            if(Utility.shared.amenitiesArray.count == 0)
            {
                Utility.shared.amenitiesArray = []
            }
            if(Utility.shared.roomtypeArray.count == 0)
            {
                Utility.shared.roomtypeArray = []
            }
            if(Utility.shared.facilitiesArray.count == 0)
            {
                Utility.shared.facilitiesArray = []
            }
            if(Utility.shared.houseRulesArray.count == 0)
            {
                Utility.shared.houseRulesArray = []
            }
            if(self.priceRangeArray.count == 0)
            {
                self.priceRangeArray = []
            }
            if(Utility.shared.locationfromSearch == nil)
            {
                Utility.shared.locationfromSearch = ""
            }
            if(Utility.shared.isSwitchEnable)
            {
                bookingtype = "instant"
            }
            var currency = String()
            if(Utility.shared.getPreferredCurrency() == nil)
            {
                currency = Utility.shared.currencyvalue_from_API_base
            }
            else{
                currency = Utility.shared.getPreferredCurrency()!
            }
            self.searchViewTopConstraint.constant = 0
            if (Utility.shared.searchLocationDict.value(forKey: "lat") as? Double) == nil {
                searchListingquery = SearchListingQueryy(personCapacity: guest_filter, currentPage: PageIndex, dates: "'\( Utility.shared.selectedstartDate_filter)' AND '\(Utility.shared.selectedEndDate_filter)'"
                                                         , amenities: Utility.shared.amenitiesArray as? [Int]
                                                         , beds: Utility.shared.beds_count as Int
                                                         , bedrooms: Utility.shared.bedrooms_count as Int
                                                         , bathrooms:Utility.shared.bathroom_count as Int
                                                         , roomType: Utility.shared.roomtypeArray as? [Int]
                                                         , spaces:(Utility.shared.facilitiesArray as! [Int])
                                                         , houseRules:(Utility.shared.houseRulesArray as! [Int])
                                                         , priceRange:self.priceRangeArray as! [Int]
                                                         ,bookingType: bookingtype
                                                         , address:Utility.shared.locationfromSearch!,currency:currency
                                                         , isOneTotal: Utility.shared.isOneTotal)
            } else {
                searchListingquery = SearchListingQueryy(personCapacity: guest_filter, currentPage: PageIndex, dates: "'\( Utility.shared.selectedstartDate_filter)' AND '\(Utility.shared.selectedEndDate_filter)'", lat: Double(Utility.shared.searchLocationDict.value(forKey: "lat") as! Double)
                                                        , lng: Double(Utility.shared.searchLocationDict.value(forKey: "lon") as! Double)
                                                         , amenities: Utility.shared.amenitiesArray as? [Int]
                                                         , beds: Utility.shared.beds_count as Int
                                                         , bedrooms: Utility.shared.bedrooms_count as Int
                                                         , bathrooms:Utility.shared.bathroom_count as Int
                                                         , roomType: Utility.shared.roomtypeArray as? [Int]
                                                         , spaces:(Utility.shared.facilitiesArray as! [Int])
                                                         , houseRules:(Utility.shared.houseRulesArray as! [Int])
                                                         , priceRange:self.priceRangeArray as! [Int]
                                                         ,bookingType: bookingtype
                                                         , address:Utility.shared.locationfromSearch!,currency:currency
                                                         , isOneTotal: Utility.shared.isOneTotal)
            }
            
//            print((personCapacity: guest_filter, currentPage: PageIndex, dates: "'\( Utility.shared.selectedstartDate_filter)' AND '\(Utility.shared.selectedEndDate_filter)'", lat: Double(Utility.shared.searchLocationDict.value(forKey: "lat") as! Double)
//                                      , lng: Double(Utility.shared.searchLocationDict.value(forKey: "lon") as! Double),
//                                      amenities: Utility.shared.amenitiesArray as? [Int], beds: Utility.shared.beds_count as Int, bedrooms: Utility.shared.bedrooms_count as Int, bathrooms:Utility.shared.bathroom_count as Int, roomType: Utility.shared.roomtypeArray as? [Int], spaces:(Utility.shared.facilitiesArray as! [Int]), houseRules:(Utility.shared.houseRulesArray as! [Int]), priceRange:self.priceRangeArray as! [Int],bookingType: bookingtype, address:Utility.shared.locationfromSearch!,currency:currency, isOneTotal: Utility.shared.isOneTotal))
            self.scrollView.isHidden = true
            apollo_headerClient.fetch(query: searchListingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                
                self.scrollView.isHidden = false
               
                self.exploreTitleLabel.text = ""
                self.exploreTitleLabel.isHidden = true
                self.skeltonView.isHidden = true
                
                if Utility.shared.isRTLLanguage() {
                    self.searchBackBtn.rotateImageViewofBtn()
                }
                
                guard let searchListingValues = result?.data?.searchListing?.results else {
                  
                    self.NoresultView.isHidden = false
                    self.collectionViewFilterPage.hideSkeleton()
                    self.collectionViewFilterPage?.isSkeletonable = false
                    self.isFilterEnable = true
                    self.searchBackBtn.backgroundColor =  UIColor(named: "viewBG")
                    self.searchBackBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                    
                    self.locationLabel.textColor = UIColor(named: "Title_Header")
                    self.headerView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
                    self.exploreTV.isHidden = true
                    self.collectionViewFilterPage.isHidden = true
                    
                    self.scrollView.isHidden = true
                    
                    self.NoViewNoresult.isHidden = false
                    self.noViewFirstText.isHidden = false
                    self.noViewSecondText.isHidden = false
                    self.NoViewthirdText.isHidden = false
                    self.NoListingFoundImage.image = #imageLiteral(resourceName: "NoSearchImg")
                    self.NoListingFoundTitle.isHidden = true
                    self.floatingMapView.isHidden = true
                    self.NoresultView.frame = CGRect(x: 0, y: self.headerView.frame.size.height+self.headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-110)
                    return
                }
                
                if((result?.data?.searchListing?.count)!>0) {
                    self.lottieView.isHidden = true
                    self.lottieView.isHidden = true
                    self.lottieView.isHidden = true
                    self.lottieWholeView.isHidden = true
                    self.NoresultView.isHidden = true
                    self.scrollView.isHidden = false
                    self.exploreTV.isHidden = true
                    self.collectionViewFilterPage.isSkeletonable = false
                    self.collectionViewFilterPage.hideSkeleton()
                    self.headerView.backgroundColor = UIColor(named: "cell_bg")
                    self.topCollectionCvc.backgroundColor = UIColor(named: "cell_bg")
                    self.bottomView.backgroundColor = UIColor(named: "cell_bg")
                    self.floatingMapView.isHidden = false
                    self.isFilterEnable = true
                    self.newFilterBtn.layer.shadowOpacity = 0.0
                    self.searchView.layer.shadowOpacity = 0.0
                    self.searchBackBtn.backgroundColor =  UIColor(named: "viewBG")
                    self.locationLabel.textColor =  UIColor(named: "Title_Header")
                    if(Utility.shared.isRTLLanguage()){
                        self.searchBackBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                        self.searchBackBtn.rotateImageViewofBtn()
                    }else{
                        self.searchBackBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                    }
                    
                    if(result?.data?.searchListing?.currentPage == 1){
                        self.FilterArray.removeAll()
                    }
                   
                    self.FilterArray.append(contentsOf: ((result?.data?.searchListing?.results)!) as! [SearchListingQueryy.Data.SearchListing.Result])
                   
                    self.collectionViewFilterPage.isHidden = false
                    self.totalListcount = (result?.data?.searchListing?.count)!
                    

                    self.exploreTV?.reloadData()
                    self.collectionViewFilterPage.reloadData()
                    
                    if self.FilterArray.count != 0 {
                        self.isHeight = false
                        self.viewDidLayoutSubviews()
                    }
                }
                else {
                    self.collectionViewFilterPage?.isSkeletonable = false
                    self.collectionViewFilterPage.hideSkeleton()
                    self.isFilterEnable = true
                    self.searchBackBtn.backgroundColor =  UIColor(named: "viewBG")
                    self.searchBackBtn.setImage(#imageLiteral(resourceName: "back_black"), for: .normal)
                    self.exploreTitleLabel.text = ""
                    self.locationLabel.textColor =  UIColor(named: "Title_Header")
                    self.headerView.backgroundColor = UIColor(named: "cell_bg")
                    self.exploreTV.isHidden = true
                    self.collectionViewFilterPage.isHidden = true
                    self.lottieView.isHidden = false
                    self.lottieWholeView.isHidden = false
                    self.NoresultView.isHidden = false
                    self.scrollView.isHidden = true
                    self.NoViewNoresult.isHidden = false
                    self.noViewFirstText.isHidden = false
                    self.noViewSecondText.isHidden = false
                    self.NoViewthirdText.isHidden = false
                    self.NoListingFoundImage.image = #imageLiteral(resourceName: "NoSearchImg")
                    self.NoListingFoundTitle.isHidden = true
                    self.floatingMapView.isHidden = true
                    self.NoresultView.frame = CGRect(x: 0, y: self.headerView.frame.size.height+self.headerView.frame.origin.y+25, width: FULLWIDTH, height:FULLHEIGHT-110)
                }
            }
        } else{
            self.exploreTV.isHidden = true
            self.offlineView.isHidden = false
            
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
            })
            self.collectionViewFilterPage.isHidden = true
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
 
    @objc func pageChanged(_ sender: UISwipeGestureRecognizer) {
        Pagecontrol.currentPage = sender.view!.tag
        Pagecontrol.inactiveTintColor = UIColor(named: "Review_Page_Line_Color")!
    }
   
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == self.FilterArray.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
        var totalPages = Int()
       
        let last_element = FilterArray.count - 1
        if(indexPath.item == last_element && isFilterEnable) {
            if(self.totalListcount % 10 == 0)
            {
                totalPages = (self.totalListcount/10)
            }
            else{
                totalPages = (self.totalListcount/10) + 1
            }
            if(totalPages >= PageIndex && PageIndex >= 1){
                self.PageIndex = self.PageIndex + 1
                self.searchListingAPICall()
            }
        }
    }
}


extension ExplorePageVC: searchPageProtocol{
    func callSearchAPI() {
        
        if Utility.shared.currentIndex == 0 {
            let index = IndexPath(row: 0, section: 0)
            topCollectionCvc.myCollectionView.scrollToItem(at: index, at: .left, animated: false)
        }
      
        if Utility.shared.locationfromSearch == "empty" || Utility.shared.locationfromSearch == "" {
            Utility.shared.locationfromSearch = ""
            self.locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            self.locationLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"losangeles") ?? "Where do you go?")"
            locationLabel.textColor =  UIColor(named: "Title_Header")
            self.PageIndex = 1
            self.FilterArray.removeAll()
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
            })
            isHeight = false
            self.collectionViewFilterPage.reloadData()
            self.searchListingAPICall()
           
        } else if Utility.shared.locationfromSearch != nil && Utility.shared.locationfromSearch != ""{
            self.locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            self.locationLabel.text = Utility.shared.locationfromSearch
            locationLabel.textColor =  UIColor(named: "Title_Header")
            self.PageIndex = 1
            self.FilterArray.removeAll()
            collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                self.collectionViewFilterPage?.isSkeletonable = true
                self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
            })
            self.collectionViewFilterPage.reloadData()
            self.searchListingAPICall()
            isHeight = false
            if (Utility.shared.TotalFilterCount == 0){
                self.newFilterBtn.backgroundColor =  UIColor(named: "colorController")
                newFilterBtn.setImage(#imageLiteral(resourceName: "explore_filter"), for: .normal)
            }
            else {
                self.newFilterBtn.backgroundColor = Theme.PRIMARY_COLOR
                newFilterBtn.setImage(#imageLiteral(resourceName: "filterblue"), for: .normal)
            }
        } else {
          
            self.locationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            self.locationLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"losangeles") ?? "Where do you go?")"
            
            if (Utility.shared.TotalFilterCount == 0) && Utility.shared.roomtypeArray.count == 0 {
                topCollectionCvc.currentIndex = -1
                self.popularAPICall()
                self.newFilterBtn.backgroundColor = UIColor(named: "colorController")
                newFilterBtn.setImage(#imageLiteral(resourceName: "explore_filter"), for: .normal)
                self.MostViewedListingAPICall()
                self.topHeight.constant = 0
                self.shadowHgt.constant = 0
                isHeight = true
            } else {
                self.PageIndex = 1
                self.newFilterBtn.backgroundColor = Theme.PRIMARY_COLOR
                newFilterBtn.setImage(#imageLiteral(resourceName: "filterblue"), for: .normal)
                self.FilterArray.removeAll()
                collectionViewFilterPage?.prepareSkeleton(completion: { [self] done in
                    self.collectionViewFilterPage?.isSkeletonable = true
                    self.collectionViewFilterPage?.showAnimatedGradientSkeleton()
                })
                self.collectionViewFilterPage.reloadData()
                self.searchListingAPICall()
                isHeight = false
            }
        }
    }
}

extension ExplorePageVC{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == recommendedCollectionView{
            
            
            let visibleRect = CGRect(origin: recommendedCollectionView.contentOffset, size: recommendedCollectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.origin.x + 50, y: visibleRect.midY)
            guard let visibleIndexpath = recommendedCollectionView.indexPathForItem(at: visiblePoint) else{
                return
            }
            
            recommendedPageControl.setCurrentPage(at: visibleIndexpath.row)
            
        }
        
        if scrollView == mostViewedCOllectionView{
            
            
            let visibleRect = CGRect(origin: mostViewedCOllectionView.contentOffset, size: mostViewedCOllectionView.bounds.size)
            
            let visiblePoint = CGPoint(x: visibleRect.origin.x + 50, y: visibleRect.midY)
            guard let visibleIndexpath = mostViewedCOllectionView.indexPathForItem(at: visiblePoint) else{
                return
            }
            
          
            mostViewedPageControl.currentPage = visibleIndexpath.row
            
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mostViewedCOllectionView{
            for cell in mostViewedCOllectionView.visibleCells {
                let indexPath = mostViewedCOllectionView.indexPath(for: cell)
                
            }
        }
    }
    
}


class CustomUITextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return true
        }
        return false
    }
}

class CustomDiscountTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return false
    }
}


extension ExplorePageVC {
    func getFilterFunc() {
        if(Utility.shared.getCurrentUserToken() != nil) {
            apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                let url = URL(string:graphQLEndpoint)!
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
        }
        let profileQuery = GetRoomTypeSettingsQuery()
        apollo_headerClient.fetch(query: profileQuery) { [self] (result,error) in
            guard let roomtype = result?.data?.getRoomTypeSettings?.results else { return }
           
            getRoomTypeArray = roomtype
            Utility.shared.getRoomTypeArray = roomtype
        }
    }
}

extension ExplorePageVC {
    
    func lottieAnimationView(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-150, width:100, height:100)
        self.lottieWholeView.frame = CGRect(x:0, y:0, width: collectionViewFilterPage.frame.width, height:collectionViewFilterPage.frame.height)
        lottieWholeView.backgroundColor =  UIColor(named: "colorController")
        self.collectionViewFilterPage.addSubview(self.lottieWholeView)
        lottieWholeView.addSubview(lottieView)
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
}


public final class SearchListingQueryy: GraphQLQuery {
  public let operationDefinition =
    "query SearchListing($personCapacity: Int, $currentPage: Int, $dates: String, $lat: Float, $lng: Float, $amenities: [Int], $safetyAmenities: [Int], $beds: Int, $bedrooms: Int, $bathrooms: Int, $roomType: [Int], $spaces: [Int], $houseRules: [Int], $priceRange: [Int], $geoType: String, $geography: String, $bookingType: String, $address: String, $currency: String, $isOneTotal: Boolean) {\n  SearchListing(personCapacity: $personCapacity, currentPage: $currentPage, dates: $dates, lat: $lat, lng: $lng, amenities: $amenities, safetyAmenities: $safetyAmenities, beds: $beds, bedrooms: $bedrooms, bathrooms: $bathrooms, roomType: $roomType, spaces: $spaces, houseRules: $houseRules, priceRange: $priceRange, geoType: $geoType, geography: $geography, bookingType: $bookingType, address: $address, currency: $currency, isOneTotal: $isOneTotal) {\n    __typename\n    currentPage\n    count\n    results {\n      __typename\n      id\n      title\n      personCapacity\n      lat\n      lng\n      beds\n      bookingType\n      coverPhoto\n      roomType\n      reviewsCount\n      reviewsStarRating\n      city\n      state\n      country\n      listPhotoName\n      listPhotos {\n        __typename\n        id\n        name\n        type\n        status\n      }\n      listingPhotos {\n        __typename\n        id\n        name\n        type\n        status\n      }\n      listingData {\n        __typename\n        basePrice\n        currency\n        dates\n        oneTotalPrice {\n          __typename\n          oneTotalPrice\n          isAverage\n          isDayTotal\n          discount\n          dayDifference\n          cleaningPrice\n          serviceFee\n        }\n      }\n      settingsData {\n        __typename\n        listsettings {\n          __typename\n          id\n          itemName\n        }\n      }\n      wishListStatus\n      isListOwner\n    }\n    status\n    errorMessage\n  }\n}"

  public var personCapacity: Int?
  public var currentPage: Int?
  public var dates: String?
  public var lat: Double?
  public var lng: Double?
  public var amenities: [Int?]?
  public var safetyAmenities: [Int?]?
  public var beds: Int?
  public var bedrooms: Int?
  public var bathrooms: Int?
  public var roomType: [Int?]?
  public var spaces: [Int?]?
  public var houseRules: [Int?]?
  public var priceRange: [Int?]?
  public var geoType: String?
  public var geography: String?
  public var bookingType: String?
  public var address: String?
  public var currency: String?
  public var isOneTotal: Bool?

  public init(personCapacity: Int? = nil, currentPage: Int? = nil, dates: String? = nil, lat: Double? = nil, lng: Double? = nil, amenities: [Int?]? = nil, safetyAmenities: [Int?]? = nil, beds: Int? = nil, bedrooms: Int? = nil, bathrooms: Int? = nil, roomType: [Int?]? = nil, spaces: [Int?]? = nil, houseRules: [Int?]? = nil, priceRange: [Int?]? = nil, geoType: String? = nil, geography: String? = nil, bookingType: String? = nil, address: String? = nil, currency: String? = nil, isOneTotal: Bool? = nil) {
    self.personCapacity = personCapacity
    self.currentPage = currentPage
    self.dates = dates
    self.lat = lat
    self.lng = lng
    self.amenities = amenities
    self.safetyAmenities = safetyAmenities
    self.beds = beds
    self.bedrooms = bedrooms
    self.bathrooms = bathrooms
    self.roomType = roomType
    self.spaces = spaces
    self.houseRules = houseRules
    self.priceRange = priceRange
    self.geoType = geoType
    self.geography = geography
    self.bookingType = bookingType
    self.address = address
    self.currency = currency
    self.isOneTotal = isOneTotal
  }

  public var variables: GraphQLMap? {
    return ["personCapacity": personCapacity, "currentPage": currentPage, "dates": dates, "lat": lat, "lng": lng, "amenities": amenities, "safetyAmenities": safetyAmenities, "beds": beds, "bedrooms": bedrooms, "bathrooms": bathrooms, "roomType": roomType, "spaces": spaces, "houseRules": houseRules, "priceRange": priceRange, "geoType": geoType, "geography": geography, "bookingType": bookingType, "address": address, "currency": currency, "isOneTotal": isOneTotal]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("SearchListing", arguments: ["personCapacity": GraphQLVariable("personCapacity"), "currentPage": GraphQLVariable("currentPage"), "dates": GraphQLVariable("dates"), "lat": GraphQLVariable("lat"), "lng": GraphQLVariable("lng"), "amenities": GraphQLVariable("amenities"), "safetyAmenities": GraphQLVariable("safetyAmenities"), "beds": GraphQLVariable("beds"), "bedrooms": GraphQLVariable("bedrooms"), "bathrooms": GraphQLVariable("bathrooms"), "roomType": GraphQLVariable("roomType"), "spaces": GraphQLVariable("spaces"), "houseRules": GraphQLVariable("houseRules"), "priceRange": GraphQLVariable("priceRange"), "geoType": GraphQLVariable("geoType"), "geography": GraphQLVariable("geography"), "bookingType": GraphQLVariable("bookingType"), "address": GraphQLVariable("address"), "currency": GraphQLVariable("currency"), "isOneTotal": GraphQLVariable("isOneTotal")], type: .object(SearchListing.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(searchListing: SearchListing? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "SearchListing": searchListing.flatMap { (value: SearchListing) -> ResultMap in value.resultMap }])
    }

    public var searchListing: SearchListing? {
      get {
        return (resultMap["SearchListing"] as? ResultMap).flatMap { SearchListing(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "SearchListing")
      }
    }

    public struct SearchListing: GraphQLSelectionSet {
      public static let possibleTypes = ["SearchListing"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("currentPage", type: .scalar(Int.self)),
        GraphQLField("count", type: .scalar(Int.self)),
        GraphQLField("results", type: .list(.object(Result.selections))),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(currentPage: Int? = nil, count: Int? = nil, results: [Result?]? = nil, status: Int? = nil, errorMessage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "SearchListing", "currentPage": currentPage, "count": count, "results": results.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }, "status": status, "errorMessage": errorMessage])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var currentPage: Int? {
        get {
          return resultMap["currentPage"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "currentPage")
        }
      }

      public var count: Int? {
        get {
          return resultMap["count"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "count")
        }
      }

      public var results: [Result?]? {
        get {
          return (resultMap["results"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Result?] in value.map { (value: ResultMap?) -> Result? in value.flatMap { (value: ResultMap) -> Result in Result(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }, forKey: "results")
        }
      }

      public var status: Int? {
        get {
          return resultMap["status"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }

      public var errorMessage: String? {
        get {
          return resultMap["errorMessage"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "errorMessage")
        }
      }

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["ShowListing"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("personCapacity", type: .scalar(Int.self)),
          GraphQLField("lat", type: .scalar(Double.self)),
          GraphQLField("lng", type: .scalar(Double.self)),
          GraphQLField("beds", type: .scalar(Int.self)),
          GraphQLField("bookingType", type: .scalar(String.self)),
          GraphQLField("coverPhoto", type: .scalar(Int.self)),
          GraphQLField("roomType", type: .scalar(String.self)),
          GraphQLField("reviewsCount", type: .scalar(Int.self)),
          GraphQLField("reviewsStarRating", type: .scalar(Int.self)),
          GraphQLField("city", type: .scalar(String.self)),
          GraphQLField("state", type: .scalar(String.self)),
          GraphQLField("country", type: .scalar(String.self)),
          GraphQLField("listPhotoName", type: .scalar(String.self)),
          GraphQLField("listPhotos", type: .list(.object(ListPhoto.selections))),
          GraphQLField("listingPhotos", type: .list(.object(ListingPhoto.selections))),
          GraphQLField("listingData", type: .object(ListingDatum.selections)),
          GraphQLField("settingsData", type: .list(.object(SettingsDatum.selections))),
          GraphQLField("wishListStatus", type: .scalar(Bool.self)),
          GraphQLField("isListOwner", type: .scalar(Bool.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int? = nil, title: String? = nil, personCapacity: Int? = nil, lat: Double? = nil, lng: Double? = nil, beds: Int? = nil, bookingType: String? = nil, coverPhoto: Int? = nil, roomType: String? = nil, reviewsCount: Int? = nil, reviewsStarRating: Int? = nil, city: String? = nil, state: String? = nil, country: String? = nil, listPhotoName: String? = nil, listPhotos: [ListPhoto?]? = nil, listingPhotos: [ListingPhoto?]? = nil, listingData: ListingDatum? = nil, settingsData: [SettingsDatum?]? = nil, wishListStatus: Bool? = nil, isListOwner: Bool? = nil) {
          self.init(unsafeResultMap: ["__typename": "ShowListing", "id": id, "title": title, "personCapacity": personCapacity, "lat": lat, "lng": lng, "beds": beds, "bookingType": bookingType, "coverPhoto": coverPhoto, "roomType": roomType, "reviewsCount": reviewsCount, "reviewsStarRating": reviewsStarRating,"city": city,"state": state, "country": country, "listPhotoName": listPhotoName, "listPhotos": listPhotos.flatMap { (value: [ListPhoto?]) -> [ResultMap?] in value.map { (value: ListPhoto?) -> ResultMap? in value.flatMap { (value: ListPhoto) -> ResultMap in value.resultMap } } }, "listingPhotos": listingPhotos.flatMap { (value: [ListingPhoto?]) -> [ResultMap?] in value.map { (value: ListingPhoto?) -> ResultMap? in value.flatMap { (value: ListingPhoto) -> ResultMap in value.resultMap } } }, "listingData": listingData.flatMap { (value: ListingDatum) -> ResultMap in value.resultMap }, "settingsData": settingsData.flatMap { (value: [SettingsDatum?]) -> [ResultMap?] in value.map { (value: SettingsDatum?) -> ResultMap? in value.flatMap { (value: SettingsDatum) -> ResultMap in value.resultMap } } }, "wishListStatus": wishListStatus, "isListOwner": isListOwner])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: Int? {
          get {
            return resultMap["id"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var title: String? {
          get {
            return resultMap["title"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
          }
        }

        public var personCapacity: Int? {
          get {
            return resultMap["personCapacity"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "personCapacity")
          }
        }

        public var lat: Double? {
          get {
            return resultMap["lat"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "lat")
          }
        }

        public var lng: Double? {
          get {
            return resultMap["lng"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "lng")
          }
        }

        public var beds: Int? {
          get {
            return resultMap["beds"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "beds")
          }
        }

        public var bookingType: String? {
          get {
            return resultMap["bookingType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bookingType")
          }
        }

        public var coverPhoto: Int? {
          get {
            return resultMap["coverPhoto"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "coverPhoto")
          }
        }

        public var roomType: String? {
          get {
            return resultMap["roomType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "roomType")
          }
        }

        public var reviewsCount: Int? {
          get {
            return resultMap["reviewsCount"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "reviewsCount")
          }
        }

        public var reviewsStarRating: Int? {
          get {
            return resultMap["reviewsStarRating"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "reviewsStarRating")
          }
        }
          
          public var city: String? {
            get {
              return resultMap["city"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "city")
            }
          }
          
          public var state: String? {
            get {
              return resultMap["state"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "state")
            }
          }
          
          public var country: String? {
            get {
              return resultMap["country"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "country")
            }
          }

        public var listPhotoName: String? {
          get {
            return resultMap["listPhotoName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "listPhotoName")
          }
        }

        public var listPhotos: [ListPhoto?]? {
          get {
            return (resultMap["listPhotos"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ListPhoto?] in value.map { (value: ResultMap?) -> ListPhoto? in value.flatMap { (value: ResultMap) -> ListPhoto in ListPhoto(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [ListPhoto?]) -> [ResultMap?] in value.map { (value: ListPhoto?) -> ResultMap? in value.flatMap { (value: ListPhoto) -> ResultMap in value.resultMap } } }, forKey: "listPhotos")
          }
        }

        public var listingPhotos: [ListingPhoto?]? {
          get {
            return (resultMap["listingPhotos"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ListingPhoto?] in value.map { (value: ResultMap?) -> ListingPhoto? in value.flatMap { (value: ResultMap) -> ListingPhoto in ListingPhoto(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [ListingPhoto?]) -> [ResultMap?] in value.map { (value: ListingPhoto?) -> ResultMap? in value.flatMap { (value: ListingPhoto) -> ResultMap in value.resultMap } } }, forKey: "listingPhotos")
          }
        }

        public var listingData: ListingDatum? {
          get {
            return (resultMap["listingData"] as? ResultMap).flatMap { ListingDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "listingData")
          }
        }

        public var settingsData: [SettingsDatum?]? {
          get {
            return (resultMap["settingsData"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [SettingsDatum?] in value.map { (value: ResultMap?) -> SettingsDatum? in value.flatMap { (value: ResultMap) -> SettingsDatum in SettingsDatum(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [SettingsDatum?]) -> [ResultMap?] in value.map { (value: SettingsDatum?) -> ResultMap? in value.flatMap { (value: SettingsDatum) -> ResultMap in value.resultMap } } }, forKey: "settingsData")
          }
        }

        public var wishListStatus: Bool? {
          get {
            return resultMap["wishListStatus"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "wishListStatus")
          }
        }

        public var isListOwner: Bool? {
          get {
            return resultMap["isListOwner"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isListOwner")
          }
        }

        public struct ListPhoto: GraphQLSelectionSet {
          public static let possibleTypes = ["listPhotosData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(String.self)),
            GraphQLField("status", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, name: String? = nil, type: String? = nil, status: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listPhotosData", "id": id, "name": name, "type": type, "status": status])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: Int? {
            get {
              return resultMap["id"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var type: String? {
            get {
              return resultMap["type"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var status: String? {
            get {
              return resultMap["status"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }
        }

        public struct ListingPhoto: GraphQLSelectionSet {
          public static let possibleTypes = ["listPhotosData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(String.self)),
            GraphQLField("status", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, name: String? = nil, type: String? = nil, status: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "listPhotosData", "id": id, "name": name, "type": type, "status": status])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: Int? {
            get {
              return resultMap["id"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var type: String? {
            get {
              return resultMap["type"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          public var status: String? {
            get {
              return resultMap["status"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }
        }

        public struct ListingDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["listingData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("basePrice", type: .scalar(Double.self)),
            GraphQLField("currency", type: .scalar(String.self)),
            GraphQLField("dates", type: .scalar(String.self)),
            GraphQLField("oneTotalPrice", type: .object(OneTotalPrice.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(basePrice: Double? = nil, currency: String? = nil, dates: String? = nil, oneTotalPrice: OneTotalPrice? = nil) {
            self.init(unsafeResultMap: ["__typename": "listingData", "basePrice": basePrice, "currency": currency, "dates": dates, "oneTotalPrice": oneTotalPrice.flatMap { (value: OneTotalPrice) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var basePrice: Double? {
            get {
              return resultMap["basePrice"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "basePrice")
            }
          }

          public var currency: String? {
            get {
              return resultMap["currency"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currency")
            }
          }

          public var dates: String? {
            get {
              return resultMap["dates"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "dates")
            }
          }

          public var oneTotalPrice: OneTotalPrice? {
            get {
              return (resultMap["oneTotalPrice"] as? ResultMap).flatMap { OneTotalPrice(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "oneTotalPrice")
            }
          }

          public struct OneTotalPrice: GraphQLSelectionSet {
            public static let possibleTypes = ["oneTotalPrice"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("oneTotalPrice", type: .scalar(Double.self)),
              GraphQLField("isAverage", type: .scalar(Double.self)),
              GraphQLField("isDayTotal", type: .scalar(Double.self)),
              GraphQLField("discount", type: .scalar(Double.self)),
              GraphQLField("dayDifference", type: .scalar(Int.self)),
              GraphQLField("cleaningPrice", type: .scalar(Double.self)),
              GraphQLField("serviceFee", type: .scalar(Double.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(oneTotalPrice: Double? = nil, isAverage: Double? = nil, isDayTotal: Double? = nil, discount: Double? = nil, dayDifference: Int? = nil, cleaningPrice: Double? = nil, serviceFee: Double? = nil) {
              self.init(unsafeResultMap: ["__typename": "oneTotalPrice", "oneTotalPrice": oneTotalPrice, "isAverage": isAverage, "isDayTotal": isDayTotal, "discount": discount, "dayDifference": dayDifference, "cleaningPrice": cleaningPrice, "serviceFee": serviceFee])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var oneTotalPrice: Double? {
              get {
                return resultMap["oneTotalPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "oneTotalPrice")
              }
            }

            public var isAverage: Double? {
              get {
                return resultMap["isAverage"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "isAverage")
              }
            }

            public var isDayTotal: Double? {
              get {
                return resultMap["isDayTotal"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "isDayTotal")
              }
            }

            public var discount: Double? {
              get {
                return resultMap["discount"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "discount")
              }
            }

            public var dayDifference: Int? {
              get {
                return resultMap["dayDifference"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "dayDifference")
              }
            }

            public var cleaningPrice: Double? {
              get {
                return resultMap["cleaningPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "cleaningPrice")
              }
            }

            public var serviceFee: Double? {
              get {
                return resultMap["serviceFee"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "serviceFee")
              }
            }
          }
        }

        public struct SettingsDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["userListingData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("listsettings", type: .object(Listsetting.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(listsettings: Listsetting? = nil) {
            self.init(unsafeResultMap: ["__typename": "userListingData", "listsettings": listsettings.flatMap { (value: Listsetting) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var listsettings: Listsetting? {
            get {
              return (resultMap["listsettings"] as? ResultMap).flatMap { Listsetting(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "listsettings")
            }
          }

          public struct Listsetting: GraphQLSelectionSet {
            public static let possibleTypes = ["singleListSettings"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(Int.self)),
              GraphQLField("itemName", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: Int? = nil, itemName: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "singleListSettings", "id": id, "itemName": itemName])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: Int? {
              get {
                return resultMap["id"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var itemName: String? {
              get {
                return resultMap["itemName"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "itemName")
              }
            }
          }
        }
      }
    }
  }
}
