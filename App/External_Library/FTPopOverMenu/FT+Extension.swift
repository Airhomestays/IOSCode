
import UIKit

public protocol Imageable {
    func getImage() -> UIImage?
}

extension String: Imageable {
    public func getImage() -> UIImage? {
        return UIImage(named: self)
    }
}

extension UIImage: Imageable {
    public func getImage() -> UIImage? {
        return self
    }
}

public protocol FTMenuObject {
    
}

extension String: FTMenuObject {
    
}

extension FTPopOverMenuModel: FTMenuObject {
    
}
