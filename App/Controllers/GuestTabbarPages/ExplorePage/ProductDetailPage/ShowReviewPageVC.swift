
import UIKit
import Apollo

class ShowReviewPageVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var showreviewTable: UITableView!
    @IBOutlet weak var topview: UIView!
     var profileid = Int()
    var profilename = String()
    var totalListcount:Int = 0
    var PageIndex : Int = 1
    var showReivewArray = [UserReviewsQuery.Data.UserReview.Result]()
    let apollo_headerClient: ApolloClient = {
           let configuration = URLSessionConfiguration.default
         
           configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
           let url = URL(string:graphQLEndpoint)!
           
           return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
           
       }()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.showreviewAPICall()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.showReivewArray.removeAll()
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    func initialSetup()
    {
        showreviewTable.register(UINib(nibName: "ReviewDetailcell", bundle: nil), forCellReuseIdentifier: "ReviewDetailcell")
        showreviewTable.estimatedRowHeight = 130
        showreviewTable.rowHeight = UITableView.automaticDimension
    }
    func showreviewAPICall()
    {
        let userreviewsquery = UserReviewsQuery(ownerType:"others",currentPage:PageIndex, profileId:profileid)
        apollo_headerClient.fetch(query: userreviewsquery, cachePolicy: .fetchIgnoringCacheData){(result,error) in
            if(result?.data?.userReviews?.status == 200)
            {
                self.showReivewArray.append(contentsOf: ((result?.data?.userReviews?.results)!) as! [UserReviewsQuery.Data.UserReview.Result])
                self.totalListcount = (result?.data?.userReviews?.results!.count)!
            }
            else
            {
               
                self.view.makeToast(result?.data?.userReviews?.errorMessage!)
            }
            self.showreviewTable.reloadData()
        }
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        if(showReivewArray.count > 0)
        {
        return 1
        }
        else
        {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(showReivewArray.count > 0)
        {
            return showReivewArray.count
        }else
        {
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = UILabel(frame: CGRect(x:20, y:10, width:
            tableView.bounds.size.width, height: 40))
        headerLabel.font = UIFont(name: "Circular-Medium", size:26)
        headerLabel.textColor =  UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0 && showReivewArray.count > 0)
        {
            return "\(showReivewArray[section].yourReviewsCount!) Reviews"
        }
        return ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewDetailcell", for: indexPath)as? ReviewDetailcell
        cell?.selectionStyle = .none
        cell?.profileimgBtn.layer.cornerRadius = (cell?.profileImage.frame.size.width)!/2
        if(showReivewArray[indexPath.row].authorData?.fragments.profileFields.firstName != nil)
            {
        cell?.nameLabel.text = "\((showReivewArray[indexPath.row].authorData?.fragments.profileFields.firstName!)!) \((showReivewArray[indexPath.row].authorData?.fragments.profileFields.lastName!)!)"
            }
            else
            {
    
            cell?.nameLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"Verifiedby"))!) \((Utility.shared.getLanguage()?.value(forKey:"appname"))!)"
            }
        cell?.reviewDescLabel.text = showReivewArray[indexPath.row].reviewContent!
        if(showReivewArray[indexPath.row].authorData?.fragments.profileFields.picture != nil)
        {
        let listimage = (showReivewArray[indexPath.row].authorData?.fragments.profileFields.picture!)!
            cell?.profileimgBtn.sd_setImage(with: URL(string: "\(IMAGE_AVATAR_MEDIUM)\(listimage)"), for: .normal, completed: nil)
        }
        else
        {

            cell?.profileimgBtn.setImage(#imageLiteral(resourceName: "adminAvatar").withRenderingMode(.alwaysOriginal),for: .normal)
        }
        cell?.profileimgBtn.tag = indexPath.row
        cell?.profileimgBtn.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
        cell?.dateLabel.text = "\(getdayValue(timestamp: (showReivewArray[indexPath.row].createdAt!)))"
        cell?.profileimgBtn.layer.masksToBounds = true
        return cell!
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func getdayValue(timestamp:String) -> String
    {
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
        return day
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        let totalPages = (showReivewArray.count/10)
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if((self.showreviewTable.contentOffset.y + self.showreviewTable.bounds.height) >= self.showreviewTable.contentSize.height)
            {
             
                if(totalPages >= PageIndex){
                    self.PageIndex = self.PageIndex + 1
                    self.showreviewAPICall()
                    
                }
            }
        
        
    }
    @objc func profileTapped(_ sender: UIButton)
    {
        if Utility().isConnectedToNetwork(){
            if(((Utility.shared.getCurrentUserToken()) != nil) && (Utility.shared.getCurrentUserToken() != ""))
            {
                if(showReivewArray[sender.tag].authorData?.fragments.profileFields.profileId != nil)
                {
                let editprofileobj = HostProfileViewPage()
                editprofileobj.profileid = (showReivewArray[sender.tag].authorData?.fragments.profileFields.profileId!)!
                editprofileobj.profilename = (showReivewArray[sender.tag].authorData?.fragments.profileFields.firstName!)!
                editprofileobj.showprofileAPICall(profileid:profileid)
                editprofileobj.modalPresentationStyle = .fullScreen
                self.present(editprofileobj, animated: true, completion: nil)
                }
            }
        }
        else
        {
            self.view.makeToast("offline")
        }
    }
    
}
