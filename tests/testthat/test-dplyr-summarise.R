context("test-dplyr-summarise")

library(dplyr)

test_that("summarise() works with a simple bootstrap", {

  x <- bootstrapify(iris, 5)

  expect_error(
    x_s <- summarise(x, y = mean(Sepal.Width)),
    NA
  )

  expect_equal(
    x_s$.bootstrap,
    1:5
  )

  expect_false("grouped_df" %in% class(x_s))
  expect_false("resampled_df" %in% class(x_s))

})

test_that("summarise() == summarize()", {

  x <- bootstrapify(iris, 5)

  expect_equal(
    summarise(x, y = mean(Sepal.Width)),
    summarize(x, y = mean(Sepal.Width))
  )

})

test_that("works with a double bootstrap", {

  x <- iris %>%
    bootstrapify(5) %>%
    bootstrapify(10, key = "bs2")

  expect_error(
    x_s <- summarise(x, y = mean(Sepal.Width)),
    NA
  )

  # We want it to be a grouped_df, but no longer a resampled_df
  # because the groups have been materialized
  expect_is(x_s, "grouped_df")
  expect_false("resampled_df" %in% class(x_s))

  expect_equal(
    nrow(x_s),
    5 * 10
  )

})

test_that("works with existing groups", {

  x <- iris %>%
    group_by(Species) %>%
    bootstrapify(5)

  expect_error(
    x_s <- summarise(x, y = mean(Sepal.Width)),
    NA
  )

  # We want it to be a grouped_df, but no longer a resampled_df
  # because the groups have been materialized
  expect_is(x_s, "grouped_df")
  expect_false("resampled_df" %in% class(x_s))

  expect_equal(
    nrow(x_s),
    5 * 3
  )

  expect_equal(
    colnames(x_s),
    c("Species", ".bootstrap", "y")
  )

})
