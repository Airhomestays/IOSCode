
import UIKit
import Apollo
import Lottie

class HostProfileViewPage: UIViewController,UITableViewDelegate,UITableViewDataSource{

 
    @IBOutlet var lblHostName: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet var backBtn: UIButton!
    var profileid = Int()
    var profilename = String()
    var verifiedInfoCount:Int = 0
    
    var lottieView: LottieAnimationView!
    var isfromreview: Bool = false
    
    @IBOutlet var hostprofileTable: UITableView!
    
    var apollo_headerClient: ApolloClient!
    var reiewListingArray = [UserReviewsQuery.Data.UserReview.Result]()
    var showuserprofileArray = ShowUserProfileQuery.Data.ShowUserProfile.Result()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkApolloStatus()
        self.registerCell()
        hostprofileTable.separatorColor = .clear
        hostprofileTable.estimatedRowHeight = 200
        hostprofileTable.rowHeight = UITableView.automaticDimension
        
        
        lblHostName.textColor = UIColor(named: "Title_Header")
        
        self.view.backgroundColor = UIColor(named: "colorController")

        
        if(profilename != "")
        {
            if(isfromreview){
                lblHostName.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
                lblHostName.text = "\((Utility.shared.getLanguage()?.value(forKey:"user"))!)"
            }
            else {
           lblHostName.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
           lblHostName.text = "\((Utility.shared.getLanguage()?.value(forKey:"host"))!)"
            }
        }
        lblHostName.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        if(Utility.shared.isRTLLanguage()){
            backBtn.rotateImageViewofBtn()
        }
       
    }
    
    func checkApolloStatus(){
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
        
        self.showprofileAPICall(profileid: self.profileid)
    }
  func registerCell()
  {
    hostprofileTable.register(UINib(nibName: "HostprofileviewCell", bundle: nil), forCellReuseIdentifier: "HostprofileviewCell")
    hostprofileTable.register(UINib(nibName: "AboutDynamicCell", bundle: nil), forCellReuseIdentifier: "AboutDynamicCell")
    hostprofileTable.register(UINib(nibName: "ReportuserCell", bundle: nil), forCellReuseIdentifier: "ReportuserCell")
    hostprofileTable.register(UINib(nibName: "HostVerifiedInfoCellTableViewCell", bundle: nil), forCellReuseIdentifier: "HostVerifiedInfoCellTableViewCell")
    hostprofileTable.register(UINib(nibName: "ReviewUserCell", bundle: nil), forCellReuseIdentifier: "ReviewUserCell")
      hostprofileTable.register(UINib(nibName: "VerifiedInfoCell", bundle: nil), forCellReuseIdentifier: "VerifiedInfoCell")
    }
    func lottieanimation()
    {
        
        lottieView = LottieAnimationView.init(name: "animation_white")
        
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y:FULLHEIGHT/2-50, width:100, height:100)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
     
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    func showprofileAPICall(profileid:Int)
    {
        if Utility().isConnectedToNetwork(){
        self.lottieanimation()
        let showprofileQuery = ShowUserProfileQuery(profileId:profileid, isUser:false)
            
         
        apollo_headerClient.fetch(query:showprofileQuery,cachePolicy:.fetchIgnoringCacheData){(result,error) in

            guard (result?.data?.showUserProfile?.results) != nil else
            {
                self.lottieView.isHidden = true

                self.view.makeToast(result?.data?.showUserProfile?.errorMessage)
                return
            }

              self.lottieView.isHidden = true
            self.showuserprofileArray = ((result?.data?.showUserProfile?.results)!)
            self.verifiedInfoCount = 0
            self.hostprofileTable.reloadData()

        }
          
        }


    }
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(showuserprofileArray.userId != nil)
        {
           if(Utility.shared.unpublish_preview_check)
            {
        return 4
            } else if((Utility.shared.getCurrentUserID() != nil) && ("\(self.showuserprofileArray.userId!)" == "\(String(describing: Utility.shared.getCurrentUserID()!))")) {

            return 5
           } else {

              return 5
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       if section == 3{
           if ((showuserprofileArray.userVerifiedInfo?.isEmailConfirmed) != false) || ((showuserprofileArray.userVerifiedInfo?.isGoogleConnected) != false) || ((showuserprofileArray.userVerifiedInfo?.isPhoneVerified) != false) {
               return 50
           }
           else {
               return 0
           }
        }
        return 0
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String?
    {
      
       if(section == 3 && verifiedInfoCount > 0)
        {
            return "\((Utility.shared.getLanguage()?.value(forKey:"verfiediinfo"))!)"
        }
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(showuserprofileArray.userId != nil)
        {
        
        if(section == 0)
        {
        
                return 1
            
        }
        if(section == 1)
        {
            if(showuserprofileArray.info != nil && showuserprofileArray.info != "")
            {
                return 1
            } else {
                return 0
            }
        }
            if(section == 2)
            {
                if(showuserprofileArray.reviewsCount != nil && showuserprofileArray.reviewsCount != 0)
                {
                    return 1
                } else {
                    return 0
                }
            }
        if(section == 3)
        {
            if ((showuserprofileArray.userVerifiedInfo?.isEmailConfirmed) != false) {
                verifiedInfoCount = verifiedInfoCount + 1
            }
           
            if ((showuserprofileArray.userVerifiedInfo?.isGoogleConnected) != false) {
                verifiedInfoCount = verifiedInfoCount + 1
            }
            if ((showuserprofileArray.userVerifiedInfo?.isPhoneVerified) != false) {
                verifiedInfoCount = verifiedInfoCount + 1
            }
            return verifiedInfoCount
        }
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width:FULLWIDTH - 30, height: 30))
        headerLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18.0)
        headerLabel.textColor = UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 0
        
        let headerView = UIView(frame: CGRect(x: 15, y: 0, width:FULLWIDTH - 30, height: 30))
        headerView.backgroundColor = UIColor.clear
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostprofileviewCell", for: indexPath)as! HostprofileviewCell
            
            if(profilename != "")
            {
                cell.nameLabel.text = "\(profilename)"
            }
            if showuserprofileArray.picture != nil
            {
                let profImage = showuserprofileArray.picture!
              cell.profileImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), completed: nil)
                
            } else {
               cell.profileImage.image  = #imageLiteral(resourceName: "unknown")
            }
            if (showuserprofileArray.createdAt != nil){
                cell.memberLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"member"))!) \(getdayValue(timestamp: (showuserprofileArray.createdAt!)))"
            }
            
            if(showuserprofileArray.location != nil)
            {
            cell.cityLbl.text = showuserprofileArray.location!
            }else{
                cell.cityLbl.text = ""
            }
            cell.cityLbl.textColor = UIColor(named: "Title_Header")
            cell.selectionStyle = .none
            return cell

        } else if(indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutDynamicCell", for: indexPath)as! AboutDynamicCell
            if(showuserprofileArray.info != nil)
            {
            cell.aboutLabel.text = showuserprofileArray.info!
            }
            cell.selectionStyle = .none
            return cell
        } else if(indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewUserCell", for: indexPath)as! ReviewUserCell
            if(showuserprofileArray.reviewsCount != nil)
            {

                  cell.reviewBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"readall"))!) \((Utility.shared.getLanguage()?.value(forKey:"reviewssmall"))!)", for: .normal)

            }
            cell.reviewBtn.addTarget(self, action: #selector(reviewpageTapped), for: .touchUpInside)

            cell.selectionStyle = .none
            return cell
            
        }
        else if(indexPath.section == 3) {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "VerifiedInfoCell", for: indexPath)as! VerifiedInfoCell
                cell.selectionStyle = .none
            cell.infoView.isHidden = true
                
                if(indexPath.row == 0)
                {
                    if ((showuserprofileArray.userVerifiedInfo?.isEmailConfirmed) != false) {
                        cell.imgLeftIcon.image = UIImage(named: "Verify_email")
                        
                     
                            cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"email") ?? "Email")"
                            cell.imgRightView.image = UIImage(named: "verify_green")
                            cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                            cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    }

                  else  if ((showuserprofileArray.userVerifiedInfo?.isGoogleConnected) != false) {
                        cell.imgLeftIcon.image = UIImage(named: "Verify_Google")
                        cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"google") ?? "Google")"
                        cell.imgRightView.image = UIImage(named: "verify_green")
                        cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                        cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                        
                    }
                  else  if ((showuserprofileArray.userVerifiedInfo?.isPhoneVerified) != false) {
                        cell.imgLeftIcon.image = UIImage(named: "Phone")
                        cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"phone") ?? "Phone")"
                        cell.imgRightView.image = UIImage(named: "verify_green")
                        cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                        cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    }
                   
                   
                    }
                    
                
                else if(indexPath.row == 1)
                {

                    if ((showuserprofileArray.userVerifiedInfo?.isGoogleConnected) != false) {
                      cell.imgLeftIcon.image = UIImage(named: "Verify_Google")
                      cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"google") ?? "Google")"
                      cell.imgRightView.image = UIImage(named: "verify_green")
                      cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                      cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                        
                    }
                   else if ((showuserprofileArray.userVerifiedInfo?.isPhoneVerified) != false) {
                       cell.imgLeftIcon.image = UIImage(named: "Phone")
                       cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"phone") ?? "Phone")"
                       cell.imgRightView.image = UIImage(named: "verify_green")
                       cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                       cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    }
                   
                   
                }
                else if(indexPath.row == 2)
                {
                  if ((showuserprofileArray.userVerifiedInfo?.isPhoneVerified) != false) {
                        cell.imgLeftIcon.image = UIImage(named: "Phone")
                        cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"phone") ?? "Phone")"
                        cell.imgRightView.image = UIImage(named: "verify_green")
                        cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                        cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    }
                   
                    
                }else {
                    cell.imgLeftIcon.image = UIImage(named: "Phone")
                    cell.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"phone") ?? "Phone")"
                    cell.imgRightView.image = UIImage(named: "verify_green")
                    cell.verifyConnectLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"verified"))!)"
                    cell.verifyConnectLabel.textColor = Theme.PRIMARY_COLOR
                    
                }
            cell.borderView.layer.cornerRadius = 5.0
            cell.leadingConstraints.constant = 15
            cell.trailingConstraints.constant = 15
            return cell
            }

        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportuserCell", for: indexPath)as! ReportuserCell
            
            if verifiedInfoCount > 0 {
                cell.lineview.isHidden = false
            }else {
                cell.lineview.isHidden = true
            }
            
            cell.btnReport.addTarget(self, action: #selector(reprtBtnTapped), for: .touchUpInside)
            cell.reportuserLAbel.textColor = UIColor(named: "Title_Header")
            if(isfromreview){
                cell.btnReport.setTitle("Report this user", for: .normal)
            }
            else {
                cell.btnReport.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"Report this host"))!)", for: .normal)
            }

            cell.selectionStyle = .none
            return cell
        }
        
    }
    @objc func reprtBtnTapped(){
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
                reportPageObj.profileid = profileid
                if(isfromreview){
                reportPageObj.isfromreview = true
                }
                else {
                    reportPageObj.isfromreview = false
                }
                 reportPageObj.modalPresentationStyle = .fullScreen
                self.present(reportPageObj, animated: false, completion: nil)
            }
        } else {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
            
        }
    }
    
    
    
    @objc func reviewpageTapped(){

        let reviewpageObj = ReviewShowVC()
        reviewpageObj.profileID = profileid
        reviewpageObj.isForProfileReviews = true
        reviewpageObj.reviewcount = (showuserprofileArray.reviewsCount != nil ? (showuserprofileArray.reviewsCount!) : 0)
        reviewpageObj.modalPresentationStyle = .fullScreen
        self.present(reviewpageObj, animated: false, completion: nil)

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 4)
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
                    let reportPageObj = ReportuserPage()
                    reportPageObj.profileid = profileid
                     reportPageObj.modalPresentationStyle = .fullScreen
                    self.present(reportPageObj, animated: false, completion: nil)
                }
            } else {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     if(indexPath.section == 3)
        {
         if ((showuserprofileArray.userVerifiedInfo?.isEmailConfirmed) != false) || ((showuserprofileArray.userVerifiedInfo?.isGoogleConnected) != false) || ((showuserprofileArray.userVerifiedInfo?.isPhoneVerified) != false) {
           
             return 70
         }
         return 0
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @objc func reviewBtnTapped() {
           let reviewPageObj = ShowReviewPageVC()
           reviewPageObj.profilename = profilename
           reviewPageObj.profileid = profileid
           reviewPageObj.modalPresentationStyle = .fullScreen
           self.present(reviewPageObj, animated: false, completion: nil)
       }
    func getdayValue(timestamp:String) -> String
    {
         if(Int(timestamp) != nil ) {
        let timestamValue = Int(timestamp)!/1000
        let showDate = Date(timeIntervalSince1970:TimeInterval(timestamValue))
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMMM YYYY"
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
  
}

