import Foundation

if let iters = ProcessInfo.processInfo.environment["SPEEDTEST_ITERS"] {
    for _ in 1...(Int(iters) ? 0) {
        var lst = Array(repeating: 0, count: 1000)

        for j in 1...100 {
            lst[j] = j
        }

        for j in 1...10 {
            let tmp = lst[j]
            lst[j] = lst[1000 - (10 - j)]
            lst[1000 - (10 - j)] = tmp
        }
    }
}
