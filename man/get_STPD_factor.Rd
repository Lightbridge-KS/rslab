% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stpd.R
\name{get_STPD_factor}
\alias{get_STPD_factor}
\title{Get STPD correction factor}
\usage{
get_STPD_factor(
  baro,
  temp_c,
  interval = c("none", "confidence", "prediction"),
  level = 0.95,
  ...
)
}
\arguments{
\item{baro}{(Numeric) Barometric pressure (in mmHg) at the collection site.}

\item{temp_c}{(Numeric) Temperature in celsius at the collection site.}

\item{interval}{Type of interval calculation: "None" returns estimated STPD correction factor; "confidence" and "prediction" return confidence interval and prediction interval, respectively.}

\item{level}{Tolerance/confidence level.}

\item{...}{passed to \code{predict.lm()}}
}
\value{
A numeric vector (invisibly) or matrix (if \code{interval} = "confidence" or "prediction").
}
\description{
This function predicts STPD correction factor using linear model with predictor variables: \code{baro} for barometric pressure and \code{temp_c} for temperature in celsius.
The data that linear model was fitted can be found in a data frame \code{\link[=btps_df]{btps_df}}.
}
\examples{
# Estimated STPD factor
get_STPD_factor(baro = 761, temp_c = 29)
get_STPD_factor(baro = 761:762, temp_c = 29:30) # Vectorized

# Estimated STPD factor value with confidence Interval
get_STPD_factor(baro = 761:762, temp_c = 29:30, interval = "c")
}
