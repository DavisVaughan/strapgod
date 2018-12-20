# Make virtual groups explicit

#' Force virtual groups to become explicit rows
#'
#' When `collect()` is used on a `bootstrapped_df`, the virtual bootstrap groups
#' are made explicit.
#'
#' @param x A `bootstrapped_df`.
#' @param id Optional. A single character that specifies a name for a column
#' containing a sequence from `1:n` for each bootstrap group.
#' @param original_id Optional. A single character that specifies a name for
#' a column containing the original position of the bootstrapped row.
#' @param ... Other arguments passed on to methods.
#'
#' @examples
#'
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
#' @importFrom dplyr collect n
#' @importFrom rlang :=
#' @export
collect.bootstrapped_df <- function(x, id = NULL, original_id = NULL, ...) {

  data_groups <- attr(x, "groups")

  # the only column name that is not in the x and is not .rows is the .key
  # better way? store .key as attribute?
  .key <- setdiff(colnames(data_groups), c(colnames(x), ".rows"))

  # Construct the correct arg list based on whether we include the original id
  call_args <- construct_arg_list(.key, original_id)

  # construct add_column() call with the right args inlined
  add_strap <- rlang::call2("add_column", !!!call_args, .ns = "tibble")

  explicit_group_df <- purrr::map2_dfr(
    .x = data_groups[[.key]],
    .y = data_groups[[".rows"]],
    .f = ~{
      # evaluate the expr in the context of the correct .x and .y
      rlang::eval_tidy(add_strap)
    }
  )

  orig_groups <- dplyr::groups(x)
  attr(x, "groups") <- NULL

  .out <- dplyr::group_by(explicit_group_df, !!!orig_groups)

  # id = 1:n for each group
  if(!is.null(id)) {
    .out <- dplyr::mutate(.out, !!id := seq_len(n()))
    # reorder
    .out <- dplyr::select(.out, !!.key, !!id, dplyr::everything())
  }

  .out
}

#' @importFrom rlang expr
#' @importFrom rlang list2
construct_arg_list <- function(.key, original_id) {

  if(is.null(original_id)) {

    call_args <- list2(
      .data = expr(x[.y,]),
      !!.key := expr(.x),
      .before = 1L
    )

  } else {

    call_args <- list2(
      .data = expr(x[.y,]),
      !!.key := expr(.x),
      !!original_id := expr(.y),
      .before = 1L
    )

  }

  call_args
}

#' @importFrom dplyr mutate
#' @export
mutate.bootstrapped_df <- function(x, ...) {
  rlang::abort("Mutating a `bootstrapped_df` is not allowed.", call. = FALSE)
}

# Global variables required for devtools::check()
# Used to build the call in construct_arg_list()
utils::globalVariables(c(".x", ".y", "x"))
