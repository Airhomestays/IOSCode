
import UIKit
import SwiftMessages
import SwiftUI
import CoreML
import SwiftyJSON
import Apollo

public protocol AirbnbDatePickerDelegate {
    func datePickerController(_ datePickerController: AirbnbDatePickerViewController, didSaveStartDate startDate: Date?, endDate: Date?)
}

public class AirbnbDatePickerViewController: UICollectionViewController {
    
    let monthHeaderID = "monthHeaderID"
    let cellID = "cellID"
    let dateFormatter = DateFormatter()
    var isblockedDate_Contain:Bool = false
    var isnextMonthCalled:Bool = false
    var delegate: AirbnbDatePickerDelegate?
    var numberofnights = Int()
    var isRemoveSelectedDate :Bool = false
    var isFromFilter: Bool = false
    var isFromEdit: Bool = false
    var isFirstTime : Bool = true
    var isFirstTimeLoaded : Bool = true
    var endDateSelected : Bool = false
    var selectedStartDate: Date? {
        didSet {
            headerView.selectedStartDate = selectedStartDate
            footerView.isSaveEnabled = (selectedStartDate == nil || selectedEndDate != nil)
        }
    }
    var startDateIndexPath: IndexPath?
    var selectedEndDate: Date? {
        didSet {
            headerView.selectedEndDate = selectedEndDate
            footerView.isSaveEnabled = (selectedStartDate == nil || selectedEndDate != nil)
        }
    }
    
    var Blocked_Selected_String:String?
    {
        didSet {
            footerView.minimumbookLabel.text = Blocked_Selected_String
            
        }
    }
    var isStartSelectedBlocked = false
    var selctedDatesCountArray = NSMutableArray()
    var endDateIndexPath: IndexPath?
    var today: Date!
    var calendar: Calendar {
        return Utility.calendar
    }
    
    var isLoadingMore = true
    var initialNumberOfMonths = 36
    var subsequentMonthsLoadCount = 12
    var lastNthMonthBeforeLoadMore = 12
    var index = 0
    
    var months: [Date]!
    var days: [(days: Int, prepend: Int, append: Int)]!
    
    var itemWidth: CGFloat {
        return floor(view.frame.size.width / 7)
    }
    var collectionViewWidthConstraint: NSLayoutConstraint?
    var viewListingArray = ViewListingDetailsQueryy.Data.ViewListing.Result()
    
    var isSelectedstartDate  = Bool()
    
  
    convenience init(dateFrom: Date?, dateTo: Date?) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        today = Date()
        initDates()
        
    
        ({ selectedStartDate = dateFrom })()
        ({ selectedEndDate = dateTo })()
        
        if selectedStartDate != nil && startDateIndexPath == nil {
            startDateIndexPath = findIndexPath(forDate: selectedStartDate!)
            if let indexPath = startDateIndexPath {
                collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
        }
        
        if self.selectedEndDate != nil && self.endDateIndexPath == nil {
            self.endDateIndexPath = self.findIndexPath(forDate: self.selectedEndDate!)
            if let indexPath = self.endDateIndexPath {
                self.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                
            }
        }
        if !isFromFilter {
            if selectedEndDate != nil && selectedStartDate != nil {
                if(Utility.shared.numberofnights_Selected == 1)
                {
                    Blocked_Selected_String = "\(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                }
                else{
                    Blocked_Selected_String = "\(Utility.shared.numberofnights_Selected) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                    footerView.isSaveEnabled = true
                }
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AirbnbDatePickerViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func initDates() {
        let month = calendar.component(.month, from: today)
        let year = calendar.component(.year, from: today)
        var dateComp = DateComponents(year: year, month: month, day: 1)
        var curMonth = calendar.date(from: dateComp)
        
        months = [Date]()
        days = [(days: Int, prepend: Int, append: Int)]()
        
        for _ in 0..<initialNumberOfMonths {
            months.append(curMonth!)
            
            let numOfDays = calendar.range(of: .day, in: .month, for: curMonth!)!.count
            let firstWeekDay = calendar.component(.weekday, from: curMonth!.startOfMonth())
            let lastWeekDay = calendar.component(.weekday, from: curMonth!.endOfmonth())
         
            days.append((days: numOfDays, prepend: firstWeekDay-1, append: 7 ))
            
            curMonth = calendar.date(byAdding: .month, value: 1, to: curMonth!)
            
        }
        
        
    }
    
    lazy var dismissButton: UIBarButtonItem = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setImage(UIImage(named: "close-black", in: Bundle(for: AirbnbDatePicker.self), compatibleWith: nil), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        btn.addTarget(self, action: #selector(AirbnbDatePickerViewController.handleDismiss), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: btn)
        return barBtn
    }()
    
    lazy var clearButton: UIBarButtonItem = {
        let btn = UIButton(type: UIButton.ButtonType.custom)
        btn.setTitle("\((Utility.shared.getLanguage()?.value(forKey:"clear"))!)", for: .normal)
        btn.setTitleColor(Theme.PRIMARY_COLOR, for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        if(Utility.shared.isRTLLanguage()) {
            btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left } else {
                btn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
                
            }
        btn.titleLabel?.font = UIFont(name: APP_FONT, size: 16.0)
        
        btn.addTarget(self, action: #selector(AirbnbDatePickerViewController.handleClearInput), for: .touchUpInside)
        let barBtn = UIBarButtonItem(customView: btn)
        return barBtn
    }()
    
    var headerView: AirbnbDatePickerHeader = {
        let view = AirbnbDatePickerHeader()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        return view
    }()
    
    var headerSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var footerView: AirbnbDatePickerFooter = {
        let view = AirbnbDatePickerFooter()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        view.delegate = self
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowOpacity = 0.4
        return view
    }()
    
    var footerSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    
  
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        
        setupNavigationBar()
        setupViews()
        setupLayout()
        
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if  isFirstTime {
            isFirstTime = false
            if self.selectedEndDate != nil {
                self.endDateIndexPath = self.findIndexPath(forDate: self.selectedEndDate!)
                if let indexPath = self.endDateIndexPath {
                   
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated:false)
                   
                }
            }
        }
    }
    
    @objc func rotated() {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor(named: "becomeAHostStep_Color")
        self.navigationItem.setLeftBarButton(dismissButton, animated: true)
        self.navigationItem.setRightBarButton(clearButton, animated: true)
    }
    
    
    func setupViews() {
        setupHeaderView()
        setupFooterView()
        setupCollectionView()
    }
    
    func setupHeaderView() {
        view.addSubview(headerView)
        
        headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.navigationController != nil ? self.navigationController!.navigationBar.frame.size.height : 0).isActive = true
        headerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        view.addSubview(headerSeparator)
        
        headerSeparator.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        headerSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerSeparator.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        headerSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func setupCollectionView() {
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(named: "colorController")
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.allowsMultipleSelection = true
        
        collectionView?.register(AirbnbDatePickerCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.register(AirbnbDatePickerMonthHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: monthHeaderID)
        
        collectionView?.topAnchor.constraint(equalTo: headerSeparator.bottomAnchor).isActive = true
        collectionView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: footerSeparator.topAnchor).isActive = true
        
        let gap = view.frame.size.width - (itemWidth * 7)
        collectionViewWidthConstraint = collectionView?.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -gap)
        collectionViewWidthConstraint?.isActive = true
        
        collectionView.semanticContentAttribute = Utility.shared.isRTLLanguage() ? .forceRightToLeft : .forceLeftToRight
        
    }
    
    func setupLayout() {
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets()
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
            layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50)
            
            
        }
    }
    
    func setupFooterView() {
        view.addSubview(footerView)
        
        footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        footerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        footerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(footerSeparator)
        
        footerSeparator.bottomAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        footerSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        footerSeparator.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        footerSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return months.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(days[section].prepend == 7) {
            return days[section].days + days[section].append
        }
        return days[section].prepend + days[section].days
    }
    
    override public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    
        if indexPath.section == (months.count - lastNthMonthBeforeLoadMore) && !isLoadingMore {
            let originalCount = months.count
            isLoadingMore = true
            
            DispatchQueue.global(qos: .background).async {
                self.loadMoreMonths(completion: {
                    () in
                    DispatchQueue.main.async {
                        collectionView.performBatchUpdates({
                            () in
                            let range = originalCount..<originalCount.advanced(by: self.subsequentMonthsLoadCount)
                            let indexSet = IndexSet(integersIn: range)
                            collectionView.insertSections(indexSet)
                            
                        }, completion: {
                            (res) in
                            self.isLoadingMore = false
                        })
                    }
                })
            }
        }
        
        
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: monthHeaderID, for: indexPath) as! AirbnbDatePickerMonthHeader
        
        let monthData = months[indexPath.section]
        let curYear = calendar.component(.year, from: today)
        let year = calendar.component(.year, from: monthData)
        let month = calendar.component(.month, from: monthData)
        dateFormatter.locale = NSLocale(localeIdentifier:Utility.shared.getAppLanguageCode()!) as Locale
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateStr = "\(dateFormatter.monthSymbols[month - 1])"
    
        header.monthLabel.text = "\(dateStr.firstCapitalized) \(year)"
       
        return header
        
    }
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AirbnbDatePickerCell
        if isFromFilter {
            cell.isFromFilter = true
        }
        configure(cell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: FULLWIDTH-40, height: 50)
    }
    
 
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isFromFilter {
            let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
            cell.type.insert(.Selected)
            
            let selectedMonth = months[indexPath.section]
            
            if (cell.type.contains(.disableCheckInDate)){
                Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The chosen date is unavailable for check-in.")"
                isStartSelectedBlocked = true
            }
            
            if(Utility.shared.minimumstay != 0)
            {
                
                if Utility.shared.minimumstay > 1{
                    footerView.minimumbookLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(Utility.shared.minimumstay) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                }else{
                    footerView.minimumbookLabel.text = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(Utility.shared.minimumstay) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                }
            }
            
            let year = calendar.component(.year, from: selectedMonth)
            let month = calendar.component(.month, from: selectedMonth)
            
            var dateComp = DateComponents(year: year, month: month, day: Int(cell.dateLabel.text!))
            let blocked_Find_Date = "\(cell.dateLabel.text!)-\(month)-\(year)"
            let selectedDate = calendar.date(from: dateComp)!
            
            if(selctedDatesCountArray.count == 0 && ( selectedStartDate != nil && selectedEndDate == nil)){
                let prevStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell
                prevStartCell?.type.remove(.Selected)
                prevStartCell?.configureCell()
                collectionView.deselectItem(at: startDateIndexPath!, animated: false)
                
            }
            
            
            if selectedStartDate == nil || (selectedEndDate == nil && selectedDate < selectedStartDate!) {
                if startDateIndexPath != nil, let prevStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                    prevStartCell.type.remove(.Selected)
                    prevStartCell.configureCell()
                    collectionView.deselectItem(at: startDateIndexPath!, animated: false)
                }
                
                if (cell.type.contains(.disableCheckInDate)){
                    Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The chosen date is unavailable for check-in.")"
                    isStartSelectedBlocked = true
                }else{
                    isStartSelectedBlocked = false
                }
                
                selectedStartDate = selectedDate
                startDateIndexPath = indexPath
                
            } else if selectedEndDate == nil && selectedDate > selectedStartDate! {
                
                
                if startDateIndexPath != nil, let cellNewOne = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell{
                    
                    if (cellNewOne.type.contains(.disableCheckInDate)){
                        
                        cellNewOne.type.remove(.Selected)
                        cellNewOne.configureCell()
                        collectionView.deselectItem(at: startDateIndexPath!, animated: false)
                        
                        deselectSelectedCells()
                        
                        selectedStartDate = selectedDate
                        selectedEndDate = nil
                        
                        startDateIndexPath = indexPath
                        endDateIndexPath = nil
                        
                        if (cell.type.contains(.disableCheckInDate)){
                            Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The selected date is available for checkout only")"
                            isStartSelectedBlocked = true
                        }else{
                            isStartSelectedBlocked = false
                        }
                        
                        if let newStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                            newStartCell.type.insert(.Selected)
                            newStartCell.configureCell()
                        }
                    }else{
                        selectedEndDate = selectedDate
                        endDateIndexPath = indexPath
                    
                        if let startCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                            startCell.type.insert(.SelectedStartDate)
                            startCell.configureCell()
                        }
                        
                     
                        if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                            if(Utility.shared.isfromcheckingPage)
                            {
                                var date = selectedStartDate
                                let endDate = selectedEndDate
                                let fmt = DateFormatter()
                              
                                fmt.dateFormat = "dd-MM-yyyy"
                                selctedDatesCountArray.removeAllObjects()
                                while date!.compare(endDate!) != .orderedDescending {
                                    
                                    if(Utility.shared.blocked_date_month.contains(fmt.string(from: date!)))
                                    {
                                        isblockedDate_Contain = true
                                      
                                    }
                                    date = calendar.date(byAdding: .day, value: 1, to: date!)
                                    selctedDatesCountArray.add(fmt.string(from: date!))
                                   
                                }
                                if(!isblockedDate_Contain)
                                {
                                    if(Utility.shared.isfromcheckingPage)
                                    {
                                        let night = selctedDatesCountArray.count - 1
                                        
                                        if((viewListingArray.listingData?.minNight != 0) || (viewListingArray.listingData?.maxNight != 0) )
                                        {
                                            if(night<(viewListingArray.listingData?.minNight!)!)
                                            {
                                                
                                                if viewListingArray.listingData!.minNight! > 1 {
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"nightrequire"))!) \(viewListingArray.listingData?.minNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                                }else{
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"nightrequire"))!) \(viewListingArray.listingData?.minNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                                }
                                                footerView.isSaveEnabled = false
                                            }
                                            else if(((viewListingArray.listingData?.maxNight!)! > 0) && (night > ((viewListingArray.listingData?.maxNight!)!)))
                                            {
                                                
                                                if viewListingArray.listingData!.maxNight! > 1 {
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                                }else{
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                                }
                                                footerView.isSaveEnabled = false
                                            }
                                            else{
                                                if(night == 1)
                                                {
                                                    Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                                }
                                                else{
                                                    Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                    footerView.isSaveEnabled = true
                                                }
                                                
                                            }
                                            
                                        }
                                        else{
                                            if(night == 1)
                                            {
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                            }
                                            else{
                                                
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                footerView.isSaveEnabled = true
                                            }
                                            
                                        }
                                        numberofnights = night
                                        
                                        endCell.type.insert(.SelectedEndDate)
                                        endCell.configureCell()
                                    }
                                    else
                                    {
                                        endCell.type.insert(.SelectedEndDate)
                                        endCell.configureCell()
                                    }
                                }
                                else{
                                    footerView.isSaveEnabled = false
                                    
                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                    isblockedDate_Contain = false
                                }
                            }
                            else
                            {
                                endCell.type.insert(.SelectedEndDate)
                                endCell.configureCell()
                            }
                        }
                        
                     
                        selectInBetweenCells()
                        
                    }
                    
                }else{
                    if (isStartSelectedBlocked){
                        
                        collectionView.deselectItem(at: startDateIndexPath!, animated: false)
                        
                        deselectSelectedCells()
                        
                        selectedStartDate = selectedDate
                        selectedEndDate = nil
                        
                        startDateIndexPath = indexPath
                        endDateIndexPath = nil
                        
                        if (cell.type.contains(.disableCheckInDate)){
                            Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The chosen date is unavailable for check-in.")"
                            isStartSelectedBlocked = true
                        }else{
                            isStartSelectedBlocked = false
                        }
                        
                        if let newStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                            newStartCell.type.insert(.Selected)
                            newStartCell.configureCell()
                        }
                    }else{
                        selectedEndDate = selectedDate
                        endDateIndexPath = indexPath
                       
                        if let startCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                            startCell.type.insert(.SelectedStartDate)
                            startCell.configureCell()
                        }
                      
                        if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                            if(Utility.shared.isfromcheckingPage)
                            {
                                var date = selectedStartDate
                                let endDate = selectedEndDate
                                let fmt = DateFormatter()
                               
                                fmt.dateFormat = "dd-MM-yyyy"
                                selctedDatesCountArray.removeAllObjects()
                                while date!.compare(endDate!) != .orderedDescending {
                                    
                                    if(Utility.shared.blocked_date_month.contains(fmt.string(from: date!)))
                                    {
                                        isblockedDate_Contain = true
                                      
                                    }
                                    date = calendar.date(byAdding: .day, value: 1, to: date!)
                                    selctedDatesCountArray.add(fmt.string(from: date!))
                                   
                                }
                                if(!isblockedDate_Contain)
                                {
                                    if(Utility.shared.isfromcheckingPage)
                                    {
                                        let night = selctedDatesCountArray.count - 1
                                        
                                        if((viewListingArray.listingData?.minNight != 0) || (viewListingArray.listingData?.maxNight != 0) )
                                        {
                                            if(night<(viewListingArray.listingData?.minNight!)!)
                                            {
                                                
                                                if viewListingArray.listingData!.minNight! > 1 {
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(viewListingArray.listingData?.minNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                                }else{
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(viewListingArray.listingData?.minNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                                }
                                                footerView.isSaveEnabled = false
                                            }
                                            else if(((viewListingArray.listingData?.maxNight!)! > 0) && (night > ((viewListingArray.listingData?.maxNight!)!)))
                                            {
                                                
                                                if viewListingArray.listingData!.maxNight! > 1 {
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                                                }else{
                                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                                                }
                                                footerView.isSaveEnabled = false
                                            }
                                            else{
                                                if(night == 1)
                                                {
                                                    Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                                }
                                                else{
                                                    Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                    footerView.isSaveEnabled = true
                                                }
                                                
                                            }
                                            
                                        }
                                        else{
                                            if(night == 1)
                                            {
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                            }
                                            else{
                                                
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                footerView.isSaveEnabled = true
                                            }
                                            
                                        }
                                        numberofnights = night
                                        
                                        endCell.type.insert(.SelectedEndDate)
                                        endCell.configureCell()
                                    }
                                    else
                                    {
                                        endCell.type.insert(.SelectedEndDate)
                                        endCell.configureCell()
                                    }
                                }
                                else{
                                    footerView.isSaveEnabled = false
                                    
                                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                    isblockedDate_Contain = false
                                }
                            }
                            else
                            {
                                endCell.type.insert(.SelectedEndDate)
                                endCell.configureCell()
                            }
                        }
                        
                      
                        selectInBetweenCells()
                    }
                    
                    
                }
                
                
                
                
            } else {
                
              
                deselectSelectedCells()
                
                selectedStartDate = selectedDate
                selectedEndDate = nil
                
                startDateIndexPath = indexPath
                endDateIndexPath = nil
                
                if (cell.type.contains(.disableCheckInDate)){
                    Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The chosen date is unavailable for check-in.")"
                    isStartSelectedBlocked = true
                }else{
                    isStartSelectedBlocked = false
                }
                
                if let newStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                    newStartCell.type.insert(.Selected)
                    newStartCell.configureCell()
                }
                
            }
            
            cell.configureCell()
            
        }
        
        else {
          
            if endDateSelected && !isFirstTimeLoaded && selectedStartDate != selectedEndDate {
                self.handleClearInput()
                isFirstTimeLoaded = false
                endDateSelected = false
            }
            else {
                isFirstTimeLoaded = false
                
                if isFromEdit {
                    isFromEdit = false
                    self.handleClearInput()
                    isFirstTimeLoaded = false
                    endDateSelected = false
                }
            }
          
            let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
            cell.type.insert(.Selected)
            
            let selectedMonth = months[indexPath.section]
            
            
            
            if (cell.type.contains(.disableCheckInDate)){
                Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The chosen date is unavailable for check-in.")"
                isStartSelectedBlocked = true
            }
            
         
            
            isSelectedstartDate = true
            let year = calendar.component(.year, from: selectedMonth)
            let month = calendar.component(.month, from: selectedMonth)
            let blocked_Find_Date = "\(cell.dateLabel.text!)-\(month)-\(year)"
            var dateComp = DateComponents(year: year, month: month, day: Int(cell.dateLabel.text!))
            
            let selectedDate = calendar.date(from: dateComp)!
            
            if(selctedDatesCountArray.count == 0 && ( selectedStartDate != nil && selectedEndDate == nil)){
                let prevStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell
                prevStartCell?.type.remove(.Selected)
                prevStartCell?.configureCell()
                collectionView.deselectItem(at: startDateIndexPath!, animated: false)
                
            }
            
            
            if selectedStartDate == nil || (selectedEndDate == nil && selectedDate < selectedStartDate!) {
                
                if startDateIndexPath != nil, let prevStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                    prevStartCell.type.remove(.Selected)
                    prevStartCell.configureCell()
                    collectionView.deselectItem(at: startDateIndexPath!, animated: false)
                }
                
                if (cell.type.contains(.disableCheckInDate)){
                    Blocked_Selected_String = "\(Utility.shared.getLanguage()?.value(forKey: "Unavailable_CheckIn") ?? "The chosen date is unavailable for check-in.")"
                    isStartSelectedBlocked = true
                }else{
                    isStartSelectedBlocked = false
                }
                isSelectedstartDate = true
                selectedStartDate = selectedDate
                startDateIndexPath = indexPath
                
                selectInBetweenCells()
                
                
            }
            
            else if selectedEndDate == nil && selectedDate > selectedStartDate! {
                
                
                if startDateIndexPath != nil, let cellNewOne = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell{
                  
                    selectedEndDate = selectedDate
                    endDateIndexPath = indexPath
                    
                   
                    if let startCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                        startCell.type.insert(.SelectedStartDate)
                        startCell.configureCell()
                    }
                    
                  
                    if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                        if(Utility.shared.isfromcheckingPage)
                        {
                            var date = selectedStartDate
                            let endDate = selectedEndDate
                            let fmt = DateFormatter()
                            fmt.dateFormat = "dd-MM-yyyy"
                            selctedDatesCountArray.removeAllObjects()
                            while date!.compare(endDate!) != .orderedDescending {
                                
                                if(Utility.shared.blocked_date_month.contains(fmt.string(from: date!)))
                                {
                                    isblockedDate_Contain = true
                                }
                                date = calendar.date(byAdding: .day, value: 1, to: date!)
                                selctedDatesCountArray.add(fmt.string(from: date!))
                            
                            }
                            
                            if cellNewOne.type.contains(.disableCheckInDate) {
                                footerView.isSaveEnabled = false
                                endDateSelected = true
                                Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                isblockedDate_Contain = false
                                
                            }
                            else if(!isblockedDate_Contain)
                            {
                                if(Utility.shared.isfromcheckingPage)
                                {
                                    let night = selctedDatesCountArray.count - 1
                                    
                                
                                    
                                    if((viewListingArray.listingData?.minNight != 0) || (viewListingArray.listingData?.maxNight != 0) )
                                    {
                                        if(night<((viewListingArray.listingData?.minNight!)!))
                                        {
                                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(viewListingArray.listingData?.minNight! ?? 0) \(viewListingArray.listingData!.minNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")")"
                                            footerView.isSaveEnabled = false
                                        }
                                        else if(((viewListingArray.listingData?.maxNight!)! > 0) && (night > ((viewListingArray.listingData?.maxNight!)!)))
                                        {
                                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \(viewListingArray.listingData!.maxNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")")"
                                            footerView.isSaveEnabled = false
                                        }
                                        else{
                                            if(night == 1)
                                            {
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                            }
                                            else{
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                footerView.isSaveEnabled = true
                                            }
                                            
                                        }
                                        
                                    }
                                    else{
                                        if(night == 1)
                                        {
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                        }
                                        else{
                                            
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                            footerView.isSaveEnabled = true
                                        }
                                        
                                    }
                                    numberofnights = night
                                    
                                    endCell.type.insert(.SelectedEndDate)
                                    endCell.configureCell()
                                }
                                else
                                {
                                    endCell.type.insert(.SelectedEndDate)
                                    endCell.configureCell()
                                }
                            }
                            else{
                                footerView.isSaveEnabled = false
                                endDateSelected = true
                                Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                isblockedDate_Contain = false
                            }
                        }
                        else
                        {
                            endCell.type.insert(.SelectedEndDate)
                            endCell.configureCell()
                        }
                    }
                
                    selectInBetweenCells()
            
                    
                }else{
                   
                    selectedEndDate = selectedDate
                    endDateIndexPath = indexPath
                  
                    if let startCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                        startCell.type.insert(.SelectedStartDate)
                        startCell.configureCell()
                    }
                    
                
                    if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                        if(Utility.shared.isfromcheckingPage)
                        {
                            var date = selectedStartDate
                            let endDate = selectedEndDate
                            let fmt = DateFormatter()
                            fmt.dateFormat = "dd-MM-yyyy"
                            selctedDatesCountArray.removeAllObjects()
                            while date!.compare(endDate!) != .orderedDescending {
                                
                                if(Utility.shared.blocked_date_month.contains(fmt.string(from: date!)))
                                {
                                    isblockedDate_Contain = true
                                 
                                }
                                date = calendar.date(byAdding: .day, value: 1, to: date!)
                                selctedDatesCountArray.add(fmt.string(from: date!))
                               
                            }
                            if cell.type.contains(.disableCheckInDate)  {
                                footerView.isSaveEnabled = false
                                endDateSelected = true
                                Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                isblockedDate_Contain = false
                                
                            }
                            else if(!isblockedDate_Contain)
                            {
                                if(Utility.shared.isfromcheckingPage)
                                {
                                    let night = selctedDatesCountArray.count - 1
                                    
                                  
                                    
                                    if((viewListingArray.listingData?.minNight != 0) || (viewListingArray.listingData?.maxNight != 0) )
                                    {
                                        if(night<((viewListingArray.listingData?.minNight!)!))
                                        {
                                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(viewListingArray.listingData?.minNight! ?? 0) \(viewListingArray.listingData!.minNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")")"
                                            footerView.isSaveEnabled = false
                                        }
                                        else if(((viewListingArray.listingData?.maxNight!)! > 0) && (night > ((viewListingArray.listingData?.maxNight!)!)))
                                        {
                                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \(viewListingArray.listingData!.maxNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")")"
                                            footerView.isSaveEnabled = false
                                        }
                                        else{
                                            if(month == 1)
                                            {
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                            }
                                            else{
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                footerView.isSaveEnabled = true
                                            }
                                            
                                        }
                                        
                                    }
                                    else{
                                        if(month == 1)
                                        {
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                        }
                                        else{
                                            
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                            footerView.isSaveEnabled = true
                                        }
                                        
                                    }
                                    numberofnights = night
                                    
                                    endCell.type.insert(.SelectedEndDate)
                                    endCell.configureCell()
                                }
                                else
                                {
                                    endCell.type.insert(.SelectedEndDate)
                                    endCell.configureCell()
                                }
                            }
                            else{
                                footerView.isSaveEnabled = false
                                endDateSelected = true
                                Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                isblockedDate_Contain = false
                            }
                        }
                        else
                        {
                            endCell.type.insert(.SelectedEndDate)
                            endCell.configureCell()
                        }
                    }
                  
                    selectInBetweenCells()
                   
                    
                }
                
                isSelectedstartDate = true
                
                
            }
            else if selectedEndDate == nil {
                
                isSelectedstartDate = false
                selectedEndDate = selectedDate
                endDateIndexPath = indexPath
                
              
                if let startCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                    if(selectedStartDate == nil) {
                        startCell.type.insert(.SelectedStartDate)
                        startCell.configureCell() } else {
                            
                            if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                              
                                startCell.type.insert(.SelectedStartDate)
                                startCell.configureCell()
                            }
                        }
                }
                
              
                if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                    if(Utility.shared.isfromcheckingPage)
                    {
                        var date = selectedStartDate
                        let endDate = selectedEndDate
                        let fmt = DateFormatter()
                        fmt.dateFormat = "dd-MM-yyyy"
                        selctedDatesCountArray.removeAllObjects()
                        while date!.compare(endDate!) != .orderedDescending {
                            
                            if(Utility.shared.blocked_date_month.contains(fmt.string(from: date!)))
                            {
                                isblockedDate_Contain = true
                               
                            }
                            date = calendar.date(byAdding: .day, value: 1, to: date!)
                            selctedDatesCountArray.add(fmt.string(from: date!))
                         
                        }
                        if(!isblockedDate_Contain)
                        {
                            if(Utility.shared.isfromcheckingPage)
                            {
                                let night = selctedDatesCountArray.count - 1
                            
                                
                                if((viewListingArray.listingData?.minNight != 0) || (viewListingArray.listingData?.maxNight != 0) )
                                {
                                    if(night<((viewListingArray.listingData?.minNight!)!))
                                    {
                                        Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(viewListingArray.listingData?.minNight! ?? 0) \(viewListingArray.listingData!.minNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")")"
                                        footerView.isSaveEnabled = false
                                    }
                                    else if(((viewListingArray.listingData?.maxNight!)! > 0) && (night > ((viewListingArray.listingData?.maxNight!)!)))
                                    {
                                        Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \(viewListingArray.listingData!.maxNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")")"
                                        footerView.isSaveEnabled = false
                                    }
                                    else{
                                        if(month == 1)
                                        {
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                        }
                                        else{
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                            footerView.isSaveEnabled = true
                                        }
                                        
                                    }
                                    
                                }
                                else{
                                    if(month == 1)
                                    {
                                        Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                    }
                                    else{
                                        
                                        Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                        footerView.isSaveEnabled = true
                                    }
                                    
                                }
                                numberofnights = night
                                
                                endCell.type.insert(.SelectedEndDate)
                                endCell.configureCell()
                            }
                            else
                            {
                                endCell.type.insert(.SelectedEndDate)
                                endCell.configureCell()
                            }
                        }
                        else{
                            footerView.isSaveEnabled = false
                            endDateSelected = true
                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                            isblockedDate_Contain = false
                        }
                    }
                    else
                    {
                        endCell.type.insert(.SelectedEndDate)
                        endCell.configureCell()
                    }
                }
             
                selectInBetweenCells()
                
                
                
            }
            
            
            else {
                
                
                
                if Calendar.current.dateComponents([.day], from: selectedStartDate!, to: selectedDate).day ?? 0 >= Utility.shared.minimumstay{
                    deselectSelectedCells()
                    isSelectedstartDate = false
                    selectedEndDate = selectedDate
                    endDateIndexPath = indexPath
                    endDateSelected = true
                    
                
                    if let startCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                        if(selectedStartDate == nil) {
                            startCell.type.insert(.SelectedStartDate)
                            startCell.configureCell() } else {
                                
                                if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                                  
                                    startCell.type.insert(.SelectedStartDate)
                                    startCell.configureCell()
                                }
                            }
                    }
                    
                  
                    if let endCell = collectionView.cellForItem(at: endDateIndexPath!) as? AirbnbDatePickerCell {
                        if(Utility.shared.isfromcheckingPage)
                        {
                            var date = selectedStartDate
                            let endDate = selectedEndDate
                            let fmt = DateFormatter()
                            fmt.dateFormat = "dd-MM-yyyy"
                            selctedDatesCountArray.removeAllObjects()
                            while date!.compare(endDate!) != .orderedDescending {
                                
                                if(Utility.shared.blocked_date_month.contains(fmt.string(from: date!)))
                                {
                                    isblockedDate_Contain = true
                                 
                                }
                                date = calendar.date(byAdding: .day, value: 1, to: date!)
                                selctedDatesCountArray.add(fmt.string(from: date!))
                              
                            }
                            if(!isblockedDate_Contain)
                            {
                                if(Utility.shared.isfromcheckingPage)
                                {
                                    let night = selctedDatesCountArray.count - 1
                                    
                                 
                                    
                                    if((viewListingArray.listingData?.minNight != 0) || (viewListingArray.listingData?.maxNight != 0) )
                                    {
                                        if(night<((viewListingArray.listingData?.minNight!)!))
                                        {
                                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"minimumstay"))!) \(viewListingArray.listingData?.minNight! ?? 0) \(viewListingArray.listingData!.minNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey:"days") ?? "days")")"
                                            footerView.isSaveEnabled = false
                                        }
                                        else if(((viewListingArray.listingData?.maxNight!)! > 0) && (night > ((viewListingArray.listingData?.maxNight!)!)))
                                        {
                                            Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"maximumstay"))!) \(viewListingArray.listingData?.maxNight! ?? 0) \(viewListingArray.listingData!.maxNight! > 1 ? "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")" : "\(Utility.shared.getLanguage()?.value(forKey: "days") ?? "days")")"
                                            footerView.isSaveEnabled = false
                                        }
                                        else{
                                            if(month == 1)
                                            {
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                            }
                                            else{
                                                Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                                footerView.isSaveEnabled = true
                                            }
                                            
                                        }
                                        
                                    }
                                    else{
                                        if(month == 1)
                                        {
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"
                                        }
                                        else{
                                            
                                            Blocked_Selected_String = "\(night) \((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)"
                                            footerView.isSaveEnabled = true
                                        }
                                        
                                    }
                                    numberofnights = night
                                    
                                    endCell.type.insert(.SelectedEndDate)
                                    endCell.configureCell()
                                }
                                else
                                {
                                    endCell.type.insert(.SelectedEndDate)
                                    endCell.configureCell()
                                }
                            }
                            else{
                                footerView.isSaveEnabled = false
                                endDateSelected = true
                                Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"datenotavail"))!)"
                                isblockedDate_Contain = false
                            }
                        }
                        else
                        {
                            endCell.type.insert(.SelectedEndDate)
                            endCell.configureCell()
                        }
                    }
                    
        
                    selectInBetweenCells()
                    
                }else{
                    
                  
                    deselectSelectedCells()
                    
                    selectedStartDate = selectedDate
                    selectedEndDate = nil
                   
                    startDateIndexPath = indexPath
                    endDateIndexPath = nil
                    
                    if let newStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                        newStartCell.type.insert(.Selected)
                        newStartCell.configureCell()
                    }
                    
                    selectInBetweenCells()
                }
                
                
            }
            
            cell.configureCell()
            
        }
        
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
        
        return cell.type.contains(.Date)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
        
        if isInBetween(indexPath: indexPath) {
            deselectSelectedCells()
            
            let selectedMonth = months[indexPath.section]
            
            let year = calendar.component(.year, from: selectedMonth)
            let month = calendar.component(.month, from: selectedMonth)
            
            var dateComp = DateComponents(year: year, month: month, day: Int(cell.dateLabel.text!))
            let selectedDate = calendar.date(from: dateComp)!
            
            selectedStartDate = selectedDate
            selectedEndDate = nil
            
            startDateIndexPath = indexPath
            endDateIndexPath = nil
            
            if let newStartCell = collectionView.cellForItem(at: startDateIndexPath!) as? AirbnbDatePickerCell {
                newStartCell.type.insert(.Selected)
                newStartCell.configureCell()
                collectionView.selectItem(at: startDateIndexPath!, animated: false, scrollPosition: .left)
            }
        }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if selectedEndDate == nil && startDateIndexPath == indexPath {
            return false
        }
        return true
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
        
        cell.type.insert(.Highlighted)
        cell.configureCell()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
        return cell.type.contains(.Date)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AirbnbDatePickerCell
        
        cell.type.remove(.Highlighted)
        
        cell.configureCell()
    }
    
    func configure(cell: AirbnbDatePickerCell, withIndexPath indexPath: IndexPath) {
        let dateData = days[indexPath.section]
        let month = calendar.component(.month, from: months[indexPath.section])
        let year = calendar.component(.year, from: months[indexPath.section])
        
        if indexPath.item < dateData.prepend || indexPath.item >= (dateData.prepend + dateData.days) {
            cell.dateLabel.text = ""
            cell.type = [.Empty]
        } else {
            let todayYear = calendar.component(.year, from: today)
            let todayMonth = calendar.component(.month, from: today)
            let todayDay = calendar.component(.day, from: today)
            
            
            let curDay = indexPath.item - dateData.prepend + 1
            let isPastDate = year == todayYear && month == todayMonth && curDay < todayDay
            var currentdate = String()
            var currentmonth = String()
            if(curDay<=9)
            {
                currentdate = "0\(curDay)"
            }
            else{
                currentdate = "\(curDay)"
            }
            if(month<=9)
            {
                currentmonth = "0\(month)"
                
            }
            else{
                currentmonth = "\(month)"
            }
            let datevalue = "\(currentdate)-\(currentmonth)-\(year)"
            let calendar = Calendar(identifier: .gregorian)
            
            let currentDate = Date()
            var components = DateComponents()
            components.calendar = calendar
            
            components.month = Utility.shared.maximum_days_notice
            let maxDate = calendar.date(byAdding: components, to: currentDate)!
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatterGet.dateFormat = "dd-MM-yyyy"
            let notice_date = (dateFormatterGet.string(from: maxDate))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let finalrestrict_Date = dateFormatter.date(from:notice_date)!
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "dd-MM-yyyy"
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            let newdate = dateFormatter1.date(from:datevalue)!
            let TodayDateConverstion = dateFormatter.string(from: today)
            
            
            
            
            
            if(Utility.shared.isfromcheckingPage)
            {
                if((index < Utility.shared.blocked_date_month.count) && (Utility.shared.blocked_date_month.contains(datevalue)))
                    
                {
                    cell.dateLabel.attributedText = String("\(curDay)").strikeThrough()
                    cell.dateLabel.textColor = Theme.hostCalendarDay_Color
                    cell.type = [.PastDate]
                    index += 1
                    
                }
                
                else {
                    
                    if((newdate > finalrestrict_Date) && (Utility.shared.maximum_days_notice != 0))
                    {
                        cell.dateLabel.text = String(curDay)
                        cell.dateLabel.textColor = Theme.hostCalendarDay_Color
                        cell.type = [.PastDate]
                    }
                    else{
                        cell.dateLabel.attributedText = String(curDay).plainText()
                        cell.dateLabel.textColor = isPastDate ? Theme.hostCalendarDay_Color : UIColor(named: "Title_Header")
                        cell.type = isPastDate ? [.PastDate] : [.Date]
                    }
                    
                    
                    if(Utility.shared.checkedInDates.contains(datevalue) && Utility.shared.fullcheckBlockedDateMonth.contains(datevalue)){
                        
                        if let blockedDates = viewListingArray.blockedDates {
                            for i in blockedDates
                            {
                                let timestamp = i?.blockedDates
                                let timestamValue = Int(timestamp!) != nil ? Int(timestamp!)!/1000 : 0
                                let newTime = Date(timeIntervalSince1970: TimeInterval(timestamValue))
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "dd-LL-YYYY"
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                                var dateToCheck = dateFormatter.string(from: newTime)
                                
                                
                                if i?.dayStatus == "firstHalf" && i?.calendarStatus == "blocked" && dateToCheck == datevalue{
                                    cell.dateLabel.attributedText = String("\(curDay)").strikeThrough()
                                    cell.dateLabel.textColor = Theme.hostCalendarDay_Color
                                    cell.type = [.PastDate]
                                    index += 1
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            else{
                cell.dateLabel.attributedText = String(curDay).plainText()
                cell.dateLabel.textColor = isPastDate ? Theme.hostCalendarDay_Color : UIColor(named: "Title_Header")
                cell.type = isPastDate ? [.PastDate] : [.Date]
            }
            
            if(index == Utility.shared.blocked_date_month.count)
            {
                index = 0
            }
            
            if todayDay == curDay, todayMonth == month, todayYear == year  {
                cell.type.insert(.Today)
            }
            
            let checkInDateFormatter = DateFormatter()
            checkInDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            checkInDateFormatter.dateFormat = "dd-LL-yyyy"
            
            let compareDate = checkInDateFormatter.string(from: newdate)
            if(!isFromFilter) {
                
                if Utility.shared.checkedInDates.contains(compareDate){
                    cell.type.insert(.disableCheckInDate)
                }
            }
        }
        
        if startDateIndexPath != nil && indexPath == startDateIndexPath {
            if endDateIndexPath == nil {
                cell.type.insert(.Selected)
            } else {
                cell.type.insert(.SelectedStartDate)
            }
        }
        
        if endDateIndexPath != nil {
            if indexPath == endDateIndexPath {
                cell.type.insert(.SelectedEndDate)
            } else if isInBetween(indexPath: indexPath) {
                cell.type.insert(.InBetweenDate)
            }
        }
        
        
        
        cell.configureCell()
        
        if(isFromFilter) {
            cell.dateLabel.layer.borderColor = UIColor.clear.cgColor
        }
        
        
        
    }
    
    
    func isInBetween(indexPath: IndexPath) -> Bool {
        if let start = startDateIndexPath, let end = endDateIndexPath {
            return (indexPath.section > start.section || (indexPath.section == start.section && indexPath.item > start.item))
            && (indexPath.section < end.section || (indexPath.section == end.section && indexPath.item < end.item))
        }
        return false
    }
    
    func selectInBetweenCells() {
        if startDateIndexPath != nil {
            
            
            var section = startDateIndexPath!.section
            var item = startDateIndexPath!.item
            
            
            var indexPathArr = [IndexPath]()
            if(selectedEndDate == nil)
            {
                
                let minimumStayNights = Utility.shared.minimumstay
                var selectedIndexes = (((days[section].append + days[section].prepend + days[section].days) - days[section].append) - item)
                var remainingIndexToBeSelected = minimumStayNights - selectedIndexes
                var i = 0, j = 1
                while (remainingIndexToBeSelected >= -1 && i != 1) {
                    i = 1
                    if (selectedIndexes > minimumStayNights){
                       
                        collectionView.isUserInteractionEnabled = false
                        collectionView.scrollToItem(at: IndexPath(item: (item + minimumStayNights), section: section), at: .bottom, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: (item + minimumStayNights), section: section))
                            self.collectionView.isUserInteractionEnabled = true
                            remainingIndexToBeSelected = -2
                        }
                    }else{
                        isnextMonthCalled = false
                        if (days.count > (section + j)) {
                            if days[section + j].days > remainingIndexToBeSelected{
                              
                                collectionView.isUserInteractionEnabled = false
                                collectionView.scrollToItem(at: IndexPath(item: self.days[section+j].prepend + remainingIndexToBeSelected, section: section + j), at: .bottom, animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: self.days[section+j].prepend + remainingIndexToBeSelected, section: section + j))
                                    self.collectionView.isUserInteractionEnabled = true
                                  
                                    remainingIndexToBeSelected = -2
                                }
                            }else{
                               
                                let remainingdays = minimumStayNights - selectedIndexes
                                
                                if days[section + j].days > remainingdays {
                                    collectionView.isUserInteractionEnabled = false
                                    collectionView.scrollToItem(at: IndexPath(item: self.days[section+j].prepend + remainingdays, section: section + j), at: .bottom, animated: true)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        
                                        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: self.days[section+j].prepend + remainingdays, section: section + j))
                                        self.collectionView.isUserInteractionEnabled = true
                                        remainingIndexToBeSelected = -2
                                        
                                    }
                                }else{
                                    remainingIndexToBeSelected = remainingdays + days[section + j].days
                                    selectedIndexes += days[section+j].days
                                    isnextMonthCalled = true
                                    i += 1
                                    j += 1
                                }
                                
                            }
                        }else{
                            self.startDateIndexPath = nil
                            self.selectedStartDate = nil
                            isSelectedstartDate = false
                            self.collectionView.reloadItems(at: [IndexPath(item: item, section: section)])
                       
                            self.view.makeToast("\(Utility.shared.getLanguage()?.value(forKey: "Date_Error") ?? "Upcoming months are currently unavailable kindly select the dates in available months.")")
                        }
                    }
                }
                
                if (selectedIndexes > minimumStayNights){
                  
                    collectionView.isUserInteractionEnabled = false
                    collectionView.scrollToItem(at: IndexPath(item: (item + minimumStayNights), section: section), at: .bottom, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: (item + minimumStayNights), section: section))
                        self.collectionView.isUserInteractionEnabled = true
                        remainingIndexToBeSelected = -2
                    }
                }
                
             
            } else {
                while section < months.count, section <= endDateIndexPath!.section {
                    let curIndexPath = IndexPath(item: item, section: section)
                    if let cell = collectionView?.cellForItem(at: curIndexPath) as? AirbnbDatePickerCell {
                        if curIndexPath != startDateIndexPath && curIndexPath != endDateIndexPath {
                            cell.type.insert(.InBetweenDate)
                            cell.configureCell()
                        }
                        indexPathArr.append(curIndexPath)
                    }
                    
                    if section == endDateIndexPath!.section && item >= endDateIndexPath!.item {
                        
                        break
                    } else if item >= (collectionView!.numberOfItems(inSection: section) - 1) {
                       
                        section += 1
                        item = 0
                    } else {
                        item += 1
                    }
                }
                collectionView?.performBatchUpdates({
                    () in
                    self.collectionView?.reloadItems(at: indexPathArr)
                }, completion: nil)
            }
        }
    }
    
    func deselectSelectedCells() {
        if let start = startDateIndexPath {
            var section = start.section
            var item = start.item + 1
            
            if let cell = collectionView?.cellForItem(at: start) as? AirbnbDatePickerCell {
                cell.type.remove([.InBetweenDate, .SelectedStartDate, .SelectedEndDate, .Selected])
                cell.configureCell()
                collectionView?.deselectItem(at: start, animated: false)
            }
            
            if let end = endDateIndexPath {
                var indexPathArr = [IndexPath]()
                while section < months.count, section <= end.section {
                    let curIndexPath = IndexPath(item: item, section: section)
                    if let cell = collectionView?.cellForItem(at: curIndexPath) as? AirbnbDatePickerCell {
                        cell.type.remove([.InBetweenDate, .SelectedStartDate, .SelectedEndDate, .Selected])
                        cell.configureCell()
                        collectionView?.deselectItem(at: curIndexPath, animated: false)
                    }
                    
                    if section == end.section && item >= end.item {
                       
                        break
                    } else if item >= (collectionView!.numberOfItems(inSection: section) - 1) {
                     
                        section += 1
                        item = 0
                    } else {
                        item += 1
                    }
                }
                
                collectionView?.performBatchUpdates({
                    () in
                    (self.collectionView?.reloadItems(at: indexPathArr))!
                },completion: nil)
            }
        }
    }
    
  
    @objc func handleDismiss() {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleClearInput() {
        deselectSelectedCells()
        selectedStartDate = nil
        endDateSelected = false
        selectedEndDate = nil
        if !isFromFilter {
            if let data  = viewListingArray.listingData {
                if viewListingArray.listingData!.minNight! > 1 {
                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"nightrequire"))!) \(viewListingArray.listingData?.minNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"nights")) ?? "nights")"
                }else{
                    Blocked_Selected_String = "\((Utility.shared.getLanguage()?.value(forKey:"nightrequire"))!) \(viewListingArray.listingData?.minNight! ?? 0) \((Utility.shared.getLanguage()?.value(forKey:"night"))!)"
                }
            }
        }
        isFirstTimeLoaded = true
        footerView.isSaveEnabled = false
        startDateIndexPath = nil
        endDateIndexPath = nil
    }
    
    func loadMoreMonths(completion: (() -> Void)?) {
        let lastDate = months.last!
        let month = calendar.component(.month, from: lastDate)
        let year = calendar.component(.year, from: lastDate)
        var dateComp = DateComponents(year: year, month: month + 1, day: 1)
        var curMonth = calendar.date(from: dateComp)
        
        for _ in 0..<subsequentMonthsLoadCount {
            months.append(curMonth!)
            
            let numOfDays = calendar.range(of: .day, in: .month, for: curMonth!)!.count
            let firstWeekDay = calendar.component(.weekday, from: curMonth!.startOfMonth())
            let lastWeekDay = calendar.component(.weekday, from: curMonth!.endOfmonth())
           
            days.append((days: numOfDays, prepend: firstWeekDay-1 , append: 7 ))
            curMonth = calendar.date(byAdding: .month, value: 1, to: curMonth!)
            
        }
        
        if let handler = completion {
            handler()
        }
    }
    

    
    func findIndexPath(forDate date: Date) -> IndexPath? {
        var indexPath: IndexPath? = nil
        if let section = months.index(where: {
            calendar.component(.year, from: $0) == calendar.component(.year, from: date) && calendar.component(.month, from: $0) == calendar.component(.month, from: date)}) {
            let item = days[section].prepend + calendar.component(.day, from: date) - 1
            indexPath = IndexPath(item: item, section: section)
        }
        return indexPath
    }
}


extension AirbnbDatePickerViewController: AirbnbDatePickerFooterDelegate {
    func didSave() {
        
        if let del = delegate {
            if(selectedStartDate != nil && selectedEndDate != nil){
                let dates = [
                    
                    "start" : selectedStartDate!,
                    "end": selectedEndDate!
                    
                ]
                if(selctedDatesCountArray.count == 0 && selectedStartDate != nil){
                    isRemoveSelectedDate = true
                }
                if(selctedDatesCountArray.count == 0 && (selectedStartDate != nil && selectedEndDate != nil)){
                    
                }
                else
                {
                    Utility.shared.numberofnights_Selected = numberofnights
                }
                
                
                NotificationCenter.default.post(name: Notification.Name("Date"), object: nil, userInfo: dates as? [AnyHashable : Any])
                
                if let str = Blocked_Selected_String {
                    if Blocked_Selected_String!.contains("\((Utility.shared.getLanguage()?.value(forKey:"nightsselect"))!)") || Blocked_Selected_String!.contains("\((Utility.shared.getLanguage()?.value(forKey:"nightselection"))!)"){
                        
                        if Utility().isConnectedToNetwork(){
                            var currency = String()
                            let fmt = DateFormatter()
                            fmt.dateFormat = "yyyy-MM-dd"
                            if(Utility.shared.getPreferredCurrency() != nil && Utility.shared.getPreferredCurrency() != "")
                            {
                                currency = Utility.shared.getPreferredCurrency()!
                            }
                            else
                            {
                                currency = Utility.shared.currencyvalue_from_API_base
                            }
                            var apollo_headerClient: ApolloClient = {
                                let configuration = URLSessionConfiguration.default
                             
                                configuration.httpAdditionalHeaders = ["auth": "\(Utility.shared.getCurrentUserToken() ?? "")"]
                                let url = URL(string:graphQLEndpoint)!
                                return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
                            }()
                            
                            if viewListingArray.id != nil {
                                let billingListquery = GetBillingCalculationQueryy(listId: viewListingArray.id!, startDate:fmt.string(from: selectedStartDate!), endDate: fmt.string(from: selectedEndDate!), guests: Utility.shared.guestCountToBeSend, visitors: 0, pets: 0, infants: 0 , convertCurrency:currency)
                                apollo_headerClient.fetch(query: billingListquery){ [self](result,error) in
                                    guard (result?.data?.getBillingCalculation?.result) != nil else{
                                       
                                        
                                        self.view.makeToast(result?.data?.getBillingCalculation?.errorMessage!)
                                        return
                                    }
                                    del.datePickerController(self, didSaveStartDate: selectedStartDate, endDate: selectedEndDate)
                                    self.navigationController?.dismiss(animated: true, completion: nil)
                                }
                            }
                            del.datePickerController(self, didSaveStartDate: selectedStartDate, endDate: selectedEndDate)
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        if(isFromFilter) {
                            del.datePickerController(self, didSaveStartDate: selectedStartDate, endDate: selectedEndDate)
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        } else {
                            self.view.makeToast(footerView.minimumbookLabel.text)
                        }
                    }
                }
                else {
                    del.datePickerController(self, didSaveStartDate: selectedStartDate, endDate: selectedEndDate)
                    
                    
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                
                
            }
            else{
                if(isFromFilter) {
                    if(selectedStartDate != nil && selectedEndDate == nil){
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selend"))!)")
                    } else {
                        
                    
                        
                        if Utility.shared.TotalFilterCount == 1 {
                            Utility.shared.TotalFilterCount = 0
                        }
                        
                        del.datePickerController(self, didSaveStartDate: selectedStartDate, endDate: selectedEndDate)
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    if(selectedStartDate == nil ){
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selstart"))!)")
                    }
                    else if(selectedEndDate == nil){
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selend"))!)")
                    }
                    else {
                        
                        self.view.makeToast("\((Utility.shared.getLanguage()?.value(forKey:"selectdate"))!)")
                    }
                }
            
            }
        }
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        
        let attributeString =  NSMutableAttributedString(string: self, attributes:[ NSAttributedString.Key.font: UIFont(name:APP_FONT_SEMIBOLD, size: 14.0)! ] )
        
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.thick.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                     value: Theme.hostCalendarDay_Color,
                                     range: NSMakeRange(0, attributeString.length))
        
        
        
        return attributeString
    }
    func strikingThrough() -> NSAttributedString {
        
        let attributeString =  NSMutableAttributedString(string: self)
        
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                     value: UIColor.red,
                                     range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
    func plainText() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor,
                                     value: UIColor.clear,
                                     range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
}

