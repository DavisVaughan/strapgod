# Make virtual groups explicit

#' @importFrom dplyr collect
#' @export
collect.bootstrapped_df <- function(.data, ...) {

  data_groups <- attr(.data, "groups")

  # the only column name that is not in the .data and is not .rows is the .key
  # better way? store .key as attribute?
  .key <- setdiff(colnames(data_groups), c(colnames(.data), ".rows"))

  explicit_group_df <- purrr::map2_dfr(
    .x = data_groups[[.key]],
    .y = data_groups[[".rows"]],
    .f = ~{
      tibble::add_column(
        .data[.y,],
        !!.key := .x,
        .id = .y,
        .before = 1L
      )
    }
  )

  orig_groups <- setdiff(colnames(data_groups), ".rows")
  attr(.data, "groups") <- NULL
  dplyr::group_by_at(explicit_group_df, orig_groups)

}

#' @importFrom dplyr mutate
#' @export
mutate.bootstrapped_df <- function(.data, ...) {
  rlang::abort("Mutating a `bootstrapped_df` is not allowed.", call. = FALSE)
}
