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
bootstrapify <- function(.data, .n) {
  UseMethod("bootstrapify")
}

#' @export
bootstrapify.data.frame <- function(.data, .n) {
  bootstrapify(dplyr::tbl_df(.data), .n)
}

#' @export
bootstrapify.tbl_df <- function(.data, .n) {

  .x <- seq_len(nrow(.data))

  new_row_indices <- dplyr::tibble(
    .virtual_strap = paste0("id_", seq_len(.n)),
    .rows = replicate(.n, sample(.x, length(.x), replace = TRUE), simplify = FALSE)
  )

  attr(.data, "groups") <- new_row_indices
  class(.data) <- c("bootstrapped_df", "grouped_df", class(.data))

  .data
}

#' @export
bootstrapify.grouped_df <- function(.data, .n) {

  group_df <- dplyr::group_data(.data)

  group_rows <- group_df[[".rows"]]

  new_row_indices <- purrr::map(group_rows, ~{

    dplyr::tibble(
      .virtual_strap = paste0("id_", seq_len(.n)),
      .rows = replicate(.n, sample(.x, length(.x), replace = TRUE), simplify = FALSE)
    )

  })

  group_df[[".rows"]] <- new_row_indices

  group_df <- tidyr::unnest(group_df) # should not have to specify

  attr(.data, "groups") <- group_df

  class(.data) <- c("bootstrapped_df", class(.data))

  .data
}
