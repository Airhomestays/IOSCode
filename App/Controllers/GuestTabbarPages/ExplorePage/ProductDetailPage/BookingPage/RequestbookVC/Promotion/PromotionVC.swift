//
//  Copyright © 2025 RADICAL START. All rights reserved.
//

import UIKit

enum PromotionType: Equatable{
  case none
  case applied(appliedValue: Double)
}

protocol PromotionDelegate {
    func didApplyPromotion(type:PromotionType)
}
class PromotionVC: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var tableVIewPromotion: UITableView!
    
    //MARK: Variables
    var delegate:PromotionDelegate?
    
    //MARK: Class life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    //MARK: Private methods
    private func setupUI() {
        self.tableVIewPromotion.registerXib(PromotionCell.self)
    
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        delegate?.didApplyPromotion(type: .none)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionApply(_ sender: UIButton) {
        delegate?.didApplyPromotion(type: .applied(appliedValue: 100.0))
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension PromotionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableVIewPromotion.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as! PromotionCell
        return cell
    }
}
