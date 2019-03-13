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

test_that("mutate()", {
  x <- bootstrapify(iris, 2)
  expect_equal(
    nrow(mutate(x, x = 4)),
    300
  )
})

test_that("transmute()", {
  x <- bootstrapify(iris, 2)
  expect_equal(
    nrow(transmute(x, x = 4)),
    300
  )
})

test_that("filter()", {
  x <- bootstrapify(iris, 2)
  expect_equal(
    nrow(filter(x, .bootstrap <= 1)),
    150
  )
})

test_that("arrange()", {
  x <- bootstrapify(iris, 2)

  expect_equal(
    nrow(arrange(x, desc(.bootstrap))),
    300
  )

  expect_equal(
    arrange(x, desc(.bootstrap))$.bootstrap,
    rep(c(2,1), each = 150)
  )
})

test_that("distinct()", {
  x <- bootstrapify(iris, 2)

  expect_equal(
    colnames(distinct(x)),
    c(".bootstrap", colnames(iris))
  )

  expect_equal(
    distinct(x, .bootstrap),
    group_by(tibble(.bootstrap = 1:2), .bootstrap)
  )

})

test_that("select()", {
  x <- bootstrapify(iris, 2)

  expect_equal(
    colnames(select(x, group_cols())),
    ".bootstrap"
  )

  expect_equal(
    nrow(select(x, group_cols())),
    300
  )

})

test_that("slice()", {
  x <- bootstrapify(iris, 2)

  expect_equal(
    nrow(slice(x, 1)),
    2
  )
})

test_that("full_join()", {

  mini_iris <- iris[1:20, 1:2]
  x <- bootstrapify(mini_iris, 2)
  y <- tibble(Sepal.Length = 100, new = 1)

  x_fj <- full_join(x, y, by = "Sepal.Length")

  expect_equal(
    nrow(x_fj),
    41
  )

  expect_equal(
    x_fj$new,
    c(rep(NA_real_, 40), 1)
  )

  expect_equal(
    colnames(x_fj),
    c(".bootstrap", "Sepal.Length", "Sepal.Width", "new")
  )

})

test_that("inner_join()", {

  mini_iris <- iris[1:20, 1:2]
  x <- bootstrapify(mini_iris, 2)
  y <- tibble(Sepal.Length = 100, new = 1)

  x_ij <- inner_join(x, y, by = "Sepal.Length")

  expect_equal(
    nrow(x_ij),
    0
  )

  expect_equal(
    colnames(x_ij),
    c(".bootstrap", "Sepal.Length", "Sepal.Width", "new")
  )

})

test_that("left_join()", {

  mini_iris <- iris[1:20, 1:2]
  x <- bootstrapify(mini_iris, 2)
  y <- tibble(Sepal.Length = 100, new = 1)

  x_lj <- left_join(x, y, by = "Sepal.Length")

  expect_equal(
    nrow(x_lj),
    40
  )

  expect_equal(
    x_lj$new,
    rep(NA_real_, times = 40)
  )

  expect_equal(
    colnames(x_lj),
    c(".bootstrap", "Sepal.Length", "Sepal.Width", "new")
  )

})

test_that("right_join()", {

  mini_iris <- iris[1:20, 1:2]
  x <- bootstrapify(mini_iris, 2)
  y <- tibble(Sepal.Length = 100, new = 1)

  x_rj <- right_join(x, y, by = "Sepal.Length")

  expect_equal(
    nrow(x_rj),
    1
  )

  expect_equal(
    x_rj$new,
    1
  )

  expect_equal(
    colnames(x_rj),
    c(".bootstrap", "Sepal.Length", "Sepal.Width", "new")
  )

})

test_that("anti_join()", {

  mini_iris <- iris[1:20, 1:2]
  x <- bootstrapify(mini_iris, 2)
  y <- tibble(Sepal.Length = 100, new = 1)

  x_aj <- anti_join(x, y, by = "Sepal.Length")

  expect_equal(
    x_aj,
    collect(x)
  )

})

test_that("semi_join()", {

  mini_iris <- iris[1:20, 1:2]
  x <- bootstrapify(mini_iris, 2)
  y <- tibble(Sepal.Length = 100, new = 1)

  x_sj <- semi_join(x, y, by = "Sepal.Length")

  expect_equal(
    x_sj,
    collect(x)[0,]
  )

})
