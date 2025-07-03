
import Foundation
import UIKit
import Apollo

extension UICollectionViewFlowLayout {
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
}

class TopCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
        self.apiCalling()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.configureCollectionView()
        
    }
    
    var onScroll: ((UIScrollView) -> Void)?
    var stopScroll: ((CGFloat, CGFloat) -> Void)?
    var apiCall: ((NSMutableArray) -> ())?
    
    var currentIndex: Int = -1
    var isManualScrolling = false
    var shouldHideUnderlines = false
    
    var myArray = NSMutableArray()
    
    var apollo_headerClient:ApolloClient!
    var getRoomTypeArray = [GetRoomTypeSettingsQuery.Data.GetRoomTypeSetting.Result?]()
    
    var stepValue = 0
    var selectedIndex = 0
    lazy var myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    @IBInspectable var whichStep : Int = 0 {
        didSet(value){
            self.stepValue = value
        }
    }
    
    @IBInspectable var selectedViewIndex : Int = 0 {
        didSet(value){
            print("values::", value)
            self.selectedIndex = value
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureCollectionView()
    }
    
    
    fileprivate func configureCollectionView(){
        self.myCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.myCollectionView.backgroundColor = UIColor.clear
        self.myCollectionView.showsVerticalScrollIndicator = false
        self.myCollectionView.showsHorizontalScrollIndicator = false
        self.myCollectionView.register(UINib(nibName: "TopCollectioViewCell", bundle: nil), forCellWithReuseIdentifier: "TopCollectioViewCell")
        self.myCollectionView.delegate = self
        self.myCollectionView.dataSource = self
        self.addSubview(myCollectionView)
        NSLayoutConstraint.activate([
            self.myCollectionView.topAnchor.constraint(equalTo: topAnchor),
            self.myCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.myCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.myCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        if(Utility.shared.isRTLLanguage()){
            self.myCollectionView.semanticContentAttribute = .forceRightToLeft
        }else{
            self.myCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        self.myCollectionView.reloadData()
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getRoomTypeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemName = self.getRoomTypeArray[indexPath.row]?.itemName ?? ""
        return CGSize(width: itemName.size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width + 14, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCollectioViewCell", for: indexPath) as! TopCollectioViewCell
        cell.nameLbl.text = getRoomTypeArray[indexPath.row]?.itemName ?? ""
        
        if let image = getRoomTypeArray[indexPath.row]?.image as? String {
            cell.topImg.sd_setImage(with: URL(string:"\(amenitiesIcons)\(String(describing: image))"), placeholderImage: UIImage(named: "amenitiesImage"), completed: { image, error, cacheType, imageURL in
                cell.topImg.image = image?.withRenderingMode(.alwaysTemplate)
            })
        } else {
            cell.topImg.image = UIImage(named: "amenitiesImage")!.withRenderingMode(.alwaysTemplate)
        }
        
        if Utility.shared.currentIndex == 0 {
            if currentIndex == 0 {
                cell.showUnderline(index: indexPath.row, currentIndex: 0)
            } else {
                cell.showUnderline(index: indexPath.row, currentIndex: -1)
            }
        } else {
            print("Index :: Value:::", currentIndex)
            cell.showUnderline(index: indexPath.row, currentIndex: currentIndex)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        Utility.shared.currentIndex = currentIndex
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        Utility.shared.roomtypeArray.removeAllObjects()
        print("Count::::", getRoomTypeArray[indexPath.row]?.id)
        Utility.shared.roomtypeArray.add(getRoomTypeArray[indexPath.row]?.id ?? 0)
        apiCall?(Utility.shared.roomtypeArray)
      
        isManualScrolling = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            collectionView.delegate = self
            self.isManualScrolling = false
        }
    }
}


extension TopCollectionView {
    func apiCalling() {
        apollo_headerClient = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken() ?? "")"] // Replace `<token>`
            let url = URL(string:graphQLEndpoint)!  
            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()
        let profileQuery = GetRoomTypeSettingsQuery()
        apollo_headerClient.fetch(query: profileQuery) { [self] (result,error) in
            guard let roomtype = result?.data?.getRoomTypeSettings?.results else { return }
            print("Valuesss:::", roomtype)
            getRoomTypeArray = roomtype
            configureCollectionView()
        }
    }
}


extension String{
    func width1() -> CGFloat {
        let label = UILabel()
        label.frame = CGRect.zero
        label.textAlignment = .center
        label.text = self
        return (label.intrinsicContentSize.width * 1.2) < 75 ? 75 : (label.intrinsicContentSize.width * 1.2)
    }
}

