from collections import Counter
from pprint import pprint

def main() -> None:
    length_counter = Counter()
    word_counter = Counter()

    with open("shakespeare_test/text.txt") as f:
        lines: list[str] = f.readlines()

    for line in lines:
        words = line.split()
        for word in words:
            length_counter[len(word)] += 1

            if len(word) >= 3:
                word_counter[word] += 1

    pprint(f"{length_counter=}")

    avg_length: float = 0.0
    for k, v in length_counter.items():
        avg_length += k * v

    avg_length /= length_counter.total()
    print(f"{avg_length=:2.2}")
    print(f"Top 3 most common words: {word_counter.most_common(3)}")


if __name__ == "__main__":
    raise SystemExit(main())
