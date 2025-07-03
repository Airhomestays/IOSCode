

import UIKit
import SwiftMessages
import Apollo
import ISPageControl
import FlexiblePageControl
import SKPhotoBrowser
import Lottie

protocol ListVCProtocol
{
    func UpdateWhishlistCall(listId:Int, status:Bool)
    
    
    
}
class UpdatedViewListing: UIViewController, ImageScrollerDelegate {
    func pageChanged(index: Int, indexpath: Int) {
        imagePageControll.currentPage = index
     
    }
    @IBOutlet var tblBeds: UITableView!
    
    @IBOutlet var tblBedsheight: NSLayoutConstraint!
    @IBOutlet var singleRoomCount: UILabel!
    @IBOutlet var singleRoomImage: UIImageView!
    @IBOutlet var minbulletImg: UIImageView!
    
    @IBOutlet var RoomsCount: UILabel!
    @IBOutlet var RoomsImage: UIImageView!
    
    @IBOutlet var singleRoomView: UIView!
    @IBOutlet var roomsView: UIView!
    
    @IBOutlet var minnightHeight: NSLayoutConstraint!
    
    @IBOutlet var lineview18: UIView!
    
    @IBOutlet var mapBgImg: UIImageView!
    
    @IBOutlet var lineview10: UIView!
    @IBOutlet var lineview9: UIView!
    @IBOutlet var lineView8: UIView!
    @IBOutlet var lineview7: UIView!
    @IBOutlet var lineview6: UIView!
    @IBOutlet var lineview5: UIView!
    @IBOutlet var lineview4: UIView!
    @IBOutlet var lineView3: UIView!
    @IBOutlet var lineView2: UIView!
    @IBOutlet var lineView1: UIView!
    
    @IBOutlet var checkinbullet: UIImageView!
    
    @IBOutlet var maxNightBullet: UIImageView!
    
    @IBOutlet var centerConstant: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topHeaderStackView: UIStackView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var checkAvailabilityBtn: UIButton!
    @IBOutlet weak var listPriceLabel: UILabel!
    @IBOutlet weak var listRatingView: UIView!
    @IBOutlet weak var listRatingStar: UIImageView!
    @IBOutlet weak var listRatingLabel: UILabel!
    var pageNumber : Int = 0
    @IBOutlet weak var selectedDateBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var imagePageControll: ISPageControl!
    
   
    var Pagecontrol:ISPageControl!
    var filteredImageArray = NSMutableArray()
    @IBOutlet weak var listTypeLabel: UILabel!
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var listAddressLabel: UILabel!
    @IBOutlet weak var addressProfileDivider: UIView!
    
    @IBOutlet weak var hostProfileImg: UIImageView!
    @IBOutlet weak var hostProfileName: UILabel!
    @IBOutlet weak var viewHostProfileBtn: UIButton!
    
    @IBOutlet weak var BedsBathroomInfoView: UIView!
    @IBOutlet weak var guestView: UIView!
    @IBOutlet weak var guestImgVIew: UIImageView!
    @IBOutlet weak var guestCountLabel: UILabel!
    
    @IBOutlet weak var bedroomView: UIView!
    @IBOutlet weak var bedroomImgView: UIImageView!
    @IBOutlet weak var bedroomCountLabel: UILabel!
    
    @IBOutlet weak var bedsView: UIView!
    @IBOutlet weak var bedsImgView: UIImageView!
    @IBOutlet weak var bedsCountLabel: UILabel!
    
    @IBOutlet weak var bathroomView: UIView!
    @IBOutlet weak var bathroomImgView: UIImageView!
    @IBOutlet weak var bathroomCountLabel: UILabel!
    
    @IBOutlet weak var aboutListingLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var readmoreLabel: UILabel!
    @IBOutlet weak var readmoreImgIcon: UIImageView!
    @IBOutlet weak var readmoreBtn: UIButton!
    @IBOutlet weak var readmoreBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var minMaxView: UIView!
    @IBOutlet weak var minMaxLabel: UILabel!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var minMaxViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var minMaxTopConstraint: NSLayoutConstraint!
    var images = [SKPhotoProtocol]()
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapTitleLabel: UILabel!
    @IBOutlet weak var staticMapImgView: UIImageView!
    @IBOutlet weak var mapCenterCircleView: UIImageView!
    @IBOutlet weak var mapDetailsView: UIView!
    @IBOutlet weak var mapLocationLabel: UILabel!
    @IBOutlet weak var exactDescLabel: UILabel!
    @IBOutlet weak var mapViewButton: UIButton!
    
    
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var reviewViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var checkInOutStackView: UIStackView!
    @IBOutlet weak var checkInOutView: UIView!
    @IBOutlet weak var checkInOutTitleLabel: UILabel!
    @IBOutlet weak var checkInValueLabel: UILabel!
  
    
    @IBOutlet weak var houseRulesView: UIView!
    @IBOutlet weak var houseRulesTitleLabel: UILabel!
    @IBOutlet weak var houseRulesValueLabel: UILabel!
    @IBOutlet weak var houseRulesBtn: UIButton!
    
    @IBOutlet weak var cancellationPolicyView: UIView!
    @IBOutlet weak var cancellationPolicyTitleLabel: UILabel!
    @IBOutlet weak var cancellationPolicyValueLabel: UILabel!
    @IBOutlet weak var cancellationPolicyBtn: UIButton!
    
    @IBOutlet weak var availabilityView: UIView!
    @IBOutlet weak var availabilityTitleLabel: UILabel!
    @IBOutlet weak var availabilityValueLabel: UILabel!
    @IBOutlet weak var availabilityBtn: UIButton!
    
    
    @IBOutlet weak var contactHostView: UIView!
    @IBOutlet weak var contactHostTitleLabel: UILabel!
    @IBOutlet weak var contactHostValueLabel: UILabel!
    @IBOutlet weak var contactHostBtn: UIButton!
    
    @IBOutlet var lightImage: UIImageView!
    
    @IBOutlet weak var similarListingView: UIView!
    @IBOutlet weak var similarListingTitleLabel: UILabel!
    @IBOutlet weak var similarListingCollectionView: UICollectionView!
    @IBOutlet weak var similarListHeightConstraint: NSLayoutConstraint!
    
    var listID = 0
    var viewModel: viewListingModel?
    var reviewTitle = ""
    @IBOutlet weak var lottieView: LottieAnimationView!
    
    @IBOutlet weak var amenitiesTableView: UITableView!
    @IBOutlet weak var amenitiesTableHeightConstraint: NSLayoutConstraint!
    var isShowMoreAmenitiesClicked = false
    @IBOutlet weak var userSpacesTableView: UITableView!
    @IBOutlet weak var userSpacesHeightConstraint: NSLayoutConstraint!
    var isShowMoreUserSpaceClicked = false
    @IBOutlet weak var safetyAmenitiesTableView: UITableView!
    @IBOutlet weak var safetyAmenitiesHeightConstriant: NSLayoutConstraint!
    var isShowMoreSafetyAmenitiesClicked = false
    
    var isShowMoreBedsClicked = false
    
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoCloseButton: UIButton!
    
    @IBOutlet weak var noListView: UIView!
    @IBOutlet weak var noListTitleLabel: UILabel!
    @IBOutlet weak var noListDescriptionLabel: UILabel!
    @IBOutlet weak var noListErrorCodeLabel: UILabel!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineTitleLabel: UILabel!
    @IBOutlet weak var offlineRetryBtn: UIButton!
    
    var delegate: ListVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.configureLottieView()
        self.configureTopView()
        self.configureCollectionViews()
        self.configuregetBillingErrorView()
        self.configureOfflineErrorViews()
        viewModel = viewListingModel()
        viewModel?.listID = listID
        viewModel?.currencyvalue_from_API_base = Utility.shared.currencyvalue_from_API_base
        self.lottieView.isHidden = false
        self.scrollView.isHidden = true
        self.topView.isHidden = true
        self.bottomView.isHidden = true
        self.checkApolloStatus()
        
        mapBgImg.image = #imageLiteral(resourceName: "mapTitleBG").withRenderingMode(.alwaysTemplate)
        mapBgImg.tintColor = UIColor(named: "becomeAHostStep_Color")
        
        self.view.backgroundColor = UIColor(named: "colorController")
        reviewView.backgroundColor = UIColor(named: "colorController")
        addressProfileDivider.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineView1.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineview18.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineView2.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineview5.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineView8.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineView3.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineview6.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineview4.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        lineview7.backgroundColor =   UIColor(named: "Review_Page_Line_Color")
        lineview9.backgroundColor =   UIColor(named: "Review_Page_Line_Color")
        lineview10.backgroundColor =   UIColor(named: "Review_Page_Line_Color")
        
     
        self.reviewView.isHidden = true
        self.reviewViewHeightConstraint.constant = 0
        
        self.similarListingView.isHidden = true
        self.similarListHeightConstraint.constant = 0
        
        self.scrollView.delegate = self
        
        self.selectedDateBtn.backgroundColor = .clear
        self.selectedDateBtn.setTitle("", for: .normal)
        self.selectedDateBtn.setTitleColor(UIColor(named: "viewList_Title"), for: .normal)
        self.selectedDateBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 12.0)
        
        
        if Utility.shared.selectedstartDate == ""{
            self.selectedDateBtn.setTitle("", for: .normal)
            self.selectedDateBtn.isHidden = true
            self.listRatingView.isHidden = false
            self.centerConstant.constant = -12
           
        }else{
            self.listRatingView.isHidden = true
            self.centerConstant.constant = -12
            let newDateFormat = DateFormatter()
           
            newDateFormat.dateFormat = "MMM dd"
            
            let sampleDateFormat = DateFormatter()
          
            sampleDateFormat.dateFormat = "yyyy-MM-dd"
            
            let firstDate = sampleDateFormat.date(from: Utility.shared.selectedstartDate)
            let secondDate = sampleDateFormat.date(from: Utility.shared.selectedEndDate)
            
            self.viewModel?.selectedStartDate = firstDate
            self.viewModel?.selectedEndDate = secondDate
            
            
            var startDateString = ""
            var endDateString = ""
            
            if let date = firstDate{
                startDateString = newDateFormat.string(from: date)
            }
            if let date = secondDate{
                endDateString = newDateFormat.string(from: date)
            }
            
            
            let yourAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attributeString = NSMutableAttributedString(
                string: "\(startDateString)-\(endDateString)",
                attributes: yourAttributes
            )
            
            self.selectedDateBtn.setAttributedTitle(attributeString, for: .normal)
            
            self.selectedDateBtn.isHidden = false
            self.listRatingView.isHidden = true
            self.centerConstant.constant = -12
            
            
            
            
            
        }
      
    }
    @objc func pageChanged(_ sender: UISwipeGestureRecognizer) {
        
        pageNumber = sender.view!.tag
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func onClickSelectedDateBtn(_ sender: UIButton) {
        if let minstay = (viewModel?.viewListingArray.listingData?.minNight!) {
            Utility.shared.minimumstay = minstay }
        Utility.shared.isfromcheckingPage = true
        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: self.viewModel?.selectedStartDate, dateTo: self.viewModel?.selectedEndDate)
        datePickerViewController.isFromFilter = false
        datePickerViewController.delegate = self
        if let viewListArray = self.viewModel?.viewListingArray{
            datePickerViewController.viewListingArray = viewListArray
        }
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    @IBAction func onClickRetryBtn(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            self.scrollView.isHidden = true
            self.topHeaderStackView.isHidden = true
            self.lottieView.isHidden = false
            viewModel?.viewDetailAPICall(listid: viewModel?.listID ?? 0, completion: { resultValue in
                resultValue
                self.viewListValueUpdates(result: resultValue)
                
                let fmt = DateFormatter()
              
                fmt.dateFormat = "yyyy-MM-dd"
                if(self.viewModel?.selectedStartDate != nil && self.viewModel?.selectedEndDate != nil)
                {
                    self.viewModel?.billingListAPICall(startDate: fmt.string(from: (self.viewModel?.selectedStartDate)!), endDate: fmt.string(from: (self.viewModel?.selectedEndDate)!), completion: {
                        value in
                        if !value.isEmpty{
                            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!)  \(value)")
                            attributedString.setColor(color:  UIColor(named: "Title_Header")!, forText:"\(value)")
                            attributedString.setColor(color:Theme.SECONDARY_COLOR, forText:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!):")
                            self.infoView.isHidden = false
                            self.infoTitleLabel.attributedText = attributedString
                        }
                    })
                    if(self.viewModel?.viewListingArray.bookingType != nil && self.viewModel?.viewListingArray.bookingType! == "instant")
                    {
                        self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"book") ?? "Book")", for: .normal)
                    }else{
                        self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"requestbook") ?? "Request to book")", for: .normal)
                    }
                }
            })
        }
    }
    
    func configureLottieView(){
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
    func configureTopView(){
        self.topView.backgroundColor = .clear
        
        self.backBtn.backgroundColor = .white
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.shareBtn.backgroundColor = .white
        self.shareBtn.setTitle("", for: .normal)
        self.shareBtn.setImage(UIImage(named: "share"), for: .normal)
        self.shareBtn.layer.cornerRadius = self.shareBtn.frame.size.height/2
        self.shareBtn.clipsToBounds = true
        
        
        
        self.reportBtn.backgroundColor = .white
        self.reportBtn.setTitle("", for: .normal)
        self.reportBtn.setImage(UIImage(named: "report"), for: .normal)
        self.reportBtn.layer.cornerRadius = self.reportBtn.frame.size.height/2
        self.reportBtn.clipsToBounds = true
        
        
        
        
        
        
        
    }
    func configureLikeBtn(){
        self.likeBtn.backgroundColor = .white
        self.likeBtn.setTitle("", for: .normal)
        if let wishListStatus = self.viewModel?.viewListingArray.wishListStatus, wishListStatus == true{
            self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
        }else{
            self.likeBtn.setImage(UIImage(named: "Heart"), for: .normal)
        }
        
        self.likeBtn.layer.cornerRadius = self.likeBtn.frame.size.height/2
        self.likeBtn.clipsToBounds = true
        
        
        if(Utility.shared.getCurrentUserID() != nil && ("\(Utility.shared.getCurrentUserID()!)" == "\(self.viewModel?.viewListingArray.userId ?? "")"))
        {
            reportBtn.isHidden = true
        }
        else {
            reportBtn.isHidden = false
        }
    }
    func configuregetBillingErrorView(){
        self.infoView.isHidden = true
        
        self.infoTitleLabel.textColor = UIColor(named: "Title_Header")
        self.infoTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.infoTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        
        self.infoCloseButton.setTitle("", for: .normal)
        self.infoCloseButton.backgroundColor = .clear
        self.infoCloseButton.setImage(UIImage(named: "close-black"), for: .normal)
    }
    func configureOfflineErrorViews(){
        self.offlineView.isHidden = true
        
        self.offlineTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        self.offlineTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.offlineTitleLabel.font = UIFont(name: APP_FONT, size: 14.0)
        self.offlineTitleLabel.textColor = UIColor(named: "Title_Header")
        
        self.offlineRetryBtn.setTitle("Retry", for: .normal)
        self.offlineRetryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        self.offlineRetryBtn.backgroundColor = .white
        
        self.noListView.isHidden = true
        
        self.noListTitleLabel.text = "Uh-oh!"
        self.noListTitleLabel.textAlignment = .center
        self.noListTitleLabel.font = UIFont(name: APP_FONT, size: 18.0)
        self.noListTitleLabel.textColor = UIColor(named: "Title_Header")
        
        self.noListDescriptionLabel.text = "We can't seem to find anything that you're looking for!"
        self.noListDescriptionLabel.textAlignment = .center
        self.noListDescriptionLabel.font = UIFont(name: APP_FONT, size: 16.0)
        self.noListDescriptionLabel.textColor = UIColor(named: "Title_Header")
        
        self.noListErrorCodeLabel.text = "Error code: 404"
        self.noListErrorCodeLabel.textAlignment = .center
        self.noListErrorCodeLabel.font = UIFont(name: APP_FONT, size: 16.0)
        self.noListErrorCodeLabel.textColor = UIColor(named: "Title_Header")
    }
    func configureBottomView(){
        self.bottomView.backgroundColor = UIColor(named: "cell_bg")
        self.bottomView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.bottomView.layer.shadowRadius = 2
        self.bottomView.layer.shadowColor =  UIColor(named: "Title_Header")?.cgColor
        self.bottomView.layer.shadowOpacity = 0.3
        
        self.checkAvailabilityBtn.backgroundColor = Theme.SECONDARY_COLOR
        self.checkAvailabilityBtn.layer.cornerRadius = self.checkAvailabilityBtn.frame.size.height/2
        self.checkAvailabilityBtn.clipsToBounds = true
        
        if self.viewModel?.selectedStartDate == nil{
            self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"checkavailability") ?? "Check Availability")", for: .normal)
        }else{
            if(self.viewModel?.viewListingArray.bookingType != nil && self.viewModel?.viewListingArray.bookingType! == "instant")
            {
                self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"book") ?? "Book")", for: .normal)
            }else{
                self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"requestbook") ?? "Request to book")", for: .normal)
            }
        }
        
        self.checkAvailabilityBtn.setTitleColor(UIColor.white, for: .normal)
        self.checkAvailabilityBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        
        self.listPriceLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.listPriceLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        self.listPriceLabel.textColor = UIColor(named: "Title_Header")
        
        self.listRatingView.backgroundColor = .clear
        self.listRatingLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.listRatingLabel.font = UIFont(name: APP_FONT, size: 12)
        self.listRatingLabel.textColor = UIColor(named: "Title_Header")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      
    }
    
    @objc func imageScrollerTapped(_ sender: UITapGestureRecognizer) {
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: imagePageControll.currentPage)
        browser.delegate = self
        
        present(browser, animated: true, completion: {})
    }
    func configureCollectionViews(){
        self.imgCollectionView.register(UINib(nibName: "imageScrollCollectionView", bundle: nil), forCellWithReuseIdentifier: "ImageScrollCollectionView")
        self.imgCollectionView.delegate = self
        self.imgCollectionView.dataSource = self
        self.imgCollectionView.bounces = false
        self.imgCollectionView.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        self.imgCollectionView.collectionViewLayout = layout
    
        imagePageControll.backgroundColor = .clear
        
        imagePageControll.radius = 5
        imagePageControll.padding = 8
        imagePageControll.inactiveTintColor = UIColor(named: "Review_Page_Line_Color")!
        imagePageControll.currentPageTintColor = Theme.PRIMARY_COLOR
        imagePageControll.inactiveTransparency = 1
       
        self.reviewTableView.register(UINib(nibName: "UpdatedReviewCells", bundle: nil), forCellReuseIdentifier: "updatedreviewCells")
        self.reviewTableView.delegate = self
        self.reviewTableView.dataSource = self
        
        self.reviewTableView.backgroundColor = .clear
        
        
        self.similarListingCollectionView.register(UINib(nibName: "customUpdatedCell", bundle: nil), forCellWithReuseIdentifier: "CellcustomUpdated")
        self.similarListingCollectionView.delegate = self
        self.similarListingCollectionView.dataSource = self
        self.similarListingCollectionView.showsHorizontalScrollIndicator = false
        let layout1 = UICollectionViewFlowLayout()
        layout1.scrollDirection = .horizontal
        layout1.minimumLineSpacing = 10
        layout1.minimumInteritemSpacing = 0
        self.similarListingCollectionView.collectionViewLayout = layout1
        
        self.amenitiesTableView.register(UINib(nibName: "AmenityDetailCell", bundle: nil), forCellReuseIdentifier: "AmenityDetailCell")
        self.amenitiesTableView.delegate = self
        self.amenitiesTableView.dataSource = self
        self.amenitiesTableView.separatorStyle = .none
        self.amenitiesTableHeightConstraint.constant = 0
        
        self.amenitiesTableView.backgroundColor = .clear
        
        amenitiesTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.userSpacesTableView.register(UINib(nibName: "AmenityDetailCell", bundle: nil), forCellReuseIdentifier: "AmenityDetailCell")
        self.userSpacesTableView.delegate = self
        self.userSpacesTableView.dataSource = self
        self.userSpacesTableView.separatorStyle = .none
        self.userSpacesHeightConstraint.constant = 0
        
        self.userSpacesTableView.backgroundColor = .clear
        
        userSpacesTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.safetyAmenitiesTableView.register(UINib(nibName: "AmenityDetailCell", bundle: nil), forCellReuseIdentifier: "AmenityDetailCell")
        self.safetyAmenitiesTableView.delegate = self
        self.safetyAmenitiesTableView.dataSource = self
        self.safetyAmenitiesTableView.separatorStyle = .none
        self.safetyAmenitiesHeightConstriant.constant = 0
        safetyAmenitiesTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.safetyAmenitiesTableView.backgroundColor = .clear
        
        self.tblBeds.register(UINib(nibName: "AmenityDetailCell", bundle: nil), forCellReuseIdentifier: "AmenityDetailCell")
        self.tblBeds.delegate = self
        self.tblBeds.dataSource = self
        self.tblBeds.separatorStyle = .none
        self.tblBedsheight.constant = 0
        tblBeds.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.tblBeds.backgroundColor = .clear
        
        
        tblBeds.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tblBeds.sectionHeaderTopPadding = 5
            
            userSpacesTableView.sectionHeaderTopPadding = 5
            amenitiesTableView.sectionHeaderTopPadding = 5
            safetyAmenitiesTableView.sectionHeaderTopPadding = 5
        }
        
        
    }
    func configureScrollViews(){
        var listTypeString = ""
        listTypeString = "\(viewModel?.viewListingArray.houseType ?? "")"
        
        
        if viewModel?.viewListingArray.residenceType == "0" || viewModel?.viewListingArray.residenceType == nil  || viewModel?.viewListingArray.residenceType == "null" {
            
        }
        else {
            listTypeString = listTypeString + " \u{2022} Personal home"
        }
        
        listTypeLabel.text = listTypeString
        listTypeLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        listTypeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        listTypeLabel.font = UIFont(name: APP_FONT, size: 14)
        
        if(self.viewModel?.viewListingArray.bookingType != "instant") {
            self.lightImage.isHidden = true
        }
        else {
            self.lightImage.isHidden = false
        }
        listTitleLabel.text = viewModel?.viewListingArray.title ?? ""
        listTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        listTitleLabel.textColor = UIColor(named: "viewList_Title")
        listTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        
        listAddressLabel.text = "\(viewModel?.viewListingArray.city ?? ""), \(viewModel?.viewListingArray.state ?? ""), \(viewModel?.viewListingArray.country ?? "")"
        listAddressLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        listAddressLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        listAddressLabel.font = UIFont(name: APP_FONT, size: 12)
        
        self.configureHostView()
        self.configureBedBathroomView()
        self.configureInfoView()
        
        if ((viewModel?.viewListingArray.listingData?.minNight == nil || viewModel?.viewListingArray.listingData?.minNight == 0) && (viewModel?.viewListingArray.listingData?.maxNight == nil || viewModel?.viewListingArray.listingData?.maxNight == 0)){
            self.minMaxView.isHidden = true
            self.minMaxViewHeightConstraint.constant = 0
          
        }else{
            self.configureMinMaxViews()
            self.minMaxView.isHidden = false
        }
        
        self.configureMapView()
        self.configureVerticalStackViews()
        
    }
    
    func configureHostView(){
        self.hostProfileImg.layer.cornerRadius = self.hostProfileImg.frame.size.height/2
        self.hostProfileImg.clipsToBounds = true
        if let hostImg = viewModel?.viewListingArray.user?.profile?.picture{
            self.hostProfileImg.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(hostImg)"), placeholderImage: #imageLiteral(resourceName: "unknown"), completed: nil)
            self.hostProfileImg.contentMode = .scaleAspectFill
        }else{
            self.hostProfileImg.image = UIImage(named: "unknown")
        }
        
        self.hostProfileName.text = "\(Utility.shared.getLanguage()?.value(forKey: "hostedby") ?? "Hosted by") \(viewModel?.viewListingArray.user?.profile?.firstName ?? "")"
        self.hostProfileName.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.hostProfileName.textColor = UIColor(named: "viewList_Title")
        self.hostProfileName.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        similarListingTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        similarListingTitleLabel.text =  "\(Utility.shared.getLanguage()?.value(forKey: "similarlsiting") ?? "Similar listings")"
        similarListingTitleLabel.textColor =  UIColor(named: "Title_Header")
        
        if #available(iOS 15.0, *) {
            self.viewHostProfileBtn.configuration?.titleAlignment = Utility.shared.isRTLLanguage() ? .trailing : .leading
            self.viewHostProfileBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        } else {
            self.viewHostProfileBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        }
        self.viewHostProfileBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "View Profile") ?? "View profile")", for: .normal)
        self.viewHostProfileBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        self.viewHostProfileBtn.backgroundColor = .clear
        self.viewHostProfileBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 14.0)
    }
    
    func configureBedBathroomView(){
        if let personCapacity = self.viewModel?.viewListingArray.personCapacity{
            if personCapacity == 1{
                self.guestCountLabel.text = "\(personCapacity) \(Utility.shared.getLanguage()?.value(forKey:"guestsmall") ?? "guest")"
            }else{
                self.guestCountLabel.text = "\(personCapacity) \(Utility.shared.getLanguage()?.value(forKey:"guestssmall") ?? "guests")"
            }
        }
        self.guestCountLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.guestCountLabel.font = UIFont(name: APP_FONT, size: 13.0)
        self.guestCountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        if let bedrooms = self.viewModel?.viewListingArray.bedrooms{
            if bedrooms == "1"{
                self.bedroomCountLabel.text = "\(bedrooms) \(Utility.shared.getLanguage()?.value(forKey:"bedroom") ?? "Bedroom")"
            }else{
                self.bedroomCountLabel.text = "\(bedrooms) \(Utility.shared.getLanguage()?.value(forKey:"bedrooms") ?? "Bedrooms")"
            }
        }
        self.bedroomCountLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.bedroomCountLabel.font = UIFont(name: APP_FONT, size: 13.0)
        self.bedroomCountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        if let beds = self.viewModel?.viewListingArray.beds{
            if beds == 1{
                self.bedsCountLabel.text = "\(beds) \(Utility.shared.getLanguage()?.value(forKey:"bed") ?? "Bed")"
            }else{
                self.bedsCountLabel.text = "\(beds) \(Utility.shared.getLanguage()?.value(forKey:"beds") ?? "Beds")"
            }
        }
        self.bedsCountLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.bedsCountLabel.font = UIFont(name: APP_FONT, size: 13.0)
        self.bedsCountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        
        if (self.viewModel?.viewListingArray.roomType) != nil{
            
            self.guestCountLabel.text = self.viewModel?.viewListingArray.roomType
            
        }
        self.guestCountLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.guestCountLabel.font = UIFont(name: APP_FONT, size: 13.0)
        self.guestCountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        if let personCapacity = self.viewModel?.viewListingArray.personCapacity{
            if personCapacity == 1{
                self.RoomsCount.text = "\(personCapacity) \(Utility.shared.getLanguage()?.value(forKey:"guestsmall") ?? "guest")"
            }else{
                self.RoomsCount.text = "\(personCapacity) \(Utility.shared.getLanguage()?.value(forKey:"guestssmall") ?? "guests")"
            }
        }
        self.RoomsCount.textColor = UIColor(named: "searchPlaces_TextColor")
        self.RoomsCount.font = UIFont(name: APP_FONT, size: 13.0)
        self.RoomsCount.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        if let beds = self.viewModel?.viewListingArray.settingsData?[2]?.listsettings?.itemName{
            
            self.singleRoomCount.text = self.viewModel?.viewListingArray.settingsData?[2]?.listsettings?.itemName
            
        }
        self.singleRoomCount.textColor = UIColor(named: "searchPlaces_TextColor")
        self.singleRoomCount.font = UIFont(name: APP_FONT, size: 13.0)
        self.singleRoomCount.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        
        
        if let bathroom = self.viewModel?.viewListingArray.bathrooms{
            if bathroom > 1.0{
                
                self.bathroomCountLabel.text = "\(Float(bathroom)) \(Utility.shared.getLanguage()?.value(forKey:"privatebaths") ?? "Private Baths")"
                
                let str = (self.bathroomCountLabel.text ?? "0") as String
                if str.contains("0") {
                    self.bathroomCountLabel.text = "\(Int(bathroom)) \(Utility.shared.getLanguage()?.value(forKey:"privatebaths") ?? "Private Baths")"
                }
            }else{
                self.bathroomCountLabel.text = "\(Float(bathroom)) \(Utility.shared.getLanguage()?.value(forKey:"privatebath") ?? "Private Bath")"
                let str = self.bathroomCountLabel.text
                if str!.contains("0") {
                    self.bathroomCountLabel.text = "\(Int(bathroom)) \(Utility.shared.getLanguage()?.value(forKey:"privatebath") ?? "Private Bath")"
                }
            }
        }
        self.bathroomCountLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.bathroomCountLabel.font = UIFont(name: APP_FONT, size: 13.0)
        self.bathroomCountLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
    }
    
    func configureInfoView(){
        self.aboutListingLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Description_Title") ?? "About this listing")"
        self.aboutListingLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.aboutListingLabel.textColor = UIColor(named: "Title_Header")
        self.aboutListingLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        
        self.descLabel.text = viewModel?.viewListingArray.description ?? ""
        self.descLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.descLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.descLabel.font = UIFont(name: APP_FONT, size: 14)
        
        self.readmoreLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "showmore") ?? "Show more")"
        self.readmoreLabel.textColor = Theme.PRIMARY_COLOR
        self.readmoreLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        self.readmoreBtn.setTitle("", for: .normal)
        self.readmoreBtn.backgroundColor = .clear
        
        if Utility.shared.isRTLLanguage(){
            self.readmoreImgIcon.performRTLTransform()
        }
        
        if ((self.descLabel.text?.count ?? 0) > 200) {
            self.descLabel.numberOfLines = 4
            self.descLabel.lineBreakMode = .byTruncatingTail
            self.readmoreBtn.isHidden = false
            self.readmoreLabel.isHidden = false
            self.readmoreImgIcon.isHidden = false
            self.readmoreBottomConstraint.constant = 0
        }else{
            self.descLabel.numberOfLines = 0
            self.descLabel.lineBreakMode = .byWordWrapping
            self.readmoreBtn.isHidden = true
            self.readmoreLabel.isHidden = true
            self.readmoreImgIcon.isHidden = true
            self.readmoreBottomConstraint.constant = -20
        }
        
        
        
    }
    
    @IBAction func onClickReadMoreBtn(_ sender: Any) {
        let readmoreObj = ReadmoreVC()
        readmoreObj.ReadmoreText = self.viewModel?.viewListingArray.description ?? ""
        readmoreObj.modalPresentationStyle = .fullScreen
        self.present(readmoreObj, animated: true, completion: nil)
    }
    
    func configureMinMaxViews(){
        if Utility.shared.isRTLLanguage() {
            minbulletImg.performRTLTransform()
            maxNightBullet.performRTLTransform()
            checkinbullet.performRTLTransform()
        }
        self.minMaxLabel.text = "Min / Max nights"
        self.minMaxLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.minMaxLabel.textColor = UIColor(named: "Title_Header")
        self.minMaxLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        
        self.minValueLabel.text = "\(viewModel?.viewListingArray.listingData?.minNight ?? 0) \(Utility.shared.getLanguage()?.value(forKey: "minnights") ?? "min nights")"
        self.minValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.minValueLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.minValueLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        if(viewModel?.viewListingArray.listingData?.minNight == 0) {
            self.minValueLabel.isHidden = false
            self.minnightHeight.constant = 0
            self.minbulletImg.isHidden = true
            minMaxViewHeightConstraint.constant = 65.5
        }
        else {
            self.minValueLabel.isHidden = false
            self.minnightHeight.constant = 20.5
            self.minbulletImg.isHidden = false
            minMaxViewHeightConstraint.constant = 95.5
        }
        
        self.maxValueLabel.text = "\(viewModel?.viewListingArray.listingData?.maxNight ?? 0) \(Utility.shared.getLanguage()?.value(forKey: "maxnights") ?? "max nights")"
        self.maxValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.maxValueLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.maxValueLabel.font = UIFont(name: APP_FONT, size: 14.0)
    }
    
    func configureMapView(){
        self.mapViewButton.setTitle("", for: .normal)
        self.mapViewButton.backgroundColor = .clear
        
        self.mapTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"youhere") ?? "You will be here")"
        self.mapTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.mapTitleLabel.textColor = UIColor(named: "Title_Header")
        self.mapTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        
        let staticMapUrl: String = "https://maps.googleapis.com/maps/api/staticmap?key=\(GOOGLE_API_KEY)&center=\(viewModel?.viewListingArray.lat ?? 0.0),\(viewModel?.viewListingArray.lng ?? 0.0)&\("zoom=15&size=\(2 * Int(self.staticMapImgView.frame.size.width))x\(2 * Int(self.staticMapImgView.frame.size.height))")&sensor=true&language=en"
        let mapUrl: NSURL = NSURL(string: staticMapUrl)!
        self.staticMapImgView.sd_setImage(with: mapUrl as URL, completed: nil)
        
        self.mapLocationLabel.text = "\(viewModel?.viewListingArray.city ?? ""), \(viewModel?.viewListingArray.state ?? ""), \(viewModel?.viewListingArray.country ?? "")"
        self.mapLocationLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.mapLocationLabel.textColor = UIColor(named: "Title_Header")
        self.mapLocationLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 12.0)
        
        
        self.exactDescLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "exactlocation") ?? "Exact location provided after booking")"
        self.exactDescLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.exactDescLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.exactDescLabel.font = UIFont(name: APP_FONT, size: 12.0)
    }
    
    func configureVerticalStackViews(){
        
        self.checkInOutTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "prefcheckin") ?? "Preferred check-in")"
        self.checkInOutTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.checkInOutTitleLabel.textColor = UIColor(named: "Title_Header")
        self.checkInOutTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        
        if let checkIn = self.viewModel?.viewListingArray.listingData?.checkInStart{
            self.checkInValueLabel.text = "Check-in: " + "\(checkIn == "Flexible" ? checkIn : checkIn.conversionRailwaytime())"
        }else{
            self.checkInValueLabel.text = "Check-in: - "
        }
        self.checkInValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.checkInValueLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        self.checkInValueLabel.font = UIFont(name: APP_FONT, size: 14.0)
        
        if let checkOut = self.viewModel?.viewListingArray.listingData?.checkInEnd{
            let checkoutVal =  "\(checkOut == "Flexible" ? checkOut : checkOut.conversionRailwaytime())"
            if(checkOut == "Flexible"){
                if let checkIn = self.viewModel?.viewListingArray.listingData?.checkInStart{
                    if checkIn == "Flexible" {
                        
                    }
                    else {
                        self.checkInValueLabel.text = "\(self.checkInValueLabel.text ?? "Check-in: - " ) - \(checkoutVal)"
                    }
                }
                else {
                    self.checkInValueLabel.text = "\(self.checkInValueLabel.text ?? "Check-in: - " ) - \(checkoutVal)"
                }
            }
            else {
                self.checkInValueLabel.text = "\(self.checkInValueLabel.text ?? "Check-in: - " ) - \(checkoutVal)"
            }
            
        }else{
           
        }
        
        if self.viewModel?.viewListingArray.houseRules?.count != 0{
            self.houseRulesView.isHidden = false
        }else{
            self.houseRulesView.isHidden = true
        }
        
        self.houseRulesTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "houserules") ?? "House rules")"
        self.houseRulesTitleLabel.textColor = UIColor(named: "Title_Header")
        self.checkInOutTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.checkInOutTitleLabel.textColor = UIColor(named: "Title_Header")
        self.checkInOutTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.houseRulesTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.houseRulesValueLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "read") ?? "Read")"
        self.houseRulesValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        self.houseRulesValueLabel.textColor = Theme.PRIMARY_COLOR
        self.houseRulesValueLabel.font = UIFont(name: APP_FONT, size: 16.0)
        self.houseRulesBtn.setTitle("", for: .normal)
        
        
        self.cancellationPolicyTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "cancellationPolicy") ?? "Cancellation policy")"
        self.cancellationPolicyTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.cancellationPolicyTitleLabel.textColor = UIColor(named: "Title_Header")
        self.cancellationPolicyTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.cancellationPolicyValueLabel.text = self.viewModel?.viewListingArray.listingData?.cancellation?.policyName ?? "-"
        self.cancellationPolicyValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        self.cancellationPolicyValueLabel.textColor = Theme.PRIMARY_COLOR
        self.cancellationPolicyValueLabel.font = UIFont(name: APP_FONT, size: 16.0)
        self.cancellationPolicyBtn.setTitle("", for: .normal)
        
        
        self.availabilityTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "availability") ?? "Availability")"
        self.availabilityTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.availabilityTitleLabel.textColor = UIColor(named: "Title_Header")
        self.availabilityTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.availabilityValueLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "check") ?? "Check")"
        self.availabilityValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        self.availabilityValueLabel.textColor = Theme.PRIMARY_COLOR
        self.availabilityValueLabel.font = UIFont(name: APP_FONT, size: 16.0)
        self.availabilityBtn.setTitle("", for: .normal)
        
        
        self.contactHostTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "contacthost") ?? "Contact host")"
        self.contactHostTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.contactHostTitleLabel.textColor = UIColor(named: "Title_Header")
        self.contactHostTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.contactHostValueLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "message") ?? "Message")"
        self.contactHostValueLabel.textAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        self.contactHostValueLabel.textColor = Theme.PRIMARY_COLOR
        self.contactHostValueLabel.font = UIFont(name: APP_FONT, size: 16.0)
        self.contactHostBtn.setTitle("", for: .normal)
        
        if(Utility.shared.getCurrentUserID() != nil && ("\(Utility.shared.getCurrentUserID()!)" == "\(self.viewModel?.viewListingArray.userId ?? "")"))
        {
            contactHostView.isHidden = true
        }
        else {
            
            contactHostView.isHidden = false
        }
    }
    
    @IBAction func onClickStaticMapBtn(_ sender: UIButton) {
        if let viewListArray = viewModel?.viewListingArray{
            let mapPageObj = MapPageVC()
            mapPageObj.mapArray = viewListArray
            mapPageObj.modalPresentationStyle = .fullScreen
            self.present(mapPageObj, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickHouseRulesBtn(_ sender: UIButton) {
        let houserulesObj = HouseRulesVC()
        houserulesObj.houserulesArray = self.viewModel?.viewListingArray.houseRules! as! [ViewListingDetailsQueryy.Data.ViewListing.Result.HouseRule]
        houserulesObj.titleString = "\((Utility.shared.getLanguage()?.value(forKey:"houserules"))!)"
        houserulesObj.modalPresentationStyle = .fullScreen
        self.present(houserulesObj, animated: true, completion: nil)
    }
    @IBAction func onClickCancellationPolicyBtn(_ sender: UIButton) {
        let cancellationObj = CancellationVC()
       
        if let policy = (viewModel?.viewListingArray.listingData?.cancellation?.policyName!) {
            Utility.shared.cancelpolicy = policy
            cancellationObj.cancelpolicy = policy
        }
        if((viewModel?.viewListingArray.listingData?.cancellation?.policyContent!) != nil)
        {
            cancellationObj.cancelpolicy_content = (viewModel?.viewListingArray.listingData?.cancellation?.policyContent!)!
        }
     
        cancellationObj.modalPresentationStyle = .fullScreen
        self.present(cancellationObj, animated: true, completion: nil)
    }
    @IBAction func onClickAvailabilityBtn(_ sender: UIButton) {
        
        
        
        if(Utility.shared.getCurrentUserID() != nil && ("\(Utility.shared.getCurrentUserID()!)" == "\(self.viewModel?.viewListingArray.userId ?? "")"))
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"ownbookalert"))!)")
            return
        }
        Utility.shared.fullcheckBlockedDateMonth.removeAllObjects()
        Utility.shared.blocked_date_month.removeAllObjects()
        if let blockedDates = self.viewModel?.viewListingArray.blockedDates{
            for i in blockedDates
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
                    Utility.shared.fullcheckBlockedDateMonth.add("\(date)")
                }
            }
        }
        
        if let blockedDates = self.viewModel?.viewListingArray.fullBlockedDates{
            for i in blockedDates
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
        }
        
        if let checkInDates = self.viewModel?.viewListingArray.checkInBlockedDates{
            Utility.shared.checkedInDates.removeAllObjects()
            for i in checkInDates{
                let timestamp = i?.blockedDates
                let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                let dateFormatter = DateFormatter()
               
                dateFormatter.dateFormat = "dd-LL-yyyy"
                
                Utility.shared.checkedInDates.add(dateFormatter.string(from: newTime))
            }
        }
        
        if let minstay = (viewModel?.viewListingArray.listingData?.minNight!) {
            Utility.shared.minimumstay = minstay }
        Utility.shared.isfromcheckingPage = true
        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: self.viewModel?.selectedStartDate, dateTo: self.viewModel?.selectedEndDate)
        datePickerViewController.isFromFilter = false
        datePickerViewController.delegate = self
        if let viewListArray = self.viewModel?.viewListingArray{
            datePickerViewController.viewListingArray = viewListArray
        }
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    @IBAction func onClickContactHostBtn(_ sender: UIButton) {
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
                
                contactpageObj.currency_Dict = Utility.shared.currency_Dict
                
                if let viewListArray = self.viewModel?.viewListingArray{
                    contactpageObj.viewListingArray = viewListArray
                }
                contactpageObj.currencyvalue_from_API_base = viewModel?.currencyvalue_from_API_base ?? ""
                
                Utility.shared.booking_message = ""
                
                contactpageObj.selectedStartDate = viewModel?.selectedStartDate
                contactpageObj.selectedEndDate = viewModel?.selectedEndDate
                
                if let getBillArray = self.viewModel?.getbillingArray{
                    contactpageObj.getbillingArray = getBillArray
                }
                contactpageObj.delegate = self
                contactpageObj.modalPresentationStyle = .fullScreen
                self.present(contactpageObj, animated: true, completion: nil)
            }
        }
        else
        {
            self.offlineView.isHidden = false
        }
    }
    
    @IBAction func onClickCheckAvailabilityBtn(_ sender: UIButton) {
        let btnsendtag: UIButton = sender as! UIButton
        if(self.viewModel?.viewListingArray.userId != nil)
        {
            if(Utility.shared.getCurrentUserID() != nil && ("\(Utility.shared.getCurrentUserID()!)" == "\(self.viewModel?.viewListingArray.userId ?? "")"))
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"ownbookalert"))!)")
            }
            else if(self.viewModel?.viewListingArray.listingData?.maxDaysNotice == "unavailable")
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"listunavailablebook"))!)")
            }
            else{
                
                if(btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"checkavailability"))!)")
                {
                    
                    if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
                    {
                        let welcomeObj = WelcomePageVC()
                        welcomeObj.modalPresentationStyle = .fullScreen
                        self.present(welcomeObj, animated:false, completion: nil)
                        
                    }
                    else
                    {
                        Utility.shared.blocked_date_month.removeAllObjects()
                        
                        if let blockedDates = self.viewModel?.viewListingArray.fullBlockedDates{
                            for i in blockedDates
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
                        }
                        
                        
                        Utility.shared.fullcheckBlockedDateMonth.removeAllObjects()
                        
                        if let blockedDates = self.viewModel?.viewListingArray.blockedDates{
                            for i in blockedDates
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
                                    Utility.shared.fullcheckBlockedDateMonth.add("\(date)")
                                }
                            }
                        }
                        
                        if let checkInDates = self.viewModel?.viewListingArray.checkInBlockedDates{
                            Utility.shared.checkedInDates.removeAllObjects()
                            for i in checkInDates{
                                let timestamp = i?.blockedDates
                                let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                                let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                                let dateFormatter = DateFormatter()
                               
                                dateFormatter.dateFormat = "dd-LL-yyyy"
                                
                                Utility.shared.checkedInDates.add(dateFormatter.string(from: newTime))
                            }
                        }
                        
                        if let minstay = (self.viewModel?.viewListingArray.listingData?.minNight!) {
                            Utility.shared.minimumstay = minstay
                        }
                        Utility.shared.isfromcheckingPage = true
                        
                        Utility.shared.maximum_days_notice = Utility.shared.maximum_notice_period(maximumnoticeperiod: (self.viewModel?.viewListingArray.listingData?.maxDaysNotice!)!)!
                        let datePickerViewController = AirbnbDatePickerViewController(dateFrom: self.viewModel?.selectedStartDate, dateTo: self.viewModel?.selectedEndDate)
                        datePickerViewController.isFromFilter = false
                        datePickerViewController.delegate = self
                        if let viewListArray = self.viewModel?.viewListingArray{
                            datePickerViewController.viewListingArray = viewListArray
                        }
                        let navigationController = UINavigationController(rootViewController: datePickerViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                    }
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
                            if(self.viewModel?.getbillingArray.checkIn != nil)
                            {
                                let bookobj = RequestbookVC()
                                Utility.shared.booking_message = ""
                                bookobj.isFromMessage  = false
                                bookobj.navigationControllerReference = self.navigationController
                                if let viewListArray = self.viewModel?.viewListingArray{
                                    bookobj.viewListingArray = viewListArray
                                }
                                bookobj.currency_Dict = Utility.shared.currency_Dict
                                bookobj.selectedStartDate = self.viewModel?.selectedStartDate
                                bookobj.selectedEndDate = self.viewModel?.selectedEndDate
                                bookobj.currencyvalue_from_API_base = self.viewModel?.currencyvalue_from_API_base ?? ""
                                if(bookobj.getbillingArray.checkIn == nil)
                                {
                                    if let getBillArray = self.viewModel?.getbillingArray{
                                        bookobj.getbillingArray = getBillArray
                                    }
                                }
                                bookobj.delegate = self
                                bookobj.modalPresentationStyle = .fullScreen
                                
//                                let navigationVC = UINavigationController(rootViewController: bookobj)
//                                navigationVC.isNavigationBarHidden = true
//                                navigationVC.modalPresentationStyle = .fullScreen
//                                self.present(navigationVC, animated: true, completion: nil)
                                
                                self.present(bookobj, animated: true, completion: nil)
                            }
                            else
                            {
                                let fmt = DateFormatter()
                              
                                fmt.dateFormat = "yyyy-MM-dd"
                                self.viewModel?.billingListAPICall(startDate: Utility.shared.selectedstartDate, endDate: Utility.shared.selectedEndDate, completion: {
                                    value in
                                    if !value.isEmpty{
                                        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!): \(value)")
                                        attributedString.setColor(color:  UIColor(named: "Title_Header")!, forText:"\(value)")
                                        attributedString.setColor(color:Theme.SECONDARY_COLOR, forText:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!):")
                                        self.infoView.isHidden = false
                                        self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"checkavailability") ?? "Check Availability")", for: .normal)
                                        self.infoTitleLabel.attributedText = attributedString
                                        
                                    }
                                    else {
                                        let bookobj = RequestbookVC()
                                        bookobj.isFromMessage  = false
                                        Utility.shared.booking_message = ""
                                        if let viewListArray = self.viewModel?.viewListingArray{
                                            bookobj.viewListingArray = viewListArray
                                        }
                                        bookobj.currency_Dict = Utility.shared.currency_Dict
                                        bookobj.selectedStartDate = self.viewModel?.selectedStartDate
                                        bookobj.selectedEndDate = self.viewModel?.selectedEndDate
                                        bookobj.currencyvalue_from_API_base = self.viewModel?.currencyvalue_from_API_base ?? ""
                                        if(bookobj.getbillingArray.checkIn == nil)
                                        {
                                            if let getBillArray = self.viewModel?.getbillingArray{
                                                bookobj.getbillingArray = getBillArray
                                            }
                                        }
                                        bookobj.delegate = self
                                        
//                                        let navigationVC = UINavigationController(rootViewController: bookobj)
//                                        navigationVC.isNavigationBarHidden = true
//                                        navigationVC.modalPresentationStyle = .fullScreen
//                                        self.present(navigationVC, animated: true, completion: nil)
                                        
                                        bookobj.modalPresentationStyle = .fullScreen
                                        self.present(bookobj, animated: true, completion: nil)
                                        
                                    }
                                })
                            }
                        }
                    }
                    else
                    {
                        self.offlineView.isHidden = false
                    }
                    
                    
                }
            }
            
        }
        
    }
   
    @IBAction func onClickBackBtn(_ sender: UIButton) {

        self.dismiss(animated:false, completion: nil)
    }
    @IBAction func onClickInfoCloseBtn(_ sender: UIButton) {
        self.infoView.isHidden = true
    }
    @IBAction func onClickShareBtn(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
           
            if let listArray = viewModel?.viewListingArray{
                let pageObj = ShareProductVC()
                pageObj.viewListingArray = listArray
                pageObj.modalPresentationStyle = .fullScreen
                self.present(pageObj, animated: true, completion: nil)
               
            }
        }else{
            self.offlineView.isHidden = false
        }
    }
    @IBAction func onClickLikeBtn(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
            }else{
                if viewModel?.viewListingArray.id != nil {
                    let headerView = WhishlistPageVC()
                    headerView.listID = viewModel?.viewListingArray.id ?? 0
                    headerView.listimage = viewModel?.viewListingArray.listPhotoName ?? ""
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: true, completion: nil)
                }
            }
        }else{
            self.offlineView.isHidden = false
        }
    }
    @IBAction func onClickReportBtn(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
           
            if((Utility.shared.getCurrentUserToken()) == nil || (Utility.shared.getCurrentUserToken()) == "")
            {
                let welcomeObj = WelcomePageVC()
                welcomeObj.modalPresentationStyle = .fullScreen
                self.present(welcomeObj, animated:false, completion: nil)
            }
            else
            {
                
                let reportPageObj = ReportuserPage()
                reportPageObj.profileid = self.viewModel?.viewListingArray.user?.profile?.profileId ?? 0
                reportPageObj.modalPresentationStyle = .fullScreen
                self.present(reportPageObj, animated: false, completion: nil)
            }
           
        }else{
            self.offlineView.isHidden = false
        }
    }
    @IBAction func onClickViewProfile(_ sender: UIButton) {
        let editprofileobj = HostProfileViewPage()
        editprofileobj.profileid = viewModel?.viewListingArray.user?.profile?.profileId ?? 0
        editprofileobj.profilename = viewModel?.viewListingArray.user?.profile?.firstName ?? ""
        editprofileobj.modalPresentationStyle = .fullScreen
        self.present(editprofileobj, animated: true, completion: nil)
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
    
    
    func checkApolloStatus()
    {
        if((Utility.shared.getCurrentUserToken()) != nil)
        {
            viewModel?.apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
        }
        else{
            viewModel?.apollo_headerClient = ApolloClient(url: URL(string:graphQLEndpoint)!)
        }
        
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
            self.scrollView.isHidden = true
            self.topHeaderStackView.isHidden = true
            self.lottieView.isHidden = false
            viewModel?.viewDetailAPICall(listid: viewModel?.listID ?? 0, completion: { resultValue in
                resultValue
                self.viewListValueUpdates(result: resultValue)
            })
        }else{
            self.lottieView.isHidden = true
            self.scrollView.isHidden = true
            self.topView.isHidden = false
            self.topHeaderStackView.isHidden = true
            self.offlineView.isHidden = false
        }
    }
    
    
}


extension UpdatedViewListing {
    func viewListValueUpdates(result: GraphQLResult<ViewListingDetailsQueryy.Data>?){
        guard (result?.data?.viewListing?.status) == 200 else{
            self.backBtn.backgroundColor = UIColor.clear
            self.bottomView.isHidden = true
            self.scrollView.isHidden = true
            self.noListView.isHidden = false
            self.topView.isHidden = false
            self.topHeaderStackView.isHidden = true
            return
        }
        
        
        if result?.data?.viewListing?.status == 200 {
            self.viewModel?.viewListingArray = (result?.data?.viewListing?.results)!
            if(self.viewModel?.viewListingArray.listingData != nil)
            {
                viewModel?.setupTestData()
                if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                    let from_currency = (self.viewModel?.viewListingArray.listingData?.currency!)
                    let currency_amount = (self.viewModel?.viewListingArray.listingData?.basePrice != nil ? (self.viewModel?.viewListingArray.listingData?.basePrice?.clean) : "0")
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:self.viewModel?.currencyvalue_from_API_base ?? "", fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:Double(currency_amount!) ?? 0.0)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    self.listPriceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 18),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    
                    let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: " / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    self.listPriceLabel.attributedText = attributedString
                }
                else
                {
                    let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.viewModel?.currencyvalue_from_API_base ?? "")
                    let from_currency = (self.viewModel?.viewListingArray.listingData?.currency!)
                    let currency_amount = (self.viewModel?.viewListingArray.listingData?.basePrice != nil ? (self.viewModel?.viewListingArray.listingData?.basePrice?.clean) : "0")
                    let price_value = Utility.shared.getCurrencyRate(basecurrency:self.viewModel?.currencyvalue_from_API_base ?? "", fromCurrency:from_currency!, toCurrency:self.viewModel?.currencyvalue_from_API_base ?? "", CurrencyRate:Utility.shared.currency_Dict, amount:Double(currency_amount!) ?? 0.0)
                    let restricted_price =  Double(String(format: "%.2f",price_value))
                    self.listPriceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 18),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    
                    let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                    ]
                    let attributedString2 = NSMutableAttributedString(string: " / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    self.listPriceLabel.attributedText = attributedString
                }
                
                if let val = (self.viewModel?.viewListingArray.listingData?.cancellation?.policyName!)
                {
                    Utility.shared.cancelpolicy = val
                }
                if let value = (self.viewModel?.viewListingArray.listingData?.cancellation?.policyContent!)
                {
                    Utility.shared.cancelpolicy_content = value
                }
                
            }else{
                self.backBtn.backgroundColor = UIColor.clear
                self.bottomView.isHidden = true
            }
            
            let value1 = Float(self.viewModel?.viewListingArray.reviewsCount ?? 0)
            let value2 = Float(self.viewModel?.viewListingArray.reviewsStarRating ?? 0)
            if(value2 != 0.0){
                let reviewcount = (value2/value1)
                self.listRatingLabel.text = "\(Int(reviewcount.rounded()))"
                if(self.selectedDateBtn.isHidden) {
                    
                    self.listRatingView.isHidden = false
                    self.centerConstant.constant = -12
                }
            }
            else{
                self.listRatingLabel.text = "0.0"
                self.listRatingView.isHidden = true
                self.centerConstant.constant = 0
            }
            self.viewModel?.reviewcountAPICall(profileid: (self.viewModel?.viewListingArray.user?.profile?.profileId ?? 0), completion: {
                value in
            })
            self.viewModel?.getreviewAPICall(listId: viewModel?.listID ?? 0, hostId: self.viewModel?.viewListingArray.userId ?? "0", completion: {
                value in
            })
            self.viewModel?.similarListingAPICall(lat:self.viewModel?.viewListingArray.lat ?? 0.0, lng: self.viewModel?.viewListingArray.lng ?? 0.0, lisId: self.viewModel?.viewListingArray.id ?? 0, completion: {
                value in
                if value {
                    self.similarListingCollectionView.reloadData()
                    
                    if ((self.viewModel?.similarlistingArray.count ?? 0) > 0){
                        self.similarListingView.isHidden = false
                        self.similarListHeightConstraint.constant = 290
                    }else{
                        self.similarListingView.isHidden = true
                        self.similarListHeightConstraint.constant = -50
                    }
                }
            })
            self.viewModel?.getPropertyReviewsAPICall(lisId: self.viewModel?.viewListingArray.id ?? 0, completion: {
                value in
                if value{
                    self.reviewTableView.reloadData()
                    
                    if ((self.viewModel?.propertyReviewsCount ?? 0) > 0){
                        self.reviewView.isHidden = false
                        self.reviewViewHeightConstraint.constant = ((self.viewModel?.propertyReviewsCount ?? 0) > 1) ? 350 : 300
                    }else{
                        self.reviewView.isHidden = true
                        self.reviewViewHeightConstraint.constant = 0
                    }
                }
            })
            
            if let amenitiesCount = self.viewModel?.viewListingArray.userAmenities?.count, amenitiesCount > 0{
                self.amenitiesTableView.isHidden = false
                if self.isShowMoreAmenitiesClicked{
                    self.amenitiesTableHeightConstraint.constant = CGFloat((amenitiesCount * 34)+110)
                }else{
                    self.amenitiesTableHeightConstraint.constant = amenitiesCount > 3 ? CGFloat((3 * 34) + 110) : CGFloat((amenitiesCount * 34)+50)
                }
                self.amenitiesTableView.reloadData()
            }else{
                self.amenitiesTableView.isHidden = true
                self.amenitiesTableHeightConstraint.constant = 0
            }
            
            if let userSpaceCount = self.viewModel?.viewListingArray.userSpaces?.count, userSpaceCount > 0{
                self.userSpacesTableView.isHidden = false
                if self.isShowMoreUserSpaceClicked{
                    self.userSpacesHeightConstraint.constant = CGFloat((userSpaceCount * 34)+110 )
                }else{
                    self.userSpacesHeightConstraint.constant = userSpaceCount > 3 ? CGFloat((3 * 34) + 110) : CGFloat((userSpaceCount * 34)+50)
                }
                self.userSpacesTableView.reloadData()
            }else{
                self.userSpacesTableView.isHidden = true
                self.userSpacesHeightConstraint.constant = 0
            }
            
            if let safetyAmenityCount = self.viewModel?.viewListingArray.userSafetyAmenities?.count, safetyAmenityCount > 0{
                self.safetyAmenitiesTableView.isHidden = false
                if self.isShowMoreSafetyAmenitiesClicked{
                    self.safetyAmenitiesHeightConstriant.constant = CGFloat((safetyAmenityCount * 34)+110 )
                }else{
                    self.safetyAmenitiesHeightConstriant.constant = safetyAmenityCount > 3 ? CGFloat((3 * 34) + 110) : CGFloat((safetyAmenityCount * 34)+50)
                }
                self.safetyAmenitiesTableView.reloadData()
            }else{
                self.safetyAmenitiesTableView.isHidden = true
                self.safetyAmenitiesHeightConstriant.constant = 0
            }
            
            self.viewModel?.viewListingArray.userBedsTypes = self.viewModel?.viewListingArray.userBedsTypes?.filter({ value in
                value != nil
            })
            
            if let safetyAmenityCount = self.viewModel?.viewListingArray.userBedsTypes?.count, safetyAmenityCount > 0{
                self.tblBeds.isHidden = false
                if self.isShowMoreBedsClicked{
                    self.tblBedsheight.constant = CGFloat((safetyAmenityCount * 34)+110 )
                }else{
                    self.tblBedsheight.constant = safetyAmenityCount > 3 ? CGFloat((3 * 34) + 110) : CGFloat((safetyAmenityCount * 34)+50)
                }
                self.tblBeds.reloadData()
            }else{
                self.tblBeds.isHidden = true
                self.tblBedsheight.constant = 0
            }
            
            self.lottieView.isHidden = true
            self.scrollView.isHidden = false
            self.topView.isHidden = false
            self.topHeaderStackView.isHidden = false
            self.bottomView.isHidden = false
            self.imgCollectionView.reloadData()
            self.configureLikeBtn()
            self.configureScrollViews()
            self.configureBottomView()
        }else{
            self.backBtn.backgroundColor = UIColor.clear
            self.bottomView.isHidden = true
        }
    }
}


extension UpdatedViewListing: WhishlistPageVCProtocol, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, SKPhotoBrowserDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.imgCollectionView{
            return (viewModel?.viewListingArray.listingPhotos?.count ?? 0) > 0 ? 1 : 0
        }else if collectionView == self.similarListingCollectionView{
            return self.viewModel?.similarlistingArray.count ?? 0
        }else{
            return self.viewModel?.propertyReviewArray.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.imgCollectionView{
            let cell: imageScrollCollectionView = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageScrollCollectionView", for: indexPath)as! imageScrollCollectionView
            
            let contentview = UIView()
            
            
            contentview.frame = CGRect(x: 0, y: 0, width:UIScreen.main.bounds.size.width, height:imgCollectionView.frame.size.height)
            let imageScroller = ImageScroller()
            imageScroller.frame = CGRect(x: 0, y: 0, width:UIScreen.main.bounds.size.width, height: imgCollectionView.frame.size.height)
            imageScroller.delegate = self
            imageScroller.isAutoScrollEnabled = false
            imageScroller.scrollTimeInterval = 2.0
            imageScroller.scrollView.bounces = false
            
            
            let array = self.viewModel?.viewListingArray.listingPhotos
            
            for j in array!
            {
                if(self.viewModel?.viewListingArray.listPhotoName == self.viewModel?.viewListingArray.listingPhotos?[0]?.name)
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
                
                imagePageControll.numberOfPages = self.filteredImageArray.count
                imagePageControll.radius = 5
                imagePageControll.padding = 8
                imagePageControll.inactiveTintColor = UIColor(named: "Review_Page_Line_Color")!
                imagePageControll.currentPageTintColor = Theme.PRIMARY_COLOR
                imagePageControll.inactiveTransparency = 1
              
                imagePageControll.tag = indexPath.row
            
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
            cell.contentView.addSubview(contentview)
            
            return cell
        }else if collectionView == self.similarListingCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellcustomUpdated", for: indexPath)as! customUpdatedCell
            
            cell.lineView.isHidden = true
            cell.heightConstant.constant = 170
            cell.imgTop.constant = 1
            
            var listTypeString = ""
            listTypeString = "\(self.viewModel?.similarlistingArray[indexPath.row].roomType ?? "")"
            if ((self.viewModel?.similarlistingArray[indexPath.row].beds ?? 0) > 1){
                listTypeString = listTypeString + " / " + "\(self.viewModel?.similarlistingArray[indexPath.row].beds ?? 0)" + " Beds"
            }else if ((self.viewModel?.similarlistingArray[indexPath.row].beds ?? 0) == 1){
                listTypeString = listTypeString + " / " + "\(self.viewModel?.similarlistingArray[indexPath.row].beds ?? 0)" + " Bed"
            }
            cell.listTypeLabel.text = listTypeString
            cell.listTypeLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            
            if let profImage = self.viewModel?.similarlistingArray[indexPath.row].listPhotoName {
                cell.imageView.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(String(describing: profImage))"),placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                cell.imageView.contentMode = .scaleAspectFill
            } else {
                cell.imageView.image = #imageLiteral(resourceName: "placeholderimg")
            }
            
            cell.listTitleLabel.text = self.viewModel?.similarlistingArray[indexPath.row].title ?? ""
            
            if(self.viewModel?.similarlistingArray[indexPath.row].bookingType != "instant") {
                cell.lightningImageView.isHidden = true
            }
            else {
                cell.lightningImageView.isHidden = false
            }
            
            
            if(self.viewModel?.similarlistingArray[indexPath.row].wishListStatus == false){
                cell.heartBtn.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
            }else{
                cell.heartBtn.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            }
            cell.heartBtn.isHidden = false
            cell.heartBtn.tag = indexPath.row
            cell.heartBtn.addTarget(self, action: #selector(likeBtnTapped), for: .touchUpInside)
            
            
            
            
            if(Utility.shared.getPreferredCurrency() != nil &&  Utility.shared.getPreferredCurrency() != "")
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode: Utility.shared.getPreferredCurrency()!)
                let from_currency = self.viewModel?.similarlistingArray[indexPath.row].listingData?.currency
                let currency_amount = self.viewModel?.similarlistingArray[indexPath.row].listingData?.basePrice != nil ? self.viewModel?.similarlistingArray[indexPath.row].listingData?.basePrice : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency: self.viewModel?.currencyvalue_from_API_base ?? "", fromCurrency:from_currency!, toCurrency:Utility.shared.getPreferredCurrency()!, CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.listPriceLabel.text =  "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 18),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                
                let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                let attributedString2 = NSMutableAttributedString(string: " / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                attributedString.append(attributedString2)
                
                cell.listPriceLabel.attributedText = attributedString
            }
            else
            {
                let currencysymbol = Utility.shared.getSymbol(forCurrencyCode:self.viewModel?.currencyvalue_from_API_base ?? "")
                let from_currency = self.viewModel?.similarlistingArray[indexPath.row].listingData?.currency
                let currency_amount = self.viewModel?.similarlistingArray[indexPath.row].listingData?.basePrice != nil ? self.viewModel?.similarlistingArray[indexPath.row].listingData?.basePrice : 0
                let price_value = Utility.shared.getCurrencyRate(basecurrency: self.viewModel?.currencyvalue_from_API_base ?? "", fromCurrency:from_currency!, toCurrency:self.viewModel?.currencyvalue_from_API_base ?? "", CurrencyRate:Utility.shared.currency_Dict, amount:currency_amount!)
                let restricted_price =  Double(String(format: "%.2f",price_value))
                cell.listPriceLabel.text = "\(currencysymbol!)\(restricted_price!.clean) / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")"
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_SEMIBOLD, size: 18),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                
                let attributedString = NSMutableAttributedString(string: "\(currencysymbol!)\(restricted_price!.clean)" , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_MEDIUM, size: 12),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "viewList_Title")
                ]
                let attributedString2 = NSMutableAttributedString(string: " / \(Utility.shared.getLanguage()?.value(forKey:"night") ?? "Night")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                attributedString.append(attributedString2)
                
                cell.listPriceLabel.attributedText = attributedString
            }
            
            
            let value1 = Float("\(self.viewModel?.similarlistingArray[indexPath.row].reviewsCount ?? 0)") ?? 0.0
            let value2 = Float("\(self.viewModel?.similarlistingArray[indexPath.row].reviewsStarRating ?? 0)") ?? 0.0
            if(value2 != 0.0){
                let divideValue = value2/value1
                cell.ratingLabel.text = "\(Int(divideValue.rounded()))"
                cell.ratingView.isHidden = false
               
            }else{
                cell.ratingLabel.text = "0.0"
                cell.ratingView.isHidden = true
             
            }
            
            return cell
        }else{
            let cell: reviewCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCollection", for: indexPath) as! reviewCollectionCell
            
            cell.ratingBtn.isHidden = true
            if !(self.viewModel?.propertyReviewArray[indexPath.row].isAdmin ?? true){
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14),
                    NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                ]
                
                let attributedString = NSMutableAttributedString(string: " \(Utility.shared.getLanguage()?.value(forKey: "review") ?? "Review")" , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributedString2 = NSMutableAttributedString(string: "\(self.viewModel?.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.firstName ?? "")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                let attributes3 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributedString3 = NSMutableAttributedString(string: "'s", attributes: attributes3 as [NSAttributedString.Key : Any])
                
                attributedString2.append(attributedString3)
                attributedString2.append(attributedString)
                
                cell.titleLabel.attributedText = attributedString2
                cell.titleLabel.isHidden = false
                
                
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
                
                cell.imgView.isUserInteractionEnabled = false
                cell.titleLabel.isUserInteractionEnabled = false
            }
            let reviewContent = self.viewModel?.propertyReviewArray[indexPath.row].reviewContent ?? ""
            let str = reviewContent.replacingOccurrences(of: "\\s+", with: " " , options: .regularExpression)
            
            if str.count > 50{
                let to = str.index(str.startIndex, offsetBy: 50, limitedBy: str.endIndex)
                
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14),
                    NSAttributedString.Key.foregroundColor:  UIColor(named: "Title_Header")
                ]
                
                let attributedString = NSMutableAttributedString(string: "\(str.substring(to: to!))..." , attributes: attributes as [NSAttributedString.Key : Any])
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 14),
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
            cell.imgView.contentMode = .scaleAspectFill
            cell.imgView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.viewModel?.propertyReviewArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
            let value1 = Float("\(self.viewModel?.propertyReviewArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
            let value2 = Float("\(self.viewModel?.propertyReviewArray[indexPath.row].rating ?? 0.0)") ?? 0.0
            cell.ratingView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
            if(value2 != 0.0){
              
                if (value1 != 0.0) {
                    let divideValue = value2/value1
                    cell.ratingBtn.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                    cell.ratingView.rating = Double((divideValue.rounded()))
                }
                else {
                    cell.ratingBtn.setTitle(" \(Int(value2)) ", for: .normal)
                    cell.ratingView.rating = Double(value2)
                }
            }else{
                cell.ratingBtn.isHidden = true
                cell.ratingView.rating = 0
                cell.ratingBtn.setTitle(" 0.0 ", for: .normal)
                
            }
          
            cell.reviewDateLabel.text = Utility.shared.convertTimeStampToString(timestamp: self.viewModel?.propertyReviewArray[indexPath.row].createdAt ?? "", toFormat: "MMMM, yyyy")
            
            cell.readMoreBtn.isHidden = true
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.imgCollectionView{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }else if collectionView == self.similarListingCollectionView{
            return CGSize(width:250, height: 290)
        }else{
            return CGSize(width: 290, height: 180)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.imgCollectionView{
            if let imagePhotos = viewModel?.images{
                let browser = SKPhotoBrowser(photos: imagePhotos, initialPageIndex: indexPath.row)
                browser.delegate = self
                present(browser, animated: true, completion: {})
            }
        }else if collectionView == self.similarListingCollectionView{
            let viewListing = UpdatedViewListing()
            viewListing.listID = self.viewModel?.similarlistingArray[indexPath.row].id ?? 0
            Utility.shared.unpublish_preview_check = false
            viewListing.modalPresentationStyle = .fullScreen
            self.present(viewListing, animated: true, completion: nil)
        }
    }
    
    func APIMethodCall(listId:Int, status:Bool) {
        
    }
    
    func didupdateWhishlistStatus(status: Bool) {
    
        self.lottieView.isHidden = false
        delegate?.UpdateWhishlistCall(listId: viewModel?.listID ?? 0, status: status)
        viewModel?.viewDetailAPICall(listid: viewModel?.listID ?? 0, completion: { resultValue in
            self.viewListValueUpdates(result: resultValue)
        })
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
                if ((self.viewModel?.similarlistingArray.count ?? 0) > 0) {
                    let headerView = WhishlistPageVC()
                    headerView.listID = self.viewModel?.similarlistingArray[sender.tag].id ?? 0
                    headerView.listimage = self.viewModel?.similarlistingArray[sender.tag].listPhotoName ?? "-"
                    headerView.senderID = sender.tag
                    headerView.delegate = self
                    headerView.modalPresentationStyle = .overFullScreen
                    self.present(headerView, animated: false, completion: nil)
                }
            }
        }else{
            self.offlineView.isHidden = false
        }
    }
}


extension UpdatedViewListing: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.reviewTableView{
            return ((viewModel?.propertyReviewsCount ?? 0) > 0) ? 1 : 0
        }else if tableView == self.amenitiesTableView{
            if self.isShowMoreAmenitiesClicked{
                return self.viewModel?.viewListingArray.userAmenities?.count ?? 0
            }else{
                return ((self.viewModel?.viewListingArray.userAmenities?.count ?? 0) > 3 ? 3 : (self.viewModel?.viewListingArray.userAmenities?.count ?? 0))
            }
        }else if tableView == self.userSpacesTableView{
            if self.isShowMoreUserSpaceClicked{
                return self.viewModel?.viewListingArray.userSpaces?.count ?? 0
            }else{
                return ((self.viewModel?.viewListingArray.userSpaces?.count ?? 0) > 3 ? 3 : (self.viewModel?.viewListingArray.userSpaces?.count ?? 0))
            }
        }else if tableView == self.safetyAmenitiesTableView{
            if self.isShowMoreSafetyAmenitiesClicked{
                return self.viewModel?.viewListingArray.userSafetyAmenities?.count ?? 0
            }else{
                return ((self.viewModel?.viewListingArray.userSafetyAmenities?.count ?? 0) > 3 ? 3 : (self.viewModel?.viewListingArray.userSafetyAmenities?.count ?? 0))
            }
            
        }
        else if tableView == self.tblBeds{
            if self.isShowMoreBedsClicked{
                return self.viewModel?.viewListingArray.userBedsTypes?.count ?? 0
            }else{
                return ((self.viewModel?.viewListingArray.userBedsTypes?.count ?? 0) > 3 ? 3 : (self.viewModel?.viewListingArray.userBedsTypes?.count ?? 0))
            }
            
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.reviewTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "updatedreviewCells", for: indexPath) as! UpdatedReviewCells
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = UIColor.clear
            let flowLayout = UICollectionViewFlowLayout()
            
            flowLayout.scrollDirection = .horizontal
            
            cell.collectionView.collectionViewLayout = flowLayout
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.register(UINib(nibName: "reviewCollectionCell", bundle: nil), forCellWithReuseIdentifier: "reviewCollection")
            cell.collectionView.backgroundColor =  UIColor.clear
            DispatchQueue.main.async {
                cell.collectionView.reloadData()
            }
            
            
            let value1 = Double(self.viewModel?.viewListingArray.reviewsCount ?? 0)
            let value2 = Double(self.viewModel?.viewListingArray.reviewsStarRating ?? 0)
            var reviewcount = 0
            if(value2 != 0.0){
                reviewcount = Int(round(value2/value1))
            }
            else{
                reviewcount = 0
            }
            
            let totalReviews = self.viewModel?.propertyReviewsCount
            
            cell.ratingTitle.text = "\(reviewcount) / \(Utility.shared.getLanguage()?.value(forKey: "reviews") ?? "Reviews") (\(totalReviews ?? 0))"
            self.reviewTitle = cell.ratingTitle.text ?? ""
            cell.showAllReviewsBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Show_all") ?? "Show all") \(totalReviews ?? 0) \(Utility.shared.getLanguage()?.value(forKey: "reviewssmall") ?? "reviews")", for: .normal)
            
            if (self.viewModel?.propertyReviewsCount ?? 0) > 1{
                cell.showAllReviewsBtn.isHidden = false
                cell.showAllBtnHeightConstraint.constant = 45
                cell.showAllReviewsBtn.addTarget(self, action: #selector(propertyReviewsReadALLBtnTapped), for: .touchUpInside)
            }else{
                cell.showAllReviewsBtn.isHidden = true
                cell.showAllBtnHeightConstraint.constant = 0
            }
            
            return cell
        }else if tableView == self.amenitiesTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.viewModel?.viewListingArray.userAmenities?[indexPath.row]?.itemName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            
            
            if let imageName = self.viewModel?.viewListingArray.userAmenities?[indexPath.row]?.image{
                cell.amenityImage.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageName))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                    cell.amenityImage.image = image?.withRenderingMode(.alwaysTemplate)
                })
                
            }else{
                cell.amenityImage.image = UIImage(named: "amenitiesImage")
            }
            cell.amenityImage.tintColor =  UIColor(named: "Title_Header")
            cell.amenityLblLeadingConstraint.constant = 12
            return cell
        }else if tableView == self.userSpacesTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.viewModel?.viewListingArray.userSpaces?[indexPath.row]?.itemName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            if let imageName = self.viewModel?.viewListingArray.userSpaces?[indexPath.row]?.image{
                cell.amenityImage.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageName))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                    cell.amenityImage.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.amenityImage.image = UIImage(named: "amenitiesImage")
            }
            cell.amenityImage.tintColor = UIColor(named: "Title_Header")
            
            if(Utility.shared.isRTLLanguage()) {
                cell.amenityImage.performRTLTransform()
            }
            cell.amenityLblLeadingConstraint.constant = 12
            return cell
        }else if tableView == self.safetyAmenitiesTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.viewModel?.viewListingArray.userSafetyAmenities?[indexPath.row]?.itemName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            if let imageName = self.viewModel?.viewListingArray.userSafetyAmenities?[indexPath.row]?.image{
                cell.amenityImage.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageName))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                    cell.amenityImage.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.amenityImage.image = UIImage(named: "amenitiesImage")
            }
            
            
            
            cell.amenityImage.tintColor =  UIColor(named: "Title_Header")
            cell.amenityLblLeadingConstraint.constant = 12
            return cell
        }
        
        else if tableView == self.tblBeds{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath) as! AmenityDetailCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.contentView.backgroundColor = UIColor.clear
         
            if let itemName = self.viewModel?.viewListingArray.userBedsTypes?[indexPath.row]?.bedName{
                cell.amenityLabel.text = "\(itemName): \(self.viewModel?.viewListingArray.userBedsTypes?[indexPath.row]?.bedCount ?? 0)"
            }else{
                cell.amenityLabel.text = "Bed: \(self.viewModel?.viewListingArray.userBedsTypes?[indexPath.row]?.bedCount ?? 0)"
            }
            
            cell.amenityImage.image = #imageLiteral(resourceName: "bullet")
            if(Utility.shared.isRTLLanguage()) {
                cell.amenityImage.performRTLTransform()
            }
            cell.amenityLblLeadingConstraint.constant = 12
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "updatedreviewCells", for: indexPath) as! UpdatedReviewCells
            cell.contentView.backgroundColor = UIColor.clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.amenitiesTableView{
            return 25
        }else if tableView == self.userSpacesTableView{
            return 25
        }else if tableView == self.safetyAmenitiesTableView{
            return 25
        }
        else if tableView == self.tblBeds{
            return 25
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.amenitiesTableView || tableView == self.userSpacesTableView || tableView == self.safetyAmenitiesTableView || tableView == tblBeds {
           
            let headerView = UIView(frame: CGRect(x:0, y:-10, width:
                                                    tableView.frame.size.width, height: 20))
            headerView.backgroundColor = UIColor.clear
            let headerLabel = UILabel(frame: CGRect(x:0, y:0, width:
                                                        tableView.frame.size.width, height: 20))
            headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size:16)
            headerLabel.textColor =  UIColor(named: "Title_Header")
            headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
            headerLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            headerView.addSubview(headerLabel)
            
            return headerView
        }else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.amenitiesTableView{
            return "\(Utility.shared.getLanguage()?.value(forKey: "whatplaceoffer") ?? "What the place offer")"
        }else if tableView == self.userSpacesTableView{
            return "\(Utility.shared.getLanguage()?.value(forKey: "userspace") ?? "Shared spaces")"
        }else if tableView == self.safetyAmenitiesTableView{
            return "\((Utility.shared.getLanguage()?.value(forKey:"usersafety"))!)"
        }
        else if tableView == self.tblBeds{
            return "\((Utility.shared.getLanguage()?.value(forKey:"bedtypes"))!)"
        }
        else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if(tableView == self.amenitiesTableView) {
            if(self.viewModel?.viewListingArray.userAmenities != nil) {
                if((self.viewModel?.viewListingArray.userAmenities!.count)! > 3) {
                    return 70
                }
                else {
                    return 20
                }
            }
            return 0
        }
        else if(tableView == self.userSpacesTableView) {
            if(self.viewModel?.viewListingArray.userSpaces != nil) {
                if((self.viewModel?.viewListingArray.userSpaces!.count)! > 3) {
                    return 70
                }
                else {
                    return 20
                }
            }
            return 0
        }
        else if(tableView == self.safetyAmenitiesTableView) {
            if(self.viewModel?.viewListingArray.userSafetyAmenities != nil) {
                if((self.viewModel?.viewListingArray.userSafetyAmenities!.count)! > 3) {
                    return 70
                }
                else {
                    return 20
                }
            }
            return 0
        }
        else if(tableView == self.tblBeds) {
            if(self.viewModel?.viewListingArray.userBedsTypes != nil) {
                if((self.viewModel?.viewListingArray.userBedsTypes!.count)! > 3) {
                    return 70
                }
                else {
                    return 20
                }
            }
            return 0
        }
        
        
        
        return 0
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.amenitiesTableView  {
            let amenitiesCount = self.viewModel?.viewListingArray.userAmenities?.count
            if (amenitiesCount! > 3) {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let showmore = UIButton()
                showmore.frame = CGRect(x:0, y: 10, width:tableView.bounds.size.width, height:45)
                showmore.backgroundColor = UIColor(named: "colorController")
                showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
                showmore.layer.cornerRadius = showmore.frame.size.height/2
                showmore.clipsToBounds = true
                showmore.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                showmore.layer.borderWidth = 1.0
                showmore.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
                showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
                if tableView == self.amenitiesTableView{
                    showmore.tag = 1
                }else if tableView == self.userSpacesTableView{
                    showmore.tag = 2
                }else{
                    showmore.tag = 3
                }
                
                showmore.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
                footerView.addSubview(showmore)
                
                let lineLabel = UILabel(frame: CGRect(x:0, y: 69, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor =   UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            else {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let lineLabel = UILabel(frame: CGRect(x:0, y:19, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor =  UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
        }
        
        else if( tableView == self.userSpacesTableView) {
            let amenitiesCount = self.viewModel?.viewListingArray.userSpaces?.count
            if (amenitiesCount! > 3) {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let showmore = UIButton()
                showmore.frame = CGRect(x:0, y: 10, width:tableView.bounds.size.width, height:45)
                showmore.backgroundColor = UIColor(named: "colorController")
                showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
                showmore.layer.cornerRadius = showmore.frame.size.height/2
                showmore.clipsToBounds = true
                showmore.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                showmore.layer.borderWidth = 1.0
                showmore.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
                showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
                if tableView == self.amenitiesTableView{
                    showmore.tag = 1
                }else if tableView == self.userSpacesTableView{
                    showmore.tag = 2
                }else{
                    showmore.tag = 3
                }
                
                showmore.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
                footerView.addSubview(showmore)
                
                let lineLabel = UILabel(frame: CGRect(x:0, y:69, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            else {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let lineLabel = UILabel(frame: CGRect(x:0, y:19, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            
        }
        
        else if( tableView == self.userSpacesTableView) {
            let amenitiesCount = self.viewModel?.viewListingArray.userSpaces?.count
            if (amenitiesCount! > 3) {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let showmore = UIButton()
                showmore.frame = CGRect(x:0, y: 10, width:tableView.bounds.size.width, height:45)
                showmore.backgroundColor = UIColor(named: "colorController")
                showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
                showmore.layer.cornerRadius = showmore.frame.size.height/2
                showmore.clipsToBounds = true
                showmore.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                showmore.layer.borderWidth = 1.0
                showmore.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
                showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
                if tableView == self.amenitiesTableView{
                    showmore.tag = 1
                }else if tableView == self.userSpacesTableView{
                    showmore.tag = 2
                }else{
                    showmore.tag = 3
                }
                
                showmore.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
                footerView.addSubview(showmore)
                
                let lineLabel = UILabel(frame: CGRect(x:0, y: 69, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            
            else {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let lineLabel = UILabel(frame: CGRect(x:0, y: 19, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            
        }
        else if (tableView == self.safetyAmenitiesTableView){
            let amenitiesCount = self.viewModel?.viewListingArray.userSafetyAmenities?.count
            if (amenitiesCount! > 3) {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let showmore = UIButton()
                showmore.frame = CGRect(x:0, y: 10, width:tableView.bounds.size.width, height:45)
                showmore.backgroundColor = UIColor(named: "colorController")
                showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
                showmore.layer.cornerRadius = showmore.frame.size.height/2
                showmore.clipsToBounds = true
                showmore.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                showmore.layer.borderWidth = 1.0
                showmore.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
                showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
                if tableView == self.amenitiesTableView{
                    showmore.tag = 1
                }else if tableView == self.userSpacesTableView{
                    showmore.tag = 2
                }else{
                    showmore.tag = 3
                }
                
                showmore.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
                footerView.addSubview(showmore)
                
                let lineLabel = UILabel(frame: CGRect(x:0, y: 69, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            
            else {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let lineLabel = UILabel(frame: CGRect(x:0, y:19, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }        }
        
        else if (tableView == self.tblBeds){
            let amenitiesCount = self.viewModel?.viewListingArray.userBedsTypes?.count
            if (amenitiesCount! > 3) {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let showmore = UIButton()
                showmore.frame = CGRect(x:0, y: 10, width:tableView.bounds.size.width, height:45)
                showmore.backgroundColor = UIColor(named: "colorController")
                showmore.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
                showmore.layer.cornerRadius = showmore.frame.size.height/2
                showmore.clipsToBounds = true
                showmore.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                showmore.layer.borderWidth = 1.0
                showmore.titleLabel?.font =  UIFont(name: APP_FONT_MEDIUM, size:17)
                showmore.setTitle(self.tableView(tableView, titleForFooterInSection: section), for: .normal)
                if tableView == self.amenitiesTableView{
                    showmore.tag = 1
                }else if tableView == self.userSpacesTableView{
                    showmore.tag = 2
                }
                else if tableView == self.tblBeds{
                    showmore.tag = 4
                }
                else{
                    showmore.tag = 3
                }
                
                showmore.addTarget(self, action: #selector(addBtnTapped(_:)), for: .touchUpInside)
                footerView.addSubview(showmore)
                
                let lineLabel = UILabel(frame: CGRect(x:0, y: 69, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }
            
            else {
                let footerView = UIView()
                footerView.backgroundColor = UIColor.clear
                
                let lineLabel = UILabel(frame: CGRect(x:0, y:19, width:
                                                        tableView.bounds.size.width, height: 1.0))
                lineLabel.backgroundColor = UIColor(named: "Review_Page_Line_Color")
                footerView.addSubview(lineLabel)
                
                return footerView
            }        }
        
        return nil
        
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?{
        if tableView == self.amenitiesTableView{
            let amenitiesCount = self.viewModel?.viewListingArray.userAmenities?.count
            if (amenitiesCount! > 3) {
                return self.isShowMoreAmenitiesClicked ? "\((Utility.shared.getLanguage()?.value(forKey:"showallamenities"))!)" : "\((Utility.shared.getLanguage()?.value(forKey:"showallamenities"))!)"
                
                
                
                
                
                
            }
            
        }else if tableView == self.userSpacesTableView{
            let amenitiesCount = self.viewModel?.viewListingArray.userSpaces?.count
            if (amenitiesCount! > 3) {
                return self.isShowMoreUserSpaceClicked ? "\((Utility.shared.getLanguage()?.value(forKey: "showshare"))!)" : "\((Utility.shared.getLanguage()?.value(forKey: "showshare"))!)"
                
                
            }
        }else if tableView == self.safetyAmenitiesTableView{
            let amenitiesCount = self.viewModel?.viewListingArray.userSafetyAmenities?.count
            if (amenitiesCount! > 3) {
                return self.isShowMoreSafetyAmenitiesClicked ? "\((Utility.shared.getLanguage()?.value(forKey: "showallsafety"))!)" :"\((Utility.shared.getLanguage()?.value(forKey: "showallsafety"))!)"
                
                
                
                
            }
        }
        
        else if tableView == self.tblBeds{
            let amenitiesCount = self.viewModel?.viewListingArray.userBedsTypes?.count
            if (amenitiesCount! > 3) {
                return self.isShowMoreBedsClicked ? "\((Utility.shared.getLanguage()?.value(forKey: "showallbed"))!)" :"\((Utility.shared.getLanguage()?.value(forKey: "showallbed"))!)"
                
                
                
                
            }
        }
        return nil
        
    }
    
    @objc func addBtnTapped(_ sender: UIButton){
        if sender.tag == 1{
            self.isShowMoreAmenitiesClicked = !self.isShowMoreAmenitiesClicked
            
            let houserulesObj = HouseRulesVC()
            houserulesObj.ameneties = self.viewModel?.viewListingArray.userAmenities as! [ViewListingDetailsQueryy.Data.ViewListing.Result.UserAmenity]
            
            houserulesObj.titleString = "\(Utility.shared.getLanguage()?.value(forKey: "whatplaceoffer") ?? "What the place offer")"
            houserulesObj.modalPresentationStyle = .fullScreen
            self.present(houserulesObj, animated: true, completion: nil)
        
        }else if sender.tag == 2{
            self.isShowMoreUserSpaceClicked = !self.isShowMoreUserSpaceClicked
            let houserulesObj = HouseRulesVC()
            houserulesObj.spaces = self.viewModel?.viewListingArray.userSpaces as! [ViewListingDetailsQueryy.Data.ViewListing.Result.UserSpace]
            houserulesObj.titleString = "\(Utility.shared.getLanguage()?.value(forKey: "userspace") ?? "Shared spaces")"
            houserulesObj.modalPresentationStyle = .fullScreen
            self.present(houserulesObj, animated: true, completion: nil)
          
        }
        
        else if sender.tag == 4{
            self.isShowMoreBedsClicked = !self.isShowMoreBedsClicked
            
            let houserulesObj = HouseRulesVC()
            
            
            if let cgvh = self.viewModel?.viewListingArray.userBedsTypes{
                houserulesObj.beds = cgvh
            }
            
            houserulesObj.titleString = "\(Utility.shared.getLanguage()?.value(forKey: "bedtypes") ?? "Bed types")"
            houserulesObj.modalPresentationStyle = .fullScreen
            self.present(houserulesObj, animated: true, completion: nil)
            
            
            
            
        }
        else{
            self.isShowMoreSafetyAmenitiesClicked = !self.isShowMoreSafetyAmenitiesClicked
            let houserulesObj = HouseRulesVC()
            houserulesObj.safetyAmeneties = self.viewModel?.viewListingArray.userSafetyAmenities as! [ViewListingDetailsQueryy.Data.ViewListing.Result.UserSafetyAmenity]
            houserulesObj.titleString = "\(Utility.shared.getLanguage()?.value(forKey: "usersafety") ?? "Safety amenities")"
            houserulesObj.modalPresentationStyle = .fullScreen
            self.present(houserulesObj, animated: true, completion: nil)
            
        }
    }
    
    
    @objc func propertyReviewsReadALLBtnTapped(sender: UIButton){
        self.goToAllReviewPage(value: false, index: 0)
    }
    
    func goToAllReviewPage(value: Bool,index: Int){
        if Utility.shared.isConnectedToNetwork(){
           
            let reviewpageObj = ReviewShowVC()
            reviewpageObj.profileID = self.listID
            
            reviewpageObj.isForProfileReviews = false
            reviewpageObj.isMoveToCell = value
            reviewpageObj.moveToIndex = index
            reviewpageObj.reviewcount = self.viewModel?.propertyReviewsCount ?? 0
            reviewpageObj.reviewTitle = reviewTitle
            reviewpageObj.modalPresentationStyle = .fullScreen
            self.present(reviewpageObj, animated: false, completion: nil)
          
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
        editprofileobj.profileid = (viewModel?.propertyReviewArray[tag].authorData?.fragments.profileFields.profileId!)!
        editprofileobj.isfromreview = true
        editprofileobj.profilename = (viewModel?.propertyReviewArray[tag].authorData?.fragments.profileFields.firstName!)!
        editprofileobj.modalPresentationStyle = .fullScreen
        self.present(editprofileobj, animated: true, completion: nil)
    }
}


extension UpdatedViewListing: AirbnbDatePickerDelegate, ContacthostVCDelegate, RequestbookVCDelegate{
    func passgetBillingArray(getbillingArray: GetBillingCalculationQueryy.Data.GetBillingCalculation.Result) {
        self.viewModel?.getbillingArray = getbillingArray
    }
    
    func billingListAPICall(startDate: String, endDate: String) {
        let fmt = DateFormatter()
       
        fmt.dateFormat = "yyyy-MM-dd"
        self.viewModel?.billingListAPICall(startDate: startDate, endDate: endDate, completion: {
            value in
            if !value.isEmpty{
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!): \(value)")
                attributedString.setColor(color:  UIColor(named: "Title_Header")!, forText:"\(value)")
                attributedString.setColor(color:Theme.SECONDARY_COLOR, forText:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!):")
                self.infoView.isHidden = false
                
                self.infoTitleLabel.attributedText = attributedString
            }
        })
    }
    
    func passSelectedStartDate(selectedstartDate: Date) {
        self.viewModel?.selectedStartDate = selectedstartDate
    }
    
    func passSelectedEndDate(selectedenddate: Date) {
        self.viewModel?.selectedEndDate = selectedenddate
        
        let dateFormatterGet = DateFormatter()
       
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        if self.viewModel?.selectedStartDate == nil && self.viewModel?.selectedEndDate == nil {
            self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"checkavailability") ?? "Check Availability")", for: .normal)
        } else {
            let fmt = DateFormatter()
          
            fmt.dateFormat = "yyyy-MM-dd"
            Utility.shared.selectedstartDate = fmt.string(from: (self.viewModel?.selectedStartDate)!)
            Utility.shared.selectedEndDate = fmt.string(from: (self.viewModel?.selectedEndDate)!)
            
            
            let newDateFormat = DateFormatter()
          
            newDateFormat.dateFormat = "MMM dd"
            
            var startDateString = ""
            var endDateString = ""
            
            startDateString = newDateFormat.string(from: (self.viewModel?.selectedStartDate)!)
            endDateString = newDateFormat.string(from: (self.viewModel?.selectedEndDate)!)
            
            self.selectedDateBtn.isHidden = false
            self.listRatingView.isHidden = true
            self.centerConstant.constant = -12
            
            let yourAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attributeString = NSMutableAttributedString(
                string: "\(startDateString)-\(endDateString)",
                attributes: yourAttributes
            )
            self.selectedDateBtn.setAttributedTitle(attributeString, for: .normal)
      
        }
    }
    
    
    func datePickerController(_ datePickerController: AirbnbDatePickerViewController, didSaveStartDate startDate: Date?, endDate: Date?) {
        if(startDate != nil)
        {
            self.viewModel?.selectedStartDate = startDate
            self.viewModel?.selectedEndDate = endDate
            
            let dateFormatterGet = DateFormatter()
          
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            if self.viewModel?.selectedStartDate == nil && self.viewModel?.selectedEndDate == nil {
                self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"checkavailability") ?? "Check Availability")", for: .normal)
            } else {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
              
                Utility.shared.selectedstartDate = fmt.string(from: startDate!)
                Utility.shared.selectedEndDate = fmt.string(from: endDate!)
                
                
                let newDateFormat = DateFormatter()
              
                newDateFormat.dateFormat = "MMM dd"
                
                var startDateString = ""
                var endDateString = ""
                
                startDateString = newDateFormat.string(from: startDate!)
                endDateString = newDateFormat.string(from: endDate!)
                
                self.selectedDateBtn.isHidden = false
                self.listRatingView.isHidden = true
                self.centerConstant.constant = -12
                
                let yourAttributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                let attributeString = NSMutableAttributedString(
                    string: "\(startDateString)-\(endDateString)",
                    attributes: yourAttributes
                )
                self.selectedDateBtn.setAttributedTitle(attributeString, for: .normal)
                
             
                
                self.viewModel?.billingListAPICall(startDate: fmt.string(from: startDate!), endDate: fmt.string(from: endDate!), completion: {
                    value in
                    if !value.isEmpty{
                        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!):  \(value)")
                        attributedString.setColor(color:  UIColor(named: "Title_Header")!, forText:"\(value)")
                        attributedString.setColor(color:Theme.SECONDARY_COLOR, forText:"\((Utility.shared.getLanguage()?.value(forKey: "info"))!):")
                        self.infoView.isHidden = false
                        self.infoTitleLabel.attributedText = attributedString
                    }
                })
                if(self.viewModel?.viewListingArray.bookingType != nil && self.viewModel?.viewListingArray.bookingType! == "instant")
                {
                    self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"book") ?? "Book")", for: .normal)
                }else{
                    self.checkAvailabilityBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"requestbook") ?? "Request to book")", for: .normal)
                }
            }
        }else{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selectdate"))!)")
        }
    }
}


extension UpdatedViewListing{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView{
            self.topView.backgroundColor = (scrollView.contentOffset.y > self.imgCollectionView.frame.size.height-80) ? UIColor(named: "cell_bg") : UIColor.clear
        }
    }
}

