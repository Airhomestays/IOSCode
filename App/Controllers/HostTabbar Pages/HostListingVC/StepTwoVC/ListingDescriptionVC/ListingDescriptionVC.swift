
import UIKit
import IQKeyboardManagerSwift
import Apollo
import SwiftMessages


class ListingDescriptionVC: BaseHostTableviewController,UITextViewDelegate {
    @IBOutlet weak var backBtn:UIButton!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var editdescTitleLabel: UILabel!
    @IBOutlet weak var offlinview: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var curvedView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var progressBGView: UIView!
    @IBOutlet weak var currentProgressView: UIView!
    var getListingStep2Array = GetListingDetailsStep2Query.Data.GetListingDetail.Result()
    var showListingstepArray = ShowListingStepsQuery.Data.ShowListingStep.Result()
    var saveexit_Activated = String()
    @IBOutlet weak var stepsTitleView: BecomeStepCollectionView!
    @IBOutlet weak var stepTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepTitleTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialsetup()
        
        self.stepsTitleView.whichStep = 2
        self.stepsTitleView.selectedViewIndex = 2
        self.stepsTitleView.delegateSteps = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stepsTitleView.toBeCheck()
    }
    
    override func setUpUI() {}
    override func setDropdownList() {}
    override func registerCells() {}
    
    func offlineviewShow() {
        self.offlinview.isHidden = false
        self.nextBtn.isHidden = true
        let shadowSize2 : CGFloat = 3.0
        let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                    y: -shadowSize2 / 2,
                                                    width: self.offlinview.frame.size.width + shadowSize2,
                                                    height: self.offlinview.frame.size.height + shadowSize2))
        
        self.offlinview.layer.masksToBounds = false
        offlinview.backgroundColor =  UIColor(named: "Button_Grey_Color")
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
    @IBAction func nextBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            super.updatelistingStep2APICall{(success) -> Void in
                if !success {
                    self.manageListingSteps(listId: "\(Utility.shared.host_step2_listId)", currentStep: 2)
                }
            }
        }else {
            self.offlineviewShow()
        }
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.nextBtn.isHidden = false
            self.offlinview.isHidden = true
        }
        
    }
    @IBAction func saveAndExitBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            self.view.endEditing(true)
            super.updatelistingStep2APICall{(success) -> Void in
                if success {
                } else {
                    self.manageListingSteps(listId: "\(Utility.shared.host_step2_listId)", currentStep: 2)
                }
            }
            
            
        } else {
            self.offlineviewShow()
        }
    }
    
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
        
        self.editdescTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "edit_desc") ?? "Edit your description")"
        self.editdescTitleLabel.textColor = UIColor(named: "Title_Header")
        self.editdescTitleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 24.0)
        self.editdescTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        progressBGView.backgroundColor = Theme.becomeAHostProgressBG_Color
        currentProgressView.backgroundColor = Theme.PRIMARY_COLOR
        
        self.curvedView.layer.borderColor = Theme.becomeAHostBorder_Color.cgColor
        self.curvedView.layer.borderWidth = 0.5
        self.curvedView.layer.cornerRadius = 20.0
        self.curvedView.clipsToBounds = true
        
        editdescTitleLabel.backgroundColor = .clear
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        descriptionTV.autocorrectionType = UITextAutocorrectionType.no
        saveBtn.setTitleColor(Theme.PRIMARY_COLOR, for:.normal)
        if Utility.shared.isRTLLanguage() {
            descriptionTV.textAlignment = .right
        } else {
            descriptionTV.textAlignment = .left
        }
        descriptionTV.isEditable = true
        if(Utility.shared.step2ValuesInfo["description"] != nil) {
            descriptionTV.text = (Utility.shared.step2ValuesInfo["description"] as! String)
        } else {
            descriptionTV.text = getListingStep2Array.description != nil ? getListingStep2Array.description! : ""
        }
        
        descriptionTV.isScrollEnabled = true
        placeholderLabel = UILabel()
        placeholderLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"desc_Placeholder"))!)"
        placeholderLabel.font = descriptionTV.font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.sizeToFit()
        descriptionTV.addSubview(placeholderLabel)
        placeholderLabel.frame = CGRect(x:6, y:-10, width:descriptionTV.frame.size.width-20, height:75)
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
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissName))
        descriptionTV.inputAccessoryView = toolBar
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        self.offlinview.isHidden = true
        errorLabel.textColor =  UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        saveBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for:.normal)
        saveBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"saveexit"))!)", for:.normal)
        summaryLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"summary"))!)"
        nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        descriptionTV.font = UIFont(name: APP_FONT_MEDIUM, size: 14)
        editdescTitleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size:22)
        summaryLabel.font = UIFont(name: APP_FONT, size:14)
        
        descriptionTV.layer.cornerRadius = 5
        descriptionTV.clipsToBounds = true
        descriptionTV.layer.borderColor = Theme.descriptionBorder_Color.cgColor
        descriptionTV.layer.borderWidth = 0.8
    }
    @objc func dismissName() {
        self.view.endEditing(true)
        
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
    
    func manageListingSteps(listId:String,currentStep:Int) {
        let manageListingStepsMutation = ManageListingStepsMutation(listId:listId, currentStep:currentStep)
        super.apollo_headerClient.perform(mutation: manageListingStepsMutation){ (result,error) in
            
            if(result?.data?.manageListingSteps?.status == 200) {
                self.goToBecomeAHost()
            } else {
                self.view.makeToast(result?.data?.manageListingSteps?.errorMessage)
            }
            
        }
        
    }
    
    func goToBecomeAHost(){
        let becomeHostObj = BecomeHostVC()
        becomeHostObj.listID = "\(Utility.shared.host_step2_listId)"
        becomeHostObj.showListingStepsAPICall(listID:"\(Utility.shared.host_step2_listId)")
        becomeHostObj.modalPresentationStyle = .fullScreen
        self.present(becomeHostObj, animated:false, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 1000
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        Utility.shared.step2_Description = textView.text!
        Utility.shared.step2ValuesInfo.updateValue(textView.text!, forKey: "description")
    }
}
extension UITextView {
    func resizeForHeight(){
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = true
    }
}

extension ListingDescriptionVC: stepsUpdateProtocol{
    func selectedPage(step: Int, selectedPageIndex: Int) {
        if step == 2{
            switch selectedPageIndex{
            case 0:
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
                break
            case 1:
                let listTitleObj = ListingTitleVC()
                Utility.shared.host_step2_listId = showListingstepArray.listId != nil ? showListingstepArray.listId! : 0
                listTitleObj.saveexit_Activated = saveexit_Activated
                listTitleObj.getListingStep2Array = getListingStep2Array
                listTitleObj.showListingstepArray = showListingstepArray
                self.view.window?.backgroundColor = UIColor.white
                listTitleObj.modalPresentationStyle = .fullScreen
                self.present(listTitleObj, animated:false, completion: nil)
                break
            case 2:
                break
            default:
                break
            }
        }
    }
}
