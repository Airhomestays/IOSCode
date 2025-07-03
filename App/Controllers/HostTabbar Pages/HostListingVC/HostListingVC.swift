

import UIKit
import Apollo
import Lottie
import SkeletonView
import SwiftMessages

class HostListingVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,SkeletonTableViewDataSource{

    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var listingTitleLabel: UILabel!
    @IBOutlet weak var youdntlistLabel: UILabel!
    
    
    @IBOutlet var delContainer: UIView!
    @IBOutlet var lineView: UIView!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var deleteListingDesc: UILabel!
    @IBOutlet var deleteListingView: UIView!
    @IBOutlet var viewDeleteListing: UILabel!
    
    
    @IBOutlet weak var nodataLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet var imgThumb: UIImageView!
    @IBOutlet weak var listAddBtn: UIButton!
    
    @IBOutlet weak var postnewBtn: UIButton!
    @IBOutlet weak var becomeListingTable: UITableView!
    @IBOutlet weak var topView: UIView!
    var lottieView: LottieAnimationView!
    
    var lottieViewbtn: LottieAnimationView!
    var ispublish:Bool = false
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var manageListingArray = [ManageListingsQuery.Data.ManageListing.Result]()
    var siteSettingArray = [GetSecureSiteSettingsQuery.Data.GetSecureSiteSetting.Result]()
    var inprogress_List_Array = [ManageListingsQuery.Data.ManageListing.Result]()
    var completed_List_Array = [ManageListingsQuery.Data.ManageListing.Result]()
    
    @IBOutlet var topContainerView: UIView!
    
    @IBOutlet var btnInProgress: UIButton!
    
    @IBOutlet var btnCompleted: UIButton!
    
    @IBOutlet var inProgressLbl: UILabel!
    
    @IBOutlet var completedLbl: UILabel!
    
    var inprogressTapped:Bool = true
    var completedTapped:Bool = false
    
    var delRow = Int()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        self.initialSetup()
        
        self.CountryAPICAll()
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        delContainer.backgroundColor = UIColor(named: "colorController")
        
        listingTitleLabel.textColor =  UIColor(named: "Title_Header")
        youdntlistLabel.textColor =  UIColor(named: "Title_Header")
        
        let  longPressGesture =  UILongPressGestureRecognizer(target: self, action: #selector(handlingLongTap(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
    
        becomeListingTable?.addGestureRecognizer(longPressGesture)
        becomeListingTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.GetListSettingAPICall()
        
        self.manageListingAPICall()
    }

    @IBAction func ListAddBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if Utility.shared.getListSettingsArray.personCapacity != nil{
                let baseHost = BaseHostTableviewController()
                baseHost.showOverlay = true
                baseHost.getListSettingsArray = Utility.shared.getListSettingsArray
                Utility.shared.createId = Int()
                Utility.shared.createId = 0
                Utility.shared.host_basePrice = 0
                Utility.shared.step1_inactivestatus  = ""
                Utility.shared.isfrombecomehoststep1Edit = false
                Utility.shared.selectedAmenityIdList.removeAllObjects()
                Utility.shared.selectedspaceAmenityIdList.removeAllObjects()
                Utility.shared.selectedsafetyAmenityIdList.removeAllObjects()
                Utility.shared.selectedRules.removeAllObjects()
                Utility.shared.step2_Description = ""
                Utility.shared.step2_Title = ""
                Utility.shared.currencyvalue = ""
                Utility.shared.step1ValuesInfo = [String : Any]()
                self.view.window?.backgroundColor = UIColor.white
                baseHost.modalPresentationStyle = .fullScreen
                self.present(baseHost, animated:false, completion: nil)
            }
        } else {
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
            
        }
    }
    
    @IBAction func newListingBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if Utility.shared.getListSettingsArray.personCapacity != nil{
                let baseHost = BaseHostTableviewController()
                baseHost.getListSettingsArray = Utility.shared.getListSettingsArray
                Utility.shared.createId = Int()
                Utility.shared.createId = 0
                baseHost.showOverlay = true
                Utility.shared.host_basePrice = 0
                Utility.shared.step1_inactivestatus = ""
                Utility.shared.isfrombecomehoststep1Edit = false
                Utility.shared.selectedAmenityIdList.removeAllObjects()
                Utility.shared.selectedspaceAmenityIdList.removeAllObjects()
                Utility.shared.selectedsafetyAmenityIdList.removeAllObjects()
                Utility.shared.selectedRules.removeAllObjects()
                Utility.shared.step2_Description = ""
                Utility.shared.step2_Title = ""
                Utility.shared.currencyvalue = ""
                Utility.shared.step1ValuesInfo = [String : Any]()
                self.view.window?.backgroundColor = UIColor.white
                baseHost.modalPresentationStyle = .fullScreen
                self.present(baseHost, animated:false, completion: nil)
            }
        } else {
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
            
        }
    }
    
    func initialSetup() {

        imgThumb.image = #imageLiteral(resourceName: "progressempty")
        inProgressLbl.backgroundColor = Theme.PRIMARY_COLOR
        completedLbl.backgroundColor = UIColor.clear
        completedLbl.isHidden = true
        btnCompleted.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        btnCompleted.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"completed"))!)", for: .normal)
        btnInProgress.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"inprogress"))!)", for: .normal)
        btnInProgress.setTitleColor( UIColor(named: "Title_Header"), for: .normal)
        if(IS_IPHONE_XR || IS_IPHONE_PLUS)
        {
            self.becomeListingTable.frame.size.width = FULLWIDTH+40
        }
        becomeListingTable.register(UINib(nibName: "InProgressCell", bundle: nil), forCellReuseIdentifier: "InProgressCell")
        becomeListingTable.register(UINib(nibName: "CompletedCell", bundle: nil), forCellReuseIdentifier: "CompletedCell")
        becomeListingTable.isSkeletonable = true
        becomeListingTable.showAnimatedGradientSkeleton()
        postnewBtn.backgroundColor = Theme.SECONDARY_COLOR
        self.offlineView.isHidden = true
        self.noDataView.isHidden = true
        self.postnewBtn.layer.cornerRadius = self.postnewBtn.frame.size.height / 2
        self.postnewBtn.layer.masksToBounds = true
        inprogress_List_Array.removeAll()
        completed_List_Array.removeAll()
        lottieViewbtn = LottieAnimationView.init(name: "animation_white")
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        
        
        viewDeleteListing.text = "\((Utility.shared.getLanguage()?.value(forKey:"deletelist"))!)"
        deleteListingDesc.text = "\((Utility.shared.getLanguage()?.value(forKey:"Suredellist"))!)"
        
        btnCancel.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        btnDelete.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        btnCancel.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancel_uppercase"))!)", for: .normal)
        btnDelete.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"DeleteUpper"))!)", for: .normal)
        
        btnDelete.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        btnCancel.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        if(Utility.shared.isRTLLanguage()) {
            
            viewDeleteListing.textAlignment = .right
        }

        btnDelete.titleLabel?.font = UIFont(name: APP_FONT, size: 16.0)
        btnCancel.titleLabel?.font = UIFont(name: APP_FONT, size: 16.0)
        
        viewDeleteListing.font = UIFont(name: APP_FONT, size: 16.0)
        deleteListingDesc.font = UIFont(name: APP_FONT, size: 14.0)
        
        
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        listingTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"listings"))!)"
        youdntlistLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nolistings"))!)"
        nodataLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nodataInprogress"))!)"
        postnewBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"postnewlisting"))!)", for:.normal)
        errorLabel.textColor = UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        self.listAddBtn.setImage(#imageLiteral(resourceName: "icon_plus"), for: .normal)
        postnewBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        listingTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 26)
        youdntlistLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        nodataLabel.font = UIFont(name: APP_FONT, size: 14)
        nodataLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
        
    }
   
    func CountryAPICAll() {
        let getcountrycodeQuery = GetCountrycodeQuery()
        apollo.fetch(query: getcountrycodeQuery,cachePolicy: .fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getCountries?.results) != nil else{
                return
            }
            Utility.shared.countrylist =  ((result?.data?.getCountries?.results)!) as! [GetCountrycodeQuery.Data.GetCountry.Result]
        }
    }
    func GetListSettingAPICall() {
        let getlistsettingsquery = GetListingSettingQuery()
        apollo_headerClient.fetch(query: getlistsettingsquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getListingSettings?.results) != nil else{
                return
            }
            Utility.shared.getListSettingsArray = (result?.data?.getListingSettings?.results)!
        }
    }
    
    
    @IBAction func removeDelete(_ sender: Any) {
        
        deleteListingView.removeFromSuperview()
    }
    
    @objc func deleteBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }
        }
        
        
    }
    
    @objc func indeleteBtnTapped(_ sender: UIButton) {
        if(inprogressTapped) {
            delRow = sender.tag
            let window = UIApplication.shared.keyWindow!
            deleteListingView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            window.addSubview(deleteListingView)
            window.bringSubviewToFront(deleteListingView)
        }
        
        
    }
    
    @IBAction func deleteListingTapped(_ sender: Any) {
        
        if Utility().isConnectedToNetwork(){

            if(inprogressTapped) {
                deleteListingView.removeFromSuperview()
                self.deleteListingAPICall(listId: self.inprogress_List_Array[(delRow)].id!)
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        deleteListingView.removeFromSuperview()
    }
    
    @objc func handlingLongTap(sender: UILongPressGestureRecognizer){
        
        if(inprogressTapped) {
            if Utility.shared.isConnectedToNetwork(){
                
                let pointTouched = sender.location(in: self.becomeListingTable)
                let indexValue = self.becomeListingTable.indexPathForRow(at: pointTouched)
                
                
                if sender.state == .ended {
                    let touchPoint = sender.location(in: self.becomeListingTable)
                    if let indexPath = self.becomeListingTable.indexPathForRow(at: touchPoint) {
                        if(indexPath.section == 0) {
                            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let DeleteAction: UIAlertAction = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"delete"))!)", style: .destructive) { action in
                                
                                if indexPath.row == nil{
                                    return
                                }else{
                                    self.deleteListingAPICall(listId: self.inprogress_List_Array[(indexPath.row)].id!)
                                }
                                
                            }
                            let cancelAction: UIAlertAction = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", style: .cancel) { action -> Void in }
                            actionSheetController.addAction(DeleteAction)
                            actionSheetController.addAction(cancelAction)
                            present(actionSheetController, animated: true, completion: nil)
                        } else {
                            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            let DeleteAction: UIAlertAction = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"delete"))!)", style: .destructive) { action in
                                
                                if indexPath.row == nil{
                                    return
                                }else{
                                    self.deleteListingAPICall(listId: self.completed_List_Array[(indexPath.row)].id!)
                                }
                                
                            }
                            let cancelAction: UIAlertAction = UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", style: .cancel) { action -> Void in }
                            actionSheetController.addAction(DeleteAction)
                            actionSheetController.addAction(cancelAction)
                            present(actionSheetController, animated: true, completion: nil)
                        }
                    }
                    
                }
                
            }else{
                
                offlineView.isHidden = false
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
                if IS_IPHONE_X || IS_IPHONE_XR{
                    offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
                }else{
                    offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
                }
            }
        }
    }
    func siteSettingsAPICall() {
        if Utility.shared.isConnectedToNetwork(){
            let siteSettingsquery = GetSecureSiteSettingsQuery(settingsType:"site_settings", securityKey: SECURE_KEY)
            apollo_headerClient.fetch(query:siteSettingsquery,cachePolicy: .fetchIgnoringCacheData){ [self](result,error) in
                if(result?.data?.getSecureSiteSettings?.status == 200) {
                    self.siteSettingArray = result?.data?.getSecureSiteSettings?.results as! [GetSecureSiteSettingsQuery.Data.GetSecureSiteSetting.Result]
                    for i in self.siteSettingArray{
                        if(i.name == "listingApproval") {
                            if(i.value == "1") {
                                Utility.shared.listingApproval = "required"
                            } else {
                                Utility.shared.listingApproval = "optional"
                            }
                        }
                    }
                    self.manageListingAPI()
                }
            }
        }
    }
    
    func manageListingAPI() {
        let manageListingquery = ManageListingsQuery()
        apollo_headerClient.fetch(query: manageListingquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            if  result?.data?.manageListings?.status == 200 {
                guard (result?.data?.manageListings?.results) != nil else{
                    
                    if result?.data?.manageListings?.status == 500{
                        let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message:result?.data?.manageListings?.errorMessage, preferredStyle: .alert)
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
                    self.becomeListingTable.isSkeletonable = false
                    self.becomeListingTable.hideSkeleton()
                    self.becomeListingTable.isHidden = true
                    self.noDataView.isHidden = false
                    return
                }
                self.becomeListingTable.isHidden = false
                self.becomeListingTable.isSkeletonable = false
                self.becomeListingTable.hideSkeleton()
                self.noDataView.isHidden = true
                self.inprogress_List_Array.removeAll()
                self.completed_List_Array.removeAll()
                self.becomeListingTable.isHidden = false
                self.manageListingArray = ((result?.data?.manageListings?.results)!) as! [ManageListingsQuery.Data.ManageListing.Result]
                
                for i in self.manageListingArray {
                    if(i.isReady == false) {
                        self.inprogress_List_Array.append(i)
                    } else{
                        self.completed_List_Array.append(i)
                    }
                }
                if((self.inprogress_List_Array.count == 0) && (self.inprogressTapped)) {
                    self.becomeListingTable.isHidden = true
                    self.noDataView.isHidden = false
                }
                else if((self.completed_List_Array.count == 0) && (self.completedTapped)) {
                    self.becomeListingTable.isHidden = true
                    self.noDataView.isHidden = false
                }
                if(!self.ispublish){
                    self.becomeListingTable.reloadData()
                }
                else{
                    self.ispublish = false
                }
                if(self.manageListingArray.count == 0 ) {
                    self.becomeListingTable.isHidden = true
                    self.noDataView.isHidden = false
                }
                
            }else{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let welcomeObj = WelcomePageVC()
                appDelegate.setInitialViewController(initialView: welcomeObj)
            }
            
            
        }
    }
    
    
    func manageListingAPICall() {
        if Utility.shared.isConnectedToNetwork(){
            self.siteSettingsAPICall()
        }else{
            offlineView.isHidden = false
            becomeListingTable.isSkeletonable = true
            becomeListingTable.showAnimatedGradientSkeleton()
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    
    func deleteListingAPICall(listId:Int) {
        if Utility.shared.isConnectedToNetwork() {
            
            let deleteListingMutation = RemoveListingMutation(listId: listId)
            apollo_headerClient.perform(mutation: deleteListingMutation){(result,error) in
                if(result?.data?.removeListing?.status == 200) {
                    self.manageListingAPICall()
                }else{
                    self.view.makeToast(result?.data?.removeListing?.errorMessage)
                }
            }
        }else{
            offlineView.isHidden = false
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineView.isHidden = true
        }
        
    }
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2, width:100, height:100)
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

    
    func numberOfSections(in tableView: UITableView) -> Int{
        if(manageListingArray.count > 0) {
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(inprogressTapped)
        {
            if(inprogress_List_Array.count > 0)
            {
                return inprogress_List_Array.count
            }
            return 0
        }
        else{
            if(completed_List_Array.count > 0)
            {
                return completed_List_Array.count
            }
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(!inprogressTapped) {
            if(completed_List_Array.count > 0)
            {
                if let status = completed_List_Array[indexPath.row].listApprovalStatus {
                    if(Utility.shared.listingApproval == "required" && completed_List_Array[indexPath.row].listApprovalStatus! == "pending")
                    {
                        return 300
                    }
                    else {
                        return 275
                    }
                }
                else {
                    return 275
                }
            } else {
                return 275
            }
        }
        return 275
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(inprogressTapped) {
            let cell = tableView.dequeueReusableCell(withIdentifier:"CompletedCell", for: indexPath)as! CompletedCell
            cell.lineLabel.isHidden = false
            cell.heightConstant.constant = 0
            cell.bottomConstant.constant = 5
            
            cell.previewBtn.semanticContentAttribute = .forceLeftToRight
            
            if (Utility.shared.isRTLLanguage()){
                cell.previewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            }else{
                cell.previewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            cell.editBtn.isHidden = true
            cell.submitLabel.isHidden = true
            cell.previewBtn.isHidden = false
            cell.selectionStyle = .none
            if(inprogress_List_Array[indexPath.row].title != nil) {
                cell.titleLabel.text = inprogress_List_Array[indexPath.row].title!
            } else {
                if(inprogress_List_Array[indexPath.row].settingsData!.count > 0) {
                    cell.titleLabel.text = inprogress_List_Array[indexPath.row].settingsData![0]!.listsettings != nil ? "\((inprogress_List_Array[indexPath.row].settingsData![0]!.listsettings!.itemName)!) \((Utility.shared.getLanguage()?.value(forKey:"in"))!) \(inprogress_List_Array[indexPath.row].city!)" : "\((Utility.shared.getLanguage()?.value(forKey:"entireplacein"))!) \(inprogress_List_Array[indexPath.row].city != nil ? inprogress_List_Array[indexPath.row].city! : "")"
                } else {
                    cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"entireplacein"))!) \(inprogress_List_Array[indexPath.row].city != nil ? inprogress_List_Array[indexPath.row].city! : "")"
                }
            }
            cell.updateDateLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"lastupdatedon"))!) \(getdateValue(timestamp: inprogress_List_Array[indexPath.row].updatedAt!))"
            if(inprogress_List_Array[indexPath.row].listPhotoName != nil) {
                let listimage = inprogress_List_Array[indexPath.row].listPhotoName!
                cell.listImage.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                cell.listImage.contentMode = .scaleAspectFill
            } else {
                cell.listImage.image = #imageLiteral(resourceName: "camera-50")
            }
            var image = String()
            
            image = inprogress_List_Array[indexPath.row].listPhotoName != nil ? inprogress_List_Array[indexPath.row].listPhotoName! : ""
            
            if(inprogress_List_Array[indexPath.row].listingSteps?.step1 != nil && inprogress_List_Array[indexPath.row].listingSteps?.step2  != nil && inprogress_List_Array[indexPath.row].listingSteps?.step3 != nil ) {
                let listValue = getistPercentage(ready: inprogress_List_Array[indexPath.row].isReady!, step1:(inprogress_List_Array[indexPath.row].listingSteps?.step1!)!, step2:(inprogress_List_Array[indexPath.row].listingSteps?.step2!)!, step3: (inprogress_List_Array[indexPath.row].listingSteps?.step3!)!, imagename:image)
                cell.listingprogressLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"youre"))!) \(listValue)% \((Utility.shared.getLanguage()?.value(forKey:"donelisting"))!)"
                cell.progressBarView.progress = Float(listValue)/Float (100)
            } else {
                cell.progressBarView.progress = Float(20)/Float (100)
            }
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(indeleteBtnTapped),for:.touchUpInside)
            
            cell.editBtn.isHidden = true
            cell.submitLabel.isHidden = true

            cell.previewBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"delete"))!)  ", for: .normal)
            cell.previewBtn.tag = indexPath.row
            cell.previewBtn.addTarget(self, action: #selector(indeleteBtnTapped),for:.touchUpInside)
            cell.previewBtn.setImage(#imageLiteral(resourceName: "deleteeye"), for: .normal)
            cell.publishBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"editlist"))!)  ", for: .normal)
            cell.publishBtn.tag = indexPath.row
            cell.publishBtn.addTarget(self, action: #selector(editBtnTapped),for:.touchUpInside)
            cell.previewBtn.addTarget(self, action: #selector(indeleteBtnTapped),for:.touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell", for: indexPath)as! CompletedCell
            cell.selectionStyle = .none
            cell.previewBtn.semanticContentAttribute = .forceRightToLeft
            cell.lineLabel.isHidden = false
            cell.previewBtn.isHidden = false
            cell.editBtn.isHidden = false
            cell.submitLabel.isHidden = false
            cell.previewBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"more"))!)  ", for: .normal)
            cell.previewBtn.tag = indexPath.row
            cell.previewBtn.setImage(#imageLiteral(resourceName: "tripsMore"), for: .normal)
            
            if(completed_List_Array[indexPath.row].title != nil) {
                cell.titleLabel.text = completed_List_Array[indexPath.row].title!
            } else {
                if(completed_List_Array[indexPath.row].settingsData!.count > 0) {
                    cell.titleLabel.text = "\((completed_List_Array[indexPath.row].settingsData![0]!.listsettings!.itemName)!) \((Utility.shared.getLanguage()?.value(forKey:"in"))!) \(completed_List_Array[indexPath.row].city!)"
                } else {
                    cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"entireplacein"))!) \(completed_List_Array[indexPath.row].city != nil ? completed_List_Array[indexPath.row].city! : "")"
                }
            }
            
            cell.publishBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"editlist"))!)  ", for: .normal)
            cell.publishBtn.tag = indexPath.row
            cell.publishBtn.addTarget(self, action: #selector(editBtnTapped),for:.touchUpInside)
            
            if let updatedat = completed_List_Array[indexPath.row].updatedAt {
                cell.updateDateLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"lastupdatedon"))!) \(getdateValue(timestamp:updatedat))" }
            if(completed_List_Array[indexPath.row].listPhotoName != nil){
                let listimage = completed_List_Array[indexPath.row].listPhotoName!
                cell.listImage.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
                cell.listImage.contentMode = .scaleAspectFill
            } else {
                cell.listImage.image = #imageLiteral(resourceName: "camera-50")
            }
            var image = String()
            if(completed_List_Array[indexPath.row].listPhotoName != nil) {
                image = completed_List_Array[indexPath.row].listPhotoName!
            } else {
                image = ""
            }
            let listValue = getistPercentage(ready: completed_List_Array[indexPath.row].isReady!, step1:(completed_List_Array[indexPath.row].listingSteps?.step1!)!, step2:(completed_List_Array[indexPath.row].listingSteps?.step2!)!, step3: (completed_List_Array[indexPath.row].listingSteps?.step3!)!, imagename:image)
            cell.listingprogressLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"youre"))!) \(listValue)% \((Utility.shared.getLanguage()?.value(forKey:"donelisting"))!)"
            cell.progressBarView.progress = Float(listValue)/Float (100)
            cell.publishBtn.tag = indexPath.row
            cell.previewBtn.tag = indexPath.row
            cell.editBtn.tag = indexPath.row
            if(Utility.shared.listingApproval == "optional") {
                cell.heightConstant.constant = 0
                cell.bottomConstant.constant = 5
                cell.editBtn.isHidden = false
                if(completed_List_Array[indexPath.row].isPublished! == true) {
                    cell.editBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"unpublish"))!)  ", for: .normal)
                    cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"unpublish"))!)  "
                    Utility.shared.unpublish_preview_check = false
                } else{
                    
                    cell.editBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"publish"))!)  ", for: .normal)
                    cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"publish"))!)  "
                    Utility.shared.unpublish_preview_check = true
                }
            } else if(Utility.shared.listingApproval == "required" &&  completed_List_Array[indexPath.row].listApprovalStatus == nil) {
                cell.heightConstant.constant = 0
                cell.bottomConstant.constant = 5
                cell.editBtn.isHidden = true
                cell.editBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)", for: .normal)
                cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)  "
            } else if(Utility.shared.listingApproval == "required" &&  completed_List_Array[indexPath.row].listApprovalStatus! == "approved") {
                cell.heightConstant.constant = 0
                cell.bottomConstant.constant = 5
                if(completed_List_Array[indexPath.row].isPublished! == true) {
                    cell.editBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"unpublish"))!)  ", for: .normal)
                    cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"unpublish"))!)  "
                    Utility.shared.unpublish_preview_check = false
                    cell.editBtn.isHidden = false
                } else {
                    cell.editBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"publish"))!)  ", for: .normal)
                    cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"publish"))!)  "
                    Utility.shared.unpublish_preview_check = true
                    cell.editBtn.isHidden = false
                }
                
            } else if(Utility.shared.listingApproval == "required" && completed_List_Array[indexPath.row].listApprovalStatus! == "declined") {
                cell.heightConstant.constant = 0
                cell.bottomConstant.constant = 5
                cell.editBtn.isHidden = true
                
                cell.editBtn.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"submit_appeal"))!)  ", for: .normal)
                cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"submit_appeal"))!)  "
            } else if(Utility.shared.listingApproval == "required" && completed_List_Array[indexPath.row].listApprovalStatus! == "pending") {
                cell.heightConstant.constant = 20
                cell.bottomConstant.constant = 16
                cell.editBtn.isHidden = true
                cell.editBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"waitingforAdmin"))!)", for: .normal)
                cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"waitingforAdmin"))!)  "
                cell.verificationLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"waitingforAdmin"))!)  "
            } else {
                
                cell.heightConstant.constant = 0
                cell.bottomConstant.constant = 0
                cell.editBtn.isHidden = true
                cell.editBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)", for: .normal)
                cell.submitLabel.text = "  \((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)  "
            }
            
            cell.deleteBtn.tag = indexPath.row
            if(cell.editBtn.titleLabel?.text == "\((Utility.shared.getLanguage()?.value(forKey:"waitingforAdmin"))!)" ) {
                cell.editBtn.removeTarget(self, action: nil, for: .touchUpInside)
            } else {
                cell.editBtn.addTarget(self, action: #selector(PublishBtnTapped),for:.touchUpInside)
                cell.editBtn.isUserInteractionEnabled = true
            }
            
            cell.previewBtn.addTarget(self, action: #selector(previewBtnTapped),for:.touchUpInside)
            cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped),for:.touchUpInside)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Utility().isConnectedToNetwork(){
            if(inprogressTapped) {
                let becomeHostObj = BecomeHostVC()
                if(inprogress_List_Array.count > 0) {
                    becomeHostObj.listID = "\(inprogress_List_Array[indexPath.row].id != nil ? inprogress_List_Array[indexPath.row].id! : 0)"
                    becomeHostObj.showListingStepsAPICall(listID: "\(inprogress_List_Array[indexPath.row].id!)")
                    becomeHostObj.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController?.present(becomeHostObj, animated:false, completion: nil)
                }
            }
            else{
                let becomeHostObj = BecomeHostVC()
                if(completed_List_Array.count > 0)
                {
                    becomeHostObj.listID = "\(completed_List_Array[indexPath.row].id != nil ? completed_List_Array[indexPath.row].id! : 0)"
                    becomeHostObj.showListingStepsAPICall(listID: "\(completed_List_Array[indexPath.row].id!)")
                    becomeHostObj.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController?.present(becomeHostObj, animated: false, completion: nil)
                }
            }
        } else {
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
            
        }
    }
    @objc func autoscrolling() {
        self.lottieViewbtn.play()
    }
    
    func lottienextAnimation(sender:UIButton) {
        lottieViewbtn = LottieAnimationView.init(name: "lottie_red")
        self.lottieViewbtn.isHidden = false
        self.lottieViewbtn.frame = CGRect(x:10, y:-30, width:100, height:100)
        self.lottieViewbtn.backgroundColor = .red
        sender.addSubview(self.lottieViewbtn)
        self.lottieViewbtn.backgroundColor = UIColor.clear
        sender.setTitle("", for:.normal)
        self.lottieViewbtn.play()
        Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    func submitForVerification(listID:Int) {
        let submitforverificationmutation = SubmitForVerificationMutation(id:listID, listApprovalStatus:"pending")
        apollo_headerClient.perform(mutation: submitforverificationmutation){(result,error) in
            
            if(result?.data?.submitForVerification?.status == 200) {
                self.lottieViewbtn.isHidden = true
                self.manageListingAPI()
                
            } else {
                self.lottieViewbtn.isHidden = true
                
                self.view.makeToast(result?.data?.submitForVerification?.errorMessage!)
                
            }
        }
    }
    
    @objc func editBtnTapped(_ sender: UIButton) {
        let becomeHostObj = BecomeHostVC()
        if(inprogressTapped) {
            if(inprogress_List_Array.count > 0) {
                becomeHostObj.listID = "\(inprogress_List_Array[sender.tag].id != nil ? inprogress_List_Array[sender.tag].id! : 0)"
                becomeHostObj.showListingStepsAPICall(listID: "\(inprogress_List_Array[sender.tag].id!)")
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.view.window?.rootViewController?.present(becomeHostObj, animated:false, completion: nil)
            }
        } else {
            if(completed_List_Array.count > 0)
            {
                becomeHostObj.listID = "\(completed_List_Array[sender.tag].id != nil ? completed_List_Array[sender.tag].id! : 0)"
                becomeHostObj.showListingStepsAPICall(listID: "\(completed_List_Array[sender.tag].id!)")
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.view.window?.rootViewController?.present(becomeHostObj, animated: false, completion: nil)
            }
        }
    }
    
    @objc func PublishBtnTapped(_ sender: UIButton) {
        if Utility().isConnectedToNetwork(){
            let btnsendtag: UIButton = sender
            
            
            if(btnsendtag.currentTitle == "  \((Utility.shared.getLanguage()?.value(forKey:"publish"))!)  "){
                Utility.shared.unpublish_preview_check = false
                self.lottienextAnimation(sender: btnsendtag)
                PublishAPICall(listid: completed_List_Array[sender.tag].id!, action: "publish", sender: sender)
            }
            else if(btnsendtag.currentTitle == "  \((Utility.shared.getLanguage()?.value(forKey:"submit_appeal"))!)  " || btnsendtag.currentTitle == "\((Utility.shared.getLanguage()?.value(forKey:"submit_verification"))!)") {
                self.lottienextAnimation(sender: btnsendtag)
                submitForVerification(listID: completed_List_Array[sender.tag].id!)
                btnsendtag.isHidden = true
            } else {
                Utility.shared.unpublish_preview_check = true
                
                self.lottienextAnimation(sender: btnsendtag)
                PublishAPICall(listid: completed_List_Array[sender.tag].id!, action: "unPublish", sender: sender)
                btnsendtag.isHidden = false
            }
        } else {
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
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
        
    }
    
    func PublishAPICall(listid:Int,action:String,sender:UIButton) {
        let managepublishstatusMutation = ManagePublishStatusMutation(listId: listid, action: action)
        apollo_headerClient.perform(mutation: managepublishstatusMutation){(result,error) in
            let btnsendtag: UIButton = sender
            
            if(result?.data?.managePublishStatus?.status == 200) {
                self.lottieViewbtn.isHidden = true
                self.ispublish = true
                self.manageListingAPICall()
                if(!Utility.shared.unpublish_preview_check){
                    btnsendtag.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"unpublish"))!)  ", for: .normal)
                    
                } else {
                    btnsendtag.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"publish"))!)  ", for: .normal)
                }
            } else {
                self.lottieViewbtn.isHidden = true
                btnsendtag.setTitle("  \((Utility.shared.getLanguage()?.value(forKey:"unpublish"))!)  ", for: .normal)
                self.view.makeToast(result?.data?.managePublishStatus?.errorMessage!)
            }
            
        }
    }
    
    
    
    
    @objc func previewBtnTapped(_ sender: UIButton) {
        if(completedTapped) {
            let  menuOptionNameArray = ["\((Utility.shared.getLanguage()?.value(forKey:"Preview"))!)","\((Utility.shared.getLanguage()?.value(forKey:"delete"))!)"]
            let menuOprionImageArray = [#imageLiteral(resourceName: "preview"),#imageLiteral(resourceName: "Cancel")]
            
            
            let configuration = FTConfiguration()
            configuration.backgoundTintColor = UIColor(named: "colorController")!
            configuration.menuSeparatorColor = UIColor(named: "colorController")!
            configuration.textColor = UIColor(named: "Title_Header")!
            configuration.cornerRadius = 5
            configuration.menuWidth = 85
            configuration.menuIconSize = 15.0
            configuration.borderColor = Theme.descriptionBorder_Color
            
            FTPopOverMenu.showForSender(sender: sender,
                                        with: menuOptionNameArray, menuImageArray: menuOprionImageArray,
                                        config: configuration,
                                        done: { [self] (selectedIndex) in
                if(selectedIndex == 0){
                    if Utility().isConnectedToNetwork(){
                        let viewListing = UpdatedViewListing()
                        viewListing.listID = self.completed_List_Array[sender.tag].id ?? 0
                        Utility.shared.unpublish_preview_check = true
                        viewListing.modalPresentationStyle = .fullScreen
                        self.present(viewListing, animated: true, completion: nil)
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
                        if IS_IPHONE_X || IS_IPHONE_XR{
                            self.offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
                        }else{
                            self.offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
                        }
                    }
                } else if(selectedIndex == 1){
                    if Utility().isConnectedToNetwork(){
                        self.deleteListingAPICall(listId: self.completed_List_Array[(sender.tag)].id!)
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
                        if IS_IPHONE_X || IS_IPHONE_XR{
                            offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
                        }else{
                            offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
                        }
                    }
                }
                
            },cancel: {
            })
        }
    }
    func getdateValue(timestamp:String) -> String
    {
        if(Int(timestamp) != nil ) {
            let timestamValue = Int(timestamp)!/1000
            let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            if(Utility.shared.isRTLLanguage()) {
                dateFormatter.locale = NSLocale(localeIdentifier:"en") as Locale
            } else {
                dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
            }
            let date = dateFormatter.string(from: showDate)
            return date } else {
                return Utility.shared.getdateformatter(date: timestamp) }
    }
    
    func getistPercentage(ready:Bool,step1:String,step2:String,step3:String,imagename:String) -> Int {
        if(ready) {
            return 100
        } else if (step1 == "completed" && step2 == "completed" &&
                   step3 == "completed" && !ready) {
            if (imagename == "") {
                return 90
            } else {
                return 100
            }
        } else if (step1 == "active") {
            return 20
        } else if(step1 == "completed"){
            if (step2 == "completed") {
                if (imagename == "") {
                    if (step3 == "completed") {
                        return 60
                    } else {
                        return 50
                    }
                } else {
                    return 60
                }
            } else if (imagename != "") {
                return 40
            } else {
                return 30
            }
        }
        return 0
    }
    
    @IBAction func inProgressTapped(_ sender: Any) {
        
        
        btnCompleted.isUserInteractionEnabled = true
        completedLbl.isHidden = true
        inProgressLbl.isHidden = false
        inProgressLbl.backgroundColor = Theme.PRIMARY_COLOR
        completedLbl.backgroundColor = UIColor.clear
        
        btnCompleted.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        
        if(offlineView.isHidden) {
            
            if(self.inprogress_List_Array.count == 0)  {
                self.becomeListingTable.isHidden = true
                self.noDataView.isHidden = false
            } else {
                self.becomeListingTable.isHidden = false
                self.noDataView.isHidden = true
            }
        } else {
            becomeListingTable.isSkeletonable = true
            becomeListingTable.showAnimatedGradientSkeleton()
            
            
        }
        btnInProgress.setTitleColor( UIColor(named: "Title_Header"), for: .normal)
        inprogressTapped = true
        completedTapped = false
        self.becomeListingTable.reloadData()
    }
    
    @IBAction func completedTapped(_ sender: Any) {
        
        btnInProgress.isUserInteractionEnabled = true
        inProgressLbl.isHidden = true
        completedLbl.isHidden = false
        completedLbl.backgroundColor = Theme.PRIMARY_COLOR
        inProgressLbl.backgroundColor = UIColor.clear
        if(offlineView.isHidden){
            if(self.completed_List_Array.count == 0)  {
                self.becomeListingTable.isHidden = true
                self.noDataView.isHidden = false
            }
            else {
                self.becomeListingTable.isHidden = false
                self.noDataView.isHidden = true
            }
        } else {
            becomeListingTable.isSkeletonable = true
            becomeListingTable.showAnimatedGradientSkeleton()
        }
        
        
        btnInProgress.setTitleColor(Theme.tripsTabDisabledColor, for: .normal)
        
        btnCompleted.setTitleColor( UIColor(named: "Title_Header"), for: .normal)
        
        inprogressTapped = false
        completedTapped = true
        self.becomeListingTable.reloadData()
        
    }
    
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier{
        
        return "CompletedCell"
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        
        let cell = skeletonView.dequeueReusableCell(withIdentifier: "CompletedCell", for: indexPath)as! CompletedCell
        cell.editBtn.isHidden = true
        cell.submitLabel.isHidden = true
        cell.lineLabel.isHidden = true
        cell.previewBtn.isHidden = true
        cell.editBtn.borderColor = .clear
        cell.editBtn.backgroundColor = .clear
        
        return cell
    }
}

