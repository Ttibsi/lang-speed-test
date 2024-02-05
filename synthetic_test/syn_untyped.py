import os

iters = int(os.environ["SPEEDTEST_ITERS"])
for i in range(iters):
    a = [0] * 1000

    for j in range(100):
        a[j] = j

    for j in range(10):
        tmp = a[j]
        a[j] = a[1000 - (10- j)]
        a[1000 - (10- j)] = tmp

