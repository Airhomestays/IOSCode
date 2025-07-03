
import UIKit
import Lottie
import Apollo
import SwiftMessages
import SkeletonView

class SavedPageVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,SaveGroupPageVCDelegate, UICollectionViewDelegateFlowLayout,SkeletonCollectionViewDataSource{
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "SavedPageVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBOutlet weak var startexploreBtn: UIButton!
    @IBOutlet weak var nolistDescriptionLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nowhishlistView: UIView!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var savedTable: UICollectionView!
    @IBOutlet weak var topView: UIView!
    var lottieView: LottieAnimationView!
    var apollo_headerClient:ApolloClient!
    
    
    @IBOutlet var nodataImage: UIImageView!
    @IBOutlet weak var savedPageTitle: UILabel!
    var whishlistarray = [GetAllWishListGroupQuery.Data.GetAllWishListGroup.Result]()
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.lottieAnimation()
        self.initialSetup()
        self.checkApolloStatus()
        
        self.savedPageTitle.text = "\(Utility.shared.getLanguage()?.value(forKey: "saved") ?? "Saved")"
        self.savedPageTitle.textColor =  UIColor(named: "Title_Header")
        self.savedPageTitle.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.savedPageTitle.font = UIFont(name: APP_FONT_MEDIUM, size: 26.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.WhishlistAPICall()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
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
    
    func initialSetup()
    {
        savedTable.register(UINib(nibName: "WhishlistCell", bundle: nil), forCellWithReuseIdentifier: "WhishlistCell")
        savedTable.register(UINib(nibName: "whishheaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "whishheaderView")
        self.nowhishlistView.isHidden = true
        
        self.view.backgroundColor = UIColor(named: "colorController")
        
        savedTable?.isSkeletonable = true
        self.savedTable?.showAnimatedGradientSkeleton()
        
        
        nodataImage.image = #imageLiteral(resourceName: "explore_empty")
        
        if let flowLayout = savedTable.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
        }
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        startexploreBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size:16)
        startexploreBtn.layer.cornerRadius = startexploreBtn.frame.size.height / 2
        startexploreBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        startexploreBtn.layer.borderWidth = 1
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        nolistDescriptionLabel.font = UIFont(name: APP_FONT, size: 14)
        self.topView.isHidden = true
        self.offlineView.isHidden = true
        startexploreBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        nolistDescriptionLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nodatasaveddesc"))!)"
        startexploreBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"tabexplore"))!)", for:.normal)
        if(Utility.shared.isRTLLanguage()){
            nolistDescriptionLabel.textAlignment = .right
            startexploreBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        }
        
    }
    @IBAction func startexploringTapped(_ sender: Any) {
        
        
        Utility.shared.setTab(index: 0)
        CustomTabbar().tabBarController?.selectedIndex = 0
        self.tabBarController?.selectedIndex = 0
        
        
        
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
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    func whishDeleteAPIcall() {
        NotificationCenter.default.post(name: Notification.Name("Whishlishdelete"), object: nil)
        self.initialSetup()
        self.lottieAnimation()
        self.checkApolloStatus()
        self.WhishlistAPICall()
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieAnimation()
            self.savedTable.isHidden = false
            offlineView.isHidden = true
            self.WhishlistAPICall()
        }
    }
    
    func WhishlistAPICall()
    {
        
        if Utility().isConnectedToNetwork(){
            let whishlistQuery = GetAllWishListGroupQuery()
            apollo_headerClient.fetch(query: whishlistQuery,cachePolicy:.fetchIgnoringCacheData){ (result,error) in
                guard (result?.data?.getAllWishListGroup?.results) != nil else{
                    if result?.data?.getAllWishListGroup?.status == 500{
                        let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.getAllWishListGroup?.errorMessage, preferredStyle: .alert)
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
                    
                    
                    self.topView.isHidden = false
                    self.nowhishlistView.isHidden = false
                    self.lottieView.isHidden = true
                    self.savedTable.isHidden = true
                    self.lottieView.isHidden = true
                    self.savedTable?.hideSkeleton()
                    self.savedTable.isSkeletonable = false
                    return
                }
                self.nowhishlistView.isHidden = true
                self.savedTable.isHidden = false
                self.whishlistarray = ((result?.data?.getAllWishListGroup?.results)!) as! [GetAllWishListGroupQuery.Data.GetAllWishListGroup.Result]
                self.lottieView.isHidden = true
                self.savedTable?.hideSkeleton()
                self.savedTable.isSkeletonable = false
                self.savedTable.reloadData()
                
            }
        }
        else
        {
            self.lottieView.isHidden = true
            
            self.offlineView.isHidden = false
            self.savedTable.isHidden = false
            self.nowhishlistView.isHidden = true
            savedTable?.prepareSkeleton(completion: { [self] done in
                savedTable?.isSkeletonable = true
                self.savedTable?.showAnimatedGradientSkeleton()
            })
            self.view?.bringSubviewToFront(offlineView)
            self.view.bringSubviewToFront(offlineView)
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (savedTable.frame.size.width/2 - 5), height:155)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return whishlistarray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhishlistCell", for: indexPath)as! WhishlistCell
        cell.tag = indexPath.item + 2000
        cell.entireView.backgroundColor = .clear
        cell.entireView.cornerRadius = 0
        cell.entireView.layer.masksToBounds = false
        cell.titleLabel.text = whishlistarray[indexPath.row].name ?? ""
        cell.countLabel.text = " (\(whishlistarray[indexPath.row].wishListCount ?? 0)) "
        cell.likeImage.isHidden = true
        if(whishlistarray[indexPath.row].wishListCount!>0)
        {
            if let listimage = whishlistarray[indexPath.row].wishListCover?.listData?.listPhotoName
            {
                cell.whishImage.sd_setImage(with: URL(string:"\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                cell.whishImage.contentMode = .scaleAspectFill
            }
            else{
                cell.whishImage.image = #imageLiteral(resourceName: "saveempty")
            }
        }
        else
        {
            cell.likeImage.isHidden = true
            cell.whishImage.image = #imageLiteral(resourceName: "saveempty")
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Utility().isConnectedToNetwork(){
            let savedPageObj = SaveGroupPageVC()
            savedPageObj.groupID = whishlistarray[indexPath.row].id != nil ? whishlistarray[indexPath.row].id! : 0
            savedPageObj.savedGroupAPICall(groupID:whishlistarray[indexPath.row].id != nil ? whishlistarray[indexPath.row].id! : 0, PageIndex: 1)
            savedPageObj.delegate = self
            self.definesPresentationContext = true
            savedPageObj.modalPresentationStyle = .overCurrentContext
            savedPageObj.modalPresentationStyle = .fullScreen
            self.present(savedPageObj, animated: true, completion: nil)
        }
        else
        {
            self.lottieView.isHidden = true
            self.savedTable.isHidden = false
            savedTable?.prepareSkeleton(completion: { [self] done in
                self.savedTable.isSkeletonable = true
                self.savedTable.showAnimatedGradientSkeleton()
            })
            self.view.bringSubviewToFront(offlineView)
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
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int  {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        
        return "WhishlistCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell?
    {
        let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: "WhishlistCell", for: indexPath)as! WhishlistCell
        cell.entireView.cornerRadius = 10
        cell.entireView.layer.masksToBounds = true
        
        return cell
    }

}
