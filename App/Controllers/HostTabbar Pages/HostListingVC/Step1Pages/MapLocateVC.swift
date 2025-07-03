
import UIKit
import GoogleMaps
import GooglePlaces
import Lottie
import Apollo
class MapLocateVC: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet var infoLable: UILabel!
    @IBOutlet var infoicon: UIImageView!

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var retryButn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLAbel: UILabel!
    @IBOutlet weak var headeview: UIView!
    var marker:GMSMarker!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet var offlineUIView: UIView!
    @IBOutlet var saveandExit: UIButton!
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet var ContainerView: UIView!
    var mapGMSView: GMSMapView!
    var centerMapCoordinate:CLLocationCoordinate2D!
    var  locationManager = CLLocationManager()
    
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    var lottieView1: LottieAnimationView!
    let basecontroller = BaseHostTableviewController()
    var firstTime = true
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstaraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstTime = true
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        borderView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        nextBtn.backgroundColor = Theme.Button_BG
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        saveandExit.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        infoLable.font = UIFont(name: APP_FONT, size: 14)
        ContainerView.backgroundColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.85)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLAbel.text = "\(Utility.shared.getLanguage()?.value(forKey: "pinplace") ?? "Is the pin in the right place?")"
        self.infoLable.text = "\(Utility.shared.getLanguage()?.value(forKey: "mapstatic") ?? "Is the pin in the right place?")"
        self.titleLAbel.textColor = UIColor(named: "Title_Header")
        self.titleLAbel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLAbel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true

        ContainerView.clipsToBounds = true
        ContainerView.halfroundedCorners(corners:[.topLeft, .topRight], radius: 20)
        saveandExit.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SaveExit") ?? "Save & Exit")", for:.normal)
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.masksToBounds = true
        
        nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for:.normal)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        saveandExit.addTarget(self, action: #selector(saveandexitTapped), for:.touchUpInside)

        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "") {
            saveandExit.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleheightConstaraint.constant = 0
            self.stepTitleTopConstaraint.constant = 0
        } else {
            saveandExit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleheightConstaraint.constant = 50
            self.stepTitleTopConstaraint.constant = 5
        }
        Utility.shared.isfromshowmap = false
        
        offlineUIView.isHidden = true
        
        self.stepsTitleView.whichStep = 1
        self.stepsTitleView.selectedViewIndex = 3
        
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        if mapGMSView == nil{
            let camera = GMSCameraPosition.camera(withLatitude:(Utility.shared.step1ValuesInfo["lat"] as! Double), longitude:(Utility.shared.step1ValuesInfo["lng"] as! Double), zoom:10)
            mapGMSView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: (self.curvedView.frame.size.width), height: (self.curvedView.frame.size.height)), camera: camera)
            
            if Utility.shared.getAppTheme() == "dark" {
                
                do {
                    if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                        mapGMSView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                    } else {
                        NSLog("Unable to find style.json")
                    }
                } catch {
                    NSLog("One or more of the map styles failed to load. \(error)")
                }
                
            }
            else if Utility.shared.getAppTheme() == nil || Utility.shared.getAppTheme() == "auto"{
                
                if #available(iOS 13.0, *) {
                    if UITraitCollection.current.userInterfaceStyle == .dark {
                        do {
                            if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                                mapGMSView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                            } else {
                                NSLog("Unable to find style.json")
                            }
                        } catch {
                            NSLog("One or more of the map styles failed to load. \(error)")
                        }
                    } else {
                        
                    }
                } else {
                    
                }
            }
            mapGMSView.isMyLocationEnabled = true
            mapGMSView.settings.zoomGestures = true
            mapGMSView.settings.compassButton = true
            mapGMSView.settings.indoorPicker = true
            mapGMSView.delegate = self
            
            progressViewWidth.constant = ((self.view.frame.width/7) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
            
            self.curvedView.addSubview(mapGMSView)
            self.curvedView.bringSubviewToFront(ContainerView)
            
            centerMapCoordinate = CLLocationCoordinate2D(latitude: (Utility.shared.step1ValuesInfo["lat"] as! Double), longitude: (Utility.shared.step1ValuesInfo["lng"] as! Double))
            
            if marker == nil {
                self.placeMarkerOnCenter(centerMapCoordinate:centerMapCoordinate)
            }
        }
    }
    
    func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
        if marker == nil {
            
            marker = GMSMarker()
            
        }
        marker.appearAnimation = GMSMarkerAnimation.pop
        
        marker.icon = UIImage(named: "mapCenterImg")
        
        marker.position = centerMapCoordinate
        Utility.shared.step1ValuesInfo.updateValue(Double(centerMapCoordinate.latitude), forKey: "lat")
        Utility.shared.step1ValuesInfo.updateValue(Double(centerMapCoordinate.longitude), forKey: "lng")
        marker.map = self.mapGMSView
        
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if marker == nil {
            marker = GMSMarker()
            marker.icon = UIImage(named: "mapCenterImg")
        }
        
        if(!firstTime) {
            ContainerView.backgroundColor = Theme.inboxPreApprovedStatusColor.withAlphaComponent(0.85)
            self.infoLable.text = "\(Utility.shared.getLanguage()?.value(forKey: "mapchanged") ?? "Is the pin in the right place?")"
            self.infoicon.image = #imageLiteral(resourceName: "tick-round")
        }
        firstTime = false
        self.placeMarkerOnCenter(centerMapCoordinate:centerMapCoordinate)
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "") {
            self.dismiss(animated: true, completion: nil)
        }else{
            let StepOne = PlaceListingViewController()
            StepOne.modalPresentationStyle = .fullScreen
            self.present(StepOne, animated:false, completion: nil)
        }
    }
    func goToBecomeHost(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    
    @objc func saveandexitTapped() {
        
        if Utility().isConnectedToNetwork() {
            Utility.shared.isfromshowmap = true
            self.lottieViewanimation()
            
            basecontroller.updateListingAPICall{ (success) -> Void in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let becomeHost = BecomeHostVC()
                        becomeHost.listID = "\(Utility.shared.createId)"
                        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
                        becomeHost.modalPresentationStyle = .fullScreen
                        self.present(becomeHost, animated:false, completion: nil)
                    }
                }
            }
            
        } else {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
        
    }
    @IBAction func RedirectnextTapped(_ sender: Any) {
        let nextpageObj = AmenitiesViewController()
        self.view.window?.backgroundColor = UIColor.white
        nextpageObj.modalPresentationStyle = .fullScreen
        self.present(nextpageObj, animated: false, completion: nil)
    }
    
    func offlineViewShow() {
        offlineUIView = UIView()
        if IS_IPHONE_X || IS_IPHONE_XR{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
        }else{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
        }
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlineUIView.frame.size.width + shadowSize2,
                                                    height: self.offlineUIView.frame.size.height + shadowSize2))
        offlineUIView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        
        self.offlineUIView.layer.masksToBounds = false
        self.offlineUIView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.offlineUIView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.offlineUIView.layer.shadowOpacity = 0.3
        self.offlineUIView.layer.shadowPath = shadowPath2.cgPath
    }
    
    func lottieViewanimation() {
        saveandExit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveandExit.frame.size.width/2)-50), y:0, width:100, height:self.saveandExit.frame.size.height)
        self.saveandExit.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView1.play()
    }
}

extension MapLocateVC: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 1{
            switch selectedPageIndex{
            case 0:
                let StepOne = PlaceListingViewController()
                StepOne.modalPresentationStyle = .fullScreen
                self.present(StepOne, animated:false, completion: nil)
                break
            case 1:
                let guestListing = GuestListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 2:
                let location = AddressListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                location.modalPresentationStyle = .fullScreen
                self.present(location, animated: false, completion: nil)
                break
            case 3:
                break
            case 4:
                let nextpageObj = AmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                nextpageObj.modalPresentationStyle = .fullScreen
                self.present(nextpageObj, animated: false, completion: nil)
                break
            case 5:
                let amenities = SafeAmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 6:
                let spaces = SpaceListViewController()
                self.view.window?.backgroundColor = UIColor.white
                spaces.modalPresentationStyle = .fullScreen
                self.present(spaces, animated: false, completion: nil)
                break
            default:
                break
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    do {
                        if mapGMSView != nil {
                            if let styleURL = Bundle.main.url(forResource: "mapstyle", withExtension: "json") {
                                mapGMSView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                            } else {
                                NSLog("Unable to find style.json")
                            }
                        }
                    } catch {
                        NSLog("One or more of the map styles failed to load. \(error)")
                    }
                } else {
                }
            }
        } else {
        }
    }
}


