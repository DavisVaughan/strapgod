# ------------------------------------------------------------------------------
# tidyr support

#' @importFrom tidyr nest
#' @importFrom lifecycle deprecated
#' @export
nest.resampled_df <- function(.data, ..., .key = deprecated()) {
  tidyr::nest(collect(.data), ..., .key = .key)
}
