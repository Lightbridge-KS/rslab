

# Convert Lung Vol --------------------------------------------------------


#' Convert Lung Volume from ATPS to BTPS
#'
#' This function converts several lung volume parameters at ATPS (Ambient Temperature and Pressure Saturated) to
#' lung volume at BTPS (Body Temperature, Pressure, water vapor Saturated).
#'
#' @param temp (Numeric) Room Temperature in celsius when gas was collected.
#' @param FEV1 (numeric) Forced Expiratory Volume in 1 second (L).
#' @param FVC (numeric) Forced Vital Capacity (L)
#' @param PEF (numeric) Peak Expiratory Flow (L/min)
#' @param TV (numeric) Tidal Volume (L)
#' @param IC (numeric) Inspiratory Capacity (L)
#' @param EC (numeric) Expiratory Capacity (L)
#' @param VC (numeric) Vital Capacity (L)
#'
#' @return A Tibble
#' @export
#'
#' @examples
#' lung_vol_atps_btps(FEV1 = 5, FVC = 10, PEF = 4, TV = 9, IC = 10, EC = 12, VC = 10)
lung_vol_atps_btps <- function(temp = NA,
                               FEV1 = NA,
                               FVC = NA,
                               PEF = NA,
                               TV = NA,
                               IC = NA,
                               EC = NA,
                               VC = NA
) {


  args_len1 <- all(sapply(list(temp, FEV1, FVC, PEF, TV,  IC,  EC,  VC), length) == 1)

  if(!args_len1) stop("All arguments must be length = 1", call. = FALSE)
  # Validate Lung Volume that VC ≥ IC ≥ TV and EC ≥ TV
  valid_lung_vol <- all((VC >= IC), (IC >= TV), (EC >= TV), na.rm = TRUE)
  if(!valid_lung_vol) stop("Not a valid lung volumn.", call. = FALSE)

  atps_val <- c(FEV1 = FEV1,
                FVC = FVC,
                `FEV1/FVC` = FEV1*100/FVC,
                PEF = PEF,
                TV = TV,
                IC = IC,
                IRV = IC - TV,
                EC = EC,
                ERV = EC - TV,
                VC = VC)
  unit <- c(rep("L", 2), "%", "L/min", rep("L", 6))

  btps_factor <- get_btps_factor(temp = temp)

  atps_val %>%
    tibble::enframe("Parameter", "ATPS") %>%
    # Compute BTPS & Add Unit
    dplyr::mutate(BTPS = ATPS * btps_factor,
                  Unit = unit)

}


# Get BTPS factor ---------------------------------------------------------


#' Get BTPS Correction factor
#'
#' Compute correction factor to convert gas volumes from room temperature saturated to BTPS, assuming that gas was sampled at barometric pressure of 760 mmHg.
#'
#' @param temp (Numeric) Room Temperature in celsius when gas was collected.
#'
#' @return A numeric factor to convert volume of gas to 37 celsius saturated with water vapor
#' @export
#'
#' @examples
#' # If temp in lookup table, simply use BTPS Correction factor from the table
#' get_btps_factor(20)
#' # If temp not in lookup table, use prediction by linear model.
#' get_btps_factor(20.5)
#' # Input can be vectorised
#' get_btps_factor(c(20.5, NA, 21:22))
#'
get_btps_factor <- function(temp) {

  ## Validate Input
  na_len1 <- (length(temp) == 1L) && is.na(temp)
  not_valid <- !is.numeric(temp) && !na_len1
  if(not_valid) stop("`temp` must be a numeric vector.", call. = FALSE)

  ## Iterate every element of `temp`
  out <- vector("numeric", length(temp))
  for (i in seq_along(temp)) {

    temp_i <- temp[[i]]

    ## If `NA` assign it, then skip to next value
    if(is.na(temp_i)){
      out[[i]] <- NA
      next
    }

    ## If `temp` in lookup table
    if (temp_i %in% btps_df[["Gas_temp_c"]]) {

      # Use `Factor_37` from lookup table
      factor_37_lookup_i <- btps_df[btps_df[["Gas_temp_c"]] == temp_i, ][["Factor_37"]]
      out[[i]] <- factor_37_lookup_i

    } else {
      ## If not, fit linear model of `Factor_37` on `Gas_temp_c` and then predict
      lm_fit <- lm(Factor_37 ~ Gas_temp_c, data = btps_df)
      newpoint <- data.frame(Gas_temp_c = temp_i)

      factor_37_pred_i <- unname(predict(lm_fit, newdata = newpoint, interval = "none"))
      out[[i]] <- factor_37_pred_i

    }

  }

  return(out)

}

#' BTPS Correction factor Lookup Table
#'
#' A data frame that has 2 columns:
#'
#'
#'
#' @format A data frame that has 2 columns:
#' * \strong{Gas_temp_c}: Gas temperature in celsius
#' * \strong{Factor_37}: factor to convert volume of gas to 37 celsius saturated
"btps_df"
