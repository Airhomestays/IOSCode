
import UIKit
import Apollo
import Lottie
import SkeletonView
class TripsMessageVC: UIViewController,UITableViewDelegate,UITableViewDataSource, SkeletonTableViewDataSource{
    

    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLAbel: UILabel!
    @IBOutlet weak var inboxnoLabel: UILabel!
    @IBOutlet weak var nomessageLabel: UILabel!
    @IBOutlet weak var noMessageView: UIView!
    
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var inboxTable: UITableView!
    var totalListcount:Int = 0
    var PageIndex : Int = 1
    var getallMessageArray = [GetAllThreadsQuery.Data.GetAllThread.Result]()
  
    var apollo_headerClient:ApolloClient!
     var lottieView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.checkApolloStatus()
        self.initialsetup()
        self.lottieAnimation()
        self.view.backgroundColor = UIColor(named: "colorController")
       
        
        Utility.shared.isFromMessageListingPage_host = false
        Utility.shared.isFromMessageListingPage_guest = false
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
        Utility.shared.timer.invalidate()
        self.lottieAnimation()
        DispatchQueue.main.async {
            self.noMessageView.isHidden = true
            self.getallMessageArray.removeAll()
            self.PageIndex = 1
            self.getMessageAPICall()
        }
    }
  func initialsetup()
  {
    
    inboxTable.register(UINib(nibName: "InboxContentCell", bundle: nil), forCellReuseIdentifier: "InboxContentCell")
    self.offlineView.isHidden = true
      inboxTable.estimatedRowHeight = 80
      inboxTable.isSkeletonable = false
      inboxTable.hideSkeleton()
      
      
      inboxTable.isSkeletonable = true
      inboxTable.showAnimatedGradientSkeleton()
    lottieView = LottieAnimationView.init(name:"animation")
    
      if(Utility.shared.host_message_isfromHost)
    {
          
      self.nomessageLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nomessageguest"))!)"
    }
    else
    {
      self.nomessageLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nomessagehost"))!)"
    }
      nomessageLabel.textColor =  UIColor(named: "searchPlaces_TextColor")
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
        noMessageView.isHidden = true
        errorLAbel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        inboxnoLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"inbox"))!)"
        inboxnoLabel.textColor = UIColor(named: "Title_Header")
        
        
        errorLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        nomessageLabel.font = UIFont(name: APP_FONT, size: 14)
        inboxnoLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 26)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getallMessageArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InboxContentCell", for: indexPath)as!InboxContentCell
        
        if Utility.shared.isRTLLanguage(){
            cell.profileImage.halfroundedCorners(corners: [.topLeft,.topRight,.bottomLeft], radius: 15.0)
        }else{
            cell.profileImage.halfroundedCorners(corners: [.topLeft,.topRight,.bottomRight], radius: 15.0)
        }
        
            cell.selectionStyle = .none
            if(getallMessageArray.count > 0)
            {
                if(Utility.shared.getTabbar()!)
                {
                    cell.nameLAbel.text = getallMessageArray[indexPath.row].guestProfile?.firstName != nil ? getallMessageArray[indexPath.row].guestProfile?.firstName! : ""
                }
                else
                {
                    cell.nameLAbel.text = getallMessageArray[indexPath.row].hostProfile?.firstName != nil ? getallMessageArray[indexPath.row].hostProfile?.firstName! : ""
                }
            if(getallMessageArray[indexPath.row].hostProfile?.picture != nil)
            {
                var listimage = String()
                if(Utility.shared.getTabbar()!)
                {
                    if(getallMessageArray[indexPath.row].guestProfile?.picture != nil)
                    {
                        listimage = (getallMessageArray[indexPath.row].guestProfile?.picture!)!
                      
                    }
                    
                }
                else
                {
                   listimage = (getallMessageArray[indexPath.row].hostProfile?.picture!)!
                }
            cell.profileImage.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "unknown"))
            }
            else
            {
            cell.profileImage.image = #imageLiteral(resourceName: "unknown")
            }
            
             if((getallMessageArray[indexPath.row].threadItem?.type == "message") || (getallMessageArray[indexPath.row].threadItem?.type == "instantBooking") || (getallMessageArray[indexPath.row].threadItem?.type == "intantBooking"))
             {
                 if(getallMessageArray[indexPath.row].threadItem?.type == "message") {
                     cell.approvedLabel.isHidden = true
                     cell.approvedLabelWidthConstraints.constant = 0
                     cell.dateLabel.text = getdateValue(timestamp:(getallMessageArray[indexPath.row].threadItem?.createdAt!)!)
                 }
                 else {
                 cell.approvedLabel.text = " " +  "\(Utility.shared.getbookingtype(type:(getallMessageArray[indexPath.row].threadItem?.type!)!) ?? "")     "
                 cell.approvedLabel.backgroundColor = Utility.shared.getbookingtypeColor(type: getallMessageArray[indexPath.row].threadItem?.type ?? "")
                 cell.approvedLabelWidthConstraints.constant = cell.approvedLabel.intrinsicContentSize.width + 10
                cell.approvedLabel.isHidden = false
                cell.dateLabel.text = getdateValue(timestamp:(getallMessageArray[indexPath.row].threadItem?.createdAt!)!)
                 }
            }else
             {
            cell.approvedLabel.isHidden = false
                cell.approvedLabel.text = " " +  "\(Utility.shared.getbookingtype(type:(getallMessageArray[indexPath.row].threadItem?.type ?? "")!) ?? "")     "
                cell.approvedLabel.backgroundColor = Utility.shared.getbookingtypeColor(type: getallMessageArray[indexPath.row].threadItem?.type ?? "")
                cell.approvedLabelWidthConstraints.constant = cell.approvedLabel.intrinsicContentSize.width + 10
            cell.dateLabel.text = getdateValue(timestamp:(getallMessageArray[indexPath.row].threadItem?.createdAt ?? "")!)
            }
                if((getallMessageArray[indexPath.row].threadItem?.content == nil) || (getallMessageArray[indexPath.row].threadItem?.content == ""))
                {
                    cell.messageLabel.isHidden = true
                    cell.messageLabel.text = ""
                }
                else
                {
                    cell.messageLabel.isHidden = false
                    cell.messageLabel.text = getallMessageArray[indexPath.row].threadItem?.content
                }
            }
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if Utility().isConnectedToNetwork(){
        let InboxListingObj = InboxListingVC()
                if(getallMessageArray.count > 0)
                {
        InboxListingObj.threadId = (getallMessageArray[indexPath.row].threadItem?.threadId ?? 0)!
        InboxListingObj.getmessageListquery.removeAll()
        Utility.shared.PreapproveValue.removeAllObjects()
        Utility.shared.PreapproveValue.add(getallMessageArray[indexPath.row])
        Utility.shared.ListID = "\((getallMessageArray[indexPath.row].listId)!)"
        InboxListingObj.modalPresentationStyle = .fullScreen
        InboxListingObj.getMessageListAPICall(threadId:(getallMessageArray[indexPath.row].threadItem?.threadId ?? 0)!)
        self.present(InboxListingObj, animated: true, completion: nil)
                }
            }
            else
            {
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
    {if(Int(timestamp) != nil) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inboxDateFormat
        if(Utility.shared.isRTLLanguage()) {
   dateFormatter.locale = NSLocale(localeIdentifier:"en") as Locale
        }
        else {
            dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
        }
        let date = dateFormatter.string(from: showDate)
        return date }  else {
        return Utility.shared.getdateformatter(date: timestamp) }
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
        self.offlineView.isHidden = true
        self.getallMessageArray.removeAll()
        PageIndex = 1
        self.getMessageAPICall()
        }
       
    }
    func getMessageAPICall()
    {
        if Utility().isConnectedToNetwork(){
            var threadtype = String()

            if(Utility.shared.getTabbar()! || Utility.shared.isfromNotificationHost || Utility.shared.isfromBackroundBooking || Utility.shared.isfromOfflineNotification || Utility.shared.isfromOfflineBooking)

            {
              threadtype = HOST
            }
            else{
                threadtype = GUEST
            }
            
            let getmessagequery = GetAllThreadsQuery(threadType:threadtype,currentPage:PageIndex)
            
            apollo_headerClient.fetch(query:getmessagequery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                self.inboxTable.isSkeletonable = false
                self.inboxTable.hideSkeleton()
                
                guard (result?.data?.getAllThreads?.results) != nil else{
                
                    if result?.data?.getAllThreads?.status == 500{
                        let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message:result?.data?.getAllThreads?.errorMessage, preferredStyle: .alert)
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
                    if(self.getallMessageArray.count == 0)
                    {
                        
                        self.inboxTable.isHidden = true
                        self.noMessageView.isHidden = false
                    }
                    else
                    {
                        self.inboxTable.isHidden = false
                        self.noMessageView.isHidden = true
                    }
                   
                    return
                }
                self.offlineView.isHidden = true
                self.inboxTable.isHidden = false
                self.lottieView.isHidden = true
                self.totalListcount = (result?.data?.getAllThreads?.count)!
                 self.getallMessageArray.append(contentsOf: ((result?.data?.getAllThreads?.results)!) as! [GetAllThreadsQuery.Data.GetAllThread.Result])
                self.inboxTable.isSkeletonable = false
                self.inboxTable.hideSkeleton()
               
               self.inboxTable.reloadData()
                
            }
        }
        else{
            self.offlineView.isHidden = false
            self.noMessageView.isHidden = true
            self.inboxTable.isHidden = false
            self.inboxTable.isSkeletonable = true
            self.inboxTable.showAnimatedGradientSkeleton()
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
            if IS_IPHONE_XR {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-150, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
            
        }
        
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
            let totalPages = (self.totalListcount/10)
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if((self.inboxTable.contentOffset.y + self.inboxTable.bounds.height) >= self.inboxTable.contentSize.height)
            {
                if(totalPages >= PageIndex){
                    self.PageIndex = self.PageIndex + 1
                    self.getMessageAPICall()
                    
                }
            }
        
        
    }
    
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier{
        return "InboxContentCell"
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell = skeletonView.dequeueReusableCell(withIdentifier: "InboxContentCell", for: indexPath)as!InboxContentCell
        return cell
    }
        

}
