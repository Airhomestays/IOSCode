
import UIKit
import Lottie
import Apollo
import SwiftMessages
import SkeletonView

class ViewReviewPage: UIViewController, WriteReviewProtocol,UITableViewDelegate , UITableViewDataSource, SkeletonTableViewDataSource {
    func reloadPendingReviews() {
        self.pendingPageIndex = 1
        self.getPendingReviewsAPICall()
    }
    

    @IBOutlet var lineview: UIView!
    @IBOutlet var lblReview: UILabel!
    @IBOutlet weak var TopSegmentView: UIView!
    @IBOutlet weak var aboutYouBtn: UIButton!
    @IBOutlet weak var byYouBtn: UIButton!
    @IBOutlet weak var aboutYouHighlightLine: UILabel!
    @IBOutlet weak var byYouHightlightLine: UILabel!
    
    @IBOutlet weak var upComingPastView: UIView!
    @IBOutlet weak var upComingBtn: UIButton!
    @IBOutlet weak var pastBtn: UIButton!
    @IBOutlet weak var upcomingPastHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var ReviewsTableView: UITableView!
    @IBOutlet weak var NoReviewsFoundView: UIView!
    @IBOutlet weak var NoReviewsFoundImage: UIImageView!
    @IBOutlet weak var NoReviewsFoundText: UILabel!
    
    var cellIdArray  = [Int]()
    var lottieView: LottieAnimationView!
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    
    var pageIndex = 1
    var selectedOwnerType = "other"
    var totalCount = 0
    var aboutYouReviewArray = [GetUserReviewsQuery.Data.GetUserReview.Result]()
    var byYouReviewArray = [GetUserReviewsQuery.Data.GetUserReview.Result]()
    var pendingReviewArray = [GetPendingUserReviewsQuery.Data.GetPendingUserReview.Result]()
    var pendingPageIndex = 1
    var pendingTotalCount = 0
    
    var selectedBottomTab = 1
    var isAPICallGoingOn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        lineview.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        initialButtonSetup()
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.ReviewsTableView.register(UINib(nibName: "PastReviewCells", bundle: nil), forCellReuseIdentifier: "pastReviewCells")
        self.ReviewsTableView.register(UINib(nibName: "UpcomingReviewCells", bundle: nil), forCellReuseIdentifier: "upcomingReviewCells")
        self.ReviewsTableView.delegate = self
        self.ReviewsTableView.dataSource = self
        self.ReviewsTableView.isSkeletonable = true
        self.ReviewsTableView.showAnimatedGradientSkeleton()
       
        self.ReviewsTableView.separatorStyle = .none
        
        self.NoReviewsFoundText.text = "\(Utility.shared.getLanguage()?.value(forKey: "No_Review_Found") ?? "No reviews yet")"
        
        self.NoReviewsFoundText.textColor = UIColor(named: "Title_Header")
        self.NoReviewsFoundText.font = UIFont(name: APP_FONT_BOLD, size: 20)
        self.NoReviewsFoundView.isHidden = true
        
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        self.ReviewsTableView.reloadData()
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = true
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.getUserReviewsAPICall()
    }

    @IBAction func onClickRetryBtn(_ sender: UIButton) {
        self.getUserReviewsAPICall()
    }
    func getUserReviewsAPICall(){
        if Utility.shared.isConnectedToNetwork(){
            self.lottieAnimation()
            self.offlineView.isHidden = true
            self.NoReviewsFoundView.isHidden = true
            self.ReviewsTableView.isHidden = false
            let getUserReview = GetUserReviewsQuery(currentPage: self.pageIndex, ownerType: self.selectedOwnerType)
            if pageIndex == 1{
                self.aboutYouReviewArray.removeAll()
                self.byYouReviewArray.removeAll()
                self.cellIdArray.removeAll()
                self.ReviewsTableView.reloadData()
            }
            self.isAPICallGoingOn = true
            apollo_headerClient.fetch(query:getUserReview,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                
                self.isAPICallGoingOn = false
                guard (result?.data?.getUserReviews?.results) != nil else{
                    self.ReviewsTableView.hideSkeleton()
                    self.ReviewsTableView.isSkeletonable = false
                    self.lottieView.isHidden = true
                    self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
                   
                    
                self.view.makeToast(result?.data?.getUserReviews?.errorMessage)
                return
            }
                
                if self.selectedOwnerType == result?.data?.getUserReviews?.ownerType{
                if result?.data?.getUserReviews?.currentPage == 1{
                    self.aboutYouReviewArray.removeAll()
                    self.byYouReviewArray.removeAll()
                    self.cellIdArray.removeAll()
                }
                self.totalCount = result?.data?.getUserReviews?.count ?? 0
                if self.selectedOwnerType == "other"{
                    self.aboutYouReviewArray.append(contentsOf: (result?.data?.getUserReviews?.results)! as! [GetUserReviewsQuery.Data.GetUserReview.Result])
                }else{
                    self.byYouReviewArray.append(contentsOf: (result?.data?.getUserReviews?.results)! as! [GetUserReviewsQuery.Data.GetUserReview.Result])
                }
                   self.ReviewsTableView.hideSkeleton()
                    self.ReviewsTableView.isSkeletonable = false
                self.lottieView.isHidden = true
                self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
                if self.totalCount != 0{
                    self.ReviewsTableView.isHidden = false
                    self.NoReviewsFoundView.isHidden = true
                    self.ReviewsTableView.reloadData()
                }else{
                    self.ReviewsTableView.isHidden = true
                    self.NoReviewsFoundView.isHidden = false
                }
                }
            }
        }else{
            self.ReviewsTableView.isSkeletonable = true
            self.ReviewsTableView.showAnimatedGradientSkeleton()
            self.lottieView.isHidden = true
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
            
            
        }
    }
    
    func getPendingReviewsAPICall(){
        if Utility.shared.isConnectedToNetwork(){
            self.lottieAnimation()
            self.offlineView.isHidden = true
            self.NoReviewsFoundView.isHidden = true
            
            let getPendingReviews = GetPendingUserReviewsQuery(currentPage: self.pendingPageIndex)
            
            if self.pendingPageIndex == 1{
                self.pendingReviewArray.removeAll()
                self.cellIdArray.removeAll()
                self.ReviewsTableView.reloadData()
            }
            self.isAPICallGoingOn = true
            apollo_headerClient.fetch(query:getPendingReviews,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                
                self.isAPICallGoingOn = false
                guard (result?.data?.getPendingUserReviews?.results) != nil else{
                    self.ReviewsTableView.hideSkeleton()
                    self.ReviewsTableView.isSkeletonable = false
                    self.lottieView.isHidden = true
                    self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
                    
                   
                    
                self.view.makeToast(result?.data?.getPendingUserReviews?.errorMessage)
                return
            }
                if result?.data?.getPendingUserReviews?.currentPage == 1{
                    self.pendingReviewArray.removeAll()
                    self.cellIdArray.removeAll()
                }
                
                self.pendingTotalCount = result?.data?.getPendingUserReviews?.count ?? 0
                self.pendingReviewArray.append(contentsOf: (result?.data?.getPendingUserReviews?.results)! as! [GetPendingUserReviewsQuery.Data.GetPendingUserReview.Result])
                self.ReviewsTableView.hideSkeleton()
                self.ReviewsTableView.isSkeletonable = false
                self.lottieView.isHidden = true
                self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:0, height:0)
                if self.pendingTotalCount != 0{
                    self.ReviewsTableView.isHidden = false
                    self.NoReviewsFoundView.isHidden = true
                    self.ReviewsTableView.reloadData()
                }else{
                    self.ReviewsTableView.isHidden = true
                    self.NoReviewsFoundView.isHidden = false
                }
            }
        }else{
            self.ReviewsTableView.isSkeletonable = true
            self.ReviewsTableView.showAnimatedGradientSkeleton()
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
            
            
        }
    }
    
    func lottieAnimation(){
        self.ReviewsTableView.isSkeletonable = false
        self.ReviewsTableView.hideSkeleton()
        if self.upComingBtn.isSelected{
           
            if self.pendingPageIndex == 1 {
                           
        self.ReviewsTableView.isSkeletonable = true
        self.ReviewsTableView.showAnimatedGradientSkeleton()
            }
        }
        else if  self.selectedOwnerType == "other" {
            if self.pageIndex == 1 {
                           
        self.ReviewsTableView.isSkeletonable = true
        self.ReviewsTableView.showAnimatedGradientSkeleton()
            }
        }
        
       
        self.lottieView.isHidden = true
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
    }
    
    func initialButtonSetup(){
        lblReview.text = "\(Utility.shared.getLanguage()?.value(forKey: "reviews") ?? "Reviews")"
        lblReview.font = UIFont(name:APP_FONT_MEDIUM , size:18)
        
        self.upcomingPastHeightConstraint.constant = 0
        self.upComingBtn.setTitle("", for: .normal)
        self.pastBtn.setTitle("", for: .normal)
        
        self.aboutYouHighlightLine.isHidden = false
        self.byYouHightlightLine.isHidden = true
        
        self.aboutYouBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "About_You") ?? "ABOUT YOU")", for: .normal)
        self.byYouBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "By_You") ?? "BY YOU")", for: .normal)
        self.aboutYouBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        self.byYouBtn.setTitleColor(UIColor(named: "searchPlaces_TextColor"), for: .normal)
        
        self.upComingPastView.isHidden = true
    }
    @IBAction func aboutYouBtnTapped(_ sender: UIButton) {
        if !self.isAPICallGoingOn {
        self.pastBtn.isSelected = false
        self.upComingBtn.isSelected = false
        
        self.initialButtonSetup()
        
        self.pageIndex = 1
        self.selectedOwnerType = "other"
        self.aboutYouReviewArray.removeAll()
        self.byYouReviewArray.removeAll()
        self.cellIdArray.removeAll()
        self.ReviewsTableView.reloadData()
        
        self.getUserReviewsAPICall()
        }
    }
    
    @IBAction func byYouBtnTapped(_ sender: UIButton) {
        if !self.isAPICallGoingOn {
        self.upcomingPastHeightConstraint.constant = 90
        self.upComingBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "UpcomingReviews") ?? "Upcoming")", for: .normal)
        self.pastBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Past") ?? "Past")", for: .normal)
        
        self.aboutYouHighlightLine.isHidden = true
        self.byYouHightlightLine.isHidden = false
        
            self.aboutYouBtn.setTitleColor(UIColor(named: "searchPlaces_TextColor"), for: .normal)
        self.byYouBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        self.upComingPastView.isHidden = false
        self.setUpcomingPastBtns()
        }
    }
    
    func setUpcomingPastBtns(){
        if self.selectedBottomTab == 1{
            self.pastBtn.isSelected = false
            
            self.pendingPageIndex = 1
            self.upComingBtn.backgroundColor = Theme.PRIMARY_COLOR
            self.upComingBtn.setTitleColor(UIColor.white, for: .normal)
            self.upComingBtn.layer.cornerRadius = 20
            self.upComingBtn.clipsToBounds = true
            self.upComingBtn.tintColor = .clear
            
            self.pastBtn.backgroundColor = UIColor(named: "Button_Grey_Color")
            self.pastBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
            self.pastBtn.layer.cornerRadius = 20
            self.pastBtn.clipsToBounds = true
            self.pastBtn.tintColor = .clear
            
            if !self.upComingBtn.isSelected{
                self.pendingPageIndex = 1
                self.upComingBtn.isSelected = true
                self.getPendingReviewsAPICall()
            }
            
            self.upComingBtn.isSelected = true
        }else{
            self.upComingBtn.isSelected = false
            
            self.pastBtn.backgroundColor = Theme.PRIMARY_COLOR
            self.pastBtn.setTitleColor(UIColor.white, for: .normal)
            self.pastBtn.layer.cornerRadius = 20
            self.pastBtn.clipsToBounds = true
            
            self.upComingBtn.backgroundColor =  UIColor(named: "Button_Grey_Color")
            self.upComingBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
            self.upComingBtn.layer.cornerRadius = 20
            self.upComingBtn.clipsToBounds = true
            
            if !self.pastBtn.isSelected{
                self.pageIndex = 1
                self.selectedOwnerType = "me"
                self.getUserReviewsAPICall()
            }
            
            self.pastBtn.isSelected = true
        }
    }
    func upcomingPastBtnConfiguration(){
        
        self.pastBtn.isSelected = false
        
        self.pendingPageIndex = 1
        self.upComingBtn.backgroundColor = Theme.PRIMARY_COLOR
        self.upComingBtn.setTitleColor(UIColor.white, for: .normal)
        self.upComingBtn.layer.cornerRadius = 20
        self.upComingBtn.clipsToBounds = true
        self.upComingBtn.tintColor = .clear
        
        self.pastBtn.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.pastBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        self.pastBtn.layer.cornerRadius = 20
        self.pastBtn.clipsToBounds = true
        self.pastBtn.tintColor = .clear
        
        if !self.upComingBtn.isSelected{
            self.pendingPageIndex = 1
            self.upComingBtn.isSelected = true
            self.getPendingReviewsAPICall()
        }
        
        self.upComingBtn.isSelected = true

    }
    @IBAction func onClickBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upcomingBtnTapped(_ sender: UIButton) {
        if !self.isAPICallGoingOn {
        self.selectedBottomTab = 1
        upcomingPastBtnConfiguration()
        }
    }
    
    @IBAction func pastBtnTapped(_ sender: UIButton) {
        if !self.isAPICallGoingOn {
        self.selectedBottomTab = 2
        self.upComingBtn.isSelected = false
        
        self.pastBtn.backgroundColor = Theme.PRIMARY_COLOR
        self.pastBtn.setTitleColor(UIColor.white, for: .normal)
        self.pastBtn.layer.cornerRadius = 20
        self.pastBtn.clipsToBounds = true
        
        self.upComingBtn.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.upComingBtn.setTitleColor(UIColor(named: "Title_Header"), for: .normal)
        self.upComingBtn.layer.cornerRadius = 20
        self.upComingBtn.clipsToBounds = true
        
        if !self.pastBtn.isSelected{
            self.pageIndex = 1
            self.selectedOwnerType = "me"
            self.getUserReviewsAPICall()
        }
        
        self.pastBtn.isSelected = true
        }

    }
    func timestampconvert(timestamp:String) -> String
    {
        if timestamp != ""{
        let timestamValue = Int(timestamp)!/1000
        let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, yyyy"
        
      let reviewDate = dateFormatter.string(from: newTime)
      return reviewDate
        }else{
            return ""
        }
    }
    
    
    @objc func writeReviewClicked(sender: UIButton){
        let writeReview = WriteReview()
        writeReview.delegate = self
        writeReview.reservationID = self.pendingReviewArray[sender.tag].id ?? 0
        writeReview.modalPresentationStyle = .fullScreen
        writeReview.isFromEmailNavigation = false
        self.present(writeReview, animated: true, completion: nil)
    }
    
    @objc func viewItineraryClicked(sender: UIButton){
        let receiptPageObj = BookingItenaryVC()
        receiptPageObj.isFromReviewPage = true
        receiptPageObj.reservID = self.pendingReviewArray[sender.tag].id ?? 0
        receiptPageObj.modalPresentationStyle = .fullScreen
        self.present(receiptPageObj, animated: true, completion: nil)
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
    guard let a = (sender.view as? UILabel)?.text else { return }
        
        self.gotoProfilePage(tag: (sender.view as? UILabel)?.tag ?? 0)
    }
    
    @objc func  handleTapEnlarge(sender: UITapGestureRecognizer) {
    guard let a = (sender.view as? UILabel)?.text else { return }
        
        let tag = (sender.view as? UILabel)?.tag ?? 0
        cellIdArray.append(tag)
        self.ReviewsTableView.reloadData()
      
    }
   
    
    @objc func upComingProfileBtnTapped(sender: UIButton){
        self.gotoListingPage_Pending(tag: sender.tag)
    }
    
    @objc func handleTapUpcoming(sender: UITapGestureRecognizer) {
    guard let a = (sender.view as? UILabel)?.text else { return }
        
        self.gotoListingPage_Pending(tag: (sender.view as? UILabel)?.tag ?? 0)
    }
    
    func gotoProfilePage(tag: Int){
        if Utility.shared.getCurrentUserID() as String? == self.pendingReviewArray[tag].hostId
        {
            let editprofileobj = HostProfileViewPage()
            editprofileobj.profileid = self.pendingReviewArray[tag].guestData?.profileId ?? 0
            editprofileobj.profilename = self.pendingReviewArray[tag].guestData?.firstName ?? ""
            editprofileobj.showprofileAPICall(profileid:self.pendingReviewArray[tag].guestData?.profileId ?? 0)
            editprofileobj.modalPresentationStyle = .fullScreen
            self.present(editprofileobj, animated: true, completion: nil)
        }else{
            let editprofileobj = HostProfileViewPage()
            editprofileobj.profileid = self.pendingReviewArray[tag].hostData?.profileId ?? 0
            editprofileobj.profilename = self.pendingReviewArray[tag].hostData?.firstName ?? ""
            editprofileobj.showprofileAPICall(profileid:self.pendingReviewArray[tag].hostData?.profileId ?? 0)
            editprofileobj.modalPresentationStyle = .fullScreen
            self.present(editprofileobj, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func handlePastProfileTap(sender: UITapGestureRecognizer) {
    guard let a = (sender.view as? UILabel)?.text else { return }
        self.gotoListingPage(tag: (sender.view as? UILabel)?.tag ?? 0)
    }
    @objc func pastProfileBtnTapped(sender: UIButton){
        self.gotoPastProfilePage(tag: sender.tag)
    }
    
    func gotoPastProfilePage(tag: Int){
        
            let editprofileobj = HostProfileViewPage()
        editprofileobj.profileid = self.byYouReviewArray[tag].userData?.fragments.profileFields.profileId ?? 0
        editprofileobj.profilename = self.byYouReviewArray[tag].userData?.fragments.profileFields.firstName ?? ""
            editprofileobj.showprofileAPICall(profileid:self.byYouReviewArray[tag].userData?.fragments.profileFields.profileId ?? 0)
            editprofileobj.modalPresentationStyle = .fullScreen
            self.present(editprofileobj, animated: true, completion: nil)
        
    }
    
    @objc func handleAboutYouProfileTap(sender: UITapGestureRecognizer) {
    guard let a = (sender.view as? UILabel)?.text else { return }
        self.gotoListingPage(tag: (sender.view as? UILabel)?.tag ?? 0)
    }
    @objc func aboutYouProfileBtnTapped(sender: UIButton){
        self.gotoAboutYouProfilePage(tag: sender.tag)
    }
    
    func gotoAboutYouProfilePage(tag: Int){
        
            let editprofileobj = HostProfileViewPage()
        editprofileobj.profileid = self.aboutYouReviewArray[tag].authorData?.fragments.profileFields.profileId ?? 0
        editprofileobj.profilename = self.aboutYouReviewArray[tag].authorData?.fragments.profileFields.firstName ?? ""
            editprofileobj.showprofileAPICall(profileid:self.aboutYouReviewArray[tag].authorData?.fragments.profileFields.profileId ?? 0)
            editprofileobj.modalPresentationStyle = .fullScreen
            self.present(editprofileobj, animated: true, completion: nil)
        
    }
    func gotoListingPage_Pending(tag: Int){
        
        let viewListing = UpdatedViewListing()
       
            viewListing.listID = pendingReviewArray[tag].listId ?? 0
        Utility.shared.unpublish_preview_check = false
      
        viewListing.modalPresentationStyle = .fullScreen
        self.present(viewListing, animated: true, completion: nil)
        
    }
    func gotoListingPage(tag: Int){
        
        let viewListing = UpdatedViewListing()
        if(aboutYouHighlightLine.isHidden) {
        viewListing.listID = byYouReviewArray[tag].listId ?? 0
        }
        else {
            viewListing.listID = aboutYouReviewArray[tag].listId ?? 0
        }
        Utility.shared.unpublish_preview_check = false
        viewListing.modalPresentationStyle = .fullScreen
        self.present(viewListing, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.upComingBtn.isSelected ? pendingReviewArray.count : self.selectedOwnerType == "other" ? aboutYouReviewArray.count : byYouReviewArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
         var totalPages = Int()
        
        if self.upComingBtn.isSelected{
            let lastElement = self.pendingReviewArray.count - 1
                    if indexPath.row == lastElement{
                        
                        if(self.pendingTotalCount % 10 == 0)
                        {
                            totalPages = (self.pendingTotalCount/10)
                        }
                        else{
                            totalPages = (self.pendingTotalCount/10) + 1
                        }
                        if(totalPages >= self.pendingPageIndex){
                            self.pendingPageIndex += 1
                            self.getPendingReviewsAPICall()
                        }
                    }
        }else{
            if self.selectedOwnerType == "other" {
                let lastElement = self.aboutYouReviewArray.count - 1
                        if indexPath.row == lastElement{
                            
                            if(self.totalCount % 10 == 0)
                            {
                                totalPages = (self.totalCount/10)
                            }
                            else{
                                totalPages = (self.totalCount/10) + 1
                            }
                            if(totalPages >= self.pageIndex){
                                self.pageIndex += 1
                                self.getUserReviewsAPICall()
                            }
                        }
            }else{
                let lastElement = self.byYouReviewArray.count - 1
                        if indexPath.row == lastElement{
                            
                            if(self.totalCount % 10 == 0)
                            {
                                totalPages = (self.totalCount/10)
                            }
                            else{
                                totalPages = (self.totalCount/10) + 1
                            }
                            if(totalPages >= self.pageIndex){
                                self.pageIndex += 1
                                self.getUserReviewsAPICall()
                            }
                        }
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.upComingBtn.isSelected {
            let cell : UpcomingReviewCells = tableView.dequeueReusableCell(withIdentifier: "upcomingReviewCells", for: indexPath) as! UpcomingReviewCells
            cell.selectionStyle = .none
            
            cell.writeReviewTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "Writereviewsmall") ?? "Write a review")"
            cell.viewItenaryTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "View_Itinerary_small") ?? "View itinerary")"
            
            cell.viewItenaryIcon.isHidden = false
            cell.writeReviewIcon.isHidden = false
            
            
            if (Utility.shared.getCurrentUserID() as String? == self.pendingReviewArray[indexPath.row].hostId)
            {
                let profileImage = "\(IMAGE_AVATAR_URL)\(self.pendingReviewArray[indexPath.row].guestData?.picture ?? "")"
                cell.profileImage.sd_setImage(with: URL(string: profileImage), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
            }else{
                let profileImage = "\(IMAGE_AVATAR_URL)\(self.pendingReviewArray[indexPath.row].hostData?.picture ?? "")"
                cell.profileImage.sd_setImage(with: URL(string: profileImage), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
            }
            

            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapUpcoming))
            cell.titleLabel.tag = indexPath.row
            cell.titleLabel.addGestureRecognizer(tapGesture)
            cell.titleLabel.isUserInteractionEnabled = true
            
            cell.profileBtn.tag = indexPath.row
            cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
            cell.profileBtn.addTarget(self, action: #selector(upComingProfileBtnTapped), for: .touchUpInside)
            
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
            ]
                
            let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "Submit_Public_Review") ?? "Submit a public review for")" , attributes: attributes as [NSAttributedString.Key : Any])
            let attributes2 = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
            ]
            let attributedString2 = NSMutableAttributedString(string: " " + "\(self.pendingReviewArray[indexPath.row].listingData?.title ?? "")", attributes: attributes2 as [NSAttributedString.Key : Any])
            if (self.pendingReviewArray[indexPath.row].listingData?.title) != nil {
            
            attributedString.append(attributedString2)
            
            cell.titleLabel.attributedText = attributedString
            }
            else {
                let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "listingnotavail") ?? "Listing not available")" , attributes: attributes as [NSAttributedString.Key : Any])
                cell.titleLabel.attributedText = attributedString
            }
            
            
            
            
            
            
            cell.writeReviewBtn.tag = indexPath.row
            cell.writeReviewBtn.addTarget(self, action: #selector(writeReviewClicked), for: .touchUpInside)
            
            cell.viewItenaryBtn.tag = indexPath.row
            cell.viewItenaryBtn.addTarget(self, action: #selector(viewItineraryClicked), for: .touchUpInside)
            return cell
        }else{
            let cell : PastReviewCells = tableView.dequeueReusableCell(withIdentifier: "pastReviewCells", for: indexPath) as! PastReviewCells
            cell.selectionStyle = .none
            cell.btnRating.isHidden = true
            
            if self.selectedOwnerType == "other"{
                
            if !(self.aboutYouReviewArray[indexPath.row].isAdmin ?? true){
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
            ]
                let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
                let attributes3 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
                ]
                let authorName = "\(self.aboutYouReviewArray[indexPath.row].authorData?.fragments.profileFields.firstName ?? "") \(self.aboutYouReviewArray[indexPath.row].authorData?.fragments.profileFields.lastName ?? "")"
                let attributedString = NSMutableAttributedString(string: authorName , attributes: attributes3 as [NSAttributedString.Key : Any])
          
            let attributedString2 = NSMutableAttributedString(string: "'s", attributes: attributes3 as [NSAttributedString.Key : Any])
           
            let attributedString3 = NSMutableAttributedString(string: " " + "\(Utility.shared.getLanguage()?.value(forKey: "reviewed") ?? "Reviewed")", attributes: attributes3 as [NSAttributedString.Key : Any])
            
                let attributedString4 = NSMutableAttributedString(string: " " + "\(self.aboutYouReviewArray[indexPath.row].listData?.title ?? "")", attributes: attributes as [NSAttributedString.Key : Any])
                
                
            attributedString.append(attributedString2)
            attributedString.append(attributedString3)
            attributedString.append(attributedString4)
            
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAboutYouProfileTap(sender:)))
                cell.titleLabel.tag = indexPath.row
                cell.titleLabel.addGestureRecognizer(tapGesture)
                cell.titleLabel.isUserInteractionEnabled = true
                
                if (self.aboutYouReviewArray[indexPath.row].listData?.title) != nil {
                cell.titleLabel.attributedText = attributedString
                }
                else {
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "listingnotavail") ?? "Listing not available")" , attributes: attributes as [NSAttributedString.Key : Any])
                    cell.titleLabel.attributedText = attributedString
                    
                    cell.titleLabel.isUserInteractionEnabled = false
                }
                
                cell.profileBtn.tag = indexPath.row
                cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
                cell.profileBtn.addTarget(self, action: #selector(aboutYouProfileBtnTapped), for: .touchUpInside)
                
                cell.titleLabel.isHidden = false
                
                cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.aboutYouReviewArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                
                let value1 = Float("\(self.aboutYouReviewArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                          let value2 = Float("\(self.aboutYouReviewArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                          if(value2 != 0.0){
                              cell.btnRatingProfile.isHidden = false
                              if (value1 != 0.0) {
                              let divideValue = value2/value1
                                  cell.btnRatingProfile.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                              }
                              else {
                                  cell.btnRatingProfile.setTitle(" \(Int(value2)) ", for: .normal)
                              }
                          }else{
                              cell.btnRatingProfile.isHidden = true
                              cell.btnRatingProfile.setTitle(" 0.0 ", for: .normal)

                          }
                let reviewContent = self.aboutYouReviewArray[indexPath.row].reviewContent ?? ""
                let str = reviewContent.replacingOccurrences(of: "\\s+", with: " " , options: .regularExpression)
                
                if (str.count > 120) && (!cellIdArray.contains(indexPath.row)){
                    let to = str.index(str.startIndex, offsetBy: 105, limitedBy: str.endIndex)
                    
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
                    ]
                    
                    let attributedString = NSMutableAttributedString(string: "\(str.substring(to: to!))..." , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "readmore") ?? "Read More")", attributes: [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                    ] as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapEnlarge))
                    cell.reviewContentLabel.tag = indexPath.row
                    cell.reviewContentLabel.addGestureRecognizer(tapGesture)
                    cell.reviewContentLabel.isUserInteractionEnabled = true
                    
                    cell.reviewContentLabel.numberOfLines = 3
                    cell.reviewDateLabel.lineBreakMode = .byTruncatingTail
                    cell.reviewContentLabel.attributedText = attributedString
                    
                }else{
                    cell.reviewContentLabel.isUserInteractionEnabled = true
                    cell.reviewContentLabel.text = str
                    cell.reviewContentLabel.numberOfLines = 0
                    cell.reviewDateLabel.lineBreakMode = .byWordWrapping
                }
               
                cell.reviewDateLabel.text = self.timestampconvert(timestamp: self.aboutYouReviewArray[indexPath.row].createdAt ?? "")
                
            }else{
                let attributes = [
                               NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                               NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
                           ]
                               
                let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "Verifiedby") ?? "Verified by") \(Utility.shared.getLanguage()?.value(forKey: "appname") ?? "RentALL")" , attributes: attributes as [NSAttributedString.Key : Any])
                cell.titleLabel.attributedText = attributedString
                
                cell.titleLabel.isHidden = false
                
                cell.titleLabel.tag = indexPath.row
                cell.titleLabel.isUserInteractionEnabled = false
                
                cell.profileBtn.tag = indexPath.row
                cell.profileBtn.removeTarget(self, action: #selector(aboutYouProfileBtnTapped), for: .touchUpInside)
                
                cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.aboutYouReviewArray[indexPath.row].authorData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                
                cell.btnRating.isHidden = true
                

                
                let value1 = Float("\(self.aboutYouReviewArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                          let value2 = Float("\(self.aboutYouReviewArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                          if(value2 != 0.0){
                              cell.btnRatingProfile.isHidden = false
                              if (value1 != 0.0) {
                              let divideValue = value2/value1
                                  cell.btnRatingProfile.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                              }
                              else {
                                  cell.btnRatingProfile.setTitle(" \(Int(value2)) ", for: .normal)
                              }
                          }else{
                              cell.btnRatingProfile.setTitle(" 0.0 ", for: .normal)
                              cell.btnRatingProfile.isHidden = true
                          }
                
                
                let reviewContent = self.aboutYouReviewArray[indexPath.row].reviewContent ?? ""
                let str = reviewContent.replacingOccurrences(of: "\\s+", with: " " , options: .regularExpression)
                
                if (str.count > 120) && (!cellIdArray.contains(indexPath.row)){
                    let to = str.index(str.startIndex, offsetBy: 105, limitedBy: str.endIndex)
                    
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
                    ]
                    
                    let attributedString = NSMutableAttributedString(string: "\(str.substring(to: to!))..." , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "readmore") ?? "Read More")", attributes: attributes2 as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapEnlarge))
                    cell.reviewContentLabel.tag = indexPath.row
                    cell.reviewContentLabel.addGestureRecognizer(tapGesture)
                    cell.reviewContentLabel.isUserInteractionEnabled = true
                    
                    cell.reviewContentLabel.numberOfLines = 3
                    cell.reviewDateLabel.lineBreakMode = .byTruncatingTail
                    cell.reviewContentLabel.attributedText = attributedString
                    
                }else{
                    cell.reviewContentLabel.isUserInteractionEnabled = true
                    cell.reviewContentLabel.text = str
                    cell.reviewContentLabel.numberOfLines = 0
                    cell.reviewDateLabel.lineBreakMode = .byWordWrapping
                }
                
             
                
                
                
              
                cell.reviewDateLabel.text = self.timestampconvert(timestamp: self.aboutYouReviewArray[indexPath.row].createdAt ?? "")
            }
                
                
                

            }else{
                let attributes = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
                ]
                let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "You_Reviewed") ?? "You reviewed")" + " ", attributes: attributes as [NSAttributedString.Key : Any])
               let attributes2 = [
                    NSAttributedString.Key.font: UIFont(name: APP_FONT_BOLD, size: 14),
                    NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                ]
               
                
                let attributedString2 = NSMutableAttributedString(string: " " + "\(self.byYouReviewArray[indexPath.row].listData?.title ?? "")", attributes: attributes2 as [NSAttributedString.Key : Any])
                
                if (self.byYouReviewArray[indexPath.row].listData?.title) != nil {
                
                attributedString.append(attributedString2)
                
                cell.titleLabel.attributedText = attributedString
                }
                else {
                    let attributedString = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "listingnotavail") ?? "Listing not available")" , attributes: attributes as [NSAttributedString.Key : Any])
                    cell.titleLabel.attributedText = attributedString
                    
                    cell.titleLabel.isUserInteractionEnabled = false
                }
                    
                    cell.titleLabel.isHidden = false
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePastProfileTap(sender:)))
                cell.titleLabel.tag = indexPath.row
                cell.titleLabel.addGestureRecognizer(tapGesture)
                cell.titleLabel.isUserInteractionEnabled = true
                
                cell.profileBtn.tag = indexPath.row
                cell.profileBtn.removeTarget(self, action: nil, for: .allEvents)
                cell.profileBtn.addTarget(self, action: #selector(pastProfileBtnTapped), for: .touchUpInside)
                
                cell.profileImageView.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_URL)\(self.byYouReviewArray[indexPath.row].userData?.fragments.profileFields.picture ?? "")"), placeholderImage: #imageLiteral(resourceName: "adminAvatar"), completed: nil)
                
                let value1 = Float("\(self.byYouReviewArray[indexPath.row].reviewContent ?? "0.0") ") ?? 0.0
                          let value2 = Float("\(self.byYouReviewArray[indexPath.row].rating ?? 0.0)") ?? 0.0
                          if(value2 != 0.0){
                              cell.btnRatingProfile.isHidden = false
                              if (value1 != 0.0) {
                              let divideValue = value2/value1
                                  cell.btnRatingProfile.setTitle(" \(Int(divideValue.rounded())) ", for: .normal)
                              }
                              else {
                                  cell.btnRatingProfile.setTitle(" \(Int(value2)) ", for: .normal)
                              }
                          }else{
                              cell.btnRatingProfile.setTitle(" 0.0 ", for: .normal)
                              cell.btnRatingProfile.isHidden = true
                          }
                let reviewContent = self.byYouReviewArray[indexPath.row].reviewContent ?? ""
                let str = reviewContent.replacingOccurrences(of: "\\s+", with: " " , options: .regularExpression)
                
                if (str.count > 120) && (!cellIdArray.contains(indexPath.row)){
                    let to = str.index(str.startIndex, offsetBy: 105, limitedBy: str.endIndex)
                    
                    let attributes = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")
                    ]
                    
                    let attributedString = NSMutableAttributedString(string: "\(str.substring(to: to!))..." , attributes: attributes as [NSAttributedString.Key : Any])
                    let attributes2 = [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                    ]
                    let attributedString2 = NSMutableAttributedString(string: "\(Utility.shared.getLanguage()?.value(forKey: "readmore") ?? "Read More")", attributes: [
                        NSAttributedString.Key.font: UIFont(name: APP_FONT, size: 12),
                        NSAttributedString.Key.foregroundColor: Theme.PRIMARY_COLOR
                    ] as [NSAttributedString.Key : Any])
                    
                    attributedString.append(attributedString2)
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapEnlarge))
                    cell.reviewContentLabel.tag = indexPath.row
                    cell.reviewContentLabel.addGestureRecognizer(tapGesture)
                    cell.reviewContentLabel.isUserInteractionEnabled = true
                    
                    cell.reviewContentLabel.numberOfLines = 3
                    cell.reviewDateLabel.lineBreakMode = .byTruncatingTail
                    cell.reviewContentLabel.attributedText = attributedString
                    
                }else{
                    cell.reviewContentLabel.isUserInteractionEnabled = true
                    cell.reviewContentLabel.text = str
                    cell.reviewContentLabel.numberOfLines = 0
                    cell.reviewDateLabel.lineBreakMode = .byWordWrapping
                }
                
             
                
                
                
              
                cell.reviewDateLabel.text = self.timestampconvert(timestamp: self.byYouReviewArray[indexPath.row].createdAt ?? "")

            }

            
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        let headerTitle = UILabel(frame: CGRect(x: 20, y: 10, width: tableView.frame.size.width-40, height: 20))
        headerTitle.text = self.upComingBtn.isSelected ? "\(Utility.shared.getLanguage()?.value(forKey: "Reviews_To_Write") ?? "Reviews to write")" : "\(Utility.shared.getLanguage()?.value(forKey: "Past_Reviews") ?? "Past Reviews")"
        headerTitle.font = UIFont(name: APP_FONT, size: 16)
        headerTitle.textColor =  UIColor(named: "Title_Header")
        headerTitle.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerView.backgroundColor = .white
        headerView.addSubview(headerTitle)
        
        return headerView
    }
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier{
        if self.upComingBtn.isSelected {
        return "upcomingReviewCells"
        }
        
        return "pastReviewCells"
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        if self.upComingBtn.isSelected {
            let cell : UpcomingReviewCells = skeletonView.dequeueReusableCell(withIdentifier: "upcomingReviewCells", for: indexPath) as! UpcomingReviewCells
            cell.viewItenaryTitle.text = ""
            cell.writeReviewTitle.text = ""
            cell.viewItenaryIcon.isHidden = true
            cell.writeReviewIcon.isHidden = true
            
            return cell
        }
        let cell : PastReviewCells = skeletonView.dequeueReusableCell(withIdentifier: "pastReviewCells", for: indexPath) as! PastReviewCells
        cell.reviewDateLabel.text = ""
        return cell
    }
    
}
