#' Create a bootstrapped tibble
#'
#' @description
#'
#' `bootstrapify()` creates a bootstrapped tibble with _virtual groups_.
#'
#' @inherit samplify details
#'
#' @inherit samplify return
#'
#' @seealso [collect.resampled_df()]
#'
#' @inheritParams samplify
#'
#' @examples
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
#' # Alternatively, use the newer group_modify()
#' iris %>%
#'   bootstrapify(5) %>%
#'   group_modify(~tidy(lm(Sepal.Width ~ Sepal.Length + Species, data = .x)))
#'
#' # Alter the name of the group with `key`
#' # Materialize them with collect()
#' straps <- bootstrapify(iris, 5, key = ".straps")
#' collect(straps)
#'
#' @family virtual samplers
#'
#' @name bootstrapify

#' @rdname bootstrapify
#' @export
bootstrapify <- function(data, times, ..., key = ".bootstrap") {
  UseMethod("bootstrapify")
}

#' @export
bootstrapify.data.frame <- function(data, times, ..., key = ".bootstrap") {
  bootstrapify(dplyr::as_tibble(data), times, ..., key = key)
}

#' @export
bootstrapify.tbl_df <- function(data, times, ..., key = ".bootstrap") {
  samplify(
    data = data,
    times = times,
    size = nrow(data),
    ...,
    replace = TRUE,
    key = key
  )
}

#' @export
bootstrapify.grouped_df <- function(data, times, ..., key = ".bootstrap") {
  samplify(
    data = data,
    times = times,
    size = dplyr::group_size(data),
    ...,
    replace = TRUE,
    key = key
  )
}
