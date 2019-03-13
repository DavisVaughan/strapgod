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

  # Materialize groups
  .out <- dplyr::group_map(x, ~.x)

  # Setup holder for optional columns
  optional_cols <- list()

  # Maybe add ID column
  if (!is.null(id)) {
    id <- rlang::sym(id)

    .out <- add_id(.out, id)

    optional_cols <- c(optional_cols, id)
  }

  # Maybe add original ID column
  if (!is.null(original_id)) {
    original_id <- rlang::sym(original_id)

    .out <- add_original_id(.out, x, original_id)

    optional_cols <- c(optional_cols, original_id)
  }

  # Reorder to groups, optionals, everything else
  .out <- dplyr::select(
    .out,
    dplyr::group_cols(),
    !!! optional_cols,
    dplyr::everything()
  )

  .out
}

# ------------------------------------------------------------------------------

# For each group, add the id
add_id <- function(.out, id) {
  dplyr::mutate(.out, !!id := dplyr::row_number())
}

# Extract the original row indices per group, then flatten
# into an int vector and add that as a column
# Order _should_ always be correct
add_original_id <- function(.out, x, original_id) {
  group_tbl <- dplyr::group_data(x)

  original_index <- rlang::flatten_int(group_tbl[[".rows"]])

  tibble::add_column(.out, !!original_id := original_index)
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
