context("test-samplify")

# many of the would-be tests here are already covered by `test-bootstrapify.R`

library(dplyr)

test_that("can alter the `size` of each resample", {

  x <- samplify(iris, 1, 5)

  expect_equal(
    length(group_data(x)$.rows[[1]]),
    5
  )

})

test_that("cannot specify vector `size` for ungrouped data frames", {

  expect_error(
    samplify(iris, 2, c(1, 5)),
    "a single integer \\(for ungrouped data frames\\)"
  )

})

test_that("can specify vector `size` for grouped data frames", {

  iris_g <- group_by(iris, Species)

  expect_error(
    x <- samplify(iris_g, 1, c(1, 2, 3)),
    NA
  )

  x_gd <- group_data(x)

  expect_equal(
    vapply(x_gd$.rows, length, integer(1)),
    c(1, 2, 3)
  )

  expect_error(
    samplify(x, 2, c(1, 5)),
    "must be size 1 or 3 \\(the number of groups\\)"
  )

})

test_that("cannot sample more than the number of rows without replacement", {

  expect_error(
    samplify(iris, 1, 151),
    "`size` \\(151\\) must be less than or equal to the size of the data / current group \\(150\\)"
  )

  iris_g <- group_by(iris, Species)

  expect_error(
    samplify(iris_g, 1, c(49, 49, 51)),
    "`size` \\(51\\) must be less than or equal to the size of the data / current group \\(50\\)"
  )

})

test_that("can sample with replacement past the number of rows", {

  expect_error(
    x <- samplify(iris, 1, 151, replace = TRUE),
    NA
  )

  x_gd <- group_data(x)

  expect_equal(
    length(x_gd$.rows[[1]]),
    151
  )

  iris_g <- group_by(iris, Species)

  expect_error(
    xx <- samplify(iris_g, 1, c(51, 55, 40), replace = TRUE),
    NA
  )

  xx_gd <- group_data(xx)


  expect_equal(
    vapply(xx_gd$.rows, length, integer(1)),
    c(51, 55, 40)
  )

})

test_that("`replace` must be a bool", {
  expect_error(
    samplify(iris, 1, 1, replace = NA),
    "a single logical \\(TRUE/FALSE\\)"
  )
})

test_that("`size` is recycled as necessary", {

  iris_g <- group_by(iris, Species)

  x <- samplify(iris_g, 2, 5)

  x_gd <- group_data(x)

  expect_equal(
    unique(vapply(x_gd$.rows, length, integer(1))),
    5
  )

})
