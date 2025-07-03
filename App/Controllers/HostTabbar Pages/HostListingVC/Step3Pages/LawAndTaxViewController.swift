
import UIKit
import Lottie

class LawAndTaxViewController: BaseHostTableviewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var saveandExit: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    var lottieView1: LottieAnimationView!
    var currencyDataArray = [GetCurrenciesListQuery.Data.GetCurrency.Result]()
    var weeklydiscountvalue = ""
    var monthlydiscountvalue = ""
    var updateResults = UpdateListingStep3Mutation.Data.UpdateListingStep3.Result()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        nextBtn.backgroundColor = Theme.Button_BG
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "locallaws") ?? "Your local laws and taxes")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        self.labelOne.text = "\(Utility.shared.getLanguage()?.value(forKey: "lawtitle") ?? "Your local laws and taxes")"
        self.labelOne.textColor = UIColor(named: "Title_Header")
        self.labelOne.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        self.labelOne.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.labelTwo.text = "\(Utility.shared.getLanguage()?.value(forKey: "lawdes") ?? "Your local laws and taxes")"
        self.labelTwo.textColor = UIColor(named: "searchPlaces_TextColor")
        self.labelTwo.font = UIFont(name: APP_FONT, size: 14)
        self.labelTwo.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        saveandExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedViewIndex = 7
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = ((self.view.frame.width/8) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        
        if(Utility.shared.step3_Edit) {
            self.saveandExit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else {
            self.saveandExit.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
    }
    
    override func setDropdownList() {
        tableView.reloadData()
    }
    
    override func registerCells() {
    }
    
    func updateListingAPI() {
        let updatelist = UpdateListingStep3Mutation(id: Utility.shared.step3ValuesInfo["id"] as? Int,
                                                    houseRules: Utility.shared.step3ValuesInfo["houseRules"] as! [Int],
                                                    bookingNoticeTime: "\(Utility.shared.step3ValuesInfo["bookingNoticeTime"] ?? "")",
                                                    checkInStart: "\(Utility.shared.step3ValuesInfo["checkInStart"] ?? "")",
                                                    checkInEnd: "\(Utility.shared.step3ValuesInfo["checkInEnd"] ?? "")",
                                                    maxDaysNotice: "\(Utility.shared.step3ValuesInfo["maxDaysNotice"] ?? "")",
                                                    minNight: Utility.shared.step3ValuesInfo["minNight"] as? Int,
                                                    maxNight: Utility.shared.step3ValuesInfo["maxNight"] as? Int,
                                                    basePrice: Utility.shared.step3ValuesInfo["basePrice"] as? Double,
                                                    cleaningPrice: Utility.shared.step3ValuesInfo["cleaningPrice"] as? Double,
                                                    tax: Utility.shared.step3ValuesInfo["taxesPrice"] as? Double,
                                                    currency: "\(Utility.shared.step3ValuesInfo["currency"] ?? "")",
                                                    weeklyDiscount: Utility.shared.step3ValuesInfo["weeklyDiscount"] as? Int,
                                                    monthlyDiscount: Utility.shared.step3ValuesInfo["monthlyDiscount"] as? Int,
                                                    bookingType: "\(Utility.shared.step3ValuesInfo["bookingType"] ?? "")",
                                                    cancellationPolicy: Utility.shared.step3ValuesInfo["cancellationPolicy"] as? Int)
        apollo_headerClient.perform(mutation: updatelist){ (result,error) in
            if(result?.data?.updateListingStep3?.status == 200) {
                self.lottieView.isHidden = true
                if(result?.data?.updateListingStep3?.results != nil) {
                    self.updateResults = (result?.data?.updateListingStep3?.results)!
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let becomeHostObj = BecomeHostVC()
                        becomeHostObj.listID = "\(Utility.shared.step3ValuesInfo["id"]!)"
                        becomeHostObj.showListingStepsAPICall(listID:"\(Utility.shared.step3ValuesInfo["id"]!)")
                        becomeHostObj.modalPresentationStyle = .fullScreen
                        self.present(becomeHostObj, animated:false, completion: nil)
                    }
                }
            } else{
                self.view.makeToast(result?.data?.updateListingStep3?.errorMessage)
            }
        }
    }
    override func addLottieViewAsSubview() {
        self.view.addSubview(self.lottieView)
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
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    func lottieViewnextanimation() {
        nextBtn.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation_white")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.nextBtn.frame.size.width/2)-50), y:0, width:100, height:self.nextBtn.frame.size.height)
        self.nextBtn.addSubview(self.lottieView1)
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
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
        }else{
            offlineUIView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
        }
    }
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewnextanimation()
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Utility.shared.step3_Edit) {
                let StepTwoObj = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    func goToBecomeHostVC(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    
    @IBAction func saveandexitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.selectedRules, forKey: "houseRules")
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            super.updateStep3ListingAPICall{ (success) -> Void in
                if success {
                    saveandExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    self.lottieView1.isHidden = true
                }
            }
        } else{
            self.offlineviewShow()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.textLabel?.text = "\((Utility.shared.getLanguage()?.value(forKey:"lawtitle"))!)"
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.font = UIFont(name: APP_FONT, size:18)
            cell.textLabel?.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.textLabel?.numberOfLines = 0
        } else if indexPath.row ==  1 {
            let text = "\((Utility.shared.getLanguage()?.value(forKey:"lawdes"))!)"
            
            cell.textLabel?.attributedText = NSAttributedString(string:text,
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2.5
            
            let attrString = NSMutableAttributedString(string: text)
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            cell.detailTextLabel?.textColor = UIColor.lightGray
            cell.textLabel?.font = UIFont(name:APP_FONT, size:18)
            cell.textLabel?.numberOfLines = 0
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = self.tableView(self.tableView, cellForRowAt: indexPath) as? UITableViewCell
            if cell?.imageView?.image == #imageLiteral(resourceName: "verify-round") {
                cell?.imageView?.image = #imageLiteral(resourceName: "unchecked")
            }else{
                cell?.imageView?.image = #imageLiteral(resourceName: "verify-round")
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 1) {
            if Utility.shared.getAppLanguageCode() == "En" || Utility.shared.getAppLanguageCode() == "en"{
                return 630
            }else if (Utility.shared.isRTLLanguage()){
                return 500
            }else{
                return 730
            }
        }
        if IS_IPHONE_678 || IS_IPHONE_X{
            return 110
        } else {
            return 110
        }
    }
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            weeklydiscountvalue = textField.text!
        }
        if textField.tag == 2 {
            monthlydiscountvalue = textField.text!
        }
    }
}

extension LawAndTaxViewController: stepsUpdateProtocol{
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
                let becomeHost = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
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
                break
            default:
                break
            }
        }
    }
}
