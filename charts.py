#!/bin/env python3
import os
import sys
from dataclasses import dataclass
from typing import TypeAlias

try:
    import matplotlib.pyplot
    import pandas
except ModuleNotFoundError:
    print("Please ensure a virtualenv with pandas and matplotlib installed is present")
    sys.exit()

frame_t: TypeAlias = pandas.core.frame.DataFrame
chart_t: TypeAlias = matplotlib.pyplot.Axes

@dataclass 
class Chart:
    title: str
    x_label: str 
    y_label: str 
    file_name: str 
    bar_chart:bool

    def to_img(self, chart: chart_t):
        chart.set_title(self.title)
        chart.set_xlabel(self.x_label)
        chart.set_ylabel(self.y_label)

        if self.bar_chart:
            chart.bar(0.3, 1)

        chart.figure.savefig(self.file_name)
        matplotlib.pyplot.close()

def main() -> None:
    if len(sys.argv) != 2:
        print("Please select an architecture to read results from")
        return -1

    if not os.path.exists("results/graphs"):
        os.makedirs("results/graphs")

    arch: str = sys.argv[1]

    with open(f"results/{arch}/synthetic_results.csv") as csv:
        frame: frame_t = pandas.read_csv(csv, index_col = "binary name")

        line_chart: Chart = Chart(
            "Size Comparison",
            "Language",
            "Binary size",
            f"results/graphs/size_comparison_{arch}.png",
            False
        )

        bar_chart: Chart = Chart(
            "Perf Comparison",
            "Language",
            "Time (seconds)",
            f"results/graphs/speed_comparison_{arch}.png",
            True
        )

        line_chart.to_img(frame["binary size (bytes)"].plot(rot=90))
        bar_chart.to_img(frame.iloc[:,1:].plot(rot=90))

    return


if __name__ == "__main__":
    raise SystemExit(main())
