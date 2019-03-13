context("test-dplyr-compat")

library(dplyr)

test_that("can ungroup() to lose `resampled_df`", {

  x <- bootstrapify(iris, 5)

  x_ug <- ungroup(x)

  expect_is(x_ug, "tbl_df")
  expect_false("resampled_df" %in% class(x_ug))
  expect_equal(attr(x_ug, "groups"), NULL)

})

test_that("can group_by() after bootstrapify()", {

  x <- bootstrapify(iris, 5)

  x_g1 <- group_by(x, Species)

  expect_is(x_g1, "grouped_df")
  expect_false("resampled_df" %in% class(x_g1))
  expect_false(".bootstrap" %in% colnames(x_g1))

  x_g2 <- group_by(x, Species, add = TRUE)

  expect_is(x_g2, "grouped_df")
  expect_false("resampled_df" %in% class(x_g2))
  expect_true(".bootstrap" %in% colnames(x_g2))
  expect_equal(group_vars(x_g2), c(".bootstrap", "Species"))

  expect_equal(
    nrow(x_g2),
    5 * 150
  )

  x_g3 <- group_by(x, add = TRUE)

  expect_is(x_g3, "grouped_df")
  expect_false("resampled_df" %in% class(x_g3))
  expect_true(".bootstrap" %in% colnames(x_g3))
  expect_equal(group_vars(x_g3), ".bootstrap")

  x_g4 <- group_by(x)

  expect_is(x_g4, "tbl_df")
  expect_false("grouped_df" %in% class(x_g4))
  expect_false("resampled_df" %in% class(x_g4))
  expect_false(".bootstrap" %in% colnames(x_g4))

  # We know we get an error here
  # as the bootstraps aren't materialized
  expect_error(
    group_by(x, .bootstrap)
  )

})
