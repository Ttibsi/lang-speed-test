#!/bin/env python3
import os
import sys
from dataclasses import dataclass
from typing import TypeAlias

try:
    import matplotlib.pyplot
    import numpy
    import pandas
except ModuleNotFoundError:
    print("Please ensure a virtualenv with pandas and matplotlib installed is present")
    sys.exit()

frame_t: TypeAlias = pandas.core.frame.DataFrame
chart_t: TypeAlias = matplotlib.pyplot.Axes


@dataclass
class Chart:
    title: str
    y_label: str
    file_name: str

    def to_img(self, chart: chart_t):
        chart.set_title(self.title)
        chart.set_xlabel("Language")
        chart.set_ylabel(self.y_label)

        chart.figure.savefig(self.file_name, bbox_inches="tight")
        matplotlib.pyplot.close()


def main() -> None:
    if len(sys.argv) != 2:
        print("Please select an architecture to read results from")
        return -1

    if not os.path.exists("results/graphs"):
        os.makedirs("results/graphs")

    arch: str = sys.argv[1]
    print(f"Generating graphs to results/graphs for arch {arch}")

    syn_csv = f"results/{arch}/synthetic_results.csv"
    gol_csv = f"results/{arch}/gol_results.csv"
    syn_frame: frame_t = pandas.read_csv(syn_csv, index_col="binary name")
    gol_frame: frame_t = pandas.read_csv(gol_csv, index_col="binary name")

    # Combine the same data set from multiple inputs
    binsize_dataframe: frame_t = pandas.merge(
        syn_frame["binary size (bytes)"],
        gol_frame["binary size (bytes)"],
        left_index=True,
        right_index=True,
    ).rename(columns={
        "binary size (bytes)_x": "synthetic",
        "binary size (bytes)_y": "gol",
        })

    line_chart: Chart = Chart(
            "Size Comparison",
            "Binary size",
            f"results/graphs/size_comparison_{arch}.png",
            )

    bar_chart: Chart = Chart(
            f"Perf Comparison ({arch})",
            "Time (seconds)",
            f"results/graphs/speed_comparison_{arch}.png",
            )

    line_chart.to_img(
        binsize_dataframe.plot(rot=90, xticks=numpy.arange(len(syn_frame)))
    )
    bar_chart.to_img(syn_frame.iloc[:, 1:].plot(kind="bar", rot=90))
    return


if __name__ == "__main__":
    raise SystemExit(main())
