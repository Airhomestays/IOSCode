

import UIKit
import Apollo
import Lottie
class ReportuserPage: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var topview: UIView!
    @IBOutlet var reportuserTable: UITableView!
    
    
    @IBOutlet var backBtn: UIButton!
    
    @IBOutlet weak var pageTitleLabel: UILabel!
    var selectedArray = [String]()
    var reportType = String()
     var lottieView: LottieAnimationView!
    var isfromreview:Bool = false
    
    let apollo_headerClient: ApolloClient = {
        let configuration = URLSessionConfiguration.default
       
        configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken()!)"] 
        let url = URL(string:graphQLEndpoint)!
        
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        
    }()
    var reportAPIArray = [String]()
    var profileid = Int()
    
    var reportcontentArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =   UIColor(named: "colorController")
        self.backBtn.setImage(UIImage(named: "left_arrow"), for: .normal)
        self.backBtn.setTitle("", for: .normal)
        self.backBtn.backgroundColor = Theme.ButtonBack_BG
        self.backBtn.layer.cornerRadius = self.backBtn.frame.size.height/2
        self.backBtn.clipsToBounds = true
        
        if Utility.shared.isRTLLanguage(){
            self.backBtn.rotateImageViewofBtn()
        }
        
        self.pageTitleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey: "Report") ?? "Report")"
        self.pageTitleLabel.textColor = UIColor(named: "Title_Header")
        self.pageTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
        self.pageTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 18)
        
      self.registerCell()
        reportuserTable.estimatedRowHeight = 50
        reportuserTable.rowHeight = UITableView.automaticDimension
       
        reportcontentArray = ["\((Utility.shared.getLanguage()?.value(forKey:"shoudnotavailable"))!)","\((Utility.shared.getLanguage()?.value(forKey:"attemptinfo"))!)","\((Utility.shared.getLanguage()?.value(forKey:"inappropriatespam"))!)"]
        reportAPIArray = ["shouldnt_available","direct_contact","spam"]
        saveBtn.layer.cornerRadius = saveBtn.frame.size.height/2
        saveBtn.layer.masksToBounds = true
        lottieView = LottieAnimationView.init(name: "animation_white")
        saveBtn.isEnabled = false
        saveBtn.backgroundColor = Theme.Button_BG
        self.saveBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Report") ?? "Report")", for: .normal)
        saveBtn.titleLabel?.font = UIFont(name: APP_FONT_MEDIUM, size: 16)
      
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func saveBtnTapped(_ sender: Any) {
        if Utility().isConnectedToNetwork(){
       
      self.reportUserAPICall(reportType: reportType, profileid: profileid)
        
        }
        else
        {
            self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
            
        }
    }
    
    func registerCell()
    {
        reportuserTable.register(UINib(nibName: "ReportuserheaderCell", bundle: nil), forCellReuseIdentifier: "ReportuserheaderCell")
        reportuserTable.register(UINib(nibName: "ReportuserSelectionCell", bundle: nil), forCellReuseIdentifier: "ReportuserSelectionCell")
       
    }
    func lottieanimation()
    {
        saveBtn.setTitle("", for:.normal)
        lottieView = LottieAnimationView.init(name: "animation_white")
        
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:saveBtn.frame.size.width/2-60, y:-25, width:100, height:100)
        self.saveBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.3, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    func lottienextAnimation()
    {
        lottieView = LottieAnimationView.init(name: "animation_white")
        self.lottieView.isHidden = false
        self.lottieView.frame = CGRect(x:saveBtn.frame.size.width/2-50, y:-30, width:100, height:100)
        self.lottieView.backgroundColor = .red
        saveBtn.addSubview(self.lottieView)
        self.lottieView.backgroundColor = UIColor.clear
        saveBtn.setTitle("", for:.normal)
        self.lottieView.play()
        Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(autoscroll), userInfo: nil, repeats: true)
    }
    @objc func autoscroll()
    {
       self.lottieView.play()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportuserheaderCell", for: indexPath)as! ReportuserheaderCell
            if(isfromreview){
                cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"doyoureportuser"))!)"
            }
            else {
                cell.titleLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"doyoureport"))!)"
            }
            cell.selectionStyle = .none
            return cell
        }
        else if(indexPath.section == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportuserSelectionCell", for: indexPath)as! ReportuserSelectionCell
            cell.selectionStyle = .none
            cell.reportuserLabel.text = reportcontentArray[indexPath.section-1]
            if(selectedArray.contains(reportcontentArray[indexPath.section-1]))
            {
                cell.selectionImg.image = #imageLiteral(resourceName: "verify-round")
               
            }
            else
            {
             cell.selectionImg.image = #imageLiteral(resourceName: "price_unclick")
            }
            return cell
        }
        else if(indexPath.section == 2)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportuserSelectionCell", for: indexPath)as! ReportuserSelectionCell
          cell.reportuserLabel.text = reportcontentArray[indexPath.section-1]
            if(selectedArray.contains(reportcontentArray[indexPath.section-1]))
            {

                cell.selectionImg.image = #imageLiteral(resourceName: "verify-round")
            } else {
                cell.selectionImg.image = #imageLiteral(resourceName: "price_unclick")
            }
            cell.selectionStyle = .none
            return cell
            
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportuserSelectionCell", for: indexPath)as! ReportuserSelectionCell
            cell.reportuserLabel.text = reportcontentArray[indexPath.section-1]
            if(selectedArray.contains(reportcontentArray[indexPath.section-1]))
            {
                cell.selectionImg.image = #imageLiteral(resourceName: "verify-round")

            } else {
                cell.selectionImg.image = #imageLiteral(resourceName: "price_unclick")
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if Utility().isConnectedToNetwork(){
            if(indexPath.section > 0)
            {
        if(selectedArray.contains(reportcontentArray[indexPath.section-1]))
        {
            saveBtn.isEnabled = false
            saveBtn.backgroundColor = Theme.Button_BG
          selectedArray.removeAll()
        } else {
            selectedArray.removeAll()
            selectedArray.append(reportcontentArray[indexPath.section-1])
            reportType = reportAPIArray[indexPath.section-1]
                saveBtn.isEnabled = true
                saveBtn.backgroundColor = Theme.Button_BG
        }
        reportuserTable.reloadData()
            }
        } else {
           self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"error_field"))!)")
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0) {
            return UITableView.automaticDimension
        }
        return 60
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func reportUserAPICall(reportType:String,profileid:Int)
    {
        self.lottienextAnimation()
        let reportuserMutation = CreateReportUserMutation(reporterId:Utility.shared.getCurrentUserID()! as String, reportType: reportType, profileId:profileid)
        apollo_headerClient.perform(mutation: reportuserMutation){(result,error) in
            
            self.lottieView.isHidden = true
            if (result?.data?.createReportUser?.status == 200)
                
            {
                self.lottieView.isHidden = true
                self.saveBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Report") ?? "Report")", for: .normal)
                self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"reportalert"))!)")
           
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                 
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                self.lottieView.isHidden = true
                self.saveBtn.setTitle("\(Utility.shared.getLanguage()?.value(forKey: "Report") ?? "Report")", for: .normal)
                self.view.makeToast(result?.data?.createReportUser?.errorMessage)
              
            }
            
    
            
        }
        
        
    }
    

}
