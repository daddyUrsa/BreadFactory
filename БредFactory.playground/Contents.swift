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

// --------------------------

var noDough: Int = 0
var prepearedDough: Int = 1

class BakeryStorage{
    private var storage: [Bread] = []
    
    var isEmtyStroage: Bool {
        return storage.isEmpty
    }

    var lock = NSConditionLock(condition: noDough)
    
    func push() {
        lock.lock(whenCondition: noDough)
        let dough = Bread.make()
        storage.append(dough)
        print("Put dough in storage")
        lock.unlock(withCondition: prepearedDough)
    }
    
    func pop() -> Bread? {
        print("Get dough from storage")
        lock.lock(whenCondition: prepearedDough)
        let bread = storage.popLast()
        print("Get dough from storage")
        lock.unlock(withCondition: noDough)
        return bread
    }
    
}

class CreatesThread: Thread {
    var timer = Timer()
    override func main() {
        print("prepare for dough")
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            bakery.push()
            print("Месим тесто. Формуем хлеб.")
        }
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 20))
        timer.invalidate()
        
    }
    
    
}

class WorkingThread: Thread {
    
    var storage: BakeryStorage
    
    init(storage: BakeryStorage) {
        self.storage = storage
    }
    
    override func main() {
//        bakery.lock.lock(whenCondition: prepearedDough)
        print("prepare for bake")
        print(storage.isEmtyStroage)
        while !storage.isEmtyStroage {
            let dough = storage.pop()
            dough?.bake()
            print("Печём хлеб")
        }
        
    }
}

var bakery = BakeryStorage()

let ct = CreatesThread()
let wt = WorkingThread(storage: bakery)

ct.start()
wt.start()
