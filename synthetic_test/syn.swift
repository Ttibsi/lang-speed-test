import Foundation

if let itersString = ProcessInfo.processInfo.environment["SPEEDTEST_ITERS"],
   let iters = Int(itersString) {
    for _ in 1...iters {
        var lst = Array(repeating: 0, count: 1000)

        for j in 1..<1000 {
            lst[j] = j
        }

        for j in 1...10 {
            let tmp = lst[j]
            lst[j] = lst[999 - (10 - j)]
            lst[999 - (10 - j)] = tmp
        }
    }
}
