

# Harvard Tracing Object --------------------------------------------------


#' New HarvardTracing Object
#'
#' @param x A data frame with at least `x` and `y` column
#' @param tracing_info list of values to be assigned to `tracing_info` attribute
#'
#' @return a `HarvardTracing` data frame
#'
new_HarvardTracing <- function(x,
                               tracing_info = list()
){
  # Validate
  stopifnot(is.data.frame(x), all(c("x", "y") %in% colnames(x)))
  # Add Class
  class(x) <- c("HarvardTracing", class(x))
  # Add Attributes
  attr(x, "tracing_info") <- tracing_info
  x

}


# Tracing Info ------------------------------------------------------------


#' Get Tracing Info from Harvard Spirometer Tracing
#'
#' This function retrieve `tracing_info` attributes from `HarvardTracing` data frame
#' produced by [sim_Harvard_tracing()].
#'
#' @param x An object class `HarvardTracing`
#'
#' @return A list with each element contains key information of the tracing
#' @export
#'
#' @examples
tracing_info <- function(x){

  if(!inherits(x, "HarvardTracing")) stop("`x` must be a 'HarvardTracing' data frame.", call. = F)

  attr(x, "tracing_info")

}
