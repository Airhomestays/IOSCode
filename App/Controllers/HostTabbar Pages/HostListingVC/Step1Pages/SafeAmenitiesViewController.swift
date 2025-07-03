
import UIKit
import Lottie

class SafeAmenitiesViewController: BaseHostTableviewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var saveandexit: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    var lottieView1: LottieAnimationView!
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    @IBOutlet var amenitiesCollection: UICollectionView!
    @IBOutlet weak var retryButn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!

    var amenity = ""
    var amenityList = [[String : Any]]()

    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstaraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        amenitiesCollection.backgroundColor = UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        nextBtn.backgroundColor = Theme.Button_BG
        saveandexit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "safetyques") ?? "Safety Amenities")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        saveandexit.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SaveExit") ?? "Save & Exit")", for:.normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveandexit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveandexit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        saveandexit.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        
        
        
        self.stepsTitleView.whichStep = 1
        self.stepsTitleView.selectedViewIndex = 5
        
        self.stepsTitleView.delegateSteps = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressViewWidth.constant = ((self.view.frame.width/7) * CGFloat((self.stepsTitleView.selectedViewIndex + 1)))
        self.stepsTitleView.toBeCheck()
    }
    
    
    override func setUpUI() {
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = true
        amenitiesCollection.isHidden = false
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        lottieView1 = LottieAnimationView.init(name: "animation")
        if(Utility.shared.step1_inactivestatus == "inactive" || Utility.shared.step1_inactivestatus == "") {
            saveandexit.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleheightConstaraint.constant = 0
            self.stepTitleTopConstaraint.constant = 0
        } else {
            saveandexit.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleheightConstaraint.constant = 50
            self.stepTitleTopConstaraint.constant = 5
        }
    }
    
    override func setDropdownList() {
        let amenitiesList = (Utility.shared.getListSettingsArray.safetyAmenities?.listSettings!)!
        for i in 0..<amenitiesList.count {
            var amenityInfo = [String : Any]()
            amenityInfo.updateValue(amenitiesList[i]!.itemName!, forKey: "itemName")
            amenityInfo.updateValue(amenitiesList[i]!.id!, forKey: "id")
            if let image = amenitiesList[i]!.image {
                amenityInfo.updateValue(amenitiesList[i]!.image!, forKey: "image")
            }
            amenityList.append(amenityInfo)
        }
        
        if let typeInfo = Utility.shared.step1ValuesInfo["safetyAmenities"] as? [Any] {
            for i in 0..<typeInfo.count {
                if let userAmenityTypes = typeInfo[i] as? GetStep1ListingDetailsQuery.Data.GetListingDetail.Result.UserSafetyAmenity {
                    if amenityList.contains(where: { (item) -> Bool in
                        (item["itemName"] as? String == (userAmenityTypes.itemName!))
                    }){
                        Utility.shared.selectedsafetyAmenityIdList.add(userAmenityTypes.id!)
                        
                    }
                }
            }
        }  else{
            amenity = (amenityList.first! is [String : Any]) ? amenityList.first!["itemName"] as! String : ""
            Utility.shared.selectedsafetyAmenityIdList.removeAllObjects()
        }
        Utility.shared.step1ValuesInfo.updateValue(Utility.shared.selectedsafetyAmenityIdList, forKey: "safetyAmenities")
        amenitiesCollection.reloadData()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "AmenitiesCell", bundle: nil), forCellReuseIdentifier: "AmenitiesCell")
        
        self.amenitiesCollection.register(UINib(nibName: "AmenitiesCollectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AmenitiesCollectionCollectionViewCell")
    }
    
    override func addLottieViewAsSubview() {}
    
    @IBAction func saveandExitTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
            Utility.shared.step1ValuesInfo.updateValue(Utility.shared.selectedsafetyAmenityIdList, forKey: "safetyAmenities")
            super.updateListingAPICall{ (success) -> Void in
                if success {
                    saveandexit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
            self.offlineViewShow()
        }
    }
    func offlineViewShow() {
        self.offlineUIView.isHidden = false
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlineUIView.frame.size.width + shadowSize2,
                                                    height: self.offlineUIView.frame.size.height + shadowSize2))
        
        self.offlineUIView.layer.masksToBounds = false
        offlineUIView.backgroundColor =  UIColor(named: "Button_Grey_Color")
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
    
    func lottieViewanimation() {
        saveandexit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveandexit.frame.size.width/2)-50), y:0, width:100, height:self.saveandexit.frame.size.height)
        self.saveandexit.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView1.play()
    }
    @IBAction func retryBtntapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            Utility.shared.step1ValuesInfo.updateValue(Utility.shared.selectedsafetyAmenityIdList, forKey: "safetyAmenities")
            let spaces = SpaceListViewController()
            self.view.window?.backgroundColor = UIColor.white
            spaces.modalPresentationStyle = .fullScreen
            self.present(spaces, animated: false, completion: nil)
        } else {
            self.offlineViewShow()
        }
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amenityList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "AmenitiesCell", for: indexPath) as? AmenitiesCell
            if amenityList.count > 0 {
                if let amenitylist = amenityList[indexPath.row]["itemName"] {
                    cell?.amenitieslistTile.text = amenitylist as! String
                }
                
                if let imageURL = amenityList[indexPath.row]["image"] as? String {
                    cell?.amenitiesImgIcon.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageURL))"),placeholderImage: UIImage(named: "amenitiesImage"))
                }else{
                    cell?.amenitiesImgIcon.image = UIImage(named: "amenitiesImage")
                }
            }
            if(Utility.shared.selectedsafetyAmenityIdList.contains(amenityList[indexPath.row]["id"] as! Int)) {
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked").withRenderingMode(.alwaysTemplate), for: .normal)
                cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
                cell?.amenitieslistTile.textColor = UIColor(named: "Title_Header")
            }
            else{
                cell?.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
                cell?.amenitieslistTile.textColor = UIColor(named: "cellColor")
            }
            cell?.checkBtn.addTarget(self, action: #selector(amenitiescheckBtnTapped(_:)), for: .touchUpInside)
            cell?.selectionStyle = .none
            return cell!
        }
        return UITableViewCell()
    }
    
    @objc func amenitiescheckBtnTapped(_ sender: UIButton) {
        let cell = view.viewWithTag(sender.tag + 300) as? AmenitiesCell
        let celltag = cell?.checkBtn.tag
        if(Utility.shared.selectedsafetyAmenityIdList.contains(amenityList[sender.tag]["id"] as! Int)) {
            Utility.shared.selectedsafetyAmenityIdList.remove(amenityList[sender.tag]["id"] as! Int)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        } else {
            Utility.shared.selectedsafetyAmenityIdList.add(amenityList[celltag!]["id"] as! Int)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked").withRenderingMode(.alwaysTemplate), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = view.viewWithTag(indexPath.row + 300) as? AmenitiesCell
        let celltag = cell?.checkBtn.tag
        if(Utility.shared.selectedsafetyAmenityIdList.contains(amenityList[indexPath.row]["id"] as! Int)) {
            Utility.shared.selectedsafetyAmenityIdList.remove(amenityList[indexPath.row]["id"] as! Int)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        } else{
            Utility.shared.selectedsafetyAmenityIdList.add(amenityList[celltag!]["id"] as! Int)
            cell?.checkBtn.setImage(#imageLiteral(resourceName: "checked").withRenderingMode(.alwaysTemplate), for: .normal)
            cell?.checkBtn.tintColor = Theme.PRIMARY_COLOR
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmenitiesCollectionCollectionViewCell", for: indexPath)as! AmenitiesCollectionCollectionViewCell
        if amenityList.count > indexPath.item {
            if let titleStr = amenityList[indexPath.item]["itemName"] as? String {
                if titleStr.contains("Towels") {
                    cell.typeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "amenties_towel"))!)"
                }else{
                    cell.typeLabel.text = titleStr
                }
                
            }
            
            var textHeightIndex = cell.typeLabel.text!.height(withConstrainedWidth: (FULLWIDTH-60)/2 , font: UIFont.systemFont(ofSize: 12))
            
            
            if(indexPath.item  % 2 == 0) {
                
                let indexPaths = NSIndexPath(row: indexPath.item + 1, section: 0)
                
                if amenityList.count > indexPaths.item {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmenitiesCollectionCollectionViewCell", for: indexPath)as! AmenitiesCollectionCollectionViewCell
                    
                    
                    if amenityList.count > indexPath.item {
                        if let titleStr = amenityList[indexPath.item]["itemName"] as? String {
                            if titleStr.contains("Towels") {
                                cell.typeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "amenties_towel"))!)"
                            } else{
                                cell.typeLabel.text = titleStr
                            }
                        }
                        
                        var textHeight = cell.typeLabel.text!.height(withConstrainedWidth: (FULLWIDTH-60)/2 , font: UIFont.systemFont(ofSize: 12))
                        
                        if(textHeightIndex > textHeight) {
                            if(textHeightIndex <= 21) {
                                return CGSize(width: (FULLWIDTH-60)/2, height:120)
                            } else {
                                return CGSize(width: (FULLWIDTH-60)/2, height: textHeightIndex  + 101)
                            }
                        } else {
                            
                            if(textHeight <= 21) {
                                return CGSize(width: (FULLWIDTH-60)/2, height:120)
                            } else {
                                return CGSize(width: (FULLWIDTH-60)/2, height: textHeight  + 101)
                            }
                        }
                    }
                }
            }
            
            if(indexPath.item  % 2 == 1) {
                let indexPaths = NSIndexPath(row: indexPath.item - 1, section: 0)
                if amenityList.count > indexPath.item {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmenitiesCollectionCollectionViewCell", for: indexPath)as! AmenitiesCollectionCollectionViewCell
                    if amenityList.count > indexPath.item {
                        if let titleStr = amenityList[indexPath.item]["itemName"] as? String {
                            if titleStr.contains("Towels") {
                                cell.typeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "amenties_towel"))!)"
                            }else{
                                cell.typeLabel.text = titleStr
                            }
                            
                        }
                        var textHeight = cell.typeLabel.text!.height(withConstrainedWidth: (FULLWIDTH-60)/2 , font: UIFont.systemFont(ofSize: 12))
                        
                        if(textHeightIndex > textHeight) {
                            if(textHeightIndex <= 21) {
                                return CGSize(width: (FULLWIDTH-60)/2, height:120)
                            } else {
                                return CGSize(width: (FULLWIDTH-60)/2, height: textHeightIndex  + 101)
                            }
                        } else {
                            if(textHeight <= 21) {
                                return CGSize(width: (FULLWIDTH-60)/2, height:120)
                            }
                            else {
                                return CGSize(width: (FULLWIDTH-60)/2, height: textHeight  + 101)
                            }
                        }
                    }
                }
                
            }
            return CGSize(width: (FULLWIDTH-60)/2, height:120)
        }
        
        return CGSize(width: (FULLWIDTH-60)/2, height:120)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        amenityList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmenitiesCollectionCollectionViewCell", for: indexPath)as! AmenitiesCollectionCollectionViewCell
        
        cell.borderView.tag = indexPath.item
        if amenityList.count > indexPath.item {
            if let titleStr = amenityList[indexPath.item]["itemName"] as? String {
                if titleStr.contains("Towels") {
                    cell.typeLabel.text = "\((Utility.shared.getLanguage()?.value(forKey: "amenties_towel"))!)"
                }else{
                    cell.typeLabel.text = titleStr
                }
            }
            
            if let imageURL = amenityList[indexPath.item]["image"] as? String
            {
                
                
                cell.typeImg.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageURL))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                    cell.typeImg.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.typeImg.image = UIImage(named: "amenitiesImage")!.withRenderingMode(.alwaysTemplate)
            }
        }
        cell.tag = indexPath.item+300
        
        if(Utility.shared.selectedsafetyAmenityIdList.contains(amenityList[indexPath.row]["id"] as! Int)) {
            
            cell.typeLabel.textColor = UIColor(named: "cellColor")
            cell.typeImg.tintColor = UIColor(named: "cellColor")
            cell.borderView.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.borderView.backgroundColor = Theme.btnbgsteps
            cell.borderView.layer.borderWidth = 1.0
            cell.borderView.layer.cornerRadius = 5.0
            cell.borderView.layer.masksToBounds = true
        } else {
            cell.typeLabel.textColor = UIColor(named: "Title_Header")
            cell.typeImg.tintColor = UIColor(named: "Title_Header")
            cell.borderView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
            cell.borderView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
            cell.borderView.layer.borderWidth = 1.0
            cell.borderView.layer.cornerRadius = 5.0
            cell.borderView.layer.masksToBounds = true
        }
        
        return cell
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = view.viewWithTag(indexPath.item + 300) as? AmenitiesCollectionCollectionViewCell
        let celltag = cell?.borderView.tag
        
        if(Utility.shared.selectedsafetyAmenityIdList.contains(amenityList[indexPath.row]["id"] as! Int)) {
            Utility.shared.selectedsafetyAmenityIdList.remove(amenityList[indexPath.row]["id"] as! Int)
            cell!.borderView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
            cell!.borderView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
            cell!.borderView.layer.borderWidth = 1.0
            cell!.borderView.layer.cornerRadius = 5.0
            cell!.typeLabel.textColor = UIColor(named: "Title_Header")
            cell!.typeImg.tintColor = UIColor(named: "Title_Header")
            cell!.borderView.layer.masksToBounds = true
        } else {
            cell!.typeLabel.textColor = UIColor(named: "cellColor")
            cell!.typeImg.tintColor = UIColor(named: "cellColor")
            Utility.shared.selectedsafetyAmenityIdList.add(amenityList[celltag!]["id"] as! Int)
            cell!.borderView.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell!.borderView.backgroundColor = Theme.btnbgsteps
            cell!.borderView.layer.borderWidth = 1.0
            cell!.borderView.layer.cornerRadius = 5.0
            cell!.borderView.layer.masksToBounds = true
        }
        
    }
    
}

extension SafeAmenitiesViewController: stepsUpdateProtocol{
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
                let becomeHostObj = MapLocateVC()
                self.view.window?.backgroundColor = UIColor.white
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.present(becomeHostObj, animated:false, completion: nil)
                break
            case 4:
                let nextpageObj = AmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                nextpageObj.modalPresentationStyle = .fullScreen
                self.present(nextpageObj, animated: false, completion: nil)
                break
            case 5:
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
}
