import Foundation

if let iters = ProcessInfo.processInfo.environment["SPEEDTEST_ITERS"] {
    for i in 1..Int(iters) {
        var lst = Array(repeating: 0, count: 1000)

        for j in 1..100 {
            lst[j] = j
            }

        for j in 1..10 {
            const tmp = lst[j]
            lst[j] = lst[1000 - (10 - j)]
            lst[1000 - (10 - j)] = tmp
            }
    }
}
