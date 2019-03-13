#' Force virtual groups to become explicit rows
#'
#' When `collect()` is used on a `resampled_df`, the virtual bootstrap groups
#' are made explicit.
#'
#' @param x A `resampled_df`.
#'
#' @param ... Not used.
#'
#' @param id Optional. A single character that specifies a name for a column
#' containing a sequence from `1:n` for each bootstrap group.
#'
#' @param original_id Optional. A single character that specifies a name for
#' a column containing the original position of the bootstrapped row.
#'
#' @examples
#' library(dplyr)
#'
#' # virtual groups become real rows
#' collect(bootstrapify(iris, 5))
#'
#' # add on the id column for an identifier per bootstrap
#' collect(bootstrapify(iris, 5), id = ".id")
#'
#' # add on the original_id column to know which row this bootstrapped row
#' # originally came from
#' collect(bootstrapify(iris, 5), original_id = ".original_id")
#'
#' @export
collect.resampled_df <- function(x, ..., id = NULL, original_id = NULL) {

  check_empty_dots(...)
  validate_null_or_single_character(id, "id")
  validate_null_or_single_character(original_id, "original_id")

  group_syms <- dplyr::groups(x)
  group_tbl <- dplyr::group_data(x)
  x <- dplyr::ungroup(x)

  # The only column names that are not in the x and are not '.rows' is the .key
  # Could potentially have multiple bootstrap columns
  .key <- setdiff(colnames(group_tbl), c(colnames(x), ".rows"))

  # Strip off non-virtual groups
  .out <- dplyr::select(group_tbl, !!!.key, .rows)

  # Order of these calls matters
  .out <- maybe_use_id(.out, id)
  .out <- add_straps(.out, x)
  .out <- maybe_use_original_id(.out, original_id)

  # Flatten (default unnests all the right things)
  .out <- tidyr::unnest(.out)

  .out <- dplyr::group_by(.out, !!!group_syms)

  .out
}

# ------------------------------------------------------------------------------

# id = 1:n for each group
maybe_use_id <- function(.out, id) {

  if(!is.null(id)) {

    id_col <- map(.out[[".rows"]], seq_along)

    .out <- tibble::add_column(.out, !!id := id_col, .before = ".rows")
  }

  .out
}

# Repeat `x` rows to generate the bootstraps
# Does vctrs::vec_slice() actually speed this up?
# Limited benchmarking seemed inconclusive
add_straps <- function(.out, x) {

  .out[["...x"]] <- map(
    .x = .out[[".rows"]],
    .f = function(idx) x[idx, , drop = FALSE]
  )

  .out
}

maybe_use_original_id <- function(.out, original_id) {

  if (!is.null(original_id)) {
    .out <- dplyr::rename(.out, !!original_id := .rows)
  }
  else {
    .out[[".rows"]] <- NULL
  }

  .out
}

# ------------------------------------------------------------------------------

validate_null_or_single_character <- function(.x, .x_nm) {

  if (is.null(.x)) {
    return(invisible(.x))
  }

  if (!rlang::is_scalar_character(.x)) {
    msg <- paste0("`", .x_nm, "` must be a character of size 1.")
    rlang::abort(msg)
  }

  invisible(.x)
}
