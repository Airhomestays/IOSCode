
import UIKit
import Lottie

class BedsListingViewController: BaseHostTableviewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var offlineUIView: UIView!
    @IBOutlet weak var saveAndExit: UIButton!
    @IBOutlet weak var retryButn: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var singleArr = [Int]()
    var singleValue = Int()
    var doubleArr = [Int]()
    var doubleValue = Int()
    var queenArr = [Int]()
    var queenValue = Int()
    var kingArr = [Int]()
    var kingValue = Int()
    var bunkBedArr = [Int]()
    var bunkBedValue = Int()
    var indoorStallArr = [Int]()
    var indoorStallVal = Int()
    var bedTypeValue = ""
    var bedType = [String]()
    
    var bedtypeInfoArr = [[String : Any]]()
    var bed_id = [Int]()
    var bed_type_id = [Int]()
    var array_Count = [Int]()
    var lottieView1: LottieAnimationView!
    
    @IBOutlet weak var stepTitleheightConstaraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstaraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        tableView.backgroundColor =  UIColor(named: "colorController")
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        nextBtn.backgroundColor = Theme.Button_BG
        saveAndExit.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "bedtypes") ?? "Bed Types")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.becomeAHostProgressBG_Color
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        saveAndExit.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"SaveExit") ?? "Save & Exit")", for:.normal)
        
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryButn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        saveAndExit.setTitleColor(Theme.PRIMARY_COLOR, for:.normal)
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryButn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        saveAndExit.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        saveAndExit.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        retryButn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {}
    
    func lottieeAnimation() {
        lottieView = LottieAnimationView.init(name:"animation")
        lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:((self.saveAndExit.frame.size.width/2)-50), y:0, width:100, height:self.saveAndExit.frame.size.height)
        self.view.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.layer.cornerRadius = 6.0
        self.lottieView.clipsToBounds = true
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(autoscrolling), userInfo: nil, repeats: true)
    }
    
    
    @objc func autoscrolling() {
        self.lottieView.play()
    }
    
    
    override func setUpUI() {
        saveAndExit.isHidden = true
        
        offlineUIView.isHidden = true
        callListingSettingsAPI(oflineView: offlineUIView, nextButton: nextBtn)
        tableView.isHidden = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        nextBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "save")as! String)", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.clipsToBounds = true
        lottieView1 = LottieAnimationView.init(name: "animation")
    }
    
    override func setDropdownList() {
        
        let bedTypes = (Utility.shared.getListSettingsArray.bedType?.listSettings!)!
        bed_id.removeAll()
        bed_type_id.removeAll()
        bedtypeInfoArr.removeAll()
        bedType.removeAll()
        for bedItem in bedTypes {
            bedType.append((bedItem?.itemName)!)
            bed_type_id.append((bedItem?.id)!)
            
        }
        array_Count.removeAll()
        if Utility.shared.step1ValuesInfo.keys.contains("bedTypes") {
            if let bedTypeInfo = Utility.shared.step1ValuesInfo["bedTypes"] as? [Any] {
                for i in 0..<bedTypeInfo.count {
                    if let userBedTypes = bedTypeInfo[i] as? GetStep1ListingDetailsQuery.Data.GetListingDetail.Result.UserBedsType {
                        let index = bedTypes.firstIndex(where: { (item) -> Bool in
                            item?.id == userBedTypes.bedType
                        })
                        bedTypeValue = bedType.count > 0 ? bedType[index != nil ? index! : 0] : ""
                        var bedTypeInfo = [String : Any]()
                        bedTypeInfo.updateValue(userBedTypes.bedType ?? "", forKey: "bedType")
                        Utility.shared.step1ValuesInfo.updateValue(userBedTypes.bedType ?? "", forKey: "bedType")
                        bedTypeInfo.updateValue(userBedTypes.bedCount ?? "", forKey: "bedCount")
                        array_Count.append(userBedTypes.bedCount ?? 0)
                        bedtypeInfoArr.append(bedTypeInfo)
                        bed_id.append(userBedTypes.bedType ?? 0)
                    }
                    
                }
                
                Utility.shared.bedcount = array_Count.reduce(0, +)
            }
        }else{
            bedTypeValue = bedType.first != nil ? bedType.first! : ""
            Utility.shared.bedcount = 0
            Utility.shared.step1ValuesInfo.updateValue(Utility.shared.getListSettingsArray.bedType?.listSettings != nil ? ((Utility.shared.getListSettingsArray.bedType?.listSettings![0]!.id!)!) : 0, forKey: "bedType")
            Utility.shared.step1ValuesInfo.updateValue("", forKey: "bedTypes")
        }
        tableView.reloadData()
    }
    
    override func registerCells() {
        tableView.register(UINib(nibName: "RoomsCell", bundle: nil), forCellReuseIdentifier: "RoomsCell")
    }
    
    override func addLottieViewAsSubview() {}
    
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.offlineUIView.isHidden = true
        }
    }
    @IBAction func RedirectNextPage(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            
            let bedsCount = Utility.shared.step1ValuesInfo["beds"] as? Int
            if(bedsCount != nil) {
                if(Utility.shared.bedcount>bedsCount!) {
                    self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "bed_count_exceed")as! String)")
                } else {
                    if(bedtypeInfoArr.count == 0) {
                        var bedTypeInfo = [String : Any]()
                        bedTypeInfo.updateValue(16, forKey: "bedType")
                        bedTypeInfo.updateValue(1, forKey: "bedCount")
                        bedtypeInfoArr.append(bedTypeInfo)
                    }
                    let data = try? JSONSerialization.data(withJSONObject:bedtypeInfoArr, options: .prettyPrinted)
                    let bedtypes = String(data: data!, encoding: String.Encoding.utf8)!
                    var bedTypeString = ""
                    if !bedtypes.isEmpty {
                        let bedTypesArr = bedtypes.components(separatedBy: "\n")
                        for str in bedTypesArr{
                            bedTypeString = bedTypeString + str
                        }
                    }
                    Utility.shared.step1ValuesInfo.updateValue(bedTypeString.trimmingCharacters(in: .whitespaces), forKey: "bedTypes")
                    if(Utility.shared.step1ValuesInfo["bedType"] == nil) {
                        if(Utility.shared.getListSettingsArray.bedType?.listSettings![0]!.id != nil) {
                            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![0]!.id!)!, forKey: "bedType")
                        } else {
                            Utility.shared.step1ValuesInfo.updateValue(16, forKey: "bedType")
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
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
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        let data = try? JSONSerialization.data(withJSONObject:bedtypeInfoArr, options: .prettyPrinted)
        let bedtypes = String(data: data!, encoding: String.Encoding.utf8)!
        var bedTypeString = ""
        if !bedtypes.isEmpty {
            let bedTypesArr = bedtypes.components(separatedBy: "\n")
            for str in bedTypesArr{
                bedTypeString = bedTypeString + str
            }
        }
        
        Utility.shared.step1ValuesInfo.updateValue(bedTypeString.trimmingCharacters(in: .whitespaces), forKey: "bedTypes")
        self.dismiss(animated: true, completion: nil)
    }
    func goToBecomeHost(){
        let becomeHost = BecomeHostVC()
        becomeHost.listID = "\(Utility.shared.createId)"
        becomeHost.showListingStepsAPICall(listID:"\(Utility.shared.createId)")
        becomeHost.modalPresentationStyle = .fullScreen
        self.present(becomeHost, animated:false, completion: nil)
    }
    func lottieViewanimation() {
        saveAndExit.setTitle("", for:.normal)
        lottieView1 = LottieAnimationView.init(name: "animation")
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:((self.saveAndExit.frame.size.width/2)-50), y:0, width:100, height:self.saveAndExit.frame.size.height)
        self.saveAndExit.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll() {
        self.lottieView1.play()
    }
    
    @IBAction func saveAndExitAction(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.lottieViewanimation()
            if(bedtypeInfoArr.count == 0) {
                var bedTypeInfo = [String : Any]()
                bedTypeInfo.updateValue(16, forKey: "bedType")
                bedTypeInfo.updateValue(1, forKey: "bedCount")
                bedtypeInfoArr.append(bedTypeInfo)
            }
            let data = try? JSONSerialization.data(withJSONObject:bedtypeInfoArr, options: .prettyPrinted)
            let bedtypes = String(data: data!, encoding: String.Encoding.utf8)!
            var bedTypeString = ""
            if !bedtypes.isEmpty {
                let bedTypesArr = bedtypes.components(separatedBy: "\n")
                for str in bedTypesArr{
                    bedTypeString = bedTypeString + str
                }
            }
            
            Utility.shared.step1ValuesInfo.updateValue(bedTypeString.trimmingCharacters(in: .whitespaces), forKey: "bedTypes")
            super.updateListingAPICall{ (success) -> Void in
                if success {
                    saveAndExit.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
                    
                    self.lottieView1.isHidden = true
                }
            }
        } else {
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
        return bedType.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "RoomsCell", for: indexPath) as? RoomsCell
        cell?.dashView.isHidden = false
        cell?.dashView.backgroundColor = UIColor(named: "Review_Page_Line_Color")
        
        cell?.roomsTitleLabel.text = bedType[indexPath.row]
        cell?.roomsTitleLabel.textColor =  UIColor(named: "Title_Header")
        array_Count.removeAll()
        if((Utility.shared.getListSettingsArray.bedType?.listSettings![indexPath.row]!.id!) == bed_type_id[indexPath.row]) {
            let index = bedtypeInfoArr.index(where: { dictionary in
                guard let value = dictionary["bedType"] as? Int
                else { return false }
                return value == (Utility.shared.getListSettingsArray.bedType?.listSettings![indexPath.row]!.id!)
            })
            if let index = index {
                cell?.countshowLabel.text = "\(bedtypeInfoArr[index]["bedCount"]!)"
            } else {
                if let bedtypeInfo = Utility.shared.step1ValuesInfo["bedTypes"] as? String {
                    if let dict = convertToDictionary(text: bedtypeInfo) {
                        for i in 0..<dict.count{
                            let userBedTypes = dict[i]
                            if let userbedType = userBedTypes["bedType"] as? Int {
                                let userbedCount = "\(userBedTypes["bedCount"]!)"
                                let bedTypes = (Utility.shared.getListSettingsArray.bedType?.listSettings!)!
                                let index = bedTypes.index(where: { (item) -> Bool in
                                    item?.id == userbedType
                                })
                                bedTypeValue = bedType[index!]
                                if((Utility.shared.getListSettingsArray.bedType?.listSettings![indexPath.row]!.id!) == userbedType) {
                                    cell?.countshowLabel.text = "\(String(describing: Int(userbedCount)!))"
                                    var bedTypeInfo = [String : Any]()
                                    
                                    bedTypeInfo.updateValue(userbedType, forKey: "bedType")
                                    Utility.shared.step1ValuesInfo.updateValue(userbedType, forKey: "bedType")
                                    bedTypeInfo.updateValue(Int(userbedCount)!, forKey: "bedCount")
                                    bedtypeInfoArr.append(bedTypeInfo)
                                    
                                }
                                array_Count.append(Int(userbedCount)!)
                                
                            }
                        }
                        Utility.shared.bedcount = array_Count.reduce(0, +)
                    }
                }
            }
            
        } else {
            cell?.countshowLabel.text = "0"
            
        }
        cell?.countshowLabel.textColor = UIColor(named: "Title_Header")
        cell?.countValue = 1
        cell?.plusBtn.tag = indexPath.row
        cell?.minusBtn.tag = indexPath.row
        cell?.tag = indexPath.row + 100
        cell?.plusBtn.addTarget(self, action: #selector(self.plusBtnTapped(sender:)), for: .touchUpInside)
        cell?.minusBtn.addTarget(self, action: #selector(self.minusBtnTapped(sender:)), for: .touchUpInside)
        cell?.plusBtn.layer.cornerRadius = (cell?.plusBtn.frame.size.width)!/2
        cell?.plusBtn.layer.borderWidth = 1.0
        cell?.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        cell?.minusBtn.layer.cornerRadius = (cell?.minusBtn.frame.size.width)!/2
        cell?.minusBtn.layer.borderWidth = 1.0
        cell?.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
        cell?.selectionStyle = .none
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    @objc func plusBtnTapped(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell, let bedsCount = Utility.shared.step1ValuesInfo["beds"] as? Int {
            if Utility.shared.bedcount >= bedsCount {
                if Int(cell.countshowLabel.text!)! >= bedsCount {
                    cell.plusBtn.isEnabled = false
                    cell.plusBtn.isUserInteractionEnabled = false
                    cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                    cell.minusBtn.isEnabled = true
                    cell.minusBtn.isUserInteractionEnabled = true
                    cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                }
                self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Maximum_bed_selected")as! String)")
            }else {
                cell.countshowLabel.text = "\(Int(cell.countshowLabel.text!)! + 1)"
                Utility.shared.bedcount = Utility.shared.bedcount + 1
                cell.plusBtn.isEnabled = true
                cell.minusBtn.isEnabled = true
                cell.plusBtn.isUserInteractionEnabled = true
                cell.minusBtn.isUserInteractionEnabled = true
                cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                var bedTypeInfo = [String : Any]()
                if (bedtypeInfoArr.count > 0) {
                    if((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!) == bed_type_id[sender.tag]){
                        let index = bedtypeInfoArr.index(where: { dictionary in
                            guard let value = dictionary["bedType"] as? Int
                            else { return false }
                            return value == (Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)
                        })
                        if let index = index {
                            bedtypeInfoArr.remove(at: index)
                            
                            bedTypeInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                            bedTypeInfo.updateValue(cell.countshowLabel.text!, forKey: "bedCount")
                            bedtypeInfoArr.append(bedTypeInfo)
                        } else {
                            bedTypeInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                            bedTypeInfo.updateValue(cell.countshowLabel.text!, forKey: "bedCount")
                            bedtypeInfoArr.append(bedTypeInfo)
                        }
                    }
                } else {
                    bedTypeInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                    Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                    bedTypeInfo.updateValue(cell.countshowLabel.text!, forKey: "bedCount")
                    bedtypeInfoArr.append(bedTypeInfo)
                }
            }
        }
    }
    
    func toJSONString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let arr = self as? [[String:AnyObject]],
           let dat = try? JSONSerialization.data(withJSONObject: arr, options: options),
           let str = String(data: dat, encoding: String.Encoding.utf8) {
            return str
        }
        return "[]"
    }
    
    @objc func minusBtnTapped(sender : UIButton) {
        if let cell = view.viewWithTag(sender.tag + 100) as? RoomsCell, let bedsCount = Utility.shared.step1ValuesInfo["beds"] as? Int {
            if Int(cell.countshowLabel.text!)! <= 0 {
                cell.minusBtn.isEnabled = false
                cell.minusBtn.isUserInteractionEnabled = false
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.withAlphaComponent(0.5).cgColor
                cell.plusBtn.isEnabled = true
                cell.plusBtn.isUserInteractionEnabled = true
                cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                
                
            }else{
                cell.minusBtn.isEnabled = true
                cell.minusBtn.isUserInteractionEnabled = true
                cell.plusBtn.isEnabled = true
                cell.plusBtn.isUserInteractionEnabled = true
                cell.plusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                cell.minusBtn.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
                
                cell.countshowLabel.text = "\(Int(cell.countshowLabel.text!)! - 1)"
                Utility.shared.bedcount = Utility.shared.bedcount - 1
                
                
                if((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!) == bed_type_id[sender.tag]) {
                    let index = bedtypeInfoArr.index(where: { dictionary in
                        guard let value = dictionary["bedType"] as? Int
                        else { return false }
                        return value == (Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)
                    })
                    if let index = index {
                        if((bedtypeInfoArr[index]["bedCount"] as? Int) == 1) {
                            bedtypeInfoArr.remove(at: index)
                        } else {
                            var bedTypeInfo = [String : Any]()
                            bedtypeInfoArr.remove(at: index)
                            bedTypeInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                            Utility.shared.step1ValuesInfo.updateValue((Utility.shared.getListSettingsArray.bedType?.listSettings![sender.tag]!.id!)!, forKey: "bedType")
                            bedTypeInfo.updateValue(cell.countshowLabel.text!, forKey: "bedCount")
                            bedtypeInfoArr.append(bedTypeInfo)
                        }
                    }
                }
            }
        }
    }
    
}

extension BedsListingViewController: stepsUpdateProtocol{
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
                break
            case 3:
                let bathroomsListing = BathroomsListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                bathroomsListing.modalPresentationStyle = .fullScreen
                self.present(bathroomsListing, animated: false, completion: nil)
                break
            case 4:
                let location = AddressListingViewController()
                self.view.window?.backgroundColor = UIColor.white
                location.modalPresentationStyle = .fullScreen
                self.present(location, animated: false, completion: nil)
                break
            case 5:
                let becomeHostObj = MapLocateVC()
                self.view.window?.backgroundColor = UIColor.white
                becomeHostObj.modalPresentationStyle = .fullScreen
                self.present(becomeHostObj, animated:false, completion: nil)
                break
            case 6:
                let nextpageObj = AmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                nextpageObj.modalPresentationStyle = .fullScreen
                self.present(nextpageObj, animated: false, completion: nil)
                break
            case 7:
                let amenities = SafeAmenitiesViewController()
                self.view.window?.backgroundColor = UIColor.white
                amenities.modalPresentationStyle = .fullScreen
                self.present(amenities, animated: false, completion: nil)
                break
            case 8:
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
