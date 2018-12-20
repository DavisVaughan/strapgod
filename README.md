
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

`dplyr 0.8` adds some more neat group-wise functionality, but it is a
little unstable right now with regards to `group_split(keep = FALSE)`
which is used by the default of `group_nest()` and `group_map()`.

``` r
iris[1:3,] %>%
  bootstrapify(2) %>% 
  group_split()
#> [[1]]
#> # A tibble: 3 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.7         3.2          1.3         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 
#> [[2]]
#> # A tibble: 3 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          4.7         3.2          1.3         0.2 setosa 
#> 2          4.7         3.2          1.3         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa
```

``` r
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>% 
  group_nest(keep = TRUE)
#> # A tibble: 30 x 3
#>    Species .bootstrap data             
#>    <fct>        <int> <list>           
#>  1 setosa           1 <tibble [50 × 5]>
#>  2 setosa           2 <tibble [50 × 5]>
#>  3 setosa           3 <tibble [50 × 5]>
#>  4 setosa           4 <tibble [50 × 5]>
#>  5 setosa           5 <tibble [50 × 5]>
#>  6 setosa           6 <tibble [50 × 5]>
#>  7 setosa           7 <tibble [50 × 5]>
#>  8 setosa           8 <tibble [50 × 5]>
#>  9 setosa           9 <tibble [50 × 5]>
#> 10 setosa          10 <tibble [50 × 5]>
#> # … with 20 more rows
```
