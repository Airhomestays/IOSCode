//
//  Copyright © 2025 RADICAL START. All rights reserved.
//

import Foundation

import UIKit

extension UITableView {
    
    /// Register a UITableViewCell from a XIB file.
    /// - Parameter cellType: The UITableViewCell class type.
    func registerXib<T: UITableViewCell>(_ cellType: T.Type) {
        let className = String(describing: cellType)
        let nib = UINib(nibName: className, bundle: nil)
        self.register(nib, forCellReuseIdentifier: className)
    }
    
    /// Dequeue a reusable cell of the specified type.
    /// - Parameter indexPath: Index path for the cell.
    /// - Returns: A reusable UITableViewCell of the specified type.
    func dequeue1ReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let className = String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withIdentifier: className, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(className)")
        }
        return cell
    }
}
