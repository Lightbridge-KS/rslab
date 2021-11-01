
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rslab

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

R 📦 for calculation of various respiratory physiology parameters.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Lightbridge-KS/rslab")
```

## BTPS Calculator

``` r
library(rslab)
```

[BTPS correction
factor](https://nddmed.com/_Resources/Persistent/8a716ac3fd123ce0becd7b56596582d4fc4c0c47/appnote-btps-correction-v01r.pdf)
is used to convert flow and volume measured at ambient conditions to the
conditions within the lungs.

``` r
# BTPS correction factor at room temperature = 27 degree celsius
btps_factor27 <- get_btps_factor(temp = 27)
btps_factor27
#> [1] 1.063
```

If Tidal Volume (TV) was measured as 500 ml at room temperature of 27
degree celsius, the TV in the lung at BTPS (body temperature, pressure,
water vapor saturated) would be:

``` r
# TV (ml) at BTPS
500 * btps_factor27 
#> [1] 531.5
```

If you want to convert several lung volumes or flow (from ATPS to BTPS),
use `lung_vol_atps_btps()` and it will show the result in a tibble.

``` r
lung_vol_atps_btps(
  temp = 27,
  FEV1 = 3.5, 
  FVC = 4.5,
  PEF = 450,
  TV = 0.5,
  IC = 2.5,
  EC = 2.5,
  VC = 4.5
)
#> # A tibble: 10 × 4
#>    Parameter  ATPS    BTPS Unit 
#>    <chr>     <dbl>   <dbl> <chr>
#>  1 FEV1        3.5   3.72  L    
#>  2 FVC         4.5   4.78  L    
#>  3 FEV1/FVC   77.8  82.7   %    
#>  4 PEF       450   478.    L/min
#>  5 TV          0.5   0.532 L    
#>  6 IC          2.5   2.66  L    
#>  7 IRV         2     2.13  L    
#>  8 EC          2.5   2.66  L    
#>  9 ERV         2     2.13  L    
#> 10 VC          4.5   4.78  L
```

## Metabolic Rate & Oxygen Consumption Calculator

In a laboratory experiment using [Harvard
Spirometer](https://www.somatco.com/Recording-Spirometer-50-1833-50-1817.pdf),
this package provides functions to calculate metabolic rate and oxygen
consumption by input a displacement in x-and y-direction of Harvard
spirometer tracing, height and weight of the subject, and environmental
conditions which are temperature and barometric pressure.

### Oxygen Consumption

In Harvard spirometer tracing, horizontal direction (x-direction)
represents time (default paper speed = 25 mm/min) whereas vertical
direction (y-direction) represents usage of oxygen (1 mm = 30 ml of
oxygen). With a little bit of calculation, we can derived an oxygen
consumption in unit of L/hr in the **ATPS** condition (**A**mbient
**T**emperature and barometric **P**ressure **S**aturated with water
vapor condition).

You can use `get_oxycons()` to calculate oxygen consumption and it will
also provide other info printed to R console as well.

``` r
oxycons <- get_oxycons(x = 15, # displacement in x-direction = 15 mm
            y = 80, # displacement in y-direction = 80 mm
            paper_speed = 25 # Paper speed of the kymograph = 25 mm/min
            )
#> Harvard spirometer tracing:
#>  - Paper speed = 25 mm/min 
#>  - Time interval = 0.6 min (horizontal displacement = 15 mm)
#>  - Volume change = 2400 ml (vertical displacement = 80 mm)
#> 
#> Oxygen Consumption at ATPS = 240 L/hr
```

### Metabolic Rate

To calculate metabolic rate, we must first convert oxygen consumption
*V̇*<sub>*o*<sub>2</sub></sub> at **ATPS** to **STPD** (**S**tandard
**T**emperature of 0°C and a barometric **P**ressure of 760 mmHg, and in
a **D**ry state).

STPD correction factor can be used to convert gas in ATPS to BTPS
condition. It has a linear relationship with barometric pressure and
temperature.

Therefore, `get_STPD_factor()` can be used to predict STPD factor using
`baro` and `temp_c` as predictors. (It use multiple linear regression
model behind the scene.)

``` r
stpd_760_25 <- get_STPD_factor(
  baro = 760, # Barometric pressure at the recording site.
  temp_c = 25 # Temperature in celsius at the recording site.
  ) 
#> STPD correction factor = 0.883 (760 mmHg, 25 degree celcius)
```

Correction can be made by multiply oxygen consumption
*V̇*<sub>*o*<sub>2</sub></sub> at ATPS to STPD correction factor.

``` r
oxycons * stpd_760_25 # Unit in L/hr
#> [1] 211.9386
```

Finally, metabolic rate can be calculated by times an oxygen consumption
*V̇*<sub>*o*<sub>2</sub></sub> (L/hr) at STPD to a caloric equivalent of
oxygen (Cal/hr) divided by Body Surface Area (BSA) in m<sup>2</sup>,
which can be calculated by [DuBois & DuBois
formula](http://www-users.med.cornell.edu/~spon/picu/calc/bsacalc.htm)
(DuBois D, DuBois EF)

<!-- $$ -->
<!-- Met \ Rate \ (Cal/m^2/hr) = \frac{ \dot{V}_{o_2} (L/hr)  \times CalEqi \ O_2 \ (Cal/hr)}{ BSA \ (m^2) }  -->
<!-- $$ -->

![equation](https://latex.codecogs.com/svg.latex?Met%20%5C%20Rate%20%5C%20%28Cal/m%5E2/hr%29%20%3D%20%5Cfrac%7B%20%5Cdot%7BV%7D_%7Bo_2%7D%20%28L/hr%29%20%5Ctimes%20CalEqi%20%5C%20O_2%20%5C%20%28Cal/hr%29%7D%7B%20BSA%20%5C%20%28m%5E2%29%20%7D)

`get_metabolic_rate()` is a final wrapper function that calculate
metabolic rate; moreover, it also reports metabolic rate along with
oxygen consumption and other related parameters printed to the R
console.

``` r
get_metabolic_rate(x = 15, # displacement in x-direction = 15 mm
                   y = 80, # displacement in y-direction = 80 mm
                   paper_speed = 25, # Paper speed of the kymograph = 25 mm/min
                   baro = 760, # Barometric pressure at the recording site.
                   temp_c = 25, # Temperature in celsius at the recording site.
                   wt_kg = 70, # Subject's weight in kilogram
                   ht_cm = 180, # Subject's height in centimetre
                   cal_eqi_oxygen = 4.825 # Caloric equivalent of Oxygen at RQ = 0.82
)
#> Harvard spirometer tracing:
#>  - Paper speed = 25 mm/min 
#>  - Time interval = 0.6 min (horizontal displacement = 15 mm)
#>  - Volume change = 2400 ml (vertical displacement = 80 mm)
#> 
#> Oxygen Consumption at ATPS = 240 L/hr
#> 
#> Metabolic rate calculation:
#>  - STPD correction factor = 0.883 (760 mmHg, 25 degree celcius) 
#>  - Oxygen Consumption at STPD = 211.939 L/hr (0.883 x 240 L/hr)
#>  - Caloric equivalent of Oxygen = 4.825 Cal/L of Oxygen
#>  - BSA = 1.886 square metre (wt = 70 kg, ht = 180 cm)
#> 
#> Metabolic Rate = 542.128 Cal/m2/hr
```
