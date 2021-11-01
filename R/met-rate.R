
# Metabolic Rate ----------------------------------------------------------



#' Calculate Metabolic Rate
#'
#' This function compute metabolic rate (Cal/m2/hr) from [Harvard Spirometer](https://www.somatco.com/Recording-Spirometer-50-1833-50-1817.pdf) tracing,
#'  subject's weight and height, and environmental condition i.e., barometric pressure and temperature.
#'  The output printed to console will show each step of calculation which is suitable for educational purposes.
#'
#' @param x Displacement of tracing in x-direction (in millimeter).
#' @param y Displacement of tracing in y-direction (in millimeter).
#' @param paper_speed Paper speed of the kymograph (in millimeter/minute), 25 ml/min by default.
#' @param baro (If `condition` = "STPD") Barometric pressure at the recording site.
#' @param temp_c (If `condition` = "STPD") Temperature in celsius at the recording site.
#' @param wt_kg (Numeric) Weight of the subject in kilogram
#' @param ht_cm (Numeric) Height of the subject in centimetre
#' @param cal_eqi_oxygen (Numeric) Caloric equivalent of Oxygen (default is 4.825, at RQ = 0.82)
#'
#' @return Report printed to console, return metabolic rate in Cal/m2/hr, invisibly
#' @export
#'
#' @examples
#' get_metabolic_rate(x = 20, y = 10,
#'                    baro = 760, temp_c = 25,
#'                    wt_kg = 80, ht_cm = 180)
get_metabolic_rate <- function(x,
                               y,
                               paper_speed = 25,
                               baro,
                               temp_c,
                               wt_kg,
                               ht_cm,
                               cal_eqi_oxygen = 4.825
) {

  ## Check Missing Args
  is_miss_args <- missing(x) || missing(y) || missing(baro) || missing(temp_c) || missing(wt_kg) || missing(ht_cm)
  if(is_miss_args) stop("Must provide all of these args: `x`, `y`, `baro`, `temp_c`, `wt_kg`, `ht_cm`.")

  # Oxygen Consumption at ATPS (L/hr)
  # oxycons_ATPS <- get_oxycons_ATPS(x = x, y = y)
  oxycons_ATPS <- get_oxycons(x = x, y = y, paper_speed = paper_speed, condition = "ATPS")

  # Metabolic Rate Calc
  cat("\n", crayon::yellow$bold("Metabolic rate calculation:"), "\n", sep = "")

  ## STPD correction factor
  cat(" - ")
  stpd_factor <- get_STPD_factor(baro = baro, temp_c = temp_c)
  ## Oxygen Consumption at STPD (L/hr)
  oxycons_STPD <- oxycons_ATPS * stpd_factor
  cat(" - ", "Oxygen Consumption at STPD = ",
      round(oxycons_STPD, 3), " L/hr ",
      "(", round(stpd_factor, 3), " x ", round(oxycons_ATPS, 3), " L/hr)",
      "\n", sep = "")
  ## Caloric Equivalent of Oxygen
  cat(" - ", "Caloric equivalent of Oxygen = ",
      cal_eqi_oxygen, " Cal/L of Oxygen", "\n", sep = "")
  ## Body Surface Area
  cat(" - ")
  bsa <- get_BSA(wt_kg = wt_kg, ht_cm = ht_cm)
  ## Metabolic Rate (Cal/m2/hr)
  met_rate <- oxycons_STPD * cal_eqi_oxygen / bsa

  cat("\n")
  cat(crayon::green$bold("Metabolic Rate =", c(

    round(met_rate, 3)

  ), "Cal/m2/hr", "\n\n"
  ))

  invisible(met_rate)

}


# Body Surface Area -------------------------------------------------------


#' Calculate Body Surface Area
#'
#' This function calculate BSA (Body Surface Area) in square metre using [DuBois & DuBois formula](http://www-users.med.cornell.edu/~spon/picu/calc/bsacalc.htm) (DuBois D, DuBois EF)
#'
#'
#' @param wt_kg (Numeric) Weight in kilogram
#' @param ht_cm (Numeric) Height in centimetre
#'
#' @return Print report to console and return BSA invisibly
#' @export
#'
#' @examples
#'
#' # BSA in square metre
#' get_BSA(wt_kg = 70, ht_cm = 180)
#' # Input can be vectorized
#' get_BSA(wt_kg = 70:72, ht_cm = 180:182)
#'
get_BSA <- function(wt_kg, ht_cm) {

  bsa_msq <- 0.007184 * (wt_kg^0.425) * (ht_cm^0.725)

  cat(
    paste0("BSA = ", round(bsa_msq, 3), " square metre ",
           "(wt = ", wt_kg, " kg, ", "ht = ", ht_cm, " cm)"),
    sep = "\n"
  )
  invisible(bsa_msq)

}
