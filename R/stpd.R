
# Get STPD factor ---------------------------------------------------------



#' Get STPD correction factor
#'
#' This function predicts STPD correction factor using linear model with predictor variables: `baro` for barometric pressure and `temp_c` for temperature in celsius.
#' The data that linear model was fitted can be found in a data frame [`btps_df`][rslab::btps_df].
#'
#' @param baro (Numeric) Barometric pressure (in mmHg) at the collection site.
#' @param temp_c (Numeric) Temperature in celsius at the collection site.
#' @param interval Type of interval calculation: "None" returns estimated STPD correction factor; "confidence" and "prediction" return confidence interval and prediction interval, respectively.
#' @param level Tolerance/confidence level.
#' @param ... passed to `predict.lm()`
#'
#' @return A numeric vector (invisibly) or matrix (if `interval` = "confidence" or "prediction").
#' @export
#'
#' @examples
#' # Estimated STPD factor
#' get_STPD_factor(baro = 761, temp_c = 29)
#' get_STPD_factor(baro = 761:762, temp_c = 29:30) # Vectorized
#'
#' # Estimated STPD factor value with confidence Interval
#' get_STPD_factor(baro = 761:762, temp_c = 29:30, interval = "c")
get_STPD_factor <- function(baro,
                            temp_c,
                            interval = c("none", "confidence", "prediction"),
                            level = 0.95,
                            ...
) {

  interval <- match.arg(interval)
  ## Predict STPD from Multiple LM
  stpd <- predict(stpd_lm_fit,
                  newdata = data.frame(baro = baro, temp_c = temp_c),
                  interval = interval,
                  level = level,
                  ...
  )

  ## For return one value
  if(interval == "none"){
    cat(
      paste0("STPD correction factor = ", round(stpd, 3),
             " (", baro, " mmHg, ", temp_c, " degree celcius",") "),
      sep = "\n"
    )
    return(invisible(unname(stpd)))
  }

  stpd

}


# STPD_df -----------------------------------------------------------------



#' STPD Correction factor Lookup Table
#'
#' A data frame contain STPD correction factor (in long format)
#'
#'
#' @format A data frame with 738 rows and 3 variables:
#' \describe{
#'   \item{baro}{Barometric pressure in mmHG}
#'   \item{temp_c}{Temperature in degree celsius}
#'   \item{stpd_factor}{STPD correction factor}
#'
#' }
#' @source William D. McArdle, Frank I. Katch, and Victor L. Katch (1996). Appendixes. In:Donna Balado Exercise Physiology:Energy, Nutrition, and Human Performance. MD, USA:Willams & Wilkins. P768
"stpd_df"

# STPD_df_wide -----------------------------------------------------------------


#' STPD Correction factor Lookup Table (Wide format)
#'
#' A data frame contain STPD correction factor (in wide format)
#'
#'
#' @format A data frame with 41 rows and 19 variables:
#' \describe{
#'   \item{baro}{Barometric pressure in mmHG}
#'   \item{temp_c_15}{STPD correction factors at temperature of 15 degree celsius}
#'   \item{temp_c_16}{STPD correction factors at temperature of 16 degree celsius}
#'   \item{temp_c_17}{STPD correction factors at temperature of 17 degree celsius}
#'   \item{temp_c_18}{STPD correction factors at temperature of 18 degree celsius}
#'   \item{temp_c_19}{STPD correction factors at temperature of 19 degree celsius}
#'   \item{temp_c_20}{STPD correction factors at temperature of 20 degree celsius}
#'   \item{temp_c_21}{STPD correction factors at temperature of 21 degree celsius}
#'   \item{temp_c_22}{STPD correction factors at temperature of 22 degree celsius}
#'   \item{temp_c_23}{STPD correction factors at temperature of 23 degree celsius}
#'   \item{temp_c_24}{STPD correction factors at temperature of 24 degree celsius}
#'   \item{temp_c_25}{STPD correction factors at temperature of 25 degree celsius}
#'   \item{temp_c_26}{STPD correction factors at temperature of 26 degree celsius}
#'   \item{temp_c_27}{STPD correction factors at temperature of 27 degree celsius}
#'   \item{temp_c_28}{STPD correction factors at temperature of 28 degree celsius}
#'   \item{temp_c_29}{STPD correction factors at temperature of 29 degree celsius}
#'   \item{temp_c_30}{STPD correction factors at temperature of 30 degree celsius}
#'   \item{temp_c_31}{STPD correction factors at temperature of 31 degree celsius}
#'   \item{temp_c_32}{STPD correction factors at temperature of 32 degree celsius}
#'   ...
#' }
#' @source William D. McArdle, Frank I. Katch, and Victor L. Katch (1996). Appendixes. In:Donna Balado Exercise Physiology:Energy, Nutrition, and Human Performance. MD, USA:Willams & Wilkins. P768
"stpd_df_wide"


