# ------------------------------------------------------------------------------
# tidyr support

#' @importFrom tidyr nest
#' @export
nest.resampled_df <- function(.data, ..., .key = "DEPRECATED") {
  tidyr::nest(collect(.data), ..., .key = .key)
}
