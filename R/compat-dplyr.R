# ------------------------------------------------------------------------------
# Supported dplyr functions

# In theory we could let the default `summarise()` do its thing. But if the
# user did a double `bootstrapify()` call, only one level of it will be removed
# and the post-summarise() object will still be a resampled_df, even though
# all of the bootstrap rows have been materialized.

#' @importFrom dplyr summarise
#' @export
summarise.resampled_df <- function(.data, ...) {
  maybe_new_grouped_df(NextMethod())
}

# ------------------------------------------------------------------------------
# Supported dplyr functions - Standard evaluation backwards compat

#' @importFrom dplyr summarise_
#' @export
summarise_.resampled_df <- function(.data, ..., .dots = list()) {
  maybe_new_grouped_df(NextMethod())
}

#' @importFrom dplyr summarize_
#' @export
summarize_.resampled_df <- function(.data, ..., .dots = list()) {
  maybe_new_grouped_df(NextMethod())
}

# summarise()
# do()

# ungroup()

# group_nest()
# group_map()
# group_walk()
# group_split()

maybe_new_grouped_df <- function(x) {

  if (dplyr::is_grouped_df(x)) {
    x <- dplyr::new_grouped_df(x = x, groups = dplyr::group_data(x))
  }

  x
}

# ------------------------------------------------------------------------------
# dplyr support

#' @importFrom dplyr mutate
#' @export
mutate.resampled_df <- function(.data, ...) {
  dplyr::mutate(collect(.data), ...)
}

#' @importFrom dplyr transmute
#' @export
transmute.resampled_df <- function(.data, ...) {
  dplyr::transmute(collect(.data), ...)
}

# Required to export filter, otherwise:
# Warning: declared S3 method 'filter.resampled_df' not found
# because of stats::filter

#' @export
dplyr::filter

#' @importFrom dplyr filter
#' @export
filter.resampled_df <- function(.data, ...) {
  dplyr::filter(collect(.data), ...)
}

#' @importFrom dplyr arrange
#' @export
arrange.resampled_df <- function(.data, ...) {
  dplyr::arrange(collect(.data), ...)
}

#' @importFrom dplyr distinct
#' @export
distinct.resampled_df <- function(.data, ..., .keep_all = FALSE) {
  dplyr::distinct(collect(.data), ..., .keep_all = .keep_all)
}

#' @importFrom dplyr full_join
#' @export
full_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::full_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @importFrom dplyr inner_join
#' @export
inner_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::inner_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @importFrom dplyr left_join
#' @export
left_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::left_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @importFrom dplyr right_join
#' @export
right_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), ...) {
  dplyr::right_join(collect(x), collect(y), by = by, copy = copy, suffix = suffix, ...)
}

#' @importFrom dplyr anti_join
#' @export
anti_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, ...) {
  dplyr::anti_join(collect(x), collect(y), by = by, copy = copy, ...)
}

#' @importFrom dplyr semi_join
#' @export
semi_join.resampled_df <- function(x, y, by = NULL, copy = FALSE, ...) {
  dplyr::semi_join(collect(x), collect(y), by = by, copy = copy, ...)
}

#' @importFrom dplyr select
#' @export
select.resampled_df <- function(.data, ...) {
  dplyr::select(collect(.data), ...)
}

#' @importFrom dplyr slice
#' @export
slice.resampled_df <- function(.data, ...) {
  dplyr::slice(collect(.data), ...)
}

#' @importFrom dplyr group_by
#' @export
group_by.resampled_df <- function(.data, ..., add = FALSE, .drop = FALSE) {
  dplyr::group_by(collect(.data), ..., add = add, .drop = .drop)
}

# ------------------------------------------------------------------------------
# Backwards compat support for deprecated standard eval dplyr

# Only a few of them need it. arrange_.grouped_df()
# directly calls arrange_impl() causing a problem.

#' @importFrom dplyr arrange_
#' @export
arrange_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::arrange_(collect(.data), ..., .dots = .dots)
}

#' @importFrom dplyr mutate_
#' @export
mutate_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::mutate_(collect(.data), ..., .dots = .dots)
}

#' @importFrom dplyr slice_
#' @export
slice_.resampled_df <- function(.data, ..., .dots = list()) {
  dplyr::slice_(collect(.data), ..., .dots = .dots)
}
