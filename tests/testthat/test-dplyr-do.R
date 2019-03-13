context("test-dplyr-do")

library(dplyr)

test_that("can use do() with bootstraps", {

  x <- bootstrapify(iris, 5)

  expect_equal(
    do(x, .),
    collect(x)
  )

})

test_that("can return non-data frames", {

  x <- bootstrapify(iris, 5)

  x_do <- do(x, mod = lm(Sepal.Width ~ Species, data = .))

  expect_is(x_do, "rowwise_df")
  expect_false("resampled_df" %in% class(x_do))

  expect_equal(
    nrow(x_do),
    5
  )

})

test_that("multiple groups", {

  x <- iris %>%
    group_by(Species) %>%
    bootstrapify(5)

  x_do <- do(x, mod = lm(Sepal.Width ~ Sepal.Length, data = .))

  expect_equal(
    nrow(x_do),
    15
  )

})

test_that("double bootstrap", {

  x <- iris %>%
    bootstrapify(5) %>%
    bootstrapify(10, key = "b2")

  x_do <- do(x, mod = lm(Sepal.Width ~ Sepal.Length, data = .))

  expect_equal(
    colnames(x_do),
    c(".bootstrap", "b2", "mod")
  )

})
