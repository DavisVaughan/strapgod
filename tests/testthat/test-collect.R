context("test-collect")

library(dplyr)

test_that("can collect()", {

  x <- bootstrapify(iris, 5)

  expect_error(
    x_c <- collect(x),
    NA
  )

  expect_equal(
    nrow(x_c),
    750
  )

  expect_is(
    x_c,
    "grouped_df"
  )

  expect_false("resample_df" %in% class(x_c))

  expect_equal(
    colnames(x_c),
    c(".bootstrap", colnames(iris))
  )

})

test_that("can do a double bootstrap collect", {

  x <- iris %>%
    bootstrapify(5) %>%
    bootstrapify(10, key = ".bootstrap_2")

  x_c <- collect(x)

  expect_equal(
    nrow(x_c),
    nrow(iris) * 5 * 10
  )

  expect_equal(
    x_c$.bootstrap,
    rep(1:5, each = nrow(iris) * 10)
  )

  expect_equal(
    x_c$.bootstrap_2,
    rep(1:10, each = nrow(iris), times = 5)
  )

})

test_that("all groups are preserved", {

  iris_g <- iris %>%
    group_by(Species)

  x <- bootstrapify(iris_g, 5)

  x_c <- collect(x)

  expect_equal(
    group_vars(x_c),
    c("Species", ".bootstrap")
  )

  expect_equal(
    nrow(x_c),
    sum(group_size(iris_g) * 5)
  )

})

test_that("`key` is propagated to `collect()`", {

  x <- bootstrapify(iris, 5, key = ".boot")

  expect_equal(
    colnames(collect(x))[1],
    ".boot"
  )

})

test_that("can collect with `id`", {

  x <- bootstrapify(iris, 5)

  x_c <- collect(x, id = ".id")

  expect_equal(
    colnames(x_c),
    c(".bootstrap", ".id", colnames(iris))
  )

  expect_equal(
    x_c$.id,
    rep(1:150, times = 5)
  )

})

test_that("can collect with `original_id`", {

  x <- bootstrapify(iris, 5)

  x_c <- collect(x, original_id = ".o_id")

  expect_equal(
    colnames(x_c),
    c(".bootstrap", ".o_id", colnames(iris))
  )

  expect_equal(
    x_c$.o_id,
    unlist(group_data(x)$.rows)
  )

})

test_that("can collect with `id` and `original_id`", {

  x <- bootstrapify(iris, 5)

  x_c <- collect(x, id = ".id", original_id = ".o_id")

  # want this column order. most intuitive.
  expect_equal(
    colnames(x_c),
    c(".bootstrap", ".id", ".o_id", colnames(iris))
  )

})

test_that("`id` must be a single character", {

  x <- bootstrapify(iris, 5)

  expect_error(
    collect(x, id = 1),
    "`id` must be a character of size 1."
  )

})

test_that("`original_id` must be a single character", {

  x <- bootstrapify(iris, 5)

  expect_error(
    collect(x, original_id = 1),
    "`original_id` must be a character of size 1."
  )

})
