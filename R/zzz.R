#' @importFrom dplyr collect
NULL

#' @importFrom rlang :=
NULL

# For collect()
utils::globalVariables(
  c(
    ".rows",
    "...x"
  )
)
