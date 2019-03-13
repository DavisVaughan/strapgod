# ------------------------------------------------------------------------------
# tidyr support

#' @importFrom tidyr nest
#' @export
nest.resampled_df <- function(data, ..., .key = "data") {
  tidyr::nest(collect(data), ..., .key = !!rlang::enquo(.key))
}
