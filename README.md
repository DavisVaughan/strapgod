
<!-- README.md is generated from README.Rmd. Please edit that file -->

# strapgod

The goal of strapgod is to create *virtual groups* on top of a `tibble`
or `grouped_df` that function as bootstraps of the rows of the data
frame. You can then perform a `summarise()` or use `do()` on this
`bootstrapped_df` to perform an efficient bootstrapped calculation.

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

Note how creating a `bootstrapped_df` does not add a new column, or new
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

You can feed a `bootstrapped_df` into `summarise()` or `do()` to perform
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
#>  1 setosa           1 (Intercept)     4.20      0.344    12.2   2.57e-16
#>  2 setosa           1 Petal.Length    0.488     0.235     2.08  4.32e- 2
#>  3 setosa           2 (Intercept)     4.22      0.444     9.50  1.32e-12
#>  4 setosa           2 Petal.Length    0.498     0.299     1.67  1.02e- 1
#>  5 setosa           3 (Intercept)     4.53      0.456     9.93  3.23e-13
#>  6 setosa           3 Petal.Length    0.331     0.309     1.07  2.90e- 1
#>  7 setosa           4 (Intercept)     3.81      0.381    10.0   2.41e-13
#>  8 setosa           4 Petal.Length    0.798     0.253     3.16  2.77e- 3
#>  9 setosa           5 (Intercept)     4.65      0.428    10.9   1.50e-14
#> 10 setosa           5 Petal.Length    0.278     0.290     0.959 3.43e- 1
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

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

``` r

# with bootstrap
mtcars %>%
  bootstrapify(10) %>%
  collect() %>%
  ggplot(aes(hp, mpg, group = .bootstrap)) + 
  geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```

<img src="man/figures/README-unnamed-chunk-8-2.png" width="100%" />

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
#>  1 setosa           1 (Intercept)     4.14      0.435     9.51  1.28e-12
#>  2 setosa           1 Petal.Length    0.593     0.301     1.97  5.47e- 2
#>  3 setosa           2 (Intercept)     4.45      0.452     9.84  4.27e-13
#>  4 setosa           2 Petal.Length    0.392     0.306     1.28  2.07e- 1
#>  5 setosa           3 (Intercept)     4.16      0.438     9.51  1.28e-12
#>  6 setosa           3 Petal.Length    0.560     0.299     1.87  6.76e- 2
#>  7 setosa           4 (Intercept)     4.38      0.392    11.2   5.91e-15
#>  8 setosa           4 Petal.Length    0.374     0.264     1.41  1.64e- 1
#>  9 setosa           5 (Intercept)     5.25      0.544     9.65  7.94e-13
#> 10 setosa           5 Petal.Length   -0.144     0.368    -0.391 6.98e- 1
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
#>  1 setosa           1 (Intercept)     5.41      0.475    11.4   3.11e-15
#>  2 setosa           1 Petal.Length   -0.248     0.331    -0.751 4.56e- 1
#>  3 setosa           2 (Intercept)     3.68      0.392     9.38  2.00e-12
#>  4 setosa           2 Petal.Length    0.899     0.269     3.34  1.64e- 3
#>  5 setosa           3 (Intercept)     4.19      0.362    11.6   1.70e-15
#>  6 setosa           3 Petal.Length    0.556     0.249     2.23  3.03e- 2
#>  7 setosa           4 (Intercept)     3.84      0.301    12.8   4.58e-17
#>  8 setosa           4 Petal.Length    0.796     0.202     3.94  2.60e- 4
#>  9 setosa           5 (Intercept)     4.46      0.414    10.8   2.15e-14
#> 10 setosa           5 Petal.Length    0.382     0.274     1.39  1.69e- 1
#> # … with 50 more rows
```
