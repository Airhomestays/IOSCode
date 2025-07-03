
import UIKit
import Lottie
import Apollo

class HouseRulesViewController: BaseHostTableviewController {
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var curvedProgressView: UIView!
    @IBOutlet weak var saveandExitBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var retryButn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    var houserule = ""
    var houseRules = [[String : Any]]()
    var lottieView1: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        
        nextBtn.backgroundColor = Theme.Button_BG
        saveandExitBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "house_rules") ?? "What are your house rules?")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        curvedProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        saveandExitBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExitBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExitBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedIndex = 0
        self.stepsTitleView.delegateSteps = self
    }
    
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        
        if(Utility.shared.step3_Edit) {
            self.saveandExitBtn.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else{
            self.saveandExitBtn.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = ((self.view.frame.width/8) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    override func setDropdownList() {
        let houseRule = (Utility.shared.getListSettingsArray.houseRules?.listSettings!)!
        for i in 0..<houseRule.count {
            var amenityInfo = [String : Any]()
            amenityInfo.updateValue(houseRule[i]!.itemName!, forKey: "itemName")
            amenityInfo.updateValue(houseRule[i]!.id!, forKey: "id")
            houseRules.append(amenityInfo)
        }
        if Utility.shared.step3ValuesInfo.keys.contains("houseRules") {
            if let typeInfo = Utility.shared.step3ValuesInfo["houseRules"] as? [Any] {
                for i in 0..<typeInfo.count {
                    if let userhouseTypes = typeInfo[i] as? GetListingDetailsStep3Queryy.Data.GetListingDetail.Result.HouseRule {
                        if houseRules.contains(where: { (item) -> Bool in
                            (item["id"] as? Int == (userhouseTypes.id))}) {
                            Utility.shared.selectedRules.add(userhouseTypes.id!)
//                            Utility.shared.selectedRulesNames.add(userhouseTypes.itemName!)
                        }
                        
                    }
                }
            }
            
        } else {
            houserule = (houseRules.first! is [String : Any]) ? houseRules.first!["itemName"] as! String : ""
            Utility.shared.selectedRules.removeAllObjects()
            Utility.shared.selectedRulesNames.removeAllObjects()
            
        }
        Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
        tableView.reloadData()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "AmenitiesCell", bundle: nil), forCellReuseIdentifier: "AmenitiesCell")
        tableView.register(UINib(nibName: "ReviewInstantCells", bundle: nil), forCellReuseIdentifier: "reviewInstantCells")
    }
    
    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
    }
    
    func lottieViewanimation() {
        saveandExitBtn.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveandExitBtn.frame.size.width/2)-50), y:0, width:100, height:self.saveandExitBtn.frame.size.height)
        self.saveandExitBtn.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    @objc func autoscrolling() {
        self.lottieView1.play()
    }
    func offlineviewShow() {
        offlineUIView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.offlineUIView.isHidden = false
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlineUIView.frame.size.width + shadowSize2,
                                                    height: self.offlineUIView.frame.size.height + shadowSize2))
        
        self.offlineUIView.layer.masksToBounds = false
        self.offlineUIView.layer.shadowColor = Theme.TextLightColor.cgColor
        self.offlineUIView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.offlineUIView.layer.shadowOpacity = 0.3
        self.offlineUIView.layer.shadowPath = shadowPath2.cgPath
        if IS_IPHONE_X || IS_IPHONE_XR{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
        }else{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
        }
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
        let becomeHost = NoticeArrivalViewController()
        self.view.window?.backgroundColor = UIColor.white
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if(Utility.shared.step3_Edit) {
            let becomeHost = BecomeHostVC()
            becomeHost.listID = "\(Utility.shared.createId)"
            becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
            becomeHost.modalPresentationStyle = .fullScreen
            self.present(becomeHost, animated:false, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func goToBecomeHostVC(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    
    @IBAction func saveandExitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork() {
            self.lottieViewanimation()
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    saveandExitBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineviewShow()
        }  
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x:15, y: 8, width: FULLWIDTH-40, height:75))
        headerLabel.font =  UIFont(name: APP_FONT_MEDIUM, size:25)
        headerLabel.addCharacterSpacing()
        headerLabel.textColor =  UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        headerLabel.numberOfLines = 0
        let headerView = UIView(frame: CGRect(x:15, y: 8, width: tableView.bounds.size.width - 20, height: 75))
        headerView.backgroundColor = UIColor.white
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return houseRules.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AmenitiesCell", for: indexPath) as? AmenitiesCell
        cell?.amenitieslistTile.text = houseRules[indexPath.row]["itemName"] as? String
        cell?.tag = ((indexPath.row)+300)
        cell?.iconWidthConstraint.constant = 0
        cell?.iconTrailingConstraint.constant = 0
        cell?.amenitiesImgIcon.isHidden = true
        
        if(Utility.shared.selectedRules.contains(houseRules[indexPath.row]["id"] as! Int)) {
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        } else {
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        }
        
        cell?.checkBtn.tag = indexPath.row
        cell?.checkBtn.addTarget(self, action: #selector(amenitiescheckBtnTapped(_:)), for: .touchUpInside)
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableView.automaticDimension : 65
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = view.viewWithTag((indexPath.row) + 300) as? AmenitiesCell
        if(Utility.shared.selectedRules.contains(houseRules[indexPath.row]["id"] as! Int)) {
            Utility.shared.selectedRulesNames.remove(houseRules[indexPath.row]["itemName"] as! String)
            Utility.shared.selectedRules.remove(houseRules[indexPath.row]["id"] as! Int)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        } else {
            if houseRules[indexPath.row]["itemName"] as? String == (cell?.amenitieslistTile.text)! {
                Utility.shared.selectedRules.add(houseRules[indexPath.row]["id"] as! Int)
                Utility.shared.selectedRulesNames.add(houseRules[indexPath.row]["itemName"] as! String)
            }
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        }
    }
    
    @objc func amenitiescheckBtnTapped(_ sender: UIButton) {
        let cell = view.viewWithTag((sender.tag) + 300) as? AmenitiesCell
        if(Utility.shared.selectedRules.contains(houseRules[sender.tag]["id"] as! Int)) {
            
            Utility.shared.selectedRulesNames.remove(houseRules[sender.tag]["itemName"] as! String)
            Utility.shared.selectedRules.remove(houseRules[sender.tag]["id"] as! Int)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        } else{
            if houseRules[sender.tag]["itemName"] as? String == (cell?.amenitieslistTile.text)! {
                
                Utility.shared.selectedRulesNames.add(houseRules[sender.tag]["itemName"] as! String)
                Utility.shared.selectedRules.add(houseRules[sender.tag]["id"] as! Int)
            }
            
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        }
    }
}

extension HouseRulesViewController: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 3{
            switch selectedPageIndex{
            case 6:
                let StepTwoObj = ReviewGuestViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
                break
            case 0:
                break
            case 1:
                let becomeHost = NoticeArrivalViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 4:
                let guestListing = TripLengthViewController()
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 2:
                let amenities = BasePriceViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 3:
                let amenities = DiscountViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 5:
                let amenities = IncreaseEarningViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 7:
                let amenities = LawAndTaxViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            default:
                break
            }
        }
    }
}


public final class GetListingDetailsStep3Queryy: GraphQLQuery {
  public let operationDefinition =
    "query GetListingDetailsStep3($listId: String!, $preview: Boolean) {\n  getListingDetails(listId: $listId, preview: $preview) {\n    __typename\n    results {\n      __typename\n      id\n      userId\n      bookingType\n      isPublished\n      houseRules {\n        __typename\n        id\n      }\n      listingData {\n        __typename\n        bookingNoticeTime\n        checkInStart\n        checkInEnd\n        maxDaysNotice\n        minNight\n        maxNight\n        basePrice\n        guestBasePrice\n        additionalPrice\n        visitorsLimit\n        visitorsPrice\n        petLimit\n        petPrice\n        infantLimit\n        infantPrice\n        cleaningPrice\n        tax\n        currency\n        weeklyDiscount\n        monthlyDiscount\n        cancellationPolicy\n      }\n      blockedDates {\n        __typename\n        blockedDates\n        reservationId\n      }\n      calendars {\n        __typename\n        id\n        name\n        url\n        listId\n        status\n      }\n    }\n    status\n    errorMessage\n  }\n}"

  public var listId: String
  public var preview: Bool?

  public init(listId: String, preview: Bool? = nil) {
    self.listId = listId
    self.preview = preview
  }

  public var variables: GraphQLMap? {
    return ["listId": listId, "preview": preview]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getListingDetails", arguments: ["listId": GraphQLVariable("listId"), "preview": GraphQLVariable("preview")], type: .object(GetListingDetail.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getListingDetails: GetListingDetail? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getListingDetails": getListingDetails.flatMap { (value: GetListingDetail) -> ResultMap in value.resultMap }])
    }

    public var getListingDetails: GetListingDetail? {
      get {
        return (resultMap["getListingDetails"] as? ResultMap).flatMap { GetListingDetail(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getListingDetails")
      }
    }

    public struct GetListingDetail: GraphQLSelectionSet {
      public static let possibleTypes = ["AllListing"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("results", type: .object(Result.selections)),
        GraphQLField("status", type: .scalar(Int.self)),
        GraphQLField("errorMessage", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(results: Result? = nil, status: Int? = nil, errorMessage: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "AllListing", "results": results.flatMap { (value: Result) -> ResultMap in value.resultMap }, "status": status, "errorMessage": errorMessage])
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

      public struct Result: GraphQLSelectionSet {
        public static let possibleTypes = ["ShowListing"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(Int.self)),
          GraphQLField("userId", type: .scalar(String.self)),
          GraphQLField("bookingType", type: .scalar(String.self)),
          GraphQLField("isPublished", type: .scalar(Bool.self)),
          GraphQLField("houseRules", type: .list(.object(HouseRule.selections))),
          GraphQLField("listingData", type: .object(ListingDatum.selections)),
          GraphQLField("blockedDates", type: .list(.object(BlockedDate.selections))),
          GraphQLField("calendars", type: .list(.object(Calendar.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int? = nil, userId: String? = nil, bookingType: String? = nil, isPublished: Bool? = nil, houseRules: [HouseRule?]? = nil, listingData: ListingDatum? = nil, blockedDates: [BlockedDate?]? = nil, calendars: [Calendar?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "ShowListing", "id": id, "userId": userId, "bookingType": bookingType, "isPublished": isPublished, "houseRules": houseRules.flatMap { (value: [HouseRule?]) -> [ResultMap?] in value.map { (value: HouseRule?) -> ResultMap? in value.flatMap { (value: HouseRule) -> ResultMap in value.resultMap } } }, "listingData": listingData.flatMap { (value: ListingDatum) -> ResultMap in value.resultMap }, "blockedDates": blockedDates.flatMap { (value: [BlockedDate?]) -> [ResultMap?] in value.map { (value: BlockedDate?) -> ResultMap? in value.flatMap { (value: BlockedDate) -> ResultMap in value.resultMap } } }, "calendars": calendars.flatMap { (value: [Calendar?]) -> [ResultMap?] in value.map { (value: Calendar?) -> ResultMap? in value.flatMap { (value: Calendar) -> ResultMap in value.resultMap } } }])
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

        public var userId: String? {
          get {
            return resultMap["userId"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "userId")
          }
        }

        public var bookingType: String? {
          get {
            return resultMap["bookingType"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "bookingType")
          }
        }

        public var isPublished: Bool? {
          get {
            return resultMap["isPublished"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isPublished")
          }
        }

        public var houseRules: [HouseRule?]? {
          get {
            return (resultMap["houseRules"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [HouseRule?] in value.map { (value: ResultMap?) -> HouseRule? in value.flatMap { (value: ResultMap) -> HouseRule in HouseRule(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [HouseRule?]) -> [ResultMap?] in value.map { (value: HouseRule?) -> ResultMap? in value.flatMap { (value: HouseRule) -> ResultMap in value.resultMap } } }, forKey: "houseRules")
          }
        }

        public var listingData: ListingDatum? {
          get {
            return (resultMap["listingData"] as? ResultMap).flatMap { ListingDatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "listingData")
          }
        }

        public var blockedDates: [BlockedDate?]? {
          get {
            return (resultMap["blockedDates"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [BlockedDate?] in value.map { (value: ResultMap?) -> BlockedDate? in value.flatMap { (value: ResultMap) -> BlockedDate in BlockedDate(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [BlockedDate?]) -> [ResultMap?] in value.map { (value: BlockedDate?) -> ResultMap? in value.flatMap { (value: BlockedDate) -> ResultMap in value.resultMap } } }, forKey: "blockedDates")
          }
        }

        public var calendars: [Calendar?]? {
          get {
            return (resultMap["calendars"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Calendar?] in value.map { (value: ResultMap?) -> Calendar? in value.flatMap { (value: ResultMap) -> Calendar in Calendar(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Calendar?]) -> [ResultMap?] in value.map { (value: Calendar?) -> ResultMap? in value.flatMap { (value: Calendar) -> ResultMap in value.resultMap } } }, forKey: "calendars")
          }
        }

        public struct HouseRule: GraphQLSelectionSet {
          public static let possibleTypes = ["allListSettingTypes"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(Int.self)),
//            GraphQLField("itemName", type: .scalar(String.self)),
            
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int? = nil, itemName: String? = nil) {
//            self.init(unsafeResultMap: ["__typename": "allListSettingTypes", "id": id, "itemName": itemName])
              self.init(unsafeResultMap: ["__typename": "allListSettingTypes", "id": id])
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
            
//            public var itemName: String? {
//              get {
//                return resultMap["itemName"] as? String
//              }
//              set {
//                resultMap.updateValue(newValue, forKey: "itemName")
//              }
//            }
        }

        public struct ListingDatum: GraphQLSelectionSet {
          public static let possibleTypes = ["listingData"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bookingNoticeTime", type: .scalar(String.self)),
            GraphQLField("checkInStart", type: .scalar(String.self)),
            GraphQLField("checkInEnd", type: .scalar(String.self)),
            GraphQLField("maxDaysNotice", type: .scalar(String.self)),
            GraphQLField("minNight", type: .scalar(Int.self)),
            GraphQLField("maxNight", type: .scalar(Int.self)),
            GraphQLField("basePrice", type: .scalar(Double.self)),
            GraphQLField("guestBasePrice", type: .scalar(Double.self)),
            GraphQLField("additionalPrice", type: .scalar(Double.self)),
            GraphQLField("visitorsLimit", type: .scalar(Double.self)),
            GraphQLField("visitorsPrice", type: .scalar(Double.self)),
            GraphQLField("petLimit", type: .scalar(Double.self)),
            GraphQLField("petPrice", type: .scalar(Double.self)),
            GraphQLField("infantLimit", type: .scalar(Double.self)),
            GraphQLField("infantPrice", type: .scalar(Double.self)),
            GraphQLField("cleaningPrice", type: .scalar(Double.self)),
            GraphQLField("tax", type: .scalar(Double.self)),
            GraphQLField("currency", type: .scalar(String.self)),
            GraphQLField("weeklyDiscount", type: .scalar(Int.self)),
            GraphQLField("monthlyDiscount", type: .scalar(Int.self)),
            GraphQLField("cancellationPolicy", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(bookingNoticeTime: String? = nil, checkInStart: String? = nil, checkInEnd: String? = nil, maxDaysNotice: String? = nil, minNight: Int? = nil, maxNight: Int? = nil, basePrice: Double? = nil, guestBasePrice: Double? = nil, additionalPrice: Double? = nil, visitorsLimit: Double? = nil, visitorsPrice: Double? = nil, petLimit: Double? = nil, petPrice: Double? = nil, infantLimit: Double? = nil, infantPrice: Double? = nil, cleaningPrice: Double? = nil, tax: Double? = nil, currency: String? = nil, weeklyDiscount: Int? = nil, monthlyDiscount: Int? = nil, cancellationPolicy: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "listingData", "bookingNoticeTime": bookingNoticeTime, "checkInStart": checkInStart, "checkInEnd": checkInEnd, "maxDaysNotice": maxDaysNotice, "minNight": minNight, "maxNight": maxNight, "basePrice": basePrice,
                                        "guestBasePrice": guestBasePrice,
                                        "additionalPrice": additionalPrice,
                                        "visitorsLimit": visitorsLimit,
                                        "visitorsPrice": visitorsPrice,
                                        "petLimit": petLimit,
                                        "petPrice": petPrice,
                                        "infantLimit": infantLimit,
                                        "infantPrice": infantPrice,
                                        "cleaningPrice": cleaningPrice, "tax": tax, "currency": currency, "weeklyDiscount": weeklyDiscount, "monthlyDiscount": monthlyDiscount, "cancellationPolicy": cancellationPolicy])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
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

            
            public var guestBasePrice: Double? {
                get {
                    return resultMap["guestBasePrice"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "guestBasePrice")
                }
            }

            public var additionalPrice: Double? {
                get {
                    return resultMap["additionalPrice"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "additionalPrice")
                }
            }

            public var visitorsLimit: Double? {
                get {
                    return resultMap["visitorsLimit"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "visitorsLimit")
                }
            }

            public var visitorsPrice: Double? {
                get {
                    return resultMap["visitorsPrice"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "visitorsPrice")
                }
            }

            public var petLimit: Double? {
                get {
                    return resultMap["petLimit"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "petLimit")
                }
            }

            public var petPrice: Double? {
                get {
                    return resultMap["petPrice"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "petPrice")
                }
            }

            public var infantLimit: Double? {
                get {
                    return resultMap["infantLimit"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "infantLimit")
                }
            }

            public var infantPrice: Double? {
                get {
                    return resultMap["infantPrice"] as? Double
                }
                set {
                    resultMap.updateValue(newValue, forKey: "infantPrice")
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

          public var cancellationPolicy: Int? {
            get {
              return resultMap["cancellationPolicy"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "cancellationPolicy")
            }
          }
        }

        public struct BlockedDate: GraphQLSelectionSet {
          public static let possibleTypes = ["listBlockedDates"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("blockedDates", type: .scalar(String.self)),
            GraphQLField("reservationId", type: .scalar(Int.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(blockedDates: String? = nil, reservationId: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "listBlockedDates", "blockedDates": blockedDates, "reservationId": reservationId])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var blockedDates: String? {
            get {
              return resultMap["blockedDates"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "blockedDates")
            }
          }

          public var reservationId: Int? {
            get {
              return resultMap["reservationId"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "reservationId")
            }
          }
        }

        public struct Calendar: GraphQLSelectionSet {
          public static let possibleTypes = ["ListCalendar"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("url", type: .scalar(String.self)),
            GraphQLField("listId", type: .nonNull(.scalar(Int.self))),
            GraphQLField("status", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: Int, name: String? = nil, url: String? = nil, listId: Int, status: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "ListCalendar", "id": id, "name": name, "url": url, "listId": listId, "status": status])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: Int {
            get {
              return resultMap["id"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var url: String? {
            get {
              return resultMap["url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "url")
            }
          }

          public var listId: Int {
            get {
              return resultMap["listId"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "listId")
            }
          }

          public var status: String? {
            get {
              return resultMap["status"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "status")
            }
          }
        }
      }
    }
  }
}
