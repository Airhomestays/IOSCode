

import UIKit
import Apollo
import Lottie
import SkeletonView

protocol CalendarListingVCProtocol {
    func manageListingAPICall()
    func BlockedlistAPICall(listId:Int)
    func APICall(listImage:String,title:String,entireTitle:String,listId:Int)
    
    
}

class CalendarListingVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,SkeletonTableViewDataSource{
    
    
    @IBOutlet weak var BGView: UIView!
    @IBOutlet weak var offlineView: UIView!
    
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var CalendarListingTable: UITableView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    var manageListingArray = [ManageListingsQuery.Data.ManageListing.Result]()
    var inprogress_List_Array = [ManageListingsQuery.Data.ManageListing.Result]()
    var completed_List_Array = [ManageListingsQuery.Data.ManageListing.Result]()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    var lottieView: LottieAnimationView!
    var deleagte:CalendarListingVCProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialSetup()
        self.lottieAnimation()
        self.manageListingAPICall()
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        BGView.layer.cornerRadius = 12
        BGView.clipsToBounds = true
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func lottieAnimation(){
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = true
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-60, y:FULLHEIGHT/2-50, width:100, height:100)
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
    func manageListingAPICall() {
        
        let manageListingquery = ManageListingsQuery()
        apollo_headerClient.fetch(query: manageListingquery,cachePolicy:.fetchIgnoringCacheData){ [self](result,error) in
            guard (result?.data?.manageListings?.results) != nil else{
                self.view.makeToast(result?.data?.manageListings?.errorMessage)
                return
            }
            self.manageListingArray = ((result?.data?.manageListings?.results)!) as! [ManageListingsQuery.Data.ManageListing.Result]
            for i in self.manageListingArray {
                if(i.isReady == false)
                {
                    self.inprogress_List_Array.append(i)
                } else {
                    self.completed_List_Array.append(i)
                }
            }
            self.lottieView.isHidden = true
            self.CalendarListingTable.hideSkeleton()
            self.CalendarListingTable.reloadData()
            for i in 0...completed_List_Array.count-1 {
                
                if(Utility.shared.host_selected_Array.contains(completed_List_Array[i].id!)) {
                    let indexPath = IndexPath(row:i,section: 0)
                    
                    self.CalendarListingTable.scrollToRow(at:indexPath, at: .none, animated: false)
                    
                }
            }
            
        }
        
    }
    
    func initialSetup() {
        CalendarListingTable.register(UINib(nibName: "CalendarListCell", bundle: nil), forCellReuseIdentifier: "CalendarListCell")
        
        BGView.backgroundColor = UIColor(named: "colorController")
        CalendarListingTable.isSkeletonable = true
        CalendarListingTable.showAnimatedGradientSkeleton()
        inprogress_List_Array.removeAll()
        completed_List_Array.removeAll()
        self.offlineView.isHidden = true
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completed_List_Array.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarListCell", for: indexPath)as! CalendarListCell
        cell.selectionStyle = .none
        if(completed_List_Array[indexPath.row].listPhotoName != nil)
        {
            let listimage = completed_List_Array[indexPath.row].listPhotoName!
            cell.listimage.sd_setImage(with: URL(string: "\(IMAGE_LISTING_MEDIUM)\(listimage)"), placeholderImage: #imageLiteral(resourceName: "placeholderimg"))
            cell.listimage.contentMode = .scaleAspectFill
        }
        if(completed_List_Array[indexPath.row].title != nil)
        {
            cell.titleLabel.text = completed_List_Array[indexPath.row].title!
        } else {
            cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"entireplacein"))!) \(completed_List_Array[indexPath.row].city!)"
        }
        if(completed_List_Array[indexPath.row].settingsData![0]?.listsettings != nil && completed_List_Array[indexPath.row].settingsData![0]?.listsettings?.itemName != nil) {
            cell.entireLabel.text = completed_List_Array[indexPath.row].settingsData![0]?.listsettings?.itemName != nil ? completed_List_Array[indexPath.row].settingsData![0]?.listsettings?.itemName! : ""
        } else {
            cell.entireLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"entireplace"))!)"
        }
        if(Utility.shared.host_selected_Array.contains(completed_List_Array[indexPath.row].id!)) {
            cell.tickImage.isHidden  = false
        } else {
            if(Utility.shared.host_selected_Array.count == 0) {
                if(indexPath.row == 0) {
                    cell.tickImage.isHidden  = false
                } else {
                    cell.tickImage.isHidden  = true
                }
            } else {
                cell.tickImage.isHidden  = true
            }
            
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(Utility.shared.host_selected_Array.contains(completed_List_Array[indexPath.row].id!)) {
            Utility.shared.host_selected_Array.remove(completed_List_Array[indexPath.row].id!)
        } else {
            Utility.shared.host_selected_Array.removeAllObjects()
            Utility.shared.host_selected_Array.add(completed_List_Array[indexPath.row].id!)
        }
        var entireTitle = String()
        if(completed_List_Array[indexPath.row].settingsData![0]?.listsettings != nil && completed_List_Array[indexPath.row].settingsData![0]?.listsettings?.itemName != nil) {
            entireTitle = (completed_List_Array[indexPath.row].settingsData![0]?.listsettings?.itemName!)!
        } else {
            entireTitle = "\((Utility.shared.getLanguage()?.value(forKey:"entireplace"))!)"
        }
        Utility.shared.isfrom_availability_calendar = true
        deleagte?.BlockedlistAPICall(listId: completed_List_Array[indexPath.row].id!)
        deleagte?.APICall(listImage:completed_List_Array[indexPath.row].listPhotoName!,title:completed_List_Array[indexPath.row].title!,entireTitle:entireTitle, listId: completed_List_Array[indexPath.row].id!)
        self.dismiss(animated: true, completion: nil)
    }
    
    func offlineViewShow() {
        CalendarListingTable.isSkeletonable = true
        CalendarListingTable.showAnimatedGradientSkeleton()
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
            offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
        }else{
            offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
        }
    }
    
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier{
        
        return "CalendarListCell"
    }
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell = skeletonView.dequeueReusableCell(withIdentifier: "CalendarListCell", for: indexPath)as! CalendarListCell
        return cell
    }
}
