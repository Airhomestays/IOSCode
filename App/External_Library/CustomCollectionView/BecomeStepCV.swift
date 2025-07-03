

import Foundation
import UIKit
import SwiftUI

protocol stepsUpdateProtocol {
    func selectedPage(step:Int,selectedPageIndex:Int)
}

@IBDesignable
class BecomeStepCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    required init?(coder aDecoder:NSCoder) {
            super.init(coder:aDecoder)
        self.configureCollectionView()
        }

        override init(frame:CGRect) {
            super.init(frame:frame)
            self.configureCollectionView()
        }
    
    var stepValue = 0
    var selectedIndex = 0
    var myCollectionView: UICollectionView?
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var delegateSteps: stepsUpdateProtocol?
    
    let step1Titles = [
        "\(Utility.shared.getLanguage()?.value(forKey: "Place_type") ?? "Place type")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Capacity") ?? "Capacity")",
        "\(Utility.shared.getLanguage()?.value(forKey: "location") ?? "Location")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Map") ?? "Map")",
        "\(Utility.shared.getLanguage()?.value(forKey: "amenities") ?? "Amenities")",
        "\(Utility.shared.getLanguage()?.value(forKey: "safe_amenty") ?? "Safety amenities")",
        "\(Utility.shared.getLanguage()?.value(forKey: "userspace") ?? "Shared spaces")"
    ]
    
    let  step1imgarray = [#imageLiteral(resourceName: "placetype"),#imageLiteral(resourceName: "beds"),#imageLiteral(resourceName: "map"),#imageLiteral(resourceName: "chipsimg"),#imageLiteral(resourceName: "safetychips"),#imageLiteral(resourceName: "chipsamenties"),#imageLiteral(resourceName: "houses")]
    let  step2imgarray = [#imageLiteral(resourceName: "camera"),#imageLiteral(resourceName: "contentmarket")]
    let  step3imgarray = [#imageLiteral(resourceName: "houserule"),#imageLiteral(resourceName: "advancenotice"),#imageLiteral(resourceName: "coins"),#imageLiteral(resourceName: "discount"),#imageLiteral(resourceName: "bookingwin"),#imageLiteral(resourceName: "guestreq"),#imageLiteral(resourceName: "calendar"),#imageLiteral(resourceName: "law")]
    
    let step2Titles = [
        "\(Utility.shared.getLanguage()?.value(forKey: "Step2FirstPage") ?? "Photos")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Placeanddesc") ?? "Name and Decsription")",
    ]
    
    let step3Titles = [
        "\(Utility.shared.getLanguage()?.value(forKey: "houserules") ?? "House rules")",
        "\(Utility.shared.getLanguage()?.value(forKey: "cancellations") ?? "Cancellation policy")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Pricing") ?? "Pricing")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Discount") ?? "Discount")",
        "\(Utility.shared.getLanguage()?.value(forKey: "bookingwindow") ?? "Booking window")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Booking") ?? "Booking")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Guest_requirements") ?? "Guest requirements")",
        "\(Utility.shared.getLanguage()?.value(forKey: "Local_laws") ?? "Local_laws")",
//        "\(Utility.shared.getLanguage()?.value(forKey: "Review_guestbook") ?? "Review guestbook")",
//
//        "\(Utility.shared.getLanguage()?.value(forKey: "bookingwindow") ?? "Booking window")",
        
       
      
        
    ]
    
    @IBInspectable var whichStep : Int = 0 {
        didSet(value){
            self.stepValue = value
        }
    }
    
    @IBInspectable var selectedViewIndex : Int = 0 {
        didSet(value){
            self.selectedIndex = value
        }
    }
    
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureCollectionView()
    }
    
    fileprivate func configureCollectionView(){
        self.backgroundColor = UIColor.clear

        
        layout.scrollDirection = .horizontal
        
        self.myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        self.myCollectionView?.backgroundColor = UIColor.clear
        self.myCollectionView?.showsVerticalScrollIndicator = false
        self.myCollectionView?.showsHorizontalScrollIndicator = false
        self.myCollectionView?.register(UINib(nibName: "BecomeHostStepTitleCell", bundle: nil), forCellWithReuseIdentifier: "becomeHostStepTitleCell")
        self.myCollectionView?.delegate = self
        self.myCollectionView?.dataSource = self
        
        self.addSubview(myCollectionView ?? UICollectionView())
        
        self.myCollectionView?.reloadData()
        
    }
    func toBeCheck(){
        self.myCollectionView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        if(Utility.shared.isRTLLanguage()){
            self.myCollectionView?.semanticContentAttribute = .forceRightToLeft
        }else{
            self.myCollectionView?.semanticContentAttribute = .forceLeftToRight
        }
        self.myCollectionView?.scrollToItem(at: IndexPath(row: self.selectedIndex, section: 0), at: Utility.shared.isRTLLanguage() ? .right : .left, animated: false)
    }
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if stepValue == 1{
            return step1Titles.count
        }else if stepValue == 2{
            return step2Titles.count
        }else if stepValue == 3{
            return step3Titles.count
        }else{
            return 0
        }
     }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if stepValue == 1{
            return CGSize(width: 20 + self.step1Titles[indexPath.row].width(), height:45)
        }else if stepValue == 2{
            if(indexPath.row == 0){
                return CGSize(width: 15 + self.step2Titles[indexPath.row].width(), height: 45)
            }
            return CGSize(width: self.step2Titles[indexPath.row].width()-20, height: 45)
        }else if stepValue == 3{
            return CGSize(width: 20 + self.step3Titles[indexPath.row].width(), height:45)
        }else{
            return CGSize(width:200, height:38)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "becomeHostStepTitleCell", for: indexPath) as! BecomeHostStepTitleCell
        
        if self.stepValue == 1{
            cell.lblTitle.text = self.step1Titles[indexPath.row]
            cell.imgBtn.setImage(self.step1imgarray[indexPath.row] , for: .normal)
            //cell.imgBtn.imageView?.tintColor = UIColor(named: "Title_Header")
        }else if self.stepValue == 2{
            cell.lblTitle.text = self.step2Titles[indexPath.row]
            cell.imgBtn.setImage(self.step2imgarray[indexPath.row] , for: .normal)
            //cell.imgBtn.imageView?.tintColor = UIColor(named: "Title_Header")
        }else{
            cell.lblTitle.text = self.step3Titles[indexPath.row]
            cell.imgBtn.setImage(self.step3imgarray[indexPath.row] , for: .normal)
          //  cell.imgBtn.imageView?.tintColor = UIColor(named: "Title_Header")
        }
        
        if indexPath.row == self.selectedIndex{
            cell.lblTitle.textColor =  UIColor(named: "cellColor")
            cell.lineBorderView.backgroundColor = Theme.btnbgsteps
            cell.imgBtn.backgroundColor = Theme.becomeAHostStep_Color
            cell.lineBorderView.layer.borderColor = Theme.PRIMARY_COLOR.cgColor
            cell.imgBtn.layer.shadowRadius = 3.0;
            cell.imgBtn.layer.shadowColor = UIColor.gray.cgColor
            cell.imgBtn.layer.masksToBounds = false
            cell.imgBtn.layer.shadowOffset = CGSize(width :0.0, height:1.0);
            cell.imgBtn.layer.shadowOpacity = 0.5;
        }else{
            cell.lblTitle.textColor =  UIColor(named: "Title_Header")
            cell.imgBtn.borderColor =   Theme.Review_Page_Line_Color
            cell.imgBtn.borderWidth = 2
            cell.lineBorderView.backgroundColor = UIColor(named: "colorController")
            cell.imgBtn.backgroundColor = Theme.becomeAHostStep_Color
            cell.imgBtn.layer.shadowRadius = 3.0;
            cell.imgBtn.layer.shadowColor = UIColor.gray.cgColor
            cell.imgBtn.layer.shadowOffset = CGSize(width :0.0, height:1.0);
            cell.imgBtn.layer.shadowOpacity = 0.5;
            cell.imgBtn.layer.masksToBounds = false
            cell.lineBorderView.layer.borderColor = UIColor(named: "Review_Page_Line_Color")?.cgColor
        }
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegateSteps?.selectedPage(step: self.stepValue, selectedPageIndex: indexPath.row)
    }
}

extension String{
    func width() -> CGFloat {
        
        
        let label = UILabel()
        label.frame = CGRect.zero
        label.textAlignment = .center
        label.font = UIFont(name: APP_FONT, size: 14.0)
        label.text = self
        
        return (label.intrinsicContentSize.width * 1.7) < 100 ? 100 : (label.intrinsicContentSize.width * 1.7)
        }
}
