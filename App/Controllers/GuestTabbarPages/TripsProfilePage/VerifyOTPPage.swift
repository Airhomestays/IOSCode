
import UIKit
import Apollo
import Lottie

class VerifyOTPPage: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var otpTF: CustomUITextField!
    @IBOutlet weak var otpTitleLabel: UILabel!
    @IBOutlet weak var descLAbel: UILabel!
    @IBOutlet weak var enterDigitLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    var EditProfileArray = GetProfileQuery.Data.UserAccount.Result()
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    var lottieView1: LottieAnimationView!
    var countrycode = String()
    var phoneno = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.lottieView1.isHidden = true
        self.nextBtn.setTitle("Next", for: .normal)
    }
    func lottienextanimation()
    {
       
        nextBtn.setTitle("", for:.normal)
        self.lottieView1.isHidden = false
        self.lottieView1.frame = CGRect(x:15, y:-25, width:100, height:100)
        self.nextBtn.addSubview(self.lottieView1)
        self.view.bringSubviewToFront(self.lottieView1)
        self.lottieView1.backgroundColor = UIColor.clear
        self.lottieView1.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll1), userInfo: nil, repeats: true)
    }
    @objc func autoscroll1()
    {
        self.lottieView1.play()
    }
    func initialSetup()
    {
        
        enterDigitLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"enter4digits"))!)"
        otpTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"4digitcode"))!)"
        descLAbel.text = "\((Utility.shared.getLanguage()?.value(forKey:"otpDesc"))!) \(phoneno). \((Utility.shared.getLanguage()?.value(forKey:"entercodeagain"))!)"
        sendCodeBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"sendcodegain"))!)", for: .normal)
        changeBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"changeno"))!)", for: .normal)
        lottieView1 = LottieAnimationView.init(name: "animation_white")
        sendCodeBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
          changeBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        let toolBar = UIToolbar().ToolbarPikerSelect(mySelect: #selector(dismissPicker))
        toolBar.barTintColor = UIColor(named: "Button_Grey_Color")
        otpTF.inputAccessoryView = toolBar
        otpTF.delegate = self
        otpTF.keyboardType = .numberPad
        otpTF.becomeFirstResponder()
        
        self.view.backgroundColor = UIColor(named: "colorController")
        
        otpTF.layer.borderColor = UIColor(named: "text_borderColor")?.cgColor
        otpTF.layer.borderWidth = 1.0
        otpTF.layer.masksToBounds = true
        otpTF.layer.cornerRadius  = 4.0
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height / 2
        
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        otpTF.leftView = paddingView
        otpTF.leftViewMode = .always
        nextBtn.layer.masksToBounds = true
        nextBtn.backgroundColor = Theme.Button_BG
        enterDigitLabel.font = UIFont(name: APP_FONT, size: 25)
         otpTF.font = UIFont(name: APP_FONT, size: 14)
        otpTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        descLAbel.font = UIFont(name: APP_FONT, size: 18)
      sendCodeBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        changeBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
               nextBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
        nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey: "next"))!)", for: .normal)
        
    }
    @objc func dismissPicker()
    {
        self.view.endEditing(true)
            
        
        
    }
    func verifyPhonenumberCall()
    {
        let verifyphonenoMutation = VerifyPhoneNumberMutation(verificationCode:Int(otpTF.text!)!)
        apollo_headerClient.perform(mutation: verifyphonenoMutation){(result,error) in
            if(result?.data?.verifyPhoneNumber?.status == 200)
            {
                self.lottieView1.isHidden = true
                               self.nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
                let editprofileobj = EditProfileVC()
                editprofileobj.EditProfileArray = self.EditProfileArray
                editprofileobj.modalPresentationStyle = .fullScreen
                self.present(editprofileobj, animated:false, completion:nil)
               
            }
            else
            {
                self.view.makeToast(result?.data?.verifyPhoneNumber?.errorMessage!)
                self.lottieView1.isHidden = true
                self.nextBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"next"))!)", for: .normal)
            }
        }
    }
    func addPhonenumberCall()
       {
           let addphonenumberMutation = AddPhoneNumberMutation(countryCode:countrycode, phoneNumber:phoneno)
           apollo_headerClient.perform(mutation: addphonenumberMutation){(result,error) in
               if(result?.data?.addPhoneNumber?.status == 200)
               {
                   self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"sentOTP"))!)")
                                   
               }
               else
               {
                   self.view.makeToast("\((result?.data?.addPhoneNumber?.errorMessage!)!)")
               }
           }
       }
    func getEnteredPhonenoAPICall()
    {
        let getEnteredphonenoquery = GetEnteredPhoneNoQuery()
        apollo_headerClient.fetch(query:getEnteredphonenoquery,cachePolicy:.fetchIgnoringCacheData){(result,error) in
            if(result?.data?.getPhoneData?.status == 200)
            {
                self.view.endEditing(true)
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"sentOTP"))!)")
               
            }
        }
    }

    @IBAction func nextBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
    
        let OTPtext = otpTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if(OTPtext == "")
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"enterotp"))!)")
        }
        else if(otpTF.text!.count < 4)
        {
            otpTF.resignFirstResponder()
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"otpalert"))!)")
            
        }
        else if(otpTF.text!.count > 10)
        {
            otpTF.resignFirstResponder()
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"otpexceedalert"))!)")
        }
        else
        {
            lottienextanimation()
            self.verifyPhonenumberCall()
        }
        }
        else
        {
         self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
        
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sendCodeTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.addPhonenumberCall()
        
    }
    @IBAction func changenumberTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let charsLimit = 4
            
            let startingLength = textField.text?.count ?? 0
            let lengthToAdd = string.count
            let lengthToReplace =  range.length
            let newLength = startingLength + lengthToAdd - lengthToReplace
            
            return newLength <= charsLimit
        }
}
