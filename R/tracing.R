

# Simulate Harvard Spirometer Tracing -------------------------------------


#' Simulate Harvard Spirometer Tracing
#'
#' This function simulates volume-time tracing data produced by breathing of a hypothetical subject as recorded by the Harvard spirometer.
#' A number of parameters can be specified to adjust the tracing data. The output of this function is a data frame to be plotted by the user.
#'
#' @param f (Character or Symbol) A function to generate 1 respiratory cycle (i.e., inspiration and expiration). The default, currently, is a cosine function. Any function can be specified such that the amplitude is 1 (peak at 1, trough at -1) and the wavelength is `2*pi`.
#' @param t_start (Numeric) Time point (minute) when the experiment start
#' @param t_end (Numeric) Time point (minute) when the experiment end
#' @param paper_speed (Numeric) Paper speed (mm/minute) of the tracing
#' @param TV (Numeric) Tidal volume (mL) that subject breath
#' @param RR (Numeric) Respiratory Rate (/min) of subject
#' @param oxycons (Numeric) Oxygen consumption of subject
#' @param oxycons_unit (Character) Units of the `oxycons` must be one of: "L/hr" or "ml/min".
#' @param y_int_O2_line (Numeric) Y-intercept of an oxygen-line, i.e., the baseline that passed through the trough of each respiratory cycle waves.
#' @param seq_x_by (Numeric) Difference between consecutive `x` values to generate. (similar to `by` argument of `seq()`)
#' @param epsilon_sd If provided as numeric, it is a standard deviation of an error term sampled from Gaussian distribution with `mean = 0`
#' @param seed (Numeric) If provided `epsilon_sd`, It is a seed to generated random error variation.
#'
#' @return A data.frame with "HarvardTracing" subclass which has 3 columns:
#' * \strong{x}: x-axis data of the respiratory wave tracing (in milimeter)
#' * \strong{y}: y-axis data of the respiratory wave tracing (in milimeter)
#' * \strong{y_O2_line}: y-axis data of the oxygen-line (in milimeter)
#'
#' @export
#'
#' @examples
sim_Harvard_tracing <- function(f = "cos",
                                t_start = 0,  # Time Start & End (minute)
                                t_end = 1,
                                paper_speed = 25, # Paper speed (mm/minute)
                                TV = 500, # Tidal Volume (mL)
                                RR = 20, # Repiratory Rate (/minute)
                                oxycons = 0, # Oxygen consumption
                                oxycons_unit = c("L/hr", "ml/min"), # Unit of `oxycons`
                                y_int_O2_line = 0, # Y-intercept of Oxygen line
                                seq_x_by = 0.05,
                                epsilon_sd = NULL,
                                seed = 1
){

  oxycons_unit <- match.arg(oxycons_unit)
  # X
  xmin <- 25 * t_start
  xmax <- 25 * t_end
  x_delta <- xmax - xmin
  # Y
  ## Unit of Oxygen Consumption
  unit_conv <- switch (oxycons_unit,
                       "L/hr" = { 1000/60 },
                       "ml/min" = { 1 }
  )
  y_delta <- oxycons * (x_delta/paper_speed) * (1/30) * unit_conv

  # Wave length & Amplitude
  lambda <- 25 / RR
  amp <- (-TV)/(2*30) # negative, so that cosine will filp upward

  # Linear Params
  slope <- y_delta/x_delta
  y_intercept <- y_int_O2_line + abs(amp)

  # Oxygen Line
  x <- seq(xmin, xmax, by = seq_x_by)
  ## Error term (Optional)
  epsilon <- if (!is.null(epsilon_sd)) {
    set.seed(seed)
    stats::rnorm(length(x), mean = 0, sd = epsilon_sd)
  } else {
    0L
  }

  y_O2_line <-  slope*x + y_int_O2_line + epsilon

  ## Combine
  set.seed(seed)
  df_out <- simWaves::sim_sinusoid_lm(f = f, lambda = lambda, amp = amp,
                                      xmin = xmin, xmax = xmax,
                                      slope = slope, y_intercept = y_intercept,
                                      by = seq_x_by, epsilon_sd = epsilon_sd)

  df_out[["y_O2_line"]] <- y_O2_line

  # Add "HarvardTracing" Class & "tracing_info" attributes
  df_out <- new_HarvardTracing(df_out,
                               tracing_info = list(
                                 f = get(as.character(f)),
                                 x_delta = x_delta,
                                 y_delta = y_delta,
                                 y_intercept = y_intercept,
                                 lambda = lambda, amp = amp
                               )
  )

  df_out
}

