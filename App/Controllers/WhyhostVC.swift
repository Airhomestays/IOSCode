

import UIKit
import SCPageControl
import Apollo

class WhyhostVC: UIViewController,UIScrollViewDelegate {
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var pageController: SCPageControlView!
    @IBOutlet weak var BckImg: UIImageView!
    @IBOutlet weak var litsBtn: UIButton!
    let skipbtn = UIButton()

    @IBOutlet weak var titleLabel: UILabel!
   
    let scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:FULLWIDTH,height: FULLHEIGHT))
    var colors:[UIColor] = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    
     let arrImg: [UIImage] = [#imageLiteral(resourceName: "bg_image1"),#imageLiteral(resourceName: "bg_image4"),#imageLiteral(resourceName: "bg_image3"),#imageLiteral(resourceName: "bg_image2")]
    var titleArray = [String]()
    var getpayoutArray = [GetPayoutsQuery.Data.GetPayout.Result]()
    var whyHostArray = [GetWhyHostDataQuery.Data.GetWhyHostDatum.Result]()
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
      
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
         skipbtn.frame = CGRect(x:frame.origin.x+20, y:40, width:40, height:40)
        skipbtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        skipbtn.setTitle("", for: .normal)
        skipbtn.backgroundColor = Theme.ButtonBack_BG
        skipbtn.layer.cornerRadius = skipbtn.frame.size.height/2
        skipbtn.clipsToBounds = true
        skipbtn.addTarget(self, action: #selector(self.backdismissBtnTapped), for: .touchUpInside)
        self.scrollView.addSubview(skipbtn)
        self.scrollView.bringSubviewToFront(skipbtn)
        
        
        self.dataAPICall()
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        titleArray = ["\((Utility.shared.getLanguage()?.value(forKey:"earnmoney"))!)","\((Utility.shared.getLanguage()?.value(forKey:"ownprice"))!)","\((Utility.shared.getLanguage()?.value(forKey:"manageupcoming"))!)","\((Utility.shared.getLanguage()?.value(forKey:"monitorreserv"))!)"]

        configurePageControl()

        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        
        if Utility.shared.isRTLLanguage() {
            self.backBtn.frame = CGRect(x:FULLWIDTH - 50, y: 45, width: 40, height: 40)
            self.backBtn.rotateImageViewofBtn()
            scrollView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.backBtn.frame = CGRect(x:25, y: 45, width: 40, height: 40)
        }
        
        self.backBtn.isHidden = true
        
        self.scrollView.addSubview(self.backBtn)
        self.scrollView.bringSubviewToFront(self.backBtn)
        self.view.addSubview(scrollView)
        
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.bounces = false

    }
    
    func setScrollViewdata() {
        for index in 0..<whyHostArray.count {
           
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            
            let overlay_view = UIView()
            overlay_view.frame = CGRect(x:frame.origin.x,y:FULLHEIGHT-400, width:FULLWIDTH , height:400)
            let gradient = CAGradientLayer()
            gradient.frame = overlay_view.bounds
            gradient.colors = [UIColor.clear.cgColor,  UIColor(named: "Title_Header")!.withAlphaComponent(0.6).cgColor]
            overlay_view.layer.insertSublayer(gradient, at: 0)
           
            
            let listBtn = UIButton()
            listBtn.frame = CGRect(x:(frame.origin.x + 20),y:FULLHEIGHT-70, width:(FULLWIDTH - 40), height:50)
            listBtn.setTitle(whyHostArray[index].buttonLabel, for: .normal)
            listBtn.backgroundColor = Theme.Button_BG
            listBtn.setTitleColor(UIColor.white, for: .normal)
            listBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size:16)
            listBtn.layer.cornerRadius = listBtn.frame.size.height/2
            listBtn.clipsToBounds = true
            
            if Utility.shared.isRTLLanguage(){
                listBtn.transform = CGAffineTransform(scaleX: -1, y: 1)
               
                listBtn.semanticContentAttribute = .forceLeftToRight

            }
            else {
                listBtn.semanticContentAttribute = .forceRightToLeft
               
            }
            
            
            let subView = UILabel(frame: CGRect(x:frame.origin.x+20, y:FULLHEIGHT-250, width:FULLWIDTH-40, height: 130))
          
            subView.text = whyHostArray[index].title
            subView.textAlignment = .center
            subView.numberOfLines = 6
            subView.textColor = .white
            subView.contentMode = .center
            subView.font = UIFont(name:APP_FONT_MEDIUM, size:25)
            let ivImage = UIImageView(frame: CGRect(x:frame.origin.x, y:0, width:FULLWIDTH, height: FULLHEIGHT))
            ivImage.contentMode = .scaleAspectFill
            
            if Utility.shared.isRTLLanguage(){
                subView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
           
            ivImage.sd_setImage(with: URL(string: "\(WHY_HOST_IMG)\(whyHostArray[index].imageName ?? "")"), placeholderImage: #imageLiteral(resourceName: "ItemTransparentImg"))
           
            if(IS_IPHONE_XR || IS_IPHONE_PLUS)
            {
            ivImage.contentMode = .scaleAspectFill
            }
            else
            {
                ivImage.contentMode = .scaleAspectFill
            }
            ivImage.clipsToBounds = true
            let pagecontrollerone = SCPageControlView()
                 
            pagecontrollerone.frame = CGRect(x:(FULLWIDTH)*CGFloat(index)+22, y: FULLHEIGHT-125, width:FULLWIDTH-40, height: 50)
            
            pagecontrollerone.scp_style = .SCJAFillCircle
                                   
                pagecontrollerone.set_view(whyHostArray.count, current:index, current_color: .white, disable_color:UIColor(named: "text_borderColor"))
           
             self.scrollView .addSubview(ivImage)
            self.scrollView.addSubview(overlay_view)
             self.scrollView .addSubview(subView)
            
            self.scrollView.bringSubviewToFront(subView)
                self.scrollView.addSubview(listBtn)
            self.scrollView.bringSubviewToFront(listBtn)
          
             self.scrollView.addSubview(pagecontrollerone)
            self.scrollView.bringSubviewToFront(skipbtn)
        
            ivImage.bringSubviewToFront(pagecontrollerone)
            
            
            listBtn.addTarget(self, action: #selector(self.listingBtnTapped), for: .touchUpInside)
             

        }
    }
    
    @objc func listingBtnTapped()
    {
        if Utility().isConnectedToNetwork(){
            let getlistsettingsquery = GetListingSettingQuery()
            apollo_headerClient.fetch(query: getlistsettingsquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
                
                
                guard (result?.data?.getListingSettings?.results) != nil else{
                    

                    
                    return
                }
                Utility.shared.getListSettingsArray = (result?.data?.getListingSettings?.results)!
                if Utility.shared.getListSettingsArray.personCapacity != nil{
            let baseHost = BaseHostTableviewController()
            baseHost.getListSettingsArray = Utility.shared.getListSettingsArray
            Utility.shared.createId = Int()
            baseHost.showOverlay = true
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
            }
             
         }
    }
    @objc func backdismissBtnTapped()
          {
              
              self.dismiss(animated: false, completion: nil)
          }
    func configurePageControl() {
      
    }

    func dataAPICall()
    {
        let getwhyhostquery = GetWhyHostDataQuery()
       
        apollo_headerClient.fetch(query: getwhyhostquery, cachePolicy: .fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getWhyHostData?.results) != nil else{
                self.view.makeToast(result?.data?.getWhyHostData?.errorMessage)
             
               
                return
            }
           
            self.whyHostArray = ((result?.data?.getWhyHostData?.results)!) as! [GetWhyHostDataQuery.Data.GetWhyHostDatum.Result]
            self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * CGFloat(self.whyHostArray.count),height: self.scrollView.frame.size.height)
            self.setScrollViewdata()
        }
        
    }
  
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }

     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
           pageController.scroll_did(scrollView)
          
       }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func listBtnTapped(_ sender: Any) {
    }
   

}
