#' Created a resampled tibble
#'
#' `samplify()` creates a resampled tibble with _virtual groups_.
#'
#' @details
#'
#' Currently you can use [dplyr::summarise()], [dplyr::do()], and the group
#' manipulation functions: [dplyr::group_map()], [dplyr::group_walk()],
#' [dplyr::group_nest()] and [dplyr::group_split()] on a `resampled_df`.
#'
#' @param data A tbl.
#'
#' @param times A single integer specifying the number of resamples.
#' If the `tibble` is grouped, this is the number of resamples per group.
#'
#' @param size A single integer specifying the size of each resample.
#'
#' @param ... Not used.
#'
#' @param replace Whether or not to sample with replacement.
#'
#' @param key A single character specifying the name of the virtual group
#' that is added.
#'
#' @return A `resampled_df` with an extra group specified by `key`.
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
#' @family virtual samplers
#'
#' @name samplify
NULL

#' @rdname samplify
#' @export
samplify <- function(data, times, size, ...,
                     replace = FALSE, key = ".sample") {
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

  check_empty_dots(...)

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

  check_empty_dots(...)

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
