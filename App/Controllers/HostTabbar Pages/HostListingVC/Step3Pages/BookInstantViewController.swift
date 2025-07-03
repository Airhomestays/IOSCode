
import UIKit
import Lottie
import SwiftMessages

class BookInstantViewController: BaseHostTableviewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var retryButn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveandExitBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    var lottieView1: LottieAnimationView!
    var reviewGuestBooks = [Any]()
    
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
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "howguest") ?? "How guests book\nInstantly")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandExitBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        saveandExitBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandExitBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        self.stepsTitleView.whichStep = 3
        self.stepsTitleView.selectedIndex = 2
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
    }
    
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.separatorStyle = .none
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        if(Utility.shared.step3_Edit) {
            self.saveandExitBtn.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else {
            self.saveandExitBtn.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
    }
    
    override func setDropdownList() {
        
        let reviewGuestBook = (Utility.shared.getListSettingsArray.reviewGuestBook?.listSettings!)!
        for i in 0..<reviewGuestBook.count {
            var amenityInfo = [String : Any]()
            amenityInfo.updateValue(reviewGuestBook[i]!.itemName!, forKey: "itemName")
            amenityInfo.updateValue(reviewGuestBook[i]!.id!, forKey: "id")
            reviewGuestBooks.append(amenityInfo)
        }
        tableView.reloadData()
    }
    
    override func registerCells() {
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
    func offlineviewShow(){
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
    
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            let becomeHost = NoticeArrivalViewController()
            self.view.window?.backgroundColor = UIColor.white
            becomeHost.modalPresentationStyle = .fullScreen
            self.present(becomeHost, animated:false, completion: nil)
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
        if(Utility.shared.step3_Edit) {
            let StepTwoObj = HouseRulesViewController()
            self.view.window?.backgroundColor = UIColor.white
            StepTwoObj.modalPresentationStyle = .fullScreen
            self.present(StepTwoObj, animated:false, completion: nil)
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
    
    @IBAction func saveandExitaction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
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
        return reviewGuestBooks.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "reviewInstantCells", for: indexPath) as! ReviewInstantCells
        cell.selectionStyle = .none
        if indexPath.row == 0{
            cell.contentLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guestcanbook"))!)"
            cell.contentLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            cell.contentLabel.font = UIFont(name: APP_FONT, size: 14)
            cell.tickImgView.isHidden = true
            cell.lineView.isHidden = true
            cell.contentLeadingConstraint.constant = -12
        } else if (indexPath.row == reviewGuestBooks.count + 1){
            cell.contentLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"guestrequirement"))!)"
            cell.contentLabel.textColor = UIColor(named: "searchPlaces_TextColor")
            cell.contentLabel.font = UIFont(name: APP_FONT, size: 14)
            
            cell.tickImgView.isHidden = true
            cell.lineView.isHidden = true
            cell.contentLeadingConstraint.constant = -12
        } else {
            
            if let text = reviewGuestBooks[indexPath.row - 1] as? [String : Any] {
                cell.contentLabel.text = "\(text["itemName"] ?? "")"
            }
            cell.contentLabel.textColor = UIColor(named: "Title_Header")
            cell.contentLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
            cell.tickImgView.isHidden = false
            cell.lineView.isHidden = false
            cell.contentLeadingConstraint.constant = 8
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension BookInstantViewController: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 3{
            switch selectedPageIndex{
            case 0:
                let StepTwoObj = ReviewGuestViewController()
                self.view.window?.backgroundColor = UIColor.white
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
                break
            case 1:
                let becomeHost = HouseRulesViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 2:
                break
            case 3:
                let becomeHost = NoticeArrivalViewController()
                self.view.window?.backgroundColor = UIColor.white
                becomeHost.modalPresentationStyle = .fullScreen
                self.present(becomeHost, animated:false, completion: nil)
                break
            case 4:
                let guestListing = BookingWindowViewController()
                self.view.window?.backgroundColor = UIColor.white
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 5:
                let guestListing = TripLengthViewController()
                guestListing.modalPresentationStyle = .fullScreen
                self.present(guestListing, animated: false, completion: nil)
                break
            case 6:
                let amenities = BasePriceViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 7:
                let amenities = DiscountViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 8:
                let amenities = IncreaseEarningViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 9:
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
