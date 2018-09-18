#' Create a bootstrapped tibble
#'
#' `bootstrapify()` creates _virtual groups_ on top of a `tibble`.
#'
#' Currently you can use `summarise()` and `do()` on a `bootstrapped_df`.
#'
#' @param .data A tbl.
#'
#' @param .n A integer specifying the number of bootstraps. If the `tibble` is
#' grouped, this is the number of bootstraps per group.
#'
#' @return A `bootstrapped_df` with an extra group named `.virtual_groups`.
#'
#' @examples
#'
#' library(dplyr)
#' library(broom)
#'
#' bootstrapify(iris, 5)
#'
#' iris %>%
#'   bootstrapify(5) %>%
#'   summarise(per_strap_mean = mean(Petal.Width))
#'
#' iris %>%
#'   group_by(Species) %>%
#'   bootstrapify(5) %>%
#'   summarise(per_strap_species_mean = mean(Petal.Width))
#'
#' iris %>%
#'   bootstrapify(5) %>%
#'   do(tidy(lm(Sepal.Width ~ Sepal.Length + Species, data = .)))
#'
#' @name bootstrapify

#' @rdname bootstrapify
#' @export
bootstrapify <- function(.data, .n, .key = ".bootstrap") {
  UseMethod("bootstrapify")
}

#' @export
bootstrapify.data.frame <- function(.data, .n, .key = ".bootstrap") {
  .key <- dplyr::enquo(.key)
  bootstrapify(dplyr::tbl_df(.data), .n, !!.key)
}

#' @export
bootstrapify.tbl_df <- function(.data, .n, .key = ".bootstrap") {

  .key <- dplyr::enquo(.key)
  .row_slice_ids <- seq_len(nrow(.data))

  groups_tbl <- bootstrap_indices(.row_slice_ids, .n, !!.key)

  # create bootstrapped_df subclass
  attr(.data, "groups") <- groups_tbl
  class(.data) <- c("bootstrapped_df", "grouped_df", class(.data))

  .data
}

#' @export
bootstrapify.grouped_df <- function(.data, .n, .key = ".bootstrap") {

  .key <- dplyr::enquo(.key)

  # extract existing group_tbl
  group_tbl <- dplyr::group_data(.data)
  index_list <- group_tbl[[".rows"]]

  new_row_index_tbl <- purrr::map(index_list, ~{
    bootstrap_indices(.row_slice_ids = .x, .n = .n, .key = !!.key)
  })

  # overwrite current .rows and unnest
  group_tbl[[".rows"]] <- new_row_index_tbl
  group_tbl <- tidyr::unnest(group_tbl)

  # update groups
  attr(.data, "groups") <- group_tbl

  class(.data) <- c("bootstrapped_df", class(.data))

  .data
}

bootstrap_indices <- function(.row_slice_ids, .n, .key) {

  .key <- dplyr::enquo(.key)
  .n_ids <- length(.row_slice_ids)
  .bootstrap_id <- seq_len(.n)

  .index_list <- replicate(
    n = .n,
    expr = sample(.row_slice_ids, .n_ids, replace = TRUE),
    simplify = FALSE
  )

  dplyr::tibble(
    !!.key := .bootstrap_id,
    .rows = .index_list
  )

}
