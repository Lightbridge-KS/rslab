#' Calculate Oxygen Consumption from Harvard Spirometer
#'
#' This function compute oxygen consumption from [Harvard Spirometer](https://www.somatco.com/Recording-Spirometer-50-1833-50-1817.pdf) tracing.
#' Simply define 2 points along oxygen line, and provide displacement in x-and y-direction.
#' Oxygen consumption can be reported in units: L/hr or ml/min, and at condition: ATPS or STPD.
#'
#' @param x Displacement of tracing in x-direction (in millimeter).
#' @param y Displacement of tracing in y-direction (in millimeter).
#' @param paper_speed Paper speed of the kymograph (in millimeter/minute).
#' @param unit (Character) Unit of the oxygen consumption to return, e.g. L/hr (default).
#' @param condition (Character) Environmental condition to calculate oxygen consumption that affect gas volume, must be one of:
#' * \strong{ATPS:} Volume of gas at ambient (A) temperature (T) (room temperature) and barometric pressure (P) saturated (S) with water vapor.
#' * \strong{STPD:} Volume of gas at the standard (S) temperature (T) of 0°C and a barometric pressure (P) of 760 mmHg, and in a dry state (D).
#' @param baro (If `condition` = "STPD") Barometric pressure at the recording site.
#' @param temp_c (If `condition` = "STPD") Temperature in celsius at the recording site.
#'
#' @return Print information to console and return oxygen consumption as numeric vector, invisibly.
#' @export
#'
#' @examples
#' # Oxygen Consumption at ATPS in L/hr
#' get_oxycons(x = 100, y = 50)
#' # Oxygen Consumption at ATPS in ml/min
#' get_oxycons(x = 100, y = 50, unit = "ml/min")
#' # Oxygen Consumption at STPD, in L/hr, must provide `baro` and `temp_c`
#' get_oxycons(x = 100, y = 50, condition = "STPD", baro = 760, temp_c = 23)
get_oxycons <- function(x,
                        y,
                        paper_speed = 25,
                        unit = c("L/hr","ml/min"),
                        condition = c("ATPS", "STPD"),
                        baro = NA,
                        temp_c = NA
) {

  unit <- match.arg(unit)
  condition <- match.arg(condition)
  if (condition == "STPD" &&  any(is.na(baro) | is.na(temp_c))) {
    stop("For Oxygen Consumption at STPD, please provide values for `baro` and `temp_c`.", call. = FALSE)
  }

  ## Oxygen Consumption in ml/min at ATPS
  time_min <- x/paper_speed # Time Interval (minute)
  vol_ml <- y * 30 # Volume Change (ml)
  oxycons_ml_min <- (vol_ml)/(time_min)

  out_ATPS <- switch (unit,
                      "L/hr" = { oxycons_ml_min*60/1000 },
                      "ml/min" = { oxycons_ml_min }
  )

  ## Get STPD factor (if oxycons at STPD)
  if (condition == "STPD") {
    stpd_factor <- predict(stpd_lm_fit,
                           newdata = data.frame(baro = baro, temp_c = temp_c),
                           interval = NULL
    )
  }

  ## Times STPD factor (if oxycons at STPD)
  if (condition == "STPD") {
    out_STPD <- out_ATPS * stpd_factor
  }

  cat(
    paste0(crayon::yellow$bold("Harvard spirometer tracing:"),"\n",

           " - Paper speed = ", paper_speed, " mm/min ", "\n",

           " - Time interval = ", time_min, " min ",
           "(horizontal displacement = ", x," mm)", "\n",

           " - Volume change = ", vol_ml, " ml ",
           "(vertical displacement = ", y," mm)", "\n",

           if(condition == "STPD") {
             paste0(" - STPD Correction factor = ", round(stpd_factor, 3),
                    " (", baro, " mmHg, ", temp_c, " degree celcius)",
                    "\n")
           },

           "\n",

           switch (condition,
                   "ATPS" = {
                     crayon::green$bold("Oxygen Consumption at ATPS =", round(out_ATPS, 3), unit)
                   },
                   "STPD" = {
                     crayon::green$bold("Oxygen Consumption at STPD =", round(out_STPD, 3), unit)
                   }
           )
    ),
    sep = "\n\n"
  )

  ## Return Raw Value Invisibly
  switch (condition,
          "ATPS" = {
            return(invisible(out_ATPS))
          },
          "STPD" = {
            return(invisible(out_STPD))
          }
  )

}
