context("test-bootstrapify")

library(dplyr)

test_that("can create bootstrapped data frames", {

  expect_error(
    x <- bootstrapify(iris, 2),
    NA
  )

  expect_is(x, "resampled_df")
  expect_is(x, "grouped_df")

  x_gd <- group_data(x)

  expect_equal(
    colnames(x_gd),
    c(".bootstrap", ".rows")
  )

  expect_equal(
    x_gd[[".bootstrap"]],
    c(1, 2)
  )

  expect_equal(
    nrow(x_gd),
    2
  )

  expect_equal(
    unique(vapply(x_gd$.rows, length, integer(1))),
    150
  )

})

test_that("can bootstrap with groups", {

  x <- iris %>%
    group_by(Species) %>%
    bootstrapify(5)

  x_gd <- group_data(x)

  expect_equal(
    colnames(x_gd),
    c("Species", ".bootstrap", ".rows")
  )

  expect_equal(
    nrow(x_gd),
    15
  )

  expect_equal(
    unique(vapply(x_gd$.rows, length, integer(1))),
    50
  )

})

test_that("can correctly double bootstrap", {

  once <- iris %>%
    bootstrapify(5)

  twice <- once %>%
    bootstrapify(5)

  once_gd <- group_data(once)
  twice_gd <- group_data(twice)

  once_strap_1 <- once_gd$.rows[[1]]

  twice_1 <- dplyr::filter(twice_gd, .bootstrap == 1)

  # Check that the indices generated from bootstrapping the second
  # time are subsets of the indices in each group from the first
  # bootstrap

  each_twice_is_subset_of_once <- vapply(
    X = twice_1$.rows,
    FUN = function(x) {all(x %in% once_strap_1)},
    FUN.VALUE = logical(1)
  )

  expect_true(all(each_twice_is_subset_of_once))

  expect_equal(
    colnames(twice_gd),
    c(".bootstrap", ".bootstrap1", ".rows")
  )

})

test_that("can alter the key", {
  x <- bootstrapify(iris, 5, key = ".boot")

  expect_equal(
    colnames(group_data(x))[1],
    ".boot"
  )
})

test_that("cannot pass into the `...`", {
  expect_error(
    bootstrapify(iris, 5, "key-in-dots"),
    "`...` must be empty"
  )
})

test_that("invalid inputs are caught", {
  expect_error(
    bootstrapify(iris, 5, key = 1),
    "`key` must be a single character."
  )
})
