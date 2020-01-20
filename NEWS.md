# strapgod 0.0.4

* The resampled data frame method for `tidyr::nest()` has been updated to
  support the changes in tidyr 1.0.0.

# strapgod 0.0.3

* In dplyr 0.8.2, the `ptype` is carried along as an attribute 
  in `group_split()`. A test was updated to reflect this.

* In dplyr 0.8.2, the behavior of `tbl_vars()` was changed to return a classed
  object. A test has been updated to reflect this (#13).

# strapgod 0.0.2

* In dplyr 0.8.1, the behavior of `group_map()` was moved to `group_modify()`,
  and `group_map()` was repurposed to always return a list. strapgod has been
  updated to reflect these changes.

# strapgod 0.0.1

* Added a `NEWS.md` file to track changes to the package.
