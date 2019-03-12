# ------------------------------------------------------------------------------
# Supported using the default behavior

# summarise()
# do()

# group_nest()
# group_map()
# group_walk()
# group_split()

# ------------------------------------------------------------------------------
# dplyr support

#' @export
mutate.resampled_df <- function(.data, ...) {
  dplyr::mutate(collect(.data), ...)
}

#' @export
transmute.resampled_df <- function(.data, ...) {
  dplyr::transmute(collect(.data), ...)
}

# Required to export filter, otherwise:
# Warning: declared S3 method 'filter.resampled_df' not found
# because of stats::filter

#' @importFrom dplyr filter
#' @export
dplyr::filter

#' @export
filter.resampled_df <- function(.data, ...) {
  dplyr::filter(collect(.data), ...)
}

#' @export
arrange.resampled_df <- function(.data, ...) {
  dplyr::arrange(collect(.data), ...)
}

#' @export
distinct.resampled_df <- function(.data, ..., .keep_all = FALSE) {
  dplyr::distinct(collect(.data), ..., .keep_all = .keep_all)
}

#' @export
full_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::full_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @export
inner_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::inner_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @export
left_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::left_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @export
right_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::right_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @export
anti_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, ...) {
  dplyr::anti_join(collect(x), collect(y), by = by, copy = copy, ...)
}

#' @export
semi_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, ...) {
  dplyr::semi_join(collect(x), collect(y), by = by, copy = copy, ...)
}

#' @export
select.resampled_df <- function(.data, ...) {
  dplyr::select(collect(.data), ...)
}

#' @export
slice.resampled_df <- function(.data, ...) {
  dplyr::slice(collect(.data), ...)
}

#' @export
group_by.resampled_df <- function(.data, ..., add = FALSE, .drop = FALSE) {
  dplyr::group_by(collect(.data), ..., add = add, .drop = .drop)
}

#' @export
ungroup.resampled_df <- function(x, ...) {
  dplyr::ungroup(collect(.data), ...)
}

# ------------------------------------------------------------------------------
# Backwards compat support for deprecated standard eval dplyr

# Only a few of them need it. arrange_.grouped_df()
# directly calls arrange_impl() causing a problem.

#' @export
arrange_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::arrange_(collect(.data), ..., .dots = .dots)
}

#' @export
mutate_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::mutate_(collect(.data), ..., .dots = .dots)
}

#' @export
summarise_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::summarise_(collect(.data), ..., .dots = .dots)
}

#' @export
summarize_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::summarize_(collect(.data), ..., .dots = .dots)
}

#' @export
slice_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::slice_(collect(.data), ..., .dots = .dots)
}
