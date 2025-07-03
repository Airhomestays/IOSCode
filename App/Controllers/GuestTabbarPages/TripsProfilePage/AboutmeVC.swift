
import UIKit
import IQKeyboardManagerSwift
import Apollo
import Lottie

class AboutmeVC: UIViewController,UITextViewDelegate{
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var aboutTxtView: UITextView!
    @IBOutlet var cancelBtn: UIButton!
    var lottieView: LottieAnimationView!
    @IBOutlet var containerView: UIView!
    var aboutvaluArray = GetProfileQuery.Data.UserAccount.Result()
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
    
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    func lottienextAnimation(sender:UIButton)
    {
        lottieView = LottieAnimationView.init(name: "animation_white")
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:sender.frame.size.width/2-50, y:-30, width:100, height:100)
        self.lottieView.backgroundColor = .red
        sender.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        sender.setTitle("", for:.normal)
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
       self.lottieView.play()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = false
        if(Utility.shared.isaboutmechanged)
        {
         aboutTxtView.text = Utility.shared.aboutme_Name
            subTitleLbl.isHidden = true
         self.countLabel.text =  "\(aboutTxtView.text.count)/250" 
        }
        else {
            
        if(aboutvaluArray.info != "" && aboutvaluArray.info != nil)
        {
        let trimToCharacter = 250
        let shortString = "\(aboutvaluArray.info!.prefix(trimToCharacter))"
        aboutTxtView.text = shortString
        self.countLabel.text =  "\(aboutTxtView.text.count)/250"
            subTitleLbl.isHidden = true
        }
        }
        aboutTxtView.tintColor = UIColor(named: "Title_Header")
        aboutTxtView.autocorrectionType = UITextAutocorrectionType.no
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissPicker))
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        aboutTxtView.inputAccessoryView = toolBar
        saveBtn.backgroundColor = Theme.Button_BG
        countLabel.textColor = Theme.PRIMARY_COLOR
        
        if(Utility.shared.isRTLLanguage()) {
            aboutTxtView.textAlignment = .right
            
        } else {
            
            aboutTxtView.textAlignment = .left
        }
        titleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"addabout")) ?? "Add about")"
        subTitleLbl.text = "\((Utility.shared.getLanguage()?.value(forKey:"addaboutPlaceholder"))!)"
        saveBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"add"))!)", for:.normal)
        cancelBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancel"))!)", for:.normal)
        
        self.view.backgroundColor = UIColor(named: "colorController")
        cancelBtn.layer.borderColor = Theme.Button_BG.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        subTitleLbl.font = UIFont(name: APP_FONT, size: 14)
        titleLbl.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        countLabel.font = UIFont(name: APP_FONT, size: 17)
        aboutTxtView.font = UIFont(name: APP_FONT, size: 14)
        saveBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        cancelBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        containerView.borderColor = UIColor(named: "text_borderColor")

    }
    @objc func dismissPicker()
    {
        view.endEditing(true)
        
    }
    @IBAction func closeBtnTapped(_ sender: Any){
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        self.view.endEditing(true)
       
        if(aboutTxtView.text != ""){
            self.lottienextAnimation(sender: sender as! UIButton)
        Utility.shared.isaboutmechanged = true
        Utility.shared.aboutme_Name = aboutTxtView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.EditProfileAPICall(fieldName: "info", fieldValue:aboutTxtView.text!.trimmingCharacters(in: .whitespacesAndNewlines))
       
        }
        else{

            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"aboutrequired"))!)")
            
        }
    }
    func EditProfileAPICall(fieldName:String,fieldValue:String)
    {
        let editprofileMutation = EditProfileMutation(userId: (Utility.shared.getCurrentUserID()! as String), fieldName: fieldName, fieldValue: fieldValue, deviceType: "iOS", deviceId:Utility.shared.pushnotification_devicetoken)
        apollo_headerClient.perform(mutation: editprofileMutation){ (result,error) in
            
            if(result?.data?.userUpdate?.status == 200)
            {
                self.lottieView.isHidden = true
                self.dismiss(animated: false, completion: nil)
            }
            else {
                self.lottieView.isHidden = true
                self.saveBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"add"))!)", for:.normal)
                self.view.makeToast(result?.data?.userUpdate?.errorMessage)
            }
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

            let descriptionCount = (textView.text.count + (text.count - range.length))
        
            return textView.text.count + (text.count - range.length) <= 250
    }
  

    @objc func keyboardWillShow(sender: NSNotification) {


    }
    @objc func keyboardWillHide(sender: NSNotification) {

        
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func textViewDidChange(_ textView: UITextView)
   {
       
       if self.aboutTxtView.text != "" {
           subTitleLbl.isHidden = true
       }else{
           subTitleLbl.isHidden = false
       }
       

       
       
    
    let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    self.countLabel.text = "\(text.count)/250"
    }
}
