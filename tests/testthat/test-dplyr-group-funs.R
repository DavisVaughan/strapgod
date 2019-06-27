context("test-dplyr-group-funs")

library(dplyr)

test_that("group_nest()", {

  x <- iris %>%
    bootstrapify(5)

  x_gn <- group_nest(x)

  expect_equal(nrow(x_gn), 5)
  expect_false("resampled_df" %in% class(x_gn))

  xx <- bootstrapify(x, 10, key = "bs2")

  xx_gn <- group_nest(xx)

  expect_equal(nrow(xx_gn), 50)
  expect_false("resampled_df" %in% class(xx_gn))

})

test_that("group_nest() with `keep = TRUE`", {

  x <- iris %>%
    bootstrapify(5)

  x_gn <- group_nest(x, keep = TRUE)

  expect_equal(
    colnames(x_gn$data[[1]])[1],
    ".bootstrap"
  )

})

test_that("group_modify()", {

  x <- iris %>%
    bootstrapify(5)

  expect_equal(
    group_modify(x, ~.x),
    collect(x)
  )

  x_gm <- group_modify(x, ~dplyr::tibble(.g = list(.y)))

  expect_equal(nrow(x_gm), 5)

  expect_equal(
    x_gm$.g[[1]],
    dplyr::tibble(.bootstrap = 1L)
  )

})

test_that("group_map()", {

  x <- iris %>%
    bootstrapify(5)

  expect_equal(
    group_map(x, ~.x),
    group_split(x, keep = FALSE)
  )

  x_gm <- group_map(x, ~dplyr::tibble(.g = list(.y)))

  expect_is(x_gm, "list")

  expect_identical(
    x_gm[[1]],
    tibble(.g = list(tibble(.bootstrap = 1L)))
  )

  # `keep` argument
  expect_equal(
    unlist(group_map(x, ~ncol(.x), keep = TRUE)),
    rep(6, times = 5)
  )

})

test_that("group_walk()", {

  x <- iris %>%
    bootstrapify(5)

  res <- NULL

  group_walk(x, ~{ res <<- dplyr::bind_rows(res, .y) })

  expect_equal(
    res,
    dplyr::tibble(.bootstrap = 1:5)
  )

  res <- NULL

  group_walk(x, ~{ res <<- dplyr::bind_rows(res, .x) })

  expect_equal(
    res,
    select(ungroup(collect(x)), -.bootstrap)
  )

})

test_that("group_split() - `keep` argument", {

  x <- iris %>%
    bootstrapify(5)

  x_gs <- group_split(x, keep = TRUE)

  expect_equal(
    colnames(x_gs[[1]]),
    c(".bootstrap", colnames(iris))
  )

  x_gs2 <- group_split(x, keep = FALSE)

  expect_equal(
    colnames(x_gs2[[1]]),
    colnames(iris)
  )
})

test_that("group_keys() can find the virtual groups", {

  x <- iris %>%
    group_by(Species) %>%
    bootstrapify(1) %>%
    bootstrapify(2)

  x_keys <- group_keys(x)

  expect_equal(
    x_keys[[1]],
    rep(unique(iris$Species), each = 2)
  )

  expect_equal(
    x_keys[[2]],
    rep(1, times = 6)
  )

  expect_equal(
    x_keys[[3]],
    rep(1:2, times = 3)
  )
})

test_that("group_data() finds virtual groups", {

  x <- iris %>%
    bootstrapify(2)

  x_gd <- group_data(x)

  expect_equal(
    x_gd$.bootstrap,
    c(1, 2)
  )
})

test_that("group_indices() returns collect()ed indices", {

  x <- iris %>%
    bootstrapify(2)

  x_gi <- group_indices(x)

  expect_equal(
    x_gi,
    c(rep(1, times = 150), rep(2, times = 150))
  )

})

test_that("group_vars() returns virtual groups", {

  x <- iris %>%
    bootstrapify(2)

  expect_equal(
    group_vars(x),
    ".bootstrap"
  )

  # I think it is correct to expect that tbl_vars()
  # doesn't return the virtual group
  expect_equal(
    as.character(tbl_vars(x)),
    colnames(iris)
  )

})
