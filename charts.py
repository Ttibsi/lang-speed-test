#!/bin/env python3

from dataclasses import dataclass
import sys
from typing import TypeAlias

try:
    import matplotlib
    import pandas
except ModuleNotFoundError:
    print("Please ensure a virtualenv with pandas and matplotlib installed is present")
    sys.exit()

frame_t: TypeAlias = pandas.core.frame.DataFrame
chart_t: TypeAlias = matplotlib.axes..Axes

@dataclass 
class Chart:
    title: str
    x_label: str 
    y_label: str 
    file_name: str 

    def to_img(self, chart: chart_t):
        chart.title(self.title)
        chart.xlabel(self.x_label)
        chart.ylabel(self.y_label)
        chart.savefig(self.file_name)
        chart.close()
        # matplotlib.pyplot.savefig()

def main():
    if len(sys.argv) != 2:
        print("Please select an architecture to read results from")
        return -1

    arch: str = sys.argv[1]
    # with open(f"results/{arch}/synthetic_results.csv") as csv:
    with open(f"example_csv.csv") as csv:
        frame: frame_t = pandas.read_csv(csv, index_col = "binary name")

        line_chart: Chart = Chart(
            "Size Comparison",
            "Language",
            "Binary size",
            "results/graphs/size_comparison.png"
        )

        bar_chart: Chart = Chart(
            "Perf Comparison",
            "Language",
            "Time (seconds)",
            "results/graphs/speed_comparison.png"
        )

        line_chart.to_img(frame["binary size (bytes)"].plot())
        bar_chart.to_img(frame.iloc[:,1:].plot().bar())


if __name__ == "__main__":
    raise SystemExit(main())
