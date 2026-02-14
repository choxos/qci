# Scatter plot of Male vs Female QCI by region

Creates a scatter plot with Male QCI on x-axis and Female QCI on y-axis,
colored by region or custom grouping. Includes a diagonal reference line
(y = x).

## Usage

``` r
plot_qci_scatter(
  data,
  score_var = "qci_score",
  year,
  age = "Age-standardized",
  color_by = NULL,
  point_size = 2,
  show_diagonal = TRUE
)
```

## Arguments

- data:

  A data.frame with columns: `location_name`, `qci_score` (or column
  specified by `score_var`), `sex_name`, `year`, `age_name`. Should
  include both Male and Female rows.

- score_var:

  Character. Column name for the score. Default `"qci_score"`.

- year:

  Integer. Single year to plot. Required.

- age:

  Character. Default `"Age-standardized"`.

- color_by:

  Character. Column name to color points by (e.g., `"type"`). Default
  `NULL` (no color grouping).

- point_size:

  Numeric. Point size. Default `2`.

- show_diagonal:

  Logical. Show y = x line. Default `TRUE`.

## Value

A ggplot2 object.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- qci_pipeline(sample_gbd)
map_data <- merge_location_type(result$wide)
plot_qci_scatter(map_data, year = 2019, color_by = "type")
} # }
```
