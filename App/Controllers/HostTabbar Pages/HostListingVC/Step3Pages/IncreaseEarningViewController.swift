

import UIKit
import Lottie
import SwiftMessages

class IncreaseEarningViewController: BaseHostTableviewController {
    
    @IBOutlet var lineView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var saveandExit: UIButton!
    
    @IBOutlet weak var offlineUIView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var instantBookDescriptionLbl: UILabel!
    @IBOutlet weak var whoCanbookLbl: UILabel!
    @IBOutlet weak var chooseDescLbl: UILabel!
    @IBOutlet weak var guestRequiredView: UIView!
    
    @IBOutlet var subTitlelabel: UILabel!
    @IBOutlet weak var requiredImgView: UIImageView!
    @IBOutlet weak var requiredTitleLbl: UILabel!
    @IBOutlet weak var requiredDescLbl: UILabel!
    @IBOutlet weak var noOneView: UIView!
    @IBOutlet weak var noOneImgView: UIImageView!
    @IBOutlet weak var noOneTitleLbl: UILabel!
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet weak var requiredBtn: UIButton!
    @IBOutlet weak var noOneOptionBtn: UIButton!
    var currencyDataArray = [GetCurrenciesListQuery.Data.GetCurrency.Result]()
    
    var weeklydiscountvalue = ""
    var monthlydiscountvalue = ""
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    var lottieView1: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lineView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
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
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "preftype") ?? "What is your preferred booking type?")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.subTitlelabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "increaseearnings") ?? "Increase your earnings with Instant Book")"
        self.subTitlelabel.textColor = UIColor(named: "Title_Header")
        self.subTitlelabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.subTitlelabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
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
        self.configureScrollViews()
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedViewIndex = 5
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = ((self.view.frame.width/8) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
    }
    
    func configureScrollViews(){
        self.instantBookDescriptionLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "instantbook_desc") ?? "Instant Book can give your listing an edge. Not only do guests prefer to book instantly, we’re promoting Instant Book listings in search results.")"
        self.instantBookDescriptionLbl.textColor = UIColor(named: "searchPlaces_TextColor")
        self.instantBookDescriptionLbl.font = UIFont(name: APP_FONT, size: 14.0)
        self.instantBookDescriptionLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.whoCanbookLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "whobook") ?? "Who can book instantly?")?"
        self.whoCanbookLbl.textColor = UIColor(named: "Title_Header")
        self.whoCanbookLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 16.0)
        self.whoCanbookLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.chooseDescLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "choosebookavailable") ?? "Choose who can book available days without requesting approval.")"
        self.chooseDescLbl.textColor = UIColor(named: "searchPlaces_TextColor")
        self.chooseDescLbl.font = UIFont(name: APP_FONT, size: 12.0)
        self.chooseDescLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.requiredTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "guestmeet") ?? "Guests who meet your requirements and agree to your rules.")"
        self.requiredTitleLbl.textColor = UIColor(named: "Title_Header")
        self.requiredTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        self.requiredTitleLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.requiredDescLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "reservereq") ?? "Anyone else must send a reservation request.")"
        self.requiredDescLbl.textColor = UIColor(named: "searchPlaces_TextColor")
        self.requiredDescLbl.font = UIFont(name: APP_FONT, size: 14.0)
        self.requiredDescLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.noOneTitleLbl.text = "\(Utility.shared.getLanguage()?.value(forKey: "noreservationrequest") ?? "No one. All guests must send reservation requests.")"
        self.noOneTitleLbl.textColor = UIColor(named: "Title_Header")
        self.noOneTitleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 14.0)
        self.noOneTitleLbl.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        self.requiredBtn.setTitle("", for: .normal)
        self.requiredBtn.backgroundColor = .clear
        self.noOneOptionBtn.setTitle("", for: .normal)
        self.noOneOptionBtn.backgroundColor = .clear
    }
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
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
        if(Utility.shared.step3ValuesInfo["bookingType"] != nil) {
            
        } else {
            Utility.shared.step3ValuesInfo.updateValue("instant", forKey: "bookingType")
        }
        
        if((Utility.shared.step3ValuesInfo["bookingType"]as? String) == "instant") {
            self.requiredImgView.image = #imageLiteral(resourceName: "verify-round")
            self.noOneImgView.image = #imageLiteral(resourceName: "price_unclick")
        }else{
            self.noOneImgView.image = #imageLiteral(resourceName: "verify-round")
            self.requiredImgView.image = #imageLiteral(resourceName: "price_unclick")
            
        }
    }
    
    @IBAction func onClickRequiredBtn(_ sender: UIButton) {
        Utility.shared.step3ValuesInfo.updateValue("instant", forKey: "bookingType")
        self.requiredImgView.image = #imageLiteral(resourceName: "verify-round")
        self.noOneImgView.image = #imageLiteral(resourceName: "price_unclick")
    }
    
    @IBAction func onClickNoOneBtn(_ sender: UIButton) {
        Utility.shared.step3ValuesInfo.updateValue("request", forKey: "bookingType")
        self.noOneImgView.image = #imageLiteral(resourceName: "verify-round")
        self.requiredImgView.image = #imageLiteral(resourceName: "price_unclick")
    }
    
    override func setDropdownList() {
        tableView.reloadData()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "AmenitiesCell", bundle: nil), forCellReuseIdentifier: "AmenitiesCell")
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
        if Utility().isConnectedToNetwork(){
            Utility.shared.step3ValuesInfo.updateValue(Utility.shared.createId, forKey: "id")
            let amenities = ReviewGuestViewController()
            self.view.window?.backgroundColor = UIColor.white
            amenities.modalPresentationStyle = .fullScreen
            self.present(amenities, animated: false, completion: nil)
        } else {
            self.offlineviewShow()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Utility.shared.step3_Edit) {
                let StepTwoObj = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            }
            else{
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
        } else {
            self.offlineviewShow()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }else {
            return "\((Utility.shared.getLanguage()?.value(forKey:"whobook"))!)"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 0
        }
        if Utility.shared.getAppLanguageCode() == "en" || Utility.shared.getAppLanguageCode() == "En"{
            return 70
        } else{
            return 90
        }
        
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 70
        }
        return 70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x:15, y: 8, width:FULLWIDTH-40, height: 100))
        headerLabel.font =  UIFont(name: APP_FONT_MEDIUM, size:14)
        headerLabel.addCharacterSpacing()
        headerLabel.textColor = UIColor(named: "Title_Header")
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 0
        let headerView = UIView(frame: CGRect(x:15, y: 8, width: tableView.bounds.size.width - 20, height: 100))
        headerView.backgroundColor = UIColor.white
        headerView.addSubview(headerLabel)
        return section == 0 ? nil : headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.textLabel?.text = "\((Utility.shared.getLanguage()?.value(forKey:"instantbook_desc"))!)"
            
            cell.textLabel?.font = UIFont(name: APP_FONT, size:14)
            cell.textLabel?.textColor = UIColor(named: "searchPlaces_TextColor")
            cell.textLabel?.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.textLabel?.numberOfLines = 0
            return cell
        }else {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.tag = indexPath.row + 2000
            
            if indexPath.row == 0 {
                cell.textLabel?.font = UIFont(name: APP_FONT, size:14)
                cell.textLabel?.text = "\((Utility.shared.getLanguage()?.value(forKey:"choosebookavailable"))!)"
                cell.textLabel?.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
                cell.textLabel?.textColor = UIColor(named: "searchPlaces_TextColor")
                cell.textLabel?.numberOfLines = 0
            } else if indexPath.row == 1 {
                cell.imageView?.image = #imageLiteral(resourceName: "verify-round")
                if((Utility.shared.step3ValuesInfo["bookingType"]as? String) == "instant")
                {
                    cell.imageView?.image = #imageLiteral(resourceName: "verify-round")
                } else {
                    cell.imageView?.image = #imageLiteral(resourceName: "price_unclick")
                }
                cell.textLabel?.text = "\((Utility.shared.getLanguage()?.value(forKey:"guestmeet"))!)"
                cell.detailTextLabel?.textColor = UIColor.lightGray
                cell.textLabel?.font = UIFont(name: APP_FONT, size:17)
                cell.textLabel?.numberOfLines = 0
                
            }else if indexPath.row == 2 {
                if((Utility.shared.step3ValuesInfo["bookingType"]as? String) == "request") {
                    cell.imageView?.image = #imageLiteral(resourceName: "verify-round")
                } else {
                    cell.imageView?.image = #imageLiteral(resourceName: "price_unclick")
                }
                cell.textLabel?.text = "\((Utility.shared.getLanguage()?.value(forKey:"noreservationrequest"))!)"
                
                cell.textLabel?.font = UIFont(name: APP_FONT, size:17)
                cell.textLabel?.numberOfLines = 0
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = view.viewWithTag(indexPath.row + 2000) as? UITableViewCell
            if(indexPath.row == 1) {
                if cell?.imageView?.image == #imageLiteral(resourceName: "verify-round") {
                    cell?.imageView?.image = #imageLiteral(resourceName: "price_unclick")
                } else if cell?.imageView?.image == #imageLiteral(resourceName: "price_unclick") {
                    Utility.shared.step3ValuesInfo.updateValue("request", forKey: "bookingType")
                    cell?.imageView?.image = #imageLiteral(resourceName: "verify-round")
                }
            } else {
                if cell?.imageView?.image == #imageLiteral(resourceName: "verify-round") {
                    cell?.imageView?.image = #imageLiteral(resourceName: "price_unclick")
                } else if cell?.imageView?.image == #imageLiteral(resourceName: "price_unclick") {
                    Utility.shared.step3ValuesInfo.updateValue("instant", forKey: "bookingType")
                    cell?.imageView?.image = #imageLiteral(resourceName: "verify-round")
                    
                }
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            if Utility.shared.getAppLanguageCode() == "en" || Utility.shared.getAppLanguageCode() == "En" || Utility.shared.getAppLanguageCode() == "it" || Utility.shared.getAppLanguageCode() == "It" {
                return 120
            }else{
                return 160
            }
            
        } else {
            if(indexPath.row == 1) {
                return 80
            } else if(indexPath.row == 2) {
                return 110
            }
        }
        return 65
    }
}


extension IncreaseEarningViewController: stepsUpdateProtocol{
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

