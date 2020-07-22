import Foundation

public struct Bread {
    public enum BreadType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let breadType: BreadType
    
    public static func make() -> Bread {
        guard let breadType = Bread.BreadType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Bread(breadType: breadType)
    }
    
    public func bake() {
        let bakeTime = breadType.rawValue
        sleep(UInt32(bakeTime))
    }
}

class BreadStroage {
    private var storage: [Bread] = []
    var lock = NSConditionLock()
    
    func push() {
        lock.lock()
        let bread = Bread.make()
        storage.append(bread)
        lock.unlock()
    }
    
    func pop() {

    }
    
}
