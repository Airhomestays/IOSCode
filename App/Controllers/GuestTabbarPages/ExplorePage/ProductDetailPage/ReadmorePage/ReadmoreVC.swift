

import UIKit

class ReadmoreVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var readmoreTable: UITableView!
    
     var ReadmoreText = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
              titleLabel.font = UIFont(name: APP_FONT_SEMIBOLD, size: 16)
        titleLabel.textColor = UIColor(named: "Title_Header")
        self.view.backgroundColor = UIColor(named: "colorController")
        readmoreTable.estimatedRowHeight = 100.0 //you can provide any
        readmoreTable.rowHeight = UITableView.automaticDimension
        readmoreTable.register(UINib(nibName: "ReadmoreCell", bundle: nil), forCellReuseIdentifier: "ReadmoreCell")
        if IS_IPHONE_5{
            
            readmoreTable.frame = CGRect(x: 0, y:75, width: FULLWIDTH+55, height:FULLHEIGHT+25)
        } else if IS_IPHONE_XR {
            
            readmoreTable.frame = CGRect(x: 0, y:75, width: FULLWIDTH-40, height:FULLHEIGHT)
            
        }
        titleLabel.text = "\(Utility.shared.getLanguage()?.value(forKey:"Description_Title") ?? "About this listing")"
      
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadmoreCell", for: indexPath)as! ReadmoreCell
        cell.selectionStyle = .none
        if(ReadmoreText != nil)
        {
        cell.descriptionLabel.text = ReadmoreText
        } else{
        cell.descriptionLabel.text = ""
        }
        cell.descriptionLabel.sizeToFit()
        return cell
     
        
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 
}
