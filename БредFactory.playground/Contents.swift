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

var array: [Int] = []

let lock = NSConditionLock(condition: 0)

class BakeryStorage{
    private var storage: [Bread] = []
    var doughCount = 0
    var isEmptyStorage: Bool {
        return storage.isEmpty
    }
    var workDone = false
    
    func push() {
        let dough = Bread.make()
        lock.lock(whenCondition: 0)
        storage.append(dough)
        doughCount += 1
        lock.unlock(withCondition: 1)
        print("Кладем заготовку из теста на склад")
    }
    
    func pop() -> Bread? {
        var coockedBread: Bread?
        lock.lock(whenCondition: 1)
        while !bakeryStorage.isEmptyStorage {
            print("Достаем заготовку со склада")
            let bread = storage.popLast()
            coockedBread = bread ?? nil
        }
        lock.unlock(withCondition: 0)
        return coockedBread
    }
}

var bakeryStorage = BakeryStorage()

class FirstThread: Thread {
    var timer = Timer()
    var i = 1

    override func main() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            bakeryStorage.push()
            print("Положили тесто №: \(self.i)")
            self.i += 1
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 20))
        print("Тесто закончилось")
        bakeryStorage.workDone = true
        timer.invalidate()
    }
}

class SecondThread: Thread {
    var timer = Timer()
    var i = 1
    override func main() {
        while isCancelled {
            let pop = bakeryStorage.pop()
            pop?.bake()
            print("Печем хлеб № \(i)")
            i += 1
        }
    }
}

let ft = FirstThread()
let st = SecondThread()

ft.start()
st.start()
