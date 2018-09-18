
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

iris %>%
  bootstrapify(10)
#> # A tibble: 150 x 5
#> # Groups:   .virtual_strap [10]
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
#> # ... with 140 more rows
```

You can feed a `bootstrapped_df` into `summarise()` or `do()` to perform
efficient bootstrapped computations.

``` r
iris %>%
  bootstrapify(10) %>%
  summarise(per_strap_mean = mean(Petal.Width))
#> # A tibble: 10 x 2
#>    .virtual_strap per_strap_mean
#>    <chr>                   <dbl>
#>  1 id_1                     1.22
#>  2 id_2                     1.23
#>  3 id_3                     1.23
#>  4 id_4                     1.24
#>  5 id_5                     1.11
#>  6 id_6                     1.24
#>  7 id_7                     1.21
#>  8 id_8                     1.30
#>  9 id_9                     1.15
#> 10 id_10                    1.2
```

The data can be grouped as well.

``` r
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>%
  summarise(per_strap_species_mean = mean(Petal.Width))
#> # A tibble: 30 x 3
#> # Groups:   Species [3]
#>    Species .virtual_strap per_strap_species_mean
#>    <fct>   <chr>                           <dbl>
#>  1 setosa  id_1                            0.24 
#>  2 setosa  id_2                            0.266
#>  3 setosa  id_3                            0.26 
#>  4 setosa  id_4                            0.24 
#>  5 setosa  id_5                            0.248
#>  6 setosa  id_6                            0.242
#>  7 setosa  id_7                            0.246
#>  8 setosa  id_8                            0.256
#>  9 setosa  id_9                            0.236
#> 10 setosa  id_10                           0.246
#> # ... with 20 more rows
```

`dplyr::collect()` can be used to make the implicit virtual groups
explicit. At that point, they are no longer virtual so the column name
is `.strap`.

``` r
iris %>%
  group_by(Species) %>%
  bootstrapify(10) %>%
  collect()
#> # A tibble: 1,500 x 7
#> # Groups:   Species, .strap [30]
#>    .strap   .id Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>    <chr>  <int>        <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1 id_1      48          4.6         3.2          1.4         0.2 setosa 
#>  2 id_1       8          5           3.4          1.5         0.2 setosa 
#>  3 id_1      39          4.4         3            1.3         0.2 setosa 
#>  4 id_1      45          5.1         3.8          1.9         0.4 setosa 
#>  5 id_1      31          4.8         3.1          1.6         0.2 setosa 
#>  6 id_1      31          4.8         3.1          1.6         0.2 setosa 
#>  7 id_1      50          5           3.3          1.4         0.2 setosa 
#>  8 id_1       2          4.9         3            1.4         0.2 setosa 
#>  9 id_1      30          4.7         3.2          1.6         0.2 setosa 
#> 10 id_1      18          5.1         3.5          1.4         0.3 setosa 
#> # ... with 1,490 more rows
```
