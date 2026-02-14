# Create a choropleth map of QCI scores

Plots QCI scores on a world map using natural earth geometries. Supports
faceting by year and custom color scales with quantile-based breaks.

## Usage

``` r
plot_qci_map(
  data,
  fill_var = "qci_score",
  years = NULL,
  sex = "Both",
  age = "Age-standardized",
  n_quantiles = 5,
  colors = c("#a40227", "#f56c42", "#dfbf72", "#a7da68", "#1a9850"),
  title = NULL,
  legend_title = "Age-standardized QCI (%)"
)
```

## Arguments

- data:

  A data.frame with at least: `iso3`, `qci_score` (or a column specified
  by `fill_var`), and optionally `year` for faceting. Use
  [`merge_location_type()`](https://choxos.github.io/qci/reference/merge_location_type.md)
  to add `iso3` to pipeline output.

- fill_var:

  Character. Column name to map to fill color. Default `"qci_score"`.

- years:

  Integer vector of years to display. Default `NULL` (all).

- sex:

  Character. Sex to filter to. Default `"Both"`.

- age:

  Character. Age group to filter to. Default `"Age-standardized"`.

- n_quantiles:

  Integer. Number of quantile bins for the color scale. Default `5`.

- colors:

  Character vector of colors for the quantile bins, from lowest to
  highest. Default red-to-green scale.

- title:

  Character. Plot title. Default `NULL` (auto-generated).

- legend_title:

  Character. Legend title. Default `"Age-standardized QCI (%)"`.

## Value

A ggplot2 object.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- qci_pipeline(sample_gbd)
map_data <- merge_location_type(result$wide)
plot_qci_map(map_data, years = c(1990, 2019))
} # }
```
