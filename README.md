
<!-- README.md is generated from README.Rmd. Please edit that file -->

# strapgod

<p align="center">

<img src="./man/figures/strap-god.jpg">

</p>

## Introduction

The goal of strapgod is to create *virtual groups* on top of a `tibble`
or `grouped_df` that function as resamples of the rows of the data
frame. You can then perform a `summarise()`, `do()`, or use
`group_map()` on this `resampled_df` to perform an efficient resampled /
bootstrapped calculation.

## Installation

You can install the released version of strapgod from
[CRAN](https://CRAN.R-project.org) with:

``` r
# no you cannot
install.packages("strapgod")
```

Install from github with:

``` r
devtools::install_github("DavisVaughan/strapgod")
```

## Example

Note how creating a `resampled_df` does not add a new column, or new
rows, but the groups are modified.

``` r
library(strapgod)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
set.seed(123)

iris %>%
  bootstrapify(10)
#> # A tibble: 150 x 5
#> # Groups:   .bootstrap [10]
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # … with 140 more rows
```

You can feed a `resampled_df` into `summarise()` or `do()` to perform
efficient bootstrapped computations.

``` r
iris %>%
  bootstrapify(10) %>%
  summarise(per_strap_mean = mean(Petal.Width))
#> # A tibble: 10 x 2
#>    .bootstrap per_strap_mean
#>         <int>          <dbl>
#>  1          1           1.20
#>  2          2           1.22
#>  3          3           1.23
#>  4          4           1.13
#>  5          5           1.20
#>  6          6           1.15
#>  7          7           1.18
#>  8          8           1.13
#>  9          9           1.31
#> 10         10           1.19
```

The data can be grouped as well.

``` r
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>%
  summarise(per_strap_species_mean = mean(Petal.Width))
#> # A tibble: 30 x 3
#> # Groups:   Species [3]
#>    Species .bootstrap per_strap_species_mean
#>    <fct>        <int>                  <dbl>
#>  1 setosa           1                  0.25 
#>  2 setosa           2                  0.246
#>  3 setosa           3                  0.24 
#>  4 setosa           4                  0.238
#>  5 setosa           5                  0.252
#>  6 setosa           6                  0.274
#>  7 setosa           7                  0.238
#>  8 setosa           8                  0.258
#>  9 setosa           9                  0.252
#> 10 setosa          10                  0.256
#> # … with 20 more rows
```

## Materializing bootstraps

`dplyr::collect()` can be used to make the implicit virtual groups
explicit.

``` r
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>%
  collect()
#> # A tibble: 1,500 x 6
#> # Groups:   Species, .bootstrap [30]
#>    .bootstrap Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>         <int>        <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          1          5.4         3.9          1.7         0.4 setosa 
#>  2          1          5.4         3.4          1.7         0.2 setosa 
#>  3          1          4.6         3.6          1           0.2 setosa 
#>  4          1          5.4         3.4          1.5         0.4 setosa 
#>  5          1          4.6         3.1          1.5         0.2 setosa 
#>  6          1          5.1         3.5          1.4         0.3 setosa 
#>  7          1          4.9         3            1.4         0.2 setosa 
#>  8          1          5.1         3.5          1.4         0.3 setosa 
#>  9          1          5.1         3.4          1.5         0.2 setosa 
#> 10          1          4.9         3.6          1.4         0.1 setosa 
#> # … with 1,490 more rows
```

You can specify an `id` column to get an in-bootstrap sequence from
`1:n`. You can also specify an `original_id` column to retrieve the
original row that the bootstrapped row came from.

``` r
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>%
  collect(id = ".id", original_id = ".original_id")
#> # A tibble: 1,500 x 8
#> # Groups:   Species, .bootstrap [30]
#>    .bootstrap   .id .original_id Sepal.Length Sepal.Width Petal.Length
#>         <int> <int>        <int>        <dbl>       <dbl>        <dbl>
#>  1          1     1           23          4.6         3.6          1  
#>  2          1     2           20          5.1         3.8          1.5
#>  3          1     3           19          5.7         3.8          1.7
#>  4          1     4           27          5           3.4          1.6
#>  5          1     5            4          4.6         3.1          1.5
#>  6          1     6           36          5           3.2          1.2
#>  7          1     7           13          4.8         3            1.4
#>  8          1     8           43          4.4         3.2          1.3
#>  9          1     9           50          5           3.3          1.4
#> 10          1    10            6          5.4         3.9          1.7
#> # … with 1,490 more rows, and 2 more variables: Petal.Width <dbl>,
#> #   Species <fct>
```

## `samplify()`

For general sampling, use `samplify()`.

``` r
iris %>%
  samplify(times = 5, size = 10, replace = FALSE)
#> # A tibble: 150 x 5
#> # Groups:   .sample [5]
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # … with 140 more rows
```

Be careful not to specify a size larger than one of your groups\! This
will throw an error.

``` r
iris_50_5_group_sizes <- iris[1:55,] %>%
  group_by(Species) %>%
  group_trim()

count(iris_50_5_group_sizes, Species)
#> # A tibble: 2 x 2
#> # Groups:   Species [2]
#>   Species        n
#>   <fct>      <int>
#> 1 setosa        50
#> 2 versicolor     5

# size = 10 > min_group_size = 5
iris_50_5_group_sizes %>%
  samplify(times = 2, size = 10)
#> Error: `size` (10) must be less than or equal to the size of the data / current group (5), set `replace = TRUE` to use sampling with replacement.
```

## `group_*()` Functions

`dplyr 0.8` adds some more neat group-wise functionality.

Here is a full walkthrough of some of the ways you can use
`bootstrapify()`, using a modified version of the examples in [this
rsample issue](https://github.com/tidymodels/rsample/issues/52).

``` r
suppressPackageStartupMessages({
  library(strapgod)
  library(dplyr)
  library(broom)
  library(ggplot2)
  library(purrr)
  library(tidyr)
})
```

### Tidying bootstrapped models

``` r
# without bootstraps
iris %>%
  group_by(Species) %>%
  group_map(~tidy(lm(Sepal.Length ~ Petal.Length, data = .x)))
#> # A tibble: 6 x 6
#> # Groups:   Species [3]
#>   Species    term         estimate std.error statistic  p.value
#> * <fct>      <chr>           <dbl>     <dbl>     <dbl>    <dbl>
#> 1 setosa     (Intercept)     4.21     0.416      10.1  1.61e-13
#> 2 setosa     Petal.Length    0.542    0.282       1.92 6.07e- 2
#> 3 versicolor (Intercept)     2.41     0.446       5.39 2.08e- 6
#> 4 versicolor Petal.Length    0.828    0.104       7.95 2.59e-10
#> 5 virginica  (Intercept)     1.06     0.467       2.27 2.77e- 2
#> 6 virginica  Petal.Length    0.996    0.0837     11.9  6.30e-16

# with bootstraps
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>%
  group_map(~tidy(lm(Sepal.Length ~ Petal.Length, data = .x)))
#> # A tibble: 60 x 7
#> # Groups:   Species, .bootstrap [30]
#>    Species .bootstrap term         estimate std.error statistic  p.value
#>  * <fct>        <int> <chr>           <dbl>     <dbl>     <dbl>    <dbl>
#>  1 setosa           1 (Intercept)     4.41      0.407    10.8   1.66e-14
#>  2 setosa           1 Petal.Length    0.366     0.275     1.33  1.90e- 1
#>  3 setosa           2 (Intercept)     4.78      0.437    10.9   1.21e-14
#>  4 setosa           2 Petal.Length    0.142     0.289     0.490 6.27e- 1
#>  5 setosa           3 (Intercept)     3.85      0.410     9.40  1.84e-12
#>  6 setosa           3 Petal.Length    0.834     0.279     2.99  4.42e- 3
#>  7 setosa           4 (Intercept)     4.50      0.406    11.1   7.78e-15
#>  8 setosa           4 Petal.Length    0.301     0.271     1.11  2.73e- 1
#>  9 setosa           5 (Intercept)     3.66      0.467     7.84  3.86e-10
#> 10 setosa           5 Petal.Length    0.917     0.333     2.76  8.22e- 3
#> # … with 50 more rows
```

### Plotting bootstrapped results

``` r
# without bootstrap
mtcars %>%
  ggplot(aes(hp, mpg)) + 
  geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="man/figures/README-bootstrap-plots-1.png" width="100%" />

``` r

# with bootstrap
mtcars %>%
  bootstrapify(10) %>%
  collect() %>%
  ggplot(aes(hp, mpg, group = .bootstrap)) + 
  geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="man/figures/README-bootstrap-plots-2.png" width="100%" />

### “Multiple models” workflow

``` r
# The nest+mutate+unnest combo
iris %>% 
  group_by(Species) %>%
  bootstrapify(10) %>%
  group_nest() %>%
  mutate(
    model = map(data, ~lm(Sepal.Length ~ Petal.Length, data = .x)),
    coef = map(model, tidy)
  ) %>%
  unnest(coef)
#> # A tibble: 60 x 7
#>    Species .bootstrap term         estimate std.error statistic  p.value
#>    <fct>        <int> <chr>           <dbl>     <dbl>     <dbl>    <dbl>
#>  1 setosa           1 (Intercept)     4.67      0.480     9.74  5.97e-13
#>  2 setosa           1 Petal.Length    0.249     0.321     0.774 4.42e- 1
#>  3 setosa           2 (Intercept)     4.07      0.481     8.45  4.58e-11
#>  4 setosa           2 Petal.Length    0.616     0.342     1.80  7.78e- 2
#>  5 setosa           3 (Intercept)     5.28      0.483    10.9   1.26e-14
#>  6 setosa           3 Petal.Length   -0.173     0.321    -0.540 5.92e- 1
#>  7 setosa           4 (Intercept)     3.83      0.400     9.57  1.04e-12
#>  8 setosa           4 Petal.Length    0.765     0.271     2.82  6.89e- 3
#>  9 setosa           5 (Intercept)     4.64      0.390    11.9   6.31e-16
#> 10 setosa           5 Petal.Length    0.263     0.264     0.998 3.23e- 1
#> # … with 50 more rows

# Using rap  
library(rap)

iris %>% 
  group_by(Species) %>%
  bootstrapify(10) %>%
  group_nest() %>%
  # cleaner than mutate+map
  rap(
    model = ~lm(Sepal.Length ~ Petal.Length, data = data),
    coef  = ~tidy(model)
  ) %>%
  unnest(coef)
#> # A tibble: 60 x 7
#>    Species .bootstrap term         estimate std.error statistic  p.value
#>    <fct>        <int> <chr>           <dbl>     <dbl>     <dbl>    <dbl>
#>  1 setosa           1 (Intercept)     3.45      0.406      8.49 4.00e-11
#>  2 setosa           1 Petal.Length    1.08      0.279      3.87 3.23e- 4
#>  3 setosa           2 (Intercept)     4.21      0.366     11.5  2.13e-15
#>  4 setosa           2 Petal.Length    0.532     0.244      2.18 3.38e- 2
#>  5 setosa           3 (Intercept)     4.20      0.340     12.4  1.56e-16
#>  6 setosa           3 Petal.Length    0.544     0.229      2.37 2.16e- 2
#>  7 setosa           4 (Intercept)     4.51      0.430     10.5  5.06e-14
#>  8 setosa           4 Petal.Length    0.372     0.287      1.30 2.01e- 1
#>  9 setosa           5 (Intercept)     4.31      0.477      9.03 6.49e-12
#> 10 setosa           5 Petal.Length    0.532     0.320      1.66 1.03e- 1
#> # … with 50 more rows
```
