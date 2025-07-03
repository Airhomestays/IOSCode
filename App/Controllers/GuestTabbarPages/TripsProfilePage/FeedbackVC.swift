

import UIKit
import Apollo
import SwiftMessages
import IQKeyboardManagerSwift

class FeedbackVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var FeedbcktextView: UITextView!
    @IBOutlet weak var wholeTitleLabel: UILabel!
    @IBOutlet weak var wholeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var feedbckTable: UITableView!
    var apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        if(Utility.shared.isRTLLanguage()) {
            backBtn.rotateImageViewofBtn()
        }
        
        self.titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "feedback") ?? "Feedback")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        self.wholeView.isHidden = true
        self.reportView.layer.cornerRadius = 5.0
        self.reportView.layer.masksToBounds = true
        self.FeedbcktextView.delegate = self
        feedbckTable.register(UINib(nibName: "FeebackHeaderCell", bundle: nil), forCellReuseIdentifier: "FeebackHeaderCell")
        feedbckTable.register(UINib(nibName: "FeedbackFooterCell", bundle: nil), forCellReuseIdentifier: "FeedbackFooterCell")
        
        cancelBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        sendBtn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        
        cancelBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"cancel_uppercase"))!)", for: .normal)
        sendBtn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"send_uppercase"))!)", for: .normal)
        titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"feedback"))!)"
        sendBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .left : .right
        cancelBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        FeedbcktextView.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        
        wholeTitleLabel.textColor = UIColor(named: "Title_Header")
        wholeTitleLabel.font = UIFont(name: APP_FONT, size: 16.0)
        FeedbcktextView.font = UIFont(name: APP_FONT, size: 14.0)
        cancelBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16.0)
        sendBtn.titleLabel?.font = UIFont(name: APP_FONT, size: 16.0)
    }
    @IBAction func sendBtnTapped(_ sender: Any) {
        self.view.endEditing(true)
        if(self.wholeTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"feedback"))!)")
        {
            if (FeedbcktextView.text == "\((Utility.shared.getLanguage()?.value(forKey:"enterfeedbck"))!)" || FeedbcktextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
                self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey:"Feedback_Error") ?? "Please fill your feedback details before sending it")")
            }else{
                self.sendUserfeedback(type: "Feed Back", message: FeedbcktextView.text!)
            }
        }
        else{
            if (FeedbcktextView.text == "\((Utility.shared.getLanguage()?.value(forKey:"enterbug"))!)" || FeedbcktextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
                self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey:"Bug_Error") ?? "Please share the bug details before sending it")")
            }else{
                self.sendUserfeedback(type: "Bug", message: FeedbcktextView.text!)
            }
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.wholeView.isHidden = true
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeebackHeaderCell", for: indexPath) as! FeebackHeaderCell
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackFooterCell", for: indexPath)as! FeedbackFooterCell
            cell.feedbcakcBtn.addTarget(self, action: #selector(feedbackBtnTapped), for: .touchUpInside)
            cell.feedbcakcBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.bugBtn.contentHorizontalAlignment = Utility.shared.isRTLLanguage() ? .right : .left
            cell.selectionStyle = .none
             cell.bugBtn.addTarget(self, action: #selector(BugBtnTapped), for: .touchUpInside)
            return cell
        }
    }
    
    func sendUserfeedback(type:String,message:String)

    {
        let senduserFeedbackMutation = SendUserFeedbackMutation(type: type, message: message)
        apollo_headerClient.perform(mutation:senduserFeedbackMutation){(result,error) in
            if(result?.data?.userFeedback?.status == 200)
            {
                self.wholeView.isHidden = true
                if(type == "Feed Back")
                {
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"feedbacksuccessAlert"))!)")
                }
                else{
                    self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"bugsuccessAlert"))!)")
                }
            }else{
                
               
                
                self.view.makeToast(result?.data?.userFeedback?.errorMessage!)
            }
        }
    }
    @objc func feedbackBtnTapped()
    { self.wholeView.isHidden = false
        self.FeedbcktextView.delegate = self
        self.wholeTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"feedback"))!)"
        self.FeedbcktextView.text = "\((Utility.shared.getLanguage()?.value(forKey:"enterfeedbck"))!)"
           self.FeedbcktextView.textColor = .lightGray
       
    }
    @objc func BugBtnTapped()
    {
        self.wholeView.isHidden = false
        self.FeedbcktextView.delegate = self
        self.wholeTitleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"bug"))!)"
        self.FeedbcktextView.text = "\((Utility.shared.getLanguage()?.value(forKey:"enterbug"))!)"
        self.FeedbcktextView.textColor = .lightGray
      
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            self.FeedbcktextView.textColor = .lightGray
            if self.wholeTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"feedback"))!)"{
                self.FeedbcktextView.text = "\((Utility.shared.getLanguage()?.value(forKey:"enterfeedbck"))!)"
            }else{
                self.FeedbcktextView.text = "\((Utility.shared.getLanguage()?.value(forKey:"enterbug"))!)"
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.FeedbcktextView.textColor =  UIColor(named: "Title_Header")
        if self.wholeTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"feedback"))!)"{
            if self.FeedbcktextView.text == "\((Utility.shared.getLanguage()?.value(forKey:"enterfeedbck"))!)" {
                self.FeedbcktextView.text = ""
            }
        }else{
            if self.FeedbcktextView.text == "\((Utility.shared.getLanguage()?.value(forKey:"enterbug"))!)" {
                self.FeedbcktextView.text = ""
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.count > 0){
            self.FeedbcktextView.textColor =  UIColor(named: "Title_Header")
        }
    }
}
