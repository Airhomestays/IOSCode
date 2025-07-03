
import UIKit
import IQKeyboardManagerSwift
import Lottie
import Apollo
protocol CreateListVCProtocol
{
    
    func updateWhishlistStatus(status:Bool, title:String)
}


class CreateListVC: UIViewController {
    
    
    @IBOutlet var lineLabel: UILabel!
    @IBOutlet weak var createTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var titleTF: CustomUITextField!
    @IBOutlet weak var topView: UIView!
    var delegate: CreateListVCProtocol?
    var listID = Int()
    var groupID = Int()
    var title_data = ""
    var isFromSave  = false
    var lottieView: LottieAnimationView!
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        offlineView.backgroundColor =  UIColor(named: "Button_Grey_Color")
        self.initialSetup()
    }
    
    func initialSetup()
    {
        self.offlineView.isHidden = true
        self.createBtn.layer.cornerRadius = self.createBtn.frame.size.height/2
        self.createBtn.layer.masksToBounds = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        createBtn.backgroundColor  = Theme.Button_BG
        errorLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)"
        retryBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"retry"))!)", for:.normal)
        createBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"create"))!)", for:.normal)
        titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"title"))!)"
        createTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"createlist"))!)"
        errorLabel.textColor =  UIColor(named: "Title_Header")
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.lineLabel.backgroundColor =  UIColor(named: "Review_Page_Line_Color")
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.createTitleLabel.textColor = UIColor(named: "Title_Header")
        self.titleTF.textColor = UIColor(named: "Title_Header")
        retryBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        errorLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        titleTF.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        retryBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 15)
        createTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        createBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 15)
        if(Utility.shared.isRTLLanguage()) {
            titleTF.textAlignment = .right
        } else {
            titleTF.textAlignment = .left
        }
        titleTF.tintColor = UIColor(named: "Title_Header")
        if isFromSave {
            titleTF.text = self.title_data
            createTitleLabel.text = "Edit a group"
            createBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"save"))!)", for:.normal)
            
        }
    }
    func configureNextBtn(enable:Bool){
        if(enable){
            self.createBtn.isUserInteractionEnabled = true
            self.createBtn.alpha = 1.0
        }
        else {
            self.createBtn.isUserInteractionEnabled = false
            self.createBtn.alpha = 0.7
        }
        
    }
    func lottieanimation()
    {
        createBtn.setTitle("", for:.normal)
        lottieView = LottieAnimationView.init(name: "animation_white")
        
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:createBtn.frame.size.width/2-60, y:-25, width:100, height:100)
        self.createBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
        self.lottieView.play()
    }
    
    func createWhishlistAPICalls(listId:Int,wishListGroupId:Int,eventKey:Bool)
    {
        let createWhishlistMutation = CreateWishListMutation(listId: listId, wishListGroupId: wishListGroupId, eventKey: eventKey)
        apollo_headerClient.perform(mutation: createWhishlistMutation){ (result,error) in
            if(result?.data?.createWishList?.status == 200) {
                self.createBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"create"))!)", for: .normal)
                self.lottieView.isHidden = true
                
                self.dismiss(animated: true, completion: nil)
                return
            }
            else{
                self.view.makeToast(result?.data?.createWishList?.errorMessage)
                let seconds = 2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func createWhishlistAPICall()
    {
        if Utility().isConnectedToNetwork(){
            let createWhishlistMutation = CreateWishListGroupMutation(name:titleTF.text!)
            apollo_headerClient.perform(mutation: createWhishlistMutation){(result,error) in
                
                if(result?.data?.createWishListGroup?.status == 200)
                {
                    self.createWhishlistAPICalls(listId: self.listID, wishListGroupId: (result?.data?.createWishListGroup?.results?.id)!, eventKey: true)
                    
                    self.delegate?.updateWhishlistStatus(status:true , title: (result?.data?.createWishListGroup?.results?.name)!)
                }
                else
                {
                    
                    
                    self.view.makeToast(result?.data?.createWishListGroup?.errorMessage)
                }
                
            }
        }
        else
        {
            self.lottieView.isHidden = true
            self.offlineView.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineView.frame.size.width + shadowSize2,
                                                        height: self.offlineView.frame.size.height + shadowSize2))
            
            self.offlineView.layer.masksToBounds = false
            self.offlineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineView.layer.shadowOpacity = 0.3
            self.offlineView.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
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
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createWhishlistAPICalls() {
        if Utility().isConnectedToNetwork(){
            let createWhishlistMutation = CreateWishListGroupMutation(name:titleTF.text! , id: self.groupID)
            apollo_headerClient.perform(mutation: createWhishlistMutation){ [self](result,error) in
                self.lottieView.isHidden = true
                if(result?.data?.createWishListGroup?.status == 200) {
                    self.delegate?.updateWhishlistStatus(status:true , title: (result?.data?.createWishListGroup?.results?.name)!)
                    self.dismiss(animated: true)
                } else {
                    self.view.makeToast(result?.data?.createWishListGroup?.errorMessage)
                }
                
            }
        }
        else
        {
            self.lottieView.isHidden = true
            self.offlineView.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineView.frame.size.width + shadowSize2,
                                                        height: self.offlineView.frame.size.height + shadowSize2))
            
            self.offlineView.layer.masksToBounds = false
            self.offlineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineView.layer.shadowOpacity = 0.3
            self.offlineView.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-130, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-100, width: FULLWIDTH, height: 55)
            }
        }
    }
    
    
    @IBAction func createBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
            titleTF.resignFirstResponder()
            if(titleTF.text!.isBlank)
            {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"eneterwhishlisttitle"))!)")
            }else if titleTF.text!.containsSpecialCharacter {
                
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"noSpecialChanges"))!)")
            }
            else{
                self.lottieanimation()
                if isFromSave {
                    self.createWhishlistAPICalls()
                }
                else {
                    self.createWhishlistAPICall()
                }
                
            }
        }
        else{
            self.titleTF.resignFirstResponder()
            self.offlineView.isHidden = false
            let shadowSize2 : CGFloat = 3.0
            let shadowPath2 = UIBezierPath(rect: CGRect(x: -shadowSize2 / 2,
                                                        y: -shadowSize2 / 2,
                                                        width: self.offlineView.frame.size.width + shadowSize2,
                                                        height: self.offlineView.frame.size.height + shadowSize2))
            
            self.offlineView.layer.masksToBounds = false
            self.offlineView.layer.shadowColor = Theme.TextLightColor.cgColor
            self.offlineView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            self.offlineView.layer.shadowOpacity = 0.3
            self.offlineView.layer.shadowPath = shadowPath2.cgPath
            if IS_IPHONE_X || IS_IPHONE_XR {
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-85, width: FULLWIDTH, height: 55)
            }else{
                offlineView.frame = CGRect.init(x: 0, y: FULLHEIGHT-55, width: FULLWIDTH, height: 55)
            }
        }
    }
    @IBAction func retryBtnTapped(_ sender: Any) {
        self.offlineView.isHidden = true
    }
    
}
extension String {
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9 ].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
}
extension CreateListVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let currenctCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currenctCharacterCount {
            return false
            
        }else{
            
            let length = currenctCharacterCount + string.count - range.length
            if range.location > 0 && string.count > 0{
                let whitespace = CharacterSet.whitespaces
                let start = string.unicodeScalars.startIndex
                if let textFieldText = textField.text{
                    let location = textFieldText.unicodeScalars.index(textFieldText.unicodeScalars.startIndex, offsetBy: range.location - 1)
                    if whitespace.contains(string.unicodeScalars[start]) && whitespace.contains(textFieldText.unicodeScalars[location]){
                        textField.text = (textFieldText as NSString?)?.replacingCharacters(in: range, with: " ")
                        
                        if let pos = textField.position(from: textField.beginningOfDocument, offset: range.location + 1)
                        {
                            textField.selectedTextRange = textField.textRange(from: pos, to: pos)

                            return false
                        }
                    }
                }
            }
            return length <= 50
        }
        
    }
    
    
    
    
}
