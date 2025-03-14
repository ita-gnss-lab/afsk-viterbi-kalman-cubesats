# An All-Digital Coherent AFSK Demodulator for CubeSat Applications

This repository contains the course code for the article named "An All-Digital Coherent AFSK Demodulator for CubeSat Applications", published in [Digital Signal Processing](https://www.sciencedirect.com/journal/digital-signal-processing), available on [ScienceDirect](.https://www.sciencedirect.com/)

---

# Usage

The main source code in this repository is the `AFSK.slx` file, which contains the AFSK demodulator model reported in the article. This file uses some MATLAB codes located in `./inputs/` to initialize the model with the correct parameters. An important initialization script is `get_scenarios.m`, which interfaces `get_scenarios.py`, a Python script responsible for obtaining real CubSats trajectories. This file is used to set the desired line-of-sight (LOS) dynamics.

The Python script's main dependency is [`skyfield`](https://rhodesmill.org/skyfield/) and [`scintpy`](https://github.com/tapyu/scintpy). While the former handles astronomic bodies (i.e., the satellites) defined in a coordinate system, the latter is used to obtain their trajectories with respect to a fixed position during the window time, thus outputting the relative LOS range. The user is encouraged to set up a Python virtual environment by using [`poetry`](https://python-poetry.org/) with all the required packages. While `skyfield` is well known in the field of Astronomy and is available on PyPI, `scintpy` is a work-in-progress Python package developed by the authors and is passing through constant modifications. Therefore, use the [correct `scintpy` version](https://github.com/tapyu/scintpy/releases/tag/v0.0.1) to make sure that everything will work correctly. Likewise, use the [correct version of AFSK model](https://github.com/ita-gnss-lab/afsk-viterbi-kalman-cubesats/releases/tag/dsp-elsevier-published-version-2025) to make sure that any further modification made on this repository will not break the code.

Besides the initialization scripts, `./inputs/` also contains files to programmatically obtain metrics for the model (e.g., bit error rate, RMSE). Such metrics are saved in `.mat` files in the `./outputs/` directory. Finally, `./outputs/` contains other MATLAB scripts to plot the results on MATLAB (such file names are prefixed with `plot_`) and to export the values in csv files (such file names are prefixed with `save_`).

The MATLAB version used for the AFSK model was R2024b.

---

# Caveat

The unique caveat you should pay attention is the virtual environment's Python path, which should be manually changed in this line

https://github.com/ita-gnss-lab/afsk-viterbi-kalman-cubesats/blob/d488d48d91ed9e0207fdf15381e3cc5e2ea3a265/inputs/get_scenarios.m#L7-L11

by the actual path on your machine.

---

# Reference
If you re-use this work, please cite:

```bib
@article{TODO,
  Title                    = {},
  Author                   = {},
  journal                  = {},
  Year                     = {},
  volume                   = {},
  number                   = {},
  pages                    = {},
}
```
