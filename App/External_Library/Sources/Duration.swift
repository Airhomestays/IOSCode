
import Foundation

prefix func - (duration: Duration) -> (Duration) {
    return Duration(value: -duration.value, unit: duration.unit)
}

class Duration {
    let value: Int
    let unit: NSCalendar.Unit
    fileprivate let calendar = (Calendar.autoupdatingCurrent as NSCalendar)
 
    var ago: Date {
        return ago(from: Date())
    }
    
    func ago(from date: Date) -> Date {
        return calendar.dateByAddingDuration(-self, toDate: date, options: .searchBackwards)!
    }
    
    var later: Date {
        return later(from: Date())
    }
    
    func later(from date: Date) -> Date {
        return calendar.dateByAddingDuration(self, toDate: date, options: .searchBackwards)!
    }
    
    init(value: Int, unit: NSCalendar.Unit) {
        self.value = value
        self.unit = unit
    }
}
