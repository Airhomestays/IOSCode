

import Foundation
import UIKit

extension UIView {
     
    func addTap(action: @escaping () -> Void) {
        let tap = MyTapgesture(target: self, action: #selector(handleTap(_ :)))
        tap.action = action
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    @objc func handleTap(_ sender: MyTapgesture) {
        sender.action!()
    }
    
    class MyTapgesture: UITapGestureRecognizer {
        var action: (() -> Void)? = nil
    }
}
