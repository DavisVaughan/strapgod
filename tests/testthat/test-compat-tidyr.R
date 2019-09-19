context("test-compat-tidyr")

test_that("nest()", {

  x <- bootstrapify(iris, 5)

  expect_error(
    x_n <- nest(x),
    NA
  )

  expect_equal(
    x_n$.bootstrap,
    1:5
  )

  expect_equal(
    colnames(nest(x, .x = -.bootstrap)),
    c(".bootstrap", ".x")
  )

})
