
import UIKit
import IQKeyboardManagerSwift
import Apollo

class ListingTitleVC: BaseHostTableviewController,UITextViewDelegate{
    
    @IBOutlet weak var backBtn:UIButton!
    @IBOutlet weak var nameListingLabel: UILabel!
    @IBOutlet weak var namedescLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlinview: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var curvedView: UIView!
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleTV: UITextField!
    @IBOutlet var titleview: UIView!
    
    
    @IBOutlet var progressViewWidth: NSLayoutConstraint!
    
    @IBOutlet var descriptionView: UIView!
    
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    
    
    var placeholderLabel : UILabel!
    var placeholderLabel1 : UILabel!
    var getListingStep2Array = GetListingDetailsStep2Query.Data.GetListingDetail.Result()
    var saveexit_Activated = String()
    var showListingstepArray = ShowListingStepsQuery.Data.ShowListingStep.Result()
    
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()
        
        self.stepsTitleView.whichStep = 2
        self.stepsTitleView.selectedViewIndex = 1
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
        progressViewWidth.constant = self.view.frame.width
    }
    
    override func setUpUI() {}
    override func setDropdownList() {}
    override func registerCells() {}
    
    func initialsetup() {
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        
        bottomView.backgroundColor =  UIColor(named: "colorController")
        curvedView.backgroundColor = UIColor(named: "colorController")
        
        nextBtn.backgroundColor = Theme.Button_BG
        saveBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = UIColor.white
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "nameyourplace") ?? "Name your place")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.summaryLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        nameListingLabel.backgroundColor = .clear
        namedescLabel.backgroundColor = .clear
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.masksToBounds = true
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        titleTV.autocorrectionType = UITextAutocorrectionType.no
        titleTV.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        titleTV.tag = 1;
        titleTV.tintColor  = UIColor(named: "Title_Header")
        titleTV.textColor = UIColor(named: "Title_Header")
        descriptionTV.tintColor = UIColor(named: "Title_Header")
        saveBtn.setTitleColor(Theme.PRIMARY_COLOR, for:.normal)
        
        if(Utility.shared.step2ValuesInfo["title"] != nil) ||  (Utility.shared.step2ValuesInfo["title"] as! String != "") {
            titleTV.text = (Utility.shared.step2ValuesInfo["title"] as! String)
        } else {
            titleTV.text = getListingStep2Array.title != nil ? getListingStep2Array.title! : ""
            
        }
        
        titleTV.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        placeholderLabel1 = UILabel()
        placeholderLabel1.text = "\((Utility.shared.getLanguage()?.value(forKey:"addtitle"))!)"
        placeholderLabel1.font = titleTV.font
        placeholderLabel1.numberOfLines = 0
        placeholderLabel1.sizeToFit()
        
        let attributes_placeholder = [
            NSAttributedString.Key.foregroundColor: Theme.Explore_PlaceHolder,
            NSAttributedString.Key.font : UIFont(name:APP_FONT_MEDIUM, size: 14)! 
        ]
        
        titleTV.attributedPlaceholder = NSAttributedString(string:"\(Utility.shared.getLanguage()?.value(forKey: "addtitle") ?? "addtitle")", attributes:attributes_placeholder)
        
        placeholderLabel1.frame = CGRect(x:6, y: 1, width:titleTV.frame.size.width-20, height:30)
        
        if Utility.shared.isRTLLanguage(){
            placeholderLabel1.frame = CGRect(x:3, y: 1, width:titleTV.frame.size.width+30, height:30)
        }
        placeholderLabel1.textColor = UIColor.lightGray
        
        if(saveexit_Activated == "true") {
            saveBtn.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else {
            saveBtn.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissName))
        titleTV.inputAccessoryView = toolBar
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        self.offlinview.isHidden = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        nameListingLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"namelisting"))!)"
        namedescLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"placespecial"))!)"
        titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"nameyourplace"))!)"
        saveBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"finish"))!)", for:.normal)
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        saveBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        nameListingLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 22)
        namedescLabel.font = UIFont(name: APP_FONT, size: 12)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        
        
        descriptionTV.autocorrectionType = UITextAutocorrectionType.no
        if Utility.shared.isRTLLanguage() {
            descriptionTV.textAlignment = .right
        } else {
            descriptionTV.textAlignment = .left
        }
        descriptionTV.isEditable = true
        if(Utility.shared.step2ValuesInfo["description"] != nil || Utility.shared.step2ValuesInfo["description"] as! String != "") {
            descriptionTV.text = (Utility.shared.step2ValuesInfo["description"] as! String)
        } else {
            descriptionTV.text = getListingStep2Array.description != nil ? getListingStep2Array.description! : ""
        }
        
        descriptionTV.isScrollEnabled = true
        placeholderLabel = UILabel()
        placeholderLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"desc_Placeholder"))!)"
        placeholderLabel.font = titleTV.font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        descriptionTV.addSubview(placeholderLabel)
        
        if Utility.shared.isRTLLanguage(){
            placeholderLabel.frame = CGRect(x:3, y:-10, width:descriptionTV.frame.size.width+30, height:45)
        } else {
            placeholderLabel.frame = CGRect(x:6, y:-10, width:descriptionTV.frame.size.width-20, height:75)
        }
        placeholderLabel.numberOfLines = 2
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !descriptionTV.text.isEmpty
        if(saveexit_Activated == "true") {
            saveBtn.isHidden = false
            self.stepsTitleView.isHidden = false
            self.stepTitleHeightConstraint.constant = 50
            self.stepTitleTopConstraint.constant = 5
        } else {
            saveBtn.isHidden = true
            self.stepsTitleView.isHidden = true
            self.stepTitleHeightConstraint.constant = 0
            self.stepTitleTopConstraint.constant = 0
        }
        descriptionTV.inputAccessoryView = toolBar
        
        
        summaryLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"descnew"))!)"
        namedescLabel.font = UIFont(name: APP_FONT, size: 12)
        namedescLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"titledesc"))!)"
        
        namedescLabel.textColor = UIColor(named: "searchPlaces_TextColor")
        
        descriptionTV.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        summaryLabel.font = UIFont(name: APP_FONT_MEDIUM, size:16)
        
        descriptionView.layer.cornerRadius = 5
        descriptionView.clipsToBounds = true
        descriptionView.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        descriptionView.layer.borderWidth = 0.8
        titleview.layer.cornerRadius = 5
        titleview.clipsToBounds = true
        titleview.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        titleview.layer.borderWidth = 0.8
        
    }
    @objc func dismissName() {
        self.view.endEditing(true)
    }
    
    func offlineviewShow() {
        self.view.endEditing(true)
        self.offlinview.isHidden = false
        self.nextBtn.isHidden = true
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlinview.frame.size.width + shadowSize2,
                                                    height: self.offlinview.frame.size.height + shadowSize2))
        
        self.offlinview.layer.masksToBounds = false
        self.offlinview.layer.shadowColor = Theme.TextLightColor.cgColor
        self.offlinview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.offlinview.layer.shadowOpacity = 0.3
        self.offlinview.layer.shadowPath = shadowPath2.cgPath
        self.view.addSubview(offlinview)
        if IS_IPHONE_X || IS_IPHONE_XR{
            offlinview.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
        }else{
            offlinview.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
        }
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            if(saveexit_Activated == "true") {
                let StepTwoObj = StepTwoVC()
                if ((!self.showListingstepArray.isPhotosAdded! || self.showListingstepArray.isPhotosAdded!) && (self.showListingstepArray.step2 == "completed")) {
                    StepTwoObj.saveexit_Activated = "true"
                }
                if(self.showListingstepArray.step2 == "active") {
                    StepTwoObj.saveexit_Activated = "false"
                }
                Utility.shared.step2_Title = ""
                Utility.shared.step2_Description = ""
                StepTwoObj.showListingstepArray = self.showListingstepArray
                StepTwoObj.getListingDetailsStep2()
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.offlineviewShow()
        }
    }
    @IBAction func savandexitBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            if(Utility.shared.host_step2_isfromEdit) {
                self.view.endEditing(true)
                super.updatelistingStep2APICall{(success) -> Void in
                    if success {
                    } else {
                        
                    }
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    func goToBecomeAHost(){
        let becomeHostObj = BecomeHostVC()
        becomeHostObj.listID = "\(Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0)"
        becomeHostObj.showListingStepsAPICall(listID:"\(Utility.shared.step2ValuesInfo["id"] != nil ? Utility.shared.step2ValuesInfo["id"] as! Int : 0)")
        becomeHostObj.showListingStepsAPICall(listID:"\(Utility.shared.host_step2_listId)")
        becomeHostObj.modalPresentationStyle = .fullScreen
        self.present(becomeHostObj, animated:false, completion: nil)
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.nextBtn.isHidden = false
            self.offlinview.isHidden = true
        }
    }
    
    func manageListingSteps(listId:String,currentStep:Int) {
        let manageListingStepsMutation = ManageListingStepsMutation(listId:listId, currentStep:currentStep)
        super.apollo_headerClient.perform(mutation: manageListingStepsMutation){ (result,error) in
            
            if(result?.data?.manageListingSteps?.status == 200) {
            } else {
                self.view.makeToast(result?.data?.manageListingSteps?.errorMessage)
            }
            
        }
        
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            let text_Title = titleTV.text!.trimmingCharacters(in:.whitespacesAndNewlines)
            if(text_Title == "") {
                self.titleTV.resignFirstResponder()
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"addtitlealert"))!)")
            } else {
                super.updatelistingStep2APICall{(success) -> Void in
                    if !success {
                        self.manageListingSteps(listId: "\(Utility.shared.host_step2_listId)", currentStep: 2)
                    }
                }
            }
        } else {
            self.offlineviewShow()
        }
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }
    
    func configureNextBtn(enable:Bool){
        if(enable){
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.alpha = 1.0
        } else {
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.alpha = 0.7
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(textView.tag == 1) {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars < 50
        }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1000
    }
    func textViewDidChange(_ textView: UITextView) {
        if(textView.tag == 1) {
            placeholderLabel1.isHidden = !textView.text.isEmpty
        } else {
            placeholderLabel.isHidden  = !textView.text.isEmpty
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.tag == 1) {
            
            Utility.shared.step2_Title = textView.text!
            Utility.shared.step2ValuesInfo.updateValue(textView.text!, forKey: "title")
        } else {
            Utility.shared.step2_Description = textView.text!
            Utility.shared.step2ValuesInfo.updateValue(textView.text!, forKey: "description")
        }
        
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if(textField.tag == 1) {
            placeholderLabel1.isHidden = !textField.text!.isEmpty
        }
    }
    override func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 1) {
            Utility.shared.step2_Title = textField.text!
            Utility.shared.step2ValuesInfo.updateValue(textField.text!, forKey: "title")
        }
    }
}

extension ListingTitleVC: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 2{
            switch selectedPageIndex{
            case 0:
                let StepTwoObj = StepTwoVC()
                if ((!self.showListingstepArray.isPhotosAdded! || self.showListingstepArray.isPhotosAdded!) && (self.showListingstepArray.step2 == "completed")) {
                    StepTwoObj.saveexit_Activated = "true"
                }
                if(self.showListingstepArray.step2 == "active")
                {
                    StepTwoObj.saveexit_Activated = "false"
                }
                Utility.shared.step2_Title = ""
                Utility.shared.step2_Description = ""
                StepTwoObj.showListingstepArray = self.showListingstepArray
                StepTwoObj.getListingDetailsStep2()
                StepTwoObj.modalPresentationStyle = .fullScreen
                self.present(StepTwoObj, animated:false, completion: nil)
                break
            case 1:
                break
            case 2:
                let listingDescriptionObj = ListingDescriptionVC()
                Utility.shared.host_step2_title = titleTV.text ?? ""
                listingDescriptionObj.saveexit_Activated = saveexit_Activated
                listingDescriptionObj.getListingStep2Array = getListingStep2Array
                listingDescriptionObj.showListingstepArray = showListingstepArray
                listingDescriptionObj.modalPresentationStyle = .fullScreen
                self.present(listingDescriptionObj, animated:false, completion: nil)
                break
            default:
                break
            }
        }
    }
}
