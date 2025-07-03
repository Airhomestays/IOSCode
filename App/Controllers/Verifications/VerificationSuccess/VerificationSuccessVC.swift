
import UIKit
import Apollo
import Lottie

class VerificationSuccessVC: UIViewController {
    
    @IBOutlet weak var UIView_Animation: UIView!
    @IBOutlet weak var Success_Validation: UILabel!
    @IBOutlet var Offline_button: UIButton!
    
    var lottieView: LottieAnimationView!
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lottieView = LottieAnimationView.init(name: "Email_success")
        self.lottieView.frame = CGRect(x:FULLWIDTH/2-40, y: FULLHEIGHT/2-100, width: 80, height: 80)
        self.view.addSubview(lottieView)
        self.view.bringSubviewToFront(lottieView)
        if Utility.shared.isConnectedToNetwork() {
            self.EmailVerification()
        } else {
            lottieView.isHidden = true
            Success_Validation.isHidden = true
            self.offlineView()
        }
    }
    
    func SetIntitalSetup(){
        Success_Validation.font = UIFont(name: APP_FONT_BOLD, size: 17)
        Offline_button.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 19)
        if Utility.shared.isConnectedToNetwork(){
            lottieView.isHidden = false
            Success_Validation.isHidden = false
            Offline_button.isHidden =  true
            self.SuccessEmail()
        } else {
            lottieView.isHidden = true
            Success_Validation.isHidden = true
            self.offlineView()
        }
    }
    
    @objc func offlineTapped(){
        if Utility.shared.isConnectedToNetwork(){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            Utility.shared.setTab(index: 0)
            appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
        } else {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "network_check"))!)")
        }
    }
    
    func SuccessEmail(){
        Success_Validation.isHidden = false
        Success_Validation.text = "\((Utility.shared.getLanguage()?.value(forKey: "email_confirm"))!)"
        self.lottieView.isHidden = false
        lottieView.play()
        var Explore_Timer = Timer()
        Explore_Timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ExplorePageNavigation), userInfo: nil, repeats: false)
    }
    
    @objc func ExplorePageNavigation(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        Utility.shared.setTab(index: 0)
        Utility.shared.isfromfloatmap_Page = false
        Utility.shared.isfromGuestProfile = false
        Utility.shared.locationfromSearch  = ""
        Utility.shared.TotalFilterCount = 0
        if(Utility.shared.searchLocationDict.count > 0) {
            Utility.shared.searchLocationDict.setValue(nil, forKey: "lat")
            Utility.shared.searchLocationDict.setValue(nil, forKey: "lon")
        }
        Utility.shared.instantBook = ""
        Utility.shared.roomtypeArray.removeAllObjects()
        Utility.shared.amenitiesArray.removeAllObjects()
        Utility.shared.priceRangeArray.removeAllObjects()
        Utility.shared.facilitiesArray.removeAllObjects()
        Utility.shared.houseRulesArray.removeAllObjects()
        Utility.shared.beds_count = 0
        Utility.shared.bedrooms_count = 0
        Utility.shared.bathroom_count = 0
        appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
    }
    
    func offlineView(){
        let imageView = UIImageView(frame: CGRect(x: UIView_Animation.frame.origin.x+50, y: 0, width: UIView_Animation.frame.size.width-120, height: UIView_Animation.frame.size.height));
        imageView.image = UIImage(named: "inbox_no.png")
        UIView_Animation.addSubview(imageView)
        UIView_Animation.bringSubviewToFront(imageView)
        Offline_button.isHidden = false
        Offline_button.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "email_offline"))!)", for: .normal)
        Offline_button.addTarget(self, action: #selector(offlineTapped), for: .touchUpInside)
        Offline_button.layer.cornerRadius = 6.0
        Offline_button.layer.masksToBounds = true
        Offline_button.layer.borderWidth = 1.0
        Offline_button.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
    }
    
    func EmailVerification(){
        if Utility.shared.isConnectedToNetwork(){
            let verifyEmail = EmailVerificationMutation(token: Utility.shared.ConfirmEmailToken, email: Utility.shared.ConfirmEmailString)
            apollo_headerClient.perform(mutation: verifyEmail){ (result,error) in
                if result?.data?.emailVerification?.status == 200 {
                    self.SetIntitalSetup()
                }else{
                    let alert = UIAlertController(title: "\((Utility.shared.getLanguage()?.value(forKey: "oops"))!)", message: result?.data?.emailVerification?.errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "\((Utility.shared.getLanguage()?.value(forKey: "okay"))!)", style: .default, handler: { (action) in
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        Utility.shared.setTab(index: 0)
                        appDelegate.GuestTabbarInitialize(initialView: CustomTabbar())
                    }))
                    self.present(alert, animated: true) {
                    }
                }
            }
        } else {
            lottieView.isHidden = true
            Success_Validation.isHidden = true
            self.offlineView()
        }
    }
}
