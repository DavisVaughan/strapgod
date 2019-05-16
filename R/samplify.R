#' Created a resampled tibble
#'
#' `samplify()` creates a resampled tibble with _virtual groups_.
#'
#' @details
#'
#' The following functions have special / interesting behavior when used with
#' a `resampled_df`:
#'
#' - [dplyr::collect()]
#'
#' - [dplyr::summarise()]
#'
#' - [dplyr::do()]
#'
#' - [dplyr::group_map()]
#'
#' - [dplyr::group_modify()]
#'
#' - [dplyr::group_walk()]
#'
#' - [dplyr::group_nest()]
#'
#' - [dplyr::group_split()]
#'
#' @param data A tbl.
#'
#' @param times A single integer specifying the number of resamples.
#' If the `tibble` is grouped, this is the number of resamples per group.
#'
#' @param size A single integer specifying the size of each resample. For a
#' grouped data frame, this is also allowed to be an integer vector with size
#' equal to the number of groups in `data`. This can be helpful when sampling
#' without replacement when the number of rows per group is very different.
#'
#' @param ... Not used.
#'
#' @param replace Whether or not to sample with replacement.
#'
#' @param key A single character specifying the name of the virtual group
#' that is added.
#'
#' @return A `resampled_df` with an extra group specified by the `key`.
#'
#' @examples
#' library(dplyr)
#' library(broom)
#'
#' samplify(iris, times = 3, size = 20)
#'
#' iris %>%
#'   samplify(times = 3, size = 20) %>%
#'   summarise(per_strap_mean = mean(Petal.Width))
#'
#' iris %>%
#'   group_by(Species) %>%
#'   samplify(times = 3, size = 20) %>%
#'   summarise(per_strap_species_mean = mean(Petal.Width))
#'
#' # Alter the name of the group with `key`
#' # Materialize them with collect()
#' samps <- samplify(iris, times = 3, size = 5, key = ".samps")
#' collect(samps)
#'
#' collect(samps, id = ".id", original_id = ".orig_id")
#'
#' #----------------------------------------------------------------------------
#'
#' # Be careful not to specify a `size` larger
#' # than one of your groups! This will throw an error.
#'
#' iris_group_sizes_of_50_and_5 <- iris[1:55,] %>%
#'   group_by(Species) %>%
#'   group_trim()
#'
#' count(iris_group_sizes_of_50_and_5, Species)
#'
#' # size = 10 > min_group_size = 5
#' \dontrun{
#' iris_group_sizes_of_50_and_5 %>%
#'   samplify(times = 2, size = 10)
#' }
#'
#' # Instead, pass a vector of sizes to `samplify()` if this
#' # structure is absolutely required for your use case.
#'
#' # size of 10 for the first group
#' # size of 5 for the second group
#' # total number of rows is 10 * 2 + 5 * 2 = 30
#' iris_group_sizes_of_50_and_5 %>%
#'   samplify(times = 2, size = c(10, 5)) %>%
#'   collect()
#'
#' @family virtual samplers
#'
#' @seealso [collect.resampled_df()]
#'
#' @name samplify
NULL

#' @rdname samplify
#' @export
samplify <- function(data, times, size, ...,
                     replace = FALSE, key = ".sample") {

  check_empty_dots(...)
  validate_is_scalar_character(key, "key")
  validate_is_bool(replace, "replace")
  validate_is_scalar_positive_integerish(times, "times")
  validate_is_positive_integerish(size, "size")

  UseMethod("samplify")
}

#' @export
samplify.data.frame <- function(data, times, size, ...,
                                replace = FALSE, key = ".sample") {
  samplify(
    data = dplyr::as_tibble(data),
    times = times,
    size = size,
    ...,
    replace = replace,
    key = key
  )
}

#' @export
samplify.tbl_df <- function(data, times, size, ...,
                            replace = FALSE, key = ".sample") {

  # additional check for size 1 here
  validate_is(
    size, "size", rlang::is_scalar_integerish,
    "a single integer (for ungrouped data frames)"
  )

  .row_slice_ids <- seq_len(nrow(data))

  group_info <- index_sampler(
    .row_slice_ids = .row_slice_ids,
    times = times,
    key = key,
    size = size,
    replace = replace
  )

  dplyr::new_grouped_df(data, group_info, class = "resampled_df")
}

#' @export
samplify.grouped_df <- function(data, times, size, ...,
                                replace = FALSE, key = ".sample") {

  size <- recycle_size(size, dplyr::n_groups(data))

  # extract existing group_info
  group_info <- dplyr::group_data(data)
  index_list <- group_info[[".rows"]]

  new_row_index_tbl <- map2(
    .x = index_list,
    .y = size,
    .f = function(.x, .y) {
      index_sampler(
        .row_slice_ids = .x,
        times = times,
        key = key,
        size = .y,
        replace = replace
      )
    }
  )

  # overwrite current .rows and unnest
  group_info[[".rows"]] <- new_row_index_tbl
  group_info <- tidyr::unnest(group_info)

  dplyr::new_grouped_df(data, group_info, class = "resampled_df")
}

# ------------------------------------------------------------------------------
# Utility

# Actually perform the resampling of the row indices
# and create the group tbl information from that

index_sampler <- function(.row_slice_ids,
                          times,
                          key,
                          size,
                          replace = FALSE) {

  check_size(size, length(.row_slice_ids), replace)

  .bootstrap_id <- seq_len(times)

  # must unquote the colname as `.rows` is an arg to tibble()
  .row_col <- ".rows"

  .index_list <- replicate(
    n = times,
    expr = sample(
      x = .row_slice_ids,
      size = size,
      replace = replace,
      prob = NULL
    ),
    simplify = FALSE
  )

  dplyr::tibble(
    !!key := .bootstrap_id,
    !!.row_col := .index_list
  )

}

# dplyr:::check_size()
check_size <- function (size, n, replace = FALSE) {
  if (size <= n || replace)
    return(invisible(size))

  msg <- paste0(
    "`size` (%i) must be less than or equal to the ",
    "size of the data / current group (%i), ",
    "set `replace = TRUE` to use sampling with replacement."
  )

  stop(sprintf(msg, size, n), call. = FALSE)
}

recycle_size <- function(.x, .n) {

  .n_x <- length(.x)

  if (.n_x == .n) {
    return(.x)
  }

  if (.n_x == 1L) {
    .x <- rep(.x, times = .n)
    return(.x)
  }

  msg <- paste0("`size` must be size 1 or ", .n, " (the number of groups).")
  rlang::abort(msg)
}

# ------------------------------------------------------------------------------
# Validation

validate_is <- function(.x, .x_nm, .is_f, .expected) {

  if (!.is_f(.x)) {
    msg <- paste0("`", .x_nm, "` must be ", .expected, ".")
    rlang::abort(msg)
  }

  invisible(.x)
}

validate_is_scalar_character <- function(.x, .x_nm) {
  validate_is(.x, .x_nm, rlang::is_scalar_character, "a single character")
}

is_bool <- function (x) {
  rlang::is_logical(x, n = 1) && !is.na(x)
}

validate_is_bool <- function(.x, .x_nm) {
  validate_is(.x, .x_nm, is_bool, "a single logical (TRUE/FALSE)")
}

is_positive <- function(x) {
  isTRUE(all(x > 0))
}

validate_is_scalar_positive_integerish <- function(.x, .x_nm) {
  validate_is(.x, .x_nm, rlang::is_scalar_integerish, "a single integer")
  validate_is(.x, .x_nm, is_positive, "a positive integer")
}

validate_is_positive_integerish <- function(.x, .x_nm) {
  validate_is(.x, .x_nm, rlang::is_integerish, "an integer vector")
  validate_is(.x, .x_nm, is_positive, "a positive integer vector")
}
