

import UIKit
import Apollo
import Lottie
import SwiftMessages

class BaseHostTableviewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate,PlaceListingViewControllerDelegate{
    func total_guest_change(guestcount: String) {
        let listSettings = (Utility.shared.getListSettingsArray.roomType?.listSettings!)!
        _ = listSettings.filter({ (item) -> Bool in
            if (Utility.shared.step1ValuesInfo["roomType"]! as? Int) == item?.id {
                placeLabel = (item?.itemName!)!
                return true
            }else{
                return false
            }
        })
        if !placeLabel.isEmpty {
            let index = itemNameArray.firstIndex(where: { (item) -> Bool in
                item == placeLabel
            })
            listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
        }
        if((Utility.shared.step1ValuesInfo["personCapacity"]!as! Int) <= 1) {
            guestLabel = ("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(Utility.shared.step1ValuesInfo["personCapacity"]!) \(Utility.shared.getLanguage()?.value(forKey: "guest")as! String)")
        } else {
            guestLabel = ("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(Utility.shared.step1ValuesInfo["personCapacity"]!) \(Utility.shared.getLanguage()?.value(forKey: "guest")as! String)s")
        }
        hostTable.reloadData()
    }
    
    func guestroom_detail(roomdetail: String) {
    }
    
    @IBOutlet weak var baseTopView: UIView!
    @IBOutlet weak var baseBackBtn: UIButton!
    @IBOutlet weak var baseTitleLabel: UILabel!
    @IBOutlet weak var baseCurvedView: UIView!
    @IBOutlet weak var baseBottomView: UIView!
    @IBOutlet weak var baseProgressBGView: UIView!
    @IBOutlet weak var baseCurvedProgressView: UIView!
    
    
    @IBOutlet var overlayBtn: UIButton!
    @IBOutlet var overlaystep3: UILabel!
    @IBOutlet var overlayUsername: UILabel!
    @IBOutlet var overlayUserImage: UIImageView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var errorLAbel: UILabel!
    
    @IBOutlet weak var hostTable: UITableView!
    @IBOutlet weak var nextRedirectBtn: UIButton!
    @IBOutlet weak var offlineView: UIView!
    var showOverlay = false
    
    @IBOutlet var handimg: UIImageView!
    
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var getListSettingsArray = GetListingSettingQuery.Data.GetListingSetting.Result()
    var ProfileAPIArray = GetProfileQuery.Data.UserAccount.Result()
    var apollo_client: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var itemNameArray = [String]()
    var guestArrayCount = Int()
    var guestsDropdownArray = [String]()
    var itemNameTouched = false
    var guestLabel = ""
    var placeLabel = ""
    
    let listInputView = UIView()
    let listValuePicker = UIPickerView()
    var tappedIndexPathRow = 0
    var selectedTextfield = Int()
    var lottieView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lottieView = LottieAnimationView.init(name:"animation")
        if(showOverlay) {
            var frame =  overlayView.frame
            frame.size.height = UIScreen.main.bounds.size.height
            frame.size.width = UIScreen.main.bounds.size.width
            overlayView.frame = frame
            self.view.addSubview(overlayView)
            overlayView.backgroundColor =  UIColor(named: "colorController")
            self.view.backgroundColor = UIColor(named: "colorController")!
            
            overlayBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"letsstart"))!)", for: .normal)
            overlayBtn.backgroundColor = Theme.Button_BG
            overlayBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
            overlayBtn.layer.cornerRadius = overlayBtn.frame.size.height/2
            overlayBtn.titleLabel?.textAlignment = .center
            
            overlayBtn.isHidden = true
            handimg.isHidden = true
            
            overlayView.isHidden = false
            
            self.CountryAPICAll()
            
            if(Utility.shared.pickedimageString == "") {
                profileAPICall()
            }
            else {
                self.setUpUI()
            }
        } else {
            setUpUI()
        }
        
        setdropdown()
        registerCells()
        self.setDropdownList()
    }
  
    func GetListSettingAPICall() {
        let getlistsettingsquery = GetListingSettingQuery()
        apollo_headerClient.fetch(query: getlistsettingsquery,cachePolicy: .fetchIgnoringCacheData){(result,error) in
            guard (result?.data?.getListingSettings?.results) != nil else{
                return
            }
            self.getListSettingsArray = (result?.data?.getListingSettings?.results)!
            
            self.lottieView.isHidden = true
            self.lottieView.stop()
        }
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
    
    func callListingSettingsAPI(oflineView : UIView, nextButton : UIButton) {
        nextButton.isHidden = false
        self.GetListSettingAPICall()
    }
   
    func updateStep3ListingAPICall(completion: (_ success:Bool) -> Void) {
        
        let minNight:Int  = (Utility.shared.step3ValuesInfo["minNight"] as? Int) != nil ? (Utility.shared.step3ValuesInfo["minNight"] as? Int)! : 0
        let maxNight:Int = (Utility.shared.step3ValuesInfo["maxNight"] as? Int) != nil ? (Utility.shared.step3ValuesInfo["maxNight"] as? Int)! : 0
        let from:Int = Utility.shared.step3ValuesInfo["checkInStart"] != nil && ((Utility.shared.step3ValuesInfo["checkInStart"]as? String) != "Flexible") ? Int("\(Utility.shared.step3ValuesInfo["checkInStart"]!)")! : 0
        let to:Int = Utility.shared.step3ValuesInfo["checkInEnd"] != nil && ((Utility.shared.step3ValuesInfo["checkInEnd"]as? String) != "Flexible") ? Int("\(Utility.shared.step3ValuesInfo["checkInEnd"]!)")! : 0
        if (maxNight != 0 && minNight > maxNight) {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "min_nights_Greaterthan_max"))!)")
            completion(true)
            return
        }
        
        if (Utility.shared.step3ValuesInfo["basePrice"] != nil &&  Utility.shared.step3ValuesInfo["basePrice"] as? String == "." || Utility.shared.host_basePrice < 1) {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "invalid_basePrice"))!)")
            completion(true)
            return
        }
        
//        if (Utility.shared.step3ValuesInfo["cleaningPrice"] != nil &&  Utility.shared.step3ValuesInfo["cleaningPrice"] as? String == "0" || Utility.shared.step3ValuesInfo["cleaningPrice"] as? String == ".") {
//            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "invalid_cleaningPrice"))!)")
//            completion(true)
//            return
//        }
        
        if (Utility.shared.step3ValuesInfo["cleaningPrice"] == nil || Utility.shared.step3ValuesInfo["cleaningPrice"] as? String == ".") {
            
            Utility.shared.step3ValuesInfo["cleaningPrice"] = 0.0
            
//            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "invalid_cleaningPrice"))!)")
//            completion(true)
//            return
        }
        
        if(from >= to && from != 0 && to != 0) {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "fromtimealert"))!)")
            completion(true)
            return
        }
        
        if let value = Utility.shared.step3ValuesInfo["weeklyDiscount"] {
            let weeklyDiscount = Double("\(value)") ?? 0.0
            if (weeklyDiscount >= 100){
                self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                completion(true)
                return
            }
        } else {
            if let value = Utility.shared.step3ValuesInfo["monthlyDiscount"] {
                let weeklyDiscount = Double("\(value)") ?? 0.0
                
                if (weeklyDiscount >= 100){
                    self.view.makeToast( "\((Utility.shared.getLanguage()?.value(forKey:"invaliddiscount"))!)")
                    completion(true)
                    return
                }
            }
        }
        
        completion(false)
        var weekprice = String()
        var monthprice = String()
        if(Utility.shared.step3ValuesInfo["weeklyDiscount"] != nil) {
            weekprice = "\(Utility.shared.step3ValuesInfo["weeklyDiscount"]!)"
        } else {
            weekprice = "0"
        }
        if(Utility.shared.step3ValuesInfo["monthlyDiscount"] != nil) {
            monthprice  = ("\(Utility.shared.step3ValuesInfo["monthlyDiscount"]!)")
        } else {
            monthprice = "0"
        }
        
        
        let updatelist = UpdateListingStep3Mutationn(id: Utility.shared.step3ValuesInfo["id"] as? Int,
                                                    houseRules: Utility.shared.step3ValuesInfo["houseRules"] as? [Int],
                                                    bookingNoticeTime: "\(Utility.shared.step3ValuesInfo["bookingNoticeTime"] ?? "")",
                                                    checkInStart: "\(Utility.shared.step3ValuesInfo["checkInStart"] ?? "")",
                                                    checkInEnd: "\(Utility.shared.step3ValuesInfo["checkInEnd"] ?? "")",
                                                    maxDaysNotice: "\(Utility.shared.step3ValuesInfo["maxDaysNotice"] ?? "")",
                                                    minNight: Utility.shared.step3ValuesInfo["minNight"] as? Int,
                                                    maxNight: Utility.shared.step3ValuesInfo["maxNight"] as? Int,
                                                    basePrice: Utility.shared.host_basePrice,
                                                    cleaningPrice:Utility.shared.host_cleanPrice,
                                                    tax:Utility.shared.host_taxPrice,
                                                    currency: "\(Utility.shared.step3ValuesInfo["currency"] ?? "")",
                                                    weeklyDiscount:Int(weekprice),
                                                    monthlyDiscount:Int(monthprice),
                                                    bookingType: "\(Utility.shared.step3ValuesInfo["bookingType"] ?? "")",
                                                    cancellationPolicy: Utility.shared.step3ValuesInfo["cancellationPolicy"] as? Int,
                                                    guestBasePrice: Int((Utility.shared.host_GuestsOnBasePrice ?? 0)),
                                                    additionalPrice: Double((Utility.shared.host_GuestsPrice ?? 0)),
                                                    visitorsLimit: Int(Utility.shared.host_VisitorCount ?? 0),
                                                    visitorsPrice: Double((Utility.shared.host_VisitorPrice ?? 0)),
                                                    petLimit:Int((Utility.shared.host_PetCount ?? 0)),
                                                    petPrice: Double(Utility.shared.host_PetPrice ?? 0),
                                                    infantLimit: Int(Utility.shared.host_InfantCount ?? 0),
                                                    infantPrice: Double(Utility.shared.host_InfantPrice ?? 0)
                                                    
        )
        apollo_headerClient.perform(mutation: updatelist){ (result,error) in
            
            if(result?.data?.updateListingStep3?.status == 200) {
                self.lottieView.isHidden = true
                
                self.manageListingStepsvalue(listId: "\(Utility.shared.step3ValuesInfo["id"]!)", currentStep: 3)
            } else {
                self.view.makeToast(result?.data?.updateListingStep3?.errorMessage)
            }
        }
    }
    
    func manageListingStepsvalue(listId:String,currentStep:Int) {
        let manageListingStepsMutation = ManageListingStepsMutation(listId:listId, currentStep:currentStep)
        apollo_headerClient.perform(mutation: manageListingStepsMutation){ (result,error) in
            if(result?.data?.manageListingSteps?.status == 200) {
                let becomeHost = BecomeHostVC()
                becomeHost.listID = "\(Utility.shared.createId)"
                becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                
            } else {
                self.view.makeToast(result?.data?.manageListingSteps?.errorMessage)
            }
        }
    }
    
    func updateListingAPICall(completion: (_ success: Bool) -> Void) {
        var bedsCount = Utility.shared.step1ValuesInfo["beds"] as? Int
        if(bedsCount == nil) {
            bedsCount = 0
        }
        if(Utility.shared.bedcount>bedsCount!) {
            
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"bed_count_exceed"))!)")
            completion(false)
            return
        }
        if Utility.shared.step1ValuesInfo["country"] == nil || (Utility.shared.step1ValuesInfo["country"] as? String) == ""  {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enter_country"))!)")
            completion(true)
            return
        }
        if Utility.shared.step1ValuesInfo["street"] == nil || (Utility.shared.step1ValuesInfo["street"] as? String) == ""{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enter_street"))!)")
            completion(true)
            return
        }
        if Utility.shared.step1ValuesInfo["city"] == nil || (Utility.shared.step1ValuesInfo["city"] as? String) == "" {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "entercity"))!)")
            completion(true)
            return
        }
        if Utility.shared.step1ValuesInfo["state"] == nil || (Utility.shared.step1ValuesInfo["state"] as? String) == "" {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enterstate"))!)")
            completion(true)
            return
        }
        //mobile validation
        if Utility.shared.step1ValuesInfo["zipcode"] == nil || (Utility.shared.step1ValuesInfo["zipcode"] as? String) == ""  {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "enterzipcode"))!)")
            completion(true)
            return
        } else {
            if(Utility.shared.isfromshowmap) {
                completion(true)
            }  else {
                completion(false)
            }
            var bedtypeInfoArr = [[String : Any]]()
            if let bedTypeInfo = Utility.shared.step1ValuesInfo["bedTypes"] as? [Any] {
                for i in 0..<bedTypeInfo.count {
                    if let userBedTypes = bedTypeInfo[i] as? GetStep1ListingDetailsQuery.Data.GetListingDetail.Result.UserBedsType {
                        
                        var bedTypeInfo = [String : Any]()
                        if userBedTypes.bedType != nil {
                            bedTypeInfo.updateValue((userBedTypes.bedType)!, forKey: "bedType")
                            Utility.shared.step1ValuesInfo.updateValue(userBedTypes.bedType!, forKey: "bedType")
                            bedTypeInfo.updateValue(userBedTypes.bedCount!, forKey: "bedCount")
                            bedtypeInfoArr.append(bedTypeInfo)
                        }
                        
                    }
                    
                }
                let data = try? JSONSerialization.data(withJSONObject: bedtypeInfoArr, options: .prettyPrinted)
                let bedtypes = String(data: data!, encoding: String.Encoding.utf8)!
                var bedTypeString = ""
                if !bedtypes.isEmpty {
                    let bedTypesArr = bedtypes.components(separatedBy: "\n")
                    for str in bedTypesArr{
                        bedTypeString = bedTypeString + str
                    }
                }
                Utility.shared.step1ValuesInfo.updateValue(bedTypeString.trimmingCharacters(in: .whitespaces), forKey: "bedTypes")
            }
            
            let createlist = CreateListingMutationn(listId: Utility.shared.createId,
                                                   roomType: "\(Utility.shared.step1ValuesInfo["roomType"] ?? "")",
                                                    mobileNumber: "\(Utility.shared.step1ValuesInfo["mobile"] ?? "")",
                                                   houseType: "\(Utility.shared.step1ValuesInfo["houseType"] ?? "")" ,
                                                   residenceType: "\(Utility.shared.step1ValuesInfo["residenceType"] ?? "")",
                                                   bedrooms: "\(Utility.shared.step1ValuesInfo["bedrooms"] ?? "")" ,
                                                   buildingSize: "\(Utility.shared.step1ValuesInfo["buildingSize"] ?? "")",
                                                   bedType: "\(Utility.shared.step1ValuesInfo["bedType"] ?? "")" ,
                                                   beds: Utility.shared.step1ValuesInfo["beds"] as? Int,
                                                   personCapacity: Utility.shared.step1ValuesInfo["personCapacity"] as? Int,
                                                   bathrooms: (Utility.shared.step1ValuesInfo["bathrooms"] as? Double),
                                                   bathroomType: "\(Utility.shared.step1ValuesInfo["bathroomType"] ?? "")",
                                                   country: "\(Utility.shared.step1ValuesInfo["country"] ?? "")",
                                                   street: "\(Utility.shared.step1ValuesInfo["street"] ?? "")",
                                                   buildingName: "\(Utility.shared.step1ValuesInfo["buildingName"] ?? "")",
                                                   city: "\(Utility.shared.step1ValuesInfo["city"] ?? "")",
                                                   state: "\(Utility.shared.step1ValuesInfo["state"] ?? "")",
                                                   zipcode: "\(Utility.shared.step1ValuesInfo["zipcode"] ?? "")",
                                                   lat: (Utility.shared.step1ValuesInfo["lat"] as! Double),
                                                   lng: (Utility.shared.step1ValuesInfo["lng"] as! Double),
                                                   bedTypes: "\(Utility.shared.step1ValuesInfo["bedTypes"] ?? "")" ,
                                                   isMapTouched: Utility.shared.step1ValuesInfo["isMapTouched"] as? Bool,
                                                   amenities: Utility.shared.step1ValuesInfo["amenities"] as? [Int?] ,
                                                   safetyAmenities: Utility.shared.step1ValuesInfo["safetyAmenities"] as? [Int?],
                                                   spaces: Utility.shared.step1ValuesInfo["spaces"] as? [Int?])
            apollo_headerClient.perform(mutation: createlist){(result,error) in
                if(result?.data?.createListing?.status == 200) {
                    Utility.shared.createId = (result?.data?.createListing?.id)!
                    
                    if(Utility.shared.isfromshowmap) {
                        return
                    }  else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            let becomeHost = BecomeHostVC()
                            becomeHost.listID = "\(Utility.shared.createId)"
                            becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
                            becomeHost.modalPresentationStyle = .fullScreen
                            self.present(becomeHost, animated:false, completion: nil)
                        }
                    }
                } else {
                    
                    self.view.makeToast(result?.data?.createListing?.errorMessage)
                }
            }
        }
    }
    
    func updatelistingStep2APICall(completion: (_ success:Bool) -> Void) {
        let text_Title = "\(Utility.shared.step2ValuesInfo["title"] ?? "")".trimmingCharacters(in:.whitespacesAndNewlines)
        let text_Title1 = "\(Utility.shared.step2ValuesInfo["description"] ?? "")".trimmingCharacters(in:.whitespacesAndNewlines)
        if(text_Title == "") {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"addtitlealert"))!)")
            completion(true)
            return
        }
        if(text_Title1 == "") {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"desc_alert"))!)")
            completion(true)
            return
        } else {
            completion(false)
            let UpdateListingStep2mutation = UpdateListingStep2Mutation(id:Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0, description:"\(Utility.shared.step2ValuesInfo["description"] ?? "")", title:"\(Utility.shared.step2ValuesInfo["title"] ?? "")", coverPhoto:Utility.shared.step2ValuesInfo["coverPhoto"] != nil ? Utility.shared.step2ValuesInfo["coverPhoto"] as! Int : 0)
            apollo_headerClient.perform(mutation: UpdateListingStep2mutation){ (result,error) in
                
                if(result?.data?.updateListingStep2?.status == 200) {
                    let becomeHostObj = BecomeHostVC()
                    becomeHostObj.listID = "\(Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0)"
                    becomeHostObj.showListingStepsAPICall(listID:"\(Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0)")
                    becomeHostObj.modalPresentationStyle = .fullScreen
                    self.present(becomeHostObj, animated:false, completion: nil)
                    
                }
                else {
                    self.view.makeToast(result?.data?.updateListingStep2?.errorMessage)
                }
            }
        }
    }
    
    func profileAPICall() {
        
        if Utility.shared.isConnectedToNetwork() {
            
            if (Utility.shared.getCurrentUserID() != nil){
                let profileQuery = GetProfileQuery()
                apollo_client = {
                    let configuration = URLSessionConfiguration.default
                    configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                    let url = URL(string:graphQLEndpoint)!
                    
                    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
                    
                }()
                
                apollo_client.fetch(query: profileQuery, cachePolicy: .fetchIgnoringCacheData){ [self]  (result, error) in
                    
                    guard (result?.data?.userAccount?.result) != nil else {
                        
                        if result?.data?.userAccount?.status == 500{
                            let alert = UIAlertController(title: "\(Utility.shared.getLanguage()?.value(forKey: "oops") ?? "oops" )", message: result?.data?.userAccount?.errorMessage, preferredStyle: .alert)
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
                        }else{
                            return
                        }
                    }
                    self.ProfileAPIArray = ((result?.data?.userAccount?.result)!)
                    
                    Utility.shared.userName  = "\(ProfileAPIArray.firstName != nil ? ProfileAPIArray.firstName! : "User")!"
                    
                    
                    if let profImage = ProfileAPIArray.picture{
                        Utility.shared.pickedimageString = "\(IMAGE_AVATAR_MEDIUM)\(profImage)"
                    } else {
                        Utility.shared.pickedimageString = "avatar"
                    }
                    
                    self.setUpUI()
                    
                    if (result?.data?.userAccount?.result?.picture) == nil {
                        Utility.shared.isprofilepictureVerified = true
                        
                    }else{
                        
                        Utility.shared.isprofilepictureVerified = false
                    }
                }
            }
        }else{
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey: "error_field"))!)")
        }
    }
    
    func setUpUI() {
        if(Utility.shared.pickedimageString == "") {
            overlayUsername.text = "Hi, \(ProfileAPIArray.firstName != nil ? ProfileAPIArray.firstName! : "User")!"
            overlaystep3.text = "\(Utility.shared.getLanguage()?.value(forKey: "ready") ?? "")"
            
            if let profImage = ProfileAPIArray.picture{
                overlayUserImage.sd_setImage(with: URL(string:"\(IMAGE_AVATAR_MEDIUM)\(profImage)"), placeholderImage: #imageLiteral(resourceName: "unknown"))
                overlayUserImage.contentMode = .scaleAspectFill
            }
            else {
                overlayUserImage.image = #imageLiteral(resourceName: "unknown")
            }
        } else {
            overlayUsername.text = "Hi, \(Utility.shared.userName)"
            overlaystep3.text = "\(Utility.shared.getLanguage()?.value(forKey: "ready") ?? "")"
            if(Utility.shared.pickedimageString == "avatar") {
                overlayUserImage.image = #imageLiteral(resourceName: "unknown")
            } else {
                overlayUserImage.sd_setImage(with: URL(string:Utility.shared.pickedimageString), placeholderImage: #imageLiteral(resourceName: "unknown"))
                overlayUserImage.contentMode = .scaleAspectFill
                
            }
        }
        overlayUserImage.borderColor = Theme.ButtonBack_BG
        overlayUserImage.borderWidth = 2.0
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        baseBottomView.backgroundColor =  UIColor(named: "colorController")
        
        baseCurvedView.backgroundColor = UIColor(named: "colorController")
        
        nextRedirectBtn.backgroundColor = Theme.Button_BG
        
        self.baseBackBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.baseBackBtn.setTitle("", for: .normal)
        self.baseBackBtn.backgroundColor = UIColor.white
        self.baseBackBtn.layer.cornerRadius = self.baseBackBtn.frame.size.height/2
        self.baseBackBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.baseBackBtn.rotateImageViewofBtn()
        }
        overlayBtn.isHidden = false
        handimg.isHidden = false
        self.baseTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "lets_become_host") ?? "Hi! Let's get you ready to become a host.")"
        self.baseTitleLabel.textColor = UIColor(named: "Title_Header")
        self.baseTitleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.baseTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        baseProgressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        baseCurvedProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.baseCurvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.baseCurvedView.layer.borderWidth = 0.5
        self.baseCurvedView.layer.cornerRadius = 20.0
        self.baseCurvedView.clipsToBounds = true
        self.offlineView.isHidden = true
        hostTable.isHidden = false
        hostTable.separatorStyle = .none
        hostTable.rowHeight = UITableView.automaticDimension
        hostTable.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextRedirectBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "next")as! String)", for: .normal)
        nextRedirectBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLAbel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButton.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        nextRedirectBtn.layer.cornerRadius = nextRedirectBtn.frame.size.height/2
        nextRedirectBtn.clipsToBounds = true
        nextRedirectBtn.tintColor = UIColor.white
        errorLAbel.textColor =  UIColor(named: "Title_Header")
        retryButton.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButton.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        
        overlayUsername.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
        overlayUsername.textColor = UIColor(named: "Title_Header")
        overlaystep3.textColor = UIColor(named: "Title_Header")
        overlaystep3.font = UIFont(name: APP_FONT_MEDIUM, size: 22)
    }
    
    func registerCells() {
        hostTable.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textfieldcell")
        hostTable.register(UINib(nibName: "SingleTextFieldCell", bundle: nil), forCellReuseIdentifier: "singletextfieldcell")
    }
    
    func setdropdown() {
        listInputView.frame = CGRect(x: 0, y: FULLHEIGHT-200, width: FULLWIDTH, height: 200)
        listValuePicker.frame = CGRect(x: 0, y: 0, width: FULLWIDTH, height: 200)
        listInputView.addSubview(listValuePicker)
        listValuePicker.delegate = self
        listValuePicker.tintColor = Theme.PRIMARY_COLOR
        listValuePicker.backgroundColor = UIColor(named: "colorController")
        listValuePicker.reloadAllComponents()
    }
    
    func setDropdownList() {
        setRoomType()
        setPersonCapacity()
        hostTable.reloadData()
    }
    
    func setRoomType() {
        if(Utility.shared.getListSettingsArray.roomType != nil) {
            let listSettings = (Utility.shared.getListSettingsArray.roomType?.listSettings!)!
            for item in listSettings {
                itemNameArray.append((item?.itemName)!)
            }
            if !Utility.shared.step1ValuesInfo.keys.contains("roomType") && itemNameArray.count > 0 {
                placeLabel = itemNameArray.first!
                listValuePicker.selectRow(0, inComponent: 0, animated: true)
                
                Utility.shared.step1ValuesInfo.updateValue((listSettings[0]?.id!)!, forKey: "roomType")
            }else{
                _ = listSettings.filter({ (item) -> Bool in
                    if (Utility.shared.step1ValuesInfo["roomType"]! as? Int) == item?.id {
                        placeLabel = (item?.itemName!)!
                        return true
                    }else{
                        return false
                    }
                })
                if !placeLabel.isEmpty {
                    let index = itemNameArray.firstIndex(where: { (item) -> Bool in
                        item == placeLabel
                    })
                    listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func setPersonCapacity() {
        if(Utility.shared.getListSettingsArray.personCapacity != nil) {
            if let guestcountStartValue = Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.startValue, let guestcountEndValue = Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.endValue {
                guestArrayCount = guestcountEndValue
            }
            
            var guestWord = ""
            if Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.startValue == 1 {
                guestWord = "\(Utility.shared.getLanguage()?.value(forKey: "guest")as! String)"
            } else{
                guestWord = "\( Utility.shared.getLanguage()?.value(forKey: "guests")as! String)"
            }
            
            var incrVal = 0
            for i in 0...guestArrayCount {
                if i == 0 {
                    incrVal = (Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.startValue!)!
                    if incrVal > 1{
                        guestsDropdownArray.insert("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(getListSettingsArray.personCapacity?.listSettings![0]?.startValue ?? 0) \(Utility.shared.getLanguage()?.value(forKey: "CapGuests") ?? "Guests")" , at: i)
                    }else{
                        guestsDropdownArray.insert("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(getListSettingsArray.personCapacity?.listSettings![0]?.startValue ?? 0) \(Utility.shared.getLanguage()?.value(forKey: "guest") ?? "Guest")" , at: i)
                    }
                }else {
                    incrVal = (incrVal + 1)
                    if incrVal > 1{
                        guestsDropdownArray.insert("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(incrVal) \(Utility.shared.getLanguage()?.value(forKey: "CapGuests") ?? "Guests")" , at: i)
                    } else {
                        guestsDropdownArray.insert("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(incrVal) \(Utility.shared.getLanguage()?.value(forKey: "guest") ?? "Guest")" , at: i)
                    }
                }
            }
            if !Utility.shared.step1ValuesInfo.keys.contains("personCapacity") {
                guestLabel = guestsDropdownArray.first!
                listValuePicker.selectRow(0, inComponent: 0, animated: true)
                Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.personCapacity?.listSettings![0]?.startValue!)!, forKey: "personCapacity")
            }else{
                if((Utility.shared.step1ValuesInfo["personCapacity"]!as! Int) <= 1) {
                    guestLabel = ("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(Utility.shared.step1ValuesInfo["personCapacity"]!) \(Utility.shared.getLanguage()?.value(forKey: "guest")as! String)")
                } else {
                    guestLabel = ("\(Utility.shared.getLanguage()?.value(forKey: "Cap_for")as! String) \(Utility.shared.step1ValuesInfo["personCapacity"]!) \(Utility.shared.getLanguage()?.value(forKey: "guests")as! String)")
                }
                if !guestLabel.isEmpty {
                    let index = guestsDropdownArray.firstIndex(where: { (item) -> Bool in
                        item == guestLabel
                    })
                    listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func addLottieViewAsSubview() {
    }
    
    @objc func autoscroll_base() {
        self.lottieView.play()
    }

    @IBAction func dismissViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func redirectToNextPage(_ sender: Any) {
        let placeListing = PlaceListingViewController()
        placeListing.delegatePlaceListing = self
        self.view.window?.backgroundColor = UIColor.white
        placeListing.modalPresentationStyle = .fullScreen
        self.present(placeListing, animated: false, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(Utility.shared.getLanguage()?.value(forKey: "lets_become_host")as! String)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textfieldcell", for: indexPath) as? TextFieldCell
            
            if indexPath.row == 0 {
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.object(forKey: "Place_kind")as! String)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: placeLabel,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.tintColor = UIColor.clear
                cell?.txtField.inputView = listInputView
                cell?.txtField.tag = 1
                cell?.txtField.delegate = self
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
                cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                
                cell?.stepNumberLblTopConstraint.constant = 0
                cell?.linebottomconstant.constant = 0
                cell?.linetopconstant.constant = 0
                
            } else if indexPath.row == 1 {
                cell?.queryTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "No_of_guestAccommodated")as! String)"
                cell?.txtField.attributedPlaceholder = NSAttributedString(string: guestLabel,
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Title_Header")])
                cell?.selectionStyle = .none
                let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissgenderPicker))
                toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
                cell?.txtField.inputAccessoryView = toolBar
                cell?.txtField.inputView = listInputView
                cell?.txtField.tintColor = UIColor.clear
                cell?.txtField.tag = 2
                cell?.txtField.delegate = self
                cell?.stepnumberLbl.isHidden = true
                cell?.queryTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
                cell?.txtField.font = UIFont(name: APP_FONT, size: 14)
                cell?.queryTitleLbl.textColor =  UIColor(named: "Title_Header")
                
                cell?.stepNumberLblTopConstraint.constant = 0
                cell?.linebottomconstant.constant = 0
                cell?.linetopconstant.constant = 0
            }
            
            cell?.imgDownArrow.isHidden = false
            return cell!
        }
        
        return UITableViewCell()
        
    }
    
    @objc func onClickedbaseDownArrow(sender: UIButton){
        let cell = hostTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TextFieldCell
        cell.txtField.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            selectedTextfield = 1
            if !placeLabel.isEmpty {
                let index = itemNameArray.firstIndex(where: { (item) -> Bool in
                    item == placeLabel
                })
                listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        } else if indexPath.row == 1 {
            selectedTextfield = 2
            if !guestLabel.isEmpty {
                let index = guestsDropdownArray.firstIndex(where: { (item) -> Bool in
                    item == guestLabel
                })
                listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
        listValuePicker.reloadAllComponents()
    }
    
    @objc func dismissgenderPicker(text:Int) {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(selectedTextfield == 1) {
            return itemNameArray.count
        } else{
            return guestArrayCount
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var titleData = ""
        if(selectedTextfield == 1) {
            titleData = itemNameArray[row]
        }else{
            titleData = guestsDropdownArray[row]
        }
        let myTitle = NSAttributedString(string: titleData , attributes: [NSAttributedString.Key.font:UIFont(name: APP_FONT, size: 15.0)!,NSAttributedString.Key.foregroundColor:Theme.PRIMARY_COLOR])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        
        if(selectedTextfield == 1) {
            placeLabel = itemNameArray[row]
            listValuePicker.selectRow(row, inComponent: component, animated: true)
            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.roomType?.listSettings![row]?.id!)!, forKey: "roomType")
        } else {
            guestLabel = guestsDropdownArray[row]
            listValuePicker.selectRow(row, inComponent: component, animated: true)
            let stringArray = guestLabel.components(separatedBy: CharacterSet.decimalDigits.inverted)
            for item in stringArray {
                if let number = Int(item) {
                    Utility.shared.step1ValuesInfo.updateValue(number, forKey: "personCapacity")
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        if selectedTextfield == 1 {
            if !placeLabel.isEmpty {
                let index = itemNameArray.firstIndex(where: { (item) -> Bool in
                    item == placeLabel
                })
                listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }else if selectedTextfield == 2 {
            if !guestLabel.isEmpty {
                let index = guestsDropdownArray.firstIndex(where: { (item) -> Bool in
                    item == guestLabel
                    
                })
                listValuePicker.selectRow(index != nil ? index! : 0, inComponent: 0, animated: true)
            }
        }
        listValuePicker.reloadAllComponents()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        selectedTextfield = textField.tag
        hostTable.reloadData()
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func overlayStartTapped(_ sender: Any) {
        self.overlayView.isHidden = true
    }
    
    
    @IBAction func overlayBackBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


public final class UpdateListingStep3Mutationn: GraphQLMutation {
  public let operationDefinition =
    "mutation UpdateListingStep3($id: Int, $houseRules: [Int], $bookingNoticeTime: String, $checkInStart: String, $checkInEnd: String, $maxDaysNotice: String, $minNight: Int, $maxNight: Int, $basePrice: Float, $cleaningPrice: Float, $tax: Float, $currency: String, $weeklyDiscount: Int, $monthlyDiscount: Int, $blockedDates: [String], $bookingType: String!, $cancellationPolicy: Int, $guestBasePrice: Int, $additionalPrice: Float, $visitorsLimit: Int, $visitorsPrice: Float, $petLimit: Int, $petPrice: Float, $infantLimit: Int, $infantPrice: Float) {\n  updateListingStep3(id: $id, houseRules: $houseRules, bookingNoticeTime: $bookingNoticeTime, checkInStart: $checkInStart, checkInEnd: $checkInEnd, maxDaysNotice: $maxDaysNotice, minNight: $minNight, maxNight: $maxNight, basePrice: $basePrice, cleaningPrice: $cleaningPrice, tax: $tax, currency: $currency, weeklyDiscount: $weeklyDiscount, monthlyDiscount: $monthlyDiscount, blockedDates: $blockedDates, bookingType: $bookingType, cancellationPolicy: $cancellationPolicy, guestBasePrice: $guestBasePrice, additionalPrice: $additionalPrice, visitorsLimit: $visitorsLimit, visitorsPrice: $visitorsPrice, petLimit: $petLimit, petPrice: $petPrice, infantLimit: $infantLimit, infantPrice: $infantPrice) {\n    __typename\n    results {\n      __typename\n      id\n      houseRules\n      bookingNoticeTime\n      checkInStart\n      checkInEnd\n      maxDaysNotice\n      minNight\n      maxNight\n      basePrice\n      cleaningPrice\n      tax\n      currency\n      weeklyDiscount\n      monthlyDiscount\n      blockedDates\n      guestBasePrice\n      additionalPrice\n      visitorsLimit\n      visitorsPrice\n      petLimit\n      petPrice\n      infantLimit\n      infantPrice\n}\n    status\n    errorMessage\n    actionType\n  }\n}"

  public var id: Int?
  public var houseRules: [Int?]?
  public var bookingNoticeTime: String?
  public var checkInStart: String?
  public var checkInEnd: String?
  public var maxDaysNotice: String?
  public var minNight: Int?
  public var maxNight: Int?
  public var basePrice: Double?
  public var cleaningPrice: Double?
  public var tax: Double?
  public var currency: String?
  public var weeklyDiscount: Int?
  public var monthlyDiscount: Int?
  public var blockedDates: [String?]?
  public var bookingType: String
  public var cancellationPolicy: Int?
  public var guestBasePrice: Int?
  public var additionalPrice: Double?
  public var visitorsLimit: Int?
  public var visitorsPrice: Double?
  public var petLimit: Int?
  public var petPrice: Double?
  public var infantLimit: Int?
  public var infantPrice: Double?

  public init(id: Int? = nil, houseRules: [Int?]? = nil, bookingNoticeTime: String? = nil, checkInStart: String? = nil, checkInEnd: String? = nil, maxDaysNotice: String? = nil, minNight: Int? = nil, maxNight: Int? = nil, basePrice: Double? = nil, cleaningPrice: Double? = nil, tax: Double? = nil, currency: String? = nil, weeklyDiscount: Int? = nil, monthlyDiscount: Int? = nil, blockedDates: [String?]? = nil, bookingType: String, cancellationPolicy: Int? = nil, guestBasePrice: Int? = nil, additionalPrice: Double? = nil, visitorsLimit: Int? = nil, visitorsPrice: Double? = nil, petLimit: Int? = nil, petPrice: Double? = nil, infantLimit: Int? = nil, infantPrice: Double? = nil) {
    self.id = id
    self.houseRules = houseRules
    self.bookingNoticeTime = bookingNoticeTime
    self.checkInStart = checkInStart
    self.checkInEnd = checkInEnd
    self.maxDaysNotice = maxDaysNotice
    self.minNight = minNight
    self.maxNight = maxNight
    self.basePrice = basePrice
    self.cleaningPrice = cleaningPrice
    self.tax = tax
    self.currency = currency
    self.weeklyDiscount = weeklyDiscount
    self.monthlyDiscount = monthlyDiscount
    self.blockedDates = blockedDates
    self.bookingType = bookingType
    self.cancellationPolicy = cancellationPolicy
    self.guestBasePrice = guestBasePrice
    self.additionalPrice = additionalPrice
    self.visitorsLimit = visitorsLimit
    self.visitorsPrice = visitorsPrice
    self.petLimit = petLimit
    self.petPrice = petPrice
    self.infantLimit = infantLimit
    self.infantPrice = infantPrice
  }

  public var variables: GraphQLMap? {
    return ["id": id, "houseRules": houseRules, "bookingNoticeTime": bookingNoticeTime, "checkInStart": checkInStart, "checkInEnd": checkInEnd, "maxDaysNotice": maxDaysNotice, "minNight": minNight, "maxNight": maxNight, "basePrice": basePrice, "cleaningPrice": cleaningPrice, "tax": tax, "currency": currency, "weeklyDiscount": weeklyDiscount, "monthlyDiscount": monthlyDiscount, "blockedDates": blockedDates, "bookingType": bookingType, "cancellationPolicy": cancellationPolicy, "guestBasePrice": guestBasePrice, "additionalPrice": additionalPrice, "visitorsLimit": visitorsLimit, "visitorsPrice": visitorsPrice, "petLimit": petLimit, "petPrice": petPrice, "infantLimit": infantLimit, "infantPrice": infantPrice]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateListingStep3", arguments: ["id": GraphQLVariable("id"), "houseRules": GraphQLVariable("houseRules"), "bookingNoticeTime": GraphQLVariable("bookingNoticeTime"), "checkInStart": GraphQLVariable("checkInStart"), "checkInEnd": GraphQLVariable("checkInEnd"), "maxDaysNotice": GraphQLVariable("maxDaysNotice"), "minNight": GraphQLVariable("minNight"), "maxNight": GraphQLVariable("maxNight"), "basePrice": GraphQLVariable("basePrice"), "cleaningPrice": GraphQLVariable("cleaningPrice"), "tax": GraphQLVariable("tax"), "currency": GraphQLVariable("currency"), "weeklyDiscount": GraphQLVariable("weeklyDiscount"), "monthlyDiscount": GraphQLVariable("monthlyDiscount"), "blockedDates": GraphQLVariable("blockedDates"), "bookingType": GraphQLVariable("bookingType"), "cancellationPolicy": GraphQLVariable("cancellationPolicy"), "guestBasePrice": GraphQLVariable("guestBasePrice"), "additionalPrice": GraphQLVariable("additionalPrice"), "visitorsLimit": GraphQLVariable("visitorsLimit"), "visitorsPrice": GraphQLVariable("visitorsPrice"), "petLimit": GraphQLVariable("petLimit"), "petPrice": GraphQLVariable("petPrice"), "infantLimit": GraphQLVariable("infantLimit"), "infantPrice": GraphQLVariable("infantPrice")], type: .object(UpdateListingStep3.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateListingStep3: UpdateListingStep3? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateListingStep3": updateListingStep3.flatMap { (value: UpdateListingStep3) -> ResultMap in value.resultMap }])
    }

    public var updateListingStep3: UpdateListingStep3? {
      get {
        return (resultMap["updateListingStep3"] as? ResultMap).flatMap { UpdateListingStep3(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "updateListingStep3")
      }
    }

    public struct UpdateListingStep3: GraphQLSelectionSet {
      public static let possibleTypes = ["EditListingResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("results", type: .object(Result.selections)),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
        GraphQLField("actionType", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(results: Result? = nil, status: Int? = nil, errorMessage: String? = nil, actionType: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "EditListingResponse", "results": results.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage, "actionType": actionType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var results: Result? {
        get {
          return (resultMap["results"] as? ResultMap).flatMap { Result(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "results")
        }
      }

      public var status: Int? {
        get {
          return resultMap["status"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }

      public var errorMessage: String? {
        get {
          return resultMap["errorMessage"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "errorMessage")
        }
      }

      public var actionType: String? {
        get {
          return resultMap["actionType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "actionType")
        }
      }

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["EditListing"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("houseRules", type: .list(.scalar(Int.self))),
          GraphQLField("bookingNoticeTime", type: .scalar(String.self)),
          GraphQLField("checkInStart", type: .scalar(String.self)),
          GraphQLField("checkInEnd", type: .scalar(String.self)),
          GraphQLField("maxDaysNotice", type: .scalar(String.self)),
          GraphQLField("minNight", type: .scalar(Int.self)),
          GraphQLField("maxNight", type: .scalar(Int.self)),
          GraphQLField("basePrice", type: .scalar(Double.self)),
          GraphQLField("cleaningPrice", type: .scalar(Double.self)),
          GraphQLField("tax", type: .scalar(Double.self)),
          GraphQLField("currency", type: .scalar(String.self)),
          GraphQLField("weeklyDiscount", type: .scalar(Int.self)),
          GraphQLField("monthlyDiscount", type: .scalar(Int.self)),
          GraphQLField("blockedDates", type: .list(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int? = nil, houseRules: [Int?]? = nil, bookingNoticeTime: String? = nil, checkInStart: String? = nil, checkInEnd: String? = nil, maxDaysNotice: String? = nil, minNight: Int? = nil, maxNight: Int? = nil, basePrice: Double? = nil, cleaningPrice: Double? = nil, tax: Double? = nil, currency: String? = nil, weeklyDiscount: Int? = nil, monthlyDiscount: Int? = nil, blockedDates: [String?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "EditListing", "id": id, "houseRules": houseRules, "bookingNoticeTime": bookingNoticeTime, "checkInStart": checkInStart, "checkInEnd": checkInEnd, "maxDaysNotice": maxDaysNotice, "minNight": minNight, "maxNight": maxNight, "basePrice": basePrice, "cleaningPrice": cleaningPrice, "tax": tax, "currency": currency, "weeklyDiscount": weeklyDiscount, "monthlyDiscount": monthlyDiscount, "blockedDates": blockedDates])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: Int? {
          get {
            return resultMap["id"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var houseRules: [Int?]? {
          get {
            return resultMap["houseRules"] as? [Int?]
          }
          set {
            resultMap.updateValue(newValue, forKey: "houseRules")
          }
        }

        public var bookingNoticeTime: String? {
          get {
            return resultMap["bookingNoticeTime"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bookingNoticeTime")
          }
        }

        public var checkInStart: String? {
          get {
            return resultMap["checkInStart"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "checkInStart")
          }
        }

        public var checkInEnd: String? {
          get {
            return resultMap["checkInEnd"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "checkInEnd")
          }
        }

        public var maxDaysNotice: String? {
          get {
            return resultMap["maxDaysNotice"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "maxDaysNotice")
          }
        }

        public var minNight: Int? {
          get {
            return resultMap["minNight"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "minNight")
          }
        }

        public var maxNight: Int? {
          get {
            return resultMap["maxNight"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "maxNight")
          }
        }

        public var basePrice: Double? {
          get {
            return resultMap["basePrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "basePrice")
          }
        }

        public var cleaningPrice: Double? {
          get {
            return resultMap["cleaningPrice"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "cleaningPrice")
          }
        }

        public var tax: Double? {
          get {
            return resultMap["tax"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "tax")
          }
        }

        public var currency: String? {
          get {
            return resultMap["currency"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currency")
          }
        }

        public var weeklyDiscount: Int? {
          get {
            return resultMap["weeklyDiscount"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "weeklyDiscount")
          }
        }

        public var monthlyDiscount: Int? {
          get {
            return resultMap["monthlyDiscount"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "monthlyDiscount")
          }
        }

        public var blockedDates: [String?]? {
          get {
            return resultMap["blockedDates"] as? [String?]
          }
          set {
            resultMap.updateValue(newValue, forKey: "blockedDates")
          }
        }
      }
    }
  }
}
