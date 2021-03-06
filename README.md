
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rslab

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/Lightbridge-KS/rslab/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Lightbridge-KS/rslab/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

> An educational R package 📦 for calculate various respiratory
> physiology parameters.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("Lightbridge-KS/rslab")
```

## Overview

`{rslab}` is an R package that contain functions for calculate
respiratory physiology parameters in the following categories.

-   **ATPS to BTPS converter:** conversion of spirometry lung
    volume/flows from *ATPS* (Ambient Temperature and Pressure
    Saturated) to *BTPS* (Body Temperature, Pressure, water vapor
    Saturated)

-   **Harvard Spirometer and Metabolic Rate & Oxygen Consumption:**

    -   Calculate metabolic rate and oxygen consumption
        *V̇*<sub>*O*<sub>2</sub></sub> from [Harvard
        Spirometer](https://www.somatco.com/Recording-Spirometer-50-1833-50-1817.pdf)
        tracing, height and weight of the subject, and environmental
        conditions which are temperature and barometric pressure.
    -   Simulate data to plot Harvard spirometer tracing from
        respiratory parameters such as oxygen consumption, tidal volume,
        respiratory rate, and random variation can also be added to give
        a more realistic plot.
