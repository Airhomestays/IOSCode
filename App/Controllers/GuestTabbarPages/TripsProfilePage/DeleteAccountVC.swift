

import UIKit
import Apollo

class DeleteAccountVC: UIViewController {
   
    @IBOutlet var bgView: UIView!
    @IBOutlet var btnNo: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var lblDelConfirm: UILabel!
    @IBOutlet var lblDelAcc: UILabel!
    var apollo_headerClient:ApolloClient!
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        
        
        
        self.checkApolloStatus()
        lblDelAcc.text = "\(Utility.shared.getLanguage()?.value(forKey:"deleteaccount") ?? "Delete account")"
        lblDelConfirm.text = "\(Utility.shared.getLanguage()?.value(forKey:"delete_confirmation") ?? "Are you sure you want delete your account permanently?")"
        btnDelete.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"yesdelete") ?? "YES")", for: .normal)
        let no = "\(Utility.shared.getLanguage()?.value(forKey:"No_Caps") ?? "NO")"
        btnNo.setTitle("\(Utility.shared.getLanguage()?.value(forKey:"No_Caps") ?? "NO")", for: .normal)
        
        lblDelConfirm.textColor =  UIColor(named: "Title_Header")
        lblDelAcc.textColor = UIColor(named: "Title_Header")
        
        lblDelAcc.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        lblDelConfirm.font = UIFont(name: APP_FONT, size: 16)
        btnDelete.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 17)
        btnNo.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 17)

        
        if(Utility.shared.isRTLLanguage()) {
           
            lblDelConfirm.textAlignment = .right
        }
       else{
      
      }
    }

    func checkApolloStatus()
    {
        if((Utility.shared.getCurrentUserToken()) != nil)
        {
            apollo_headerClient = {
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"]
                let url = URL(string:graphQLEndpoint)!
                
                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
            }()
        }
        else{
            apollo_headerClient = ApolloClient(url: URL(string:graphQLEndpoint)!)
        }
        
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func deleteAaction(_ sender: Any) {
        if Utility.shared.isConnectedToNetwork(){
        let deleteMutation = DeleteUserMutation()
            apollo_headerClient.perform(mutation: deleteMutation){(result,error) in
            if(result?.data?.deleteUser?.status == 200) {
                self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey:"delacccontent") ?? "No")")
                UserDefaults.standard.removeObject(forKey: "user_token")
                UserDefaults.standard.removeObject(forKey: "user_id")
                UserDefaults.standard.removeObject(forKey: "password")
                UserDefaults.standard.removeObject(forKey: "currency_rate")
                let seconds = 2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let welcomeObj = WelcomePageVC()
                    appDelegate.setInitialViewController(initialView: welcomeObj)
                }
               
            }
            else{
                let alert = UIAlertController(title: "\(result?.data?.deleteUser?.errorMessage! ?? "Unable to delete")", message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,  handler: { (action) in
                    self.dismiss(animated:false, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)

            }
        }
        }
    }
}
