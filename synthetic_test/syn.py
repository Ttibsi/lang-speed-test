import os

def main() -> None:
    iters: int = int(os.environ["SPEEDTEST_ITERS"])
    for i in range(iters):
        a: list[int] = [0] * 1000

        for j in range(100):
            a[j] = j

        for j in range(10):
            tmp: int = a[j]
            a[j] = a[1000 - (10- j)]
            a[1000 - (10- j)] = tmp


if __name__ == "__main__":
    raise SystemExit(main())
