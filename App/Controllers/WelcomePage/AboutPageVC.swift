

import UIKit

class AboutPageVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var aboutTable: UITableView!
    
    @IBOutlet weak var topView: UIView!
    var titleArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            backBtn.imageView?.performRTLTransform()
        }
        titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"about") ?? "About")"
        self.titleLabel.textColor = UIColor(named: "Title_Header")
        self.titleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.titleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
        titleArray = ["\((Utility.shared.getLanguage()?.value(forKey:"whyhost"))!)","\((Utility.shared.getLanguage()?.value(forKey:"aboutus"))!)","\((Utility.shared.getLanguage()?.value(forKey:"trustandsafety"))!)"]
            aboutTable.register(UINib(nibName: "SwitchtohostCell", bundle: nil), forCellReuseIdentifier: "SwitchtohostCell")
     
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchtohostCell", for: indexPath) as! SwitchtohostCell
           cell.selectionStyle = UITableViewCell.SelectionStyle.none
           cell.profileSettingLabel.text = titleArray[indexPath.row]
           cell.iconImage.isHidden = true
           cell.profileLblLeadingConstraint.constant = -30
           return cell
       }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0)
        {
            let whyhostObj = WhyhostVC()
            whyhostObj.modalPresentationStyle = .fullScreen
            self.present(whyhostObj, animated: false, completion: nil)
        }

        else if(indexPath.row == 1)
        {
            let webviewObj = WebviewVC()
            webviewObj.isFromStaticContent = true
                                       webviewObj.webstring = ABOUT_URL
            webviewObj.id = 1
            webviewObj.pageTitle = "\(Utility.shared.getLanguage()?.value(forKey: "aboutus") ?? "About Us")"
                                       webviewObj.modalPresentationStyle = .fullScreen
                                      webviewObj.webviewRedirection(webviewString:ABOUT_URL)
                                       self.present(webviewObj, animated: true, completion: nil)
        } else{
            
            let webviewObj = WebviewVC()
            webviewObj.isFromStaticContent = true
                                       webviewObj.webstring = SAFETY_URL
            webviewObj.id = 2
            webviewObj.pageTitle = "\(Utility.shared.getLanguage()?.value(forKey: "trustandsafety") ?? "Trust & Safety")"
                                       webviewObj.modalPresentationStyle = .fullScreen
                                      webviewObj.webviewRedirection(webviewString:SAFETY_URL)
                                       self.present(webviewObj, animated: true, completion: nil)
        }
    }

}
