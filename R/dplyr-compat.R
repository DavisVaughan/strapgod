# Make virtual groups explicit

#' @importFrom dplyr collect
#' @export
collect.bootstrapped_df <- function(.data) {

  data_groups <- attr(.data, "groups")

  explicit_group_df <- purrr::map2_dfr(
    .x = data_groups[[".virtual_strap"]],
    .y = data_groups[[".rows"]],
    .f = ~{
      tibble::add_column(
        .data[.y,],
        .strap = .x,
        .id = .y,
        .before = 1L
      )
    }
  )

  orig_groups <- setdiff(names(data_groups), c(".virtual_strap", ".rows"))
  attr(.data, "groups") <- NULL
  dplyr::group_by_at(explicit_group_df, c(orig_groups, ".strap"))

}

#' @importFrom dplyr mutate
#' @export
mutate.bootstrapped_df <- function(.data, ...) {
  rlang::abort("Mutating a `bootstrapped_df` is not allowed.", call. = FALSE)
}
