

import UIKit

class HouseRulesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var houseTitleLabel: UILabel!
    
    @IBOutlet weak var houseTV: UITableView!
    @IBOutlet weak var topView: UIView!
    var titleString = ""
    var houserulesArray = [ViewListingDetailsQueryy.Data.ViewListing.Result.HouseRule]()
    var safetyAmeneties = [ViewListingDetailsQueryy.Data.ViewListing.Result.UserSafetyAmenity]()
    var beds = [ViewListingDetailsQueryy.Data.ViewListing.Result.UserBedsType?]()
    var ameneties = [ViewListingDetailsQueryy.Data.ViewListing.Result.UserAmenity]()
    var spaces =  [ViewListingDetailsQueryy.Data.ViewListing.Result.UserSpace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        self.view.backgroundColor = UIColor(named: "colorController")

    }
    func initialSetup()
    {
    houseTitleLabel.text = titleString
    houseTV.register(UINib(nibName: "AmenityDetailCell", bundle: nil), forCellReuseIdentifier: "AmenityDetailCell")
        houseTitleLabel.textColor =  UIColor(named: "Title_Header")
        
    houseTitleLabel.font = UIFont(name: APP_FONT_MEDIUM, size: 24)
        houseTitleLabel.textAlignment = Utility.shared.isRTLLanguage() ? .right : .left
   
        
    }

    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if houseTitleLabel.text == "\(Utility.shared.getLanguage()?.value(forKey: "whatplaceoffer") ?? "What the place offer")"{
            return ameneties.count
        }
        else if houseTitleLabel.text == "\(Utility.shared.getLanguage()?.value(forKey: "userspace") ?? "Shared spaces")"{
            return spaces.count
        }
        else if houseTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"usersafety"))!)"{
            return safetyAmeneties.count
        }
        else if houseTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"bedtypes"))!)"{
            return beds.count
        }
        return houserulesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "AmenityDetailCell", for: indexPath)as! AmenityDetailCell
        cell.selectionStyle = .none
        if(Utility.shared.isRTLLanguage()) {
        cell.amenityImage.performRTLTransform()
        }
        
        if houseTitleLabel.text == "\(Utility.shared.getLanguage()?.value(forKey: "whatplaceoffer") ?? "What the place offer")" {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.ameneties[indexPath.row].itemName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            
            if let imageName = self.ameneties[indexPath.row].image{
                cell.amenityImage.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageName))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                   cell.amenityImage.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.amenityImage.image = UIImage(named: "amenitiesImage")
            }
            cell.amenityImage.tintColor =  UIColor(named: "Title_Header")
            cell.amenityImgLeading.constant = 15
            cell.amenityLblLeadingConstraint.constant = 12
            return cell
        }else if houseTitleLabel.text == "\(Utility.shared.getLanguage()?.value(forKey: "userspace") ?? "Shared spaces")"{
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.spaces[indexPath.row].itemName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            if(Utility.shared.isRTLLanguage()) {
            cell.amenityImage.performRTLTransform()
            }
            if let imageName = self.spaces[indexPath.row].image{
                cell.amenityImage.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageName))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                   cell.amenityImage.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.amenityImage.image = UIImage(named: "amenitiesImage")
            }
            cell.amenityImage.tintColor =  UIColor(named: "Title_Header")
            cell.amenityImgLeading.constant = 15
            cell.amenityLblLeadingConstraint.constant = 12
             return cell
        } else if houseTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"usersafety"))!)"{
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.safetyAmeneties[indexPath.row].itemName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            if let imageName = self.safetyAmeneties[indexPath.row].image{
                cell.amenityImage.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: imageName))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                   cell.amenityImage.image = image?.withRenderingMode(.alwaysTemplate)
                })
            }else{
                cell.amenityImage.image = UIImage(named: "amenitiesImage")
            }
            cell.amenityImage.tintColor =  UIColor(named: "Title_Header")
            cell.amenityImgLeading.constant = 15
            cell.amenityLblLeadingConstraint.constant = 12
             return cell
        }
        else if houseTitleLabel.text == "\((Utility.shared.getLanguage()?.value(forKey:"bedtypes"))!)"{
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            if let itemName = self.beds[indexPath.row]?.bedName{
                cell.amenityLabel.text = itemName
            }else{
                cell.amenityLabel.text = ""
            }
            if(Utility.shared.isRTLLanguage()) {
            cell.amenityImage.performRTLTransform()
            }
            cell.amenityImage.image = #imageLiteral(resourceName: "bullet")
            cell.amenityImgLeading.constant = 15
            cell.amenityLblLeadingConstraint.constant = 12
             return cell
        }
        
        
        if(Utility.shared.isRTLLanguage()) {
        cell.amenityImage.performRTLTransform()
        }
        cell.amenityLabel.text = houserulesArray[indexPath.row].itemName != nil ?  houserulesArray[indexPath.row].itemName! : ""
        cell.amenityImage.image = #imageLiteral(resourceName: "bullet")
        cell.amenityImgLeading.constant = 15
        cell.amenityLblLeadingConstraint.constant = 12
        return cell
    }
    
  

}
