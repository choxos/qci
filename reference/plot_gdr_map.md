# Create a choropleth map of Gender Disparity Ratio

Create a choropleth map of Gender Disparity Ratio

## Usage

``` r
plot_gdr_map(
  data,
  years = NULL,
  breaks = c(0, 0.5, 0.95, 1.05, 2, Inf),
  labels = c("< 0.5", "[0.5, 0.95)", "[0.95, 1.05]", "(1.05, 2.0]", "> 2.0"),
  colors = c("#878787", "#b7b7b7", "#64c2a5", "#b1abd0", "#7f74ac"),
  title = NULL,
  legend_title = "Age-standardized GDR"
)
```

## Arguments

- data:

  A data.frame with at least: `iso3`, `gdr`, and optionally `year`. Use
  [`merge_location_type()`](https://choxos.github.io/qci/reference/merge_location_type.md)
  to add `iso3` to
  [`qci_gdr()`](https://choxos.github.io/qci/reference/qci_gdr.md)
  output.

- years:

  Integer vector. Default `NULL` (all).

- breaks:

  Numeric vector of GDR breakpoints. Default
  `c(0, 0.5, 0.95, 1.05, 2.0, Inf)`.

- labels:

  Character vector of labels for GDR bins. Default
  `c("< 0.5", "[0.5, 0.95)", "[0.95, 1.05]", "(1.05, 2.0]", "> 2.0")`.

- colors:

  Character vector of 5 colors. Default grey-to-purple scale.

- title:

  Character. Default `NULL` (auto-generated).

- legend_title:

  Character. Default `"Age-standardized GDR"`.

## Value

A ggplot2 object.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- qci_pipeline(sample_gbd)
gdr <- qci_gdr(result$wide)
gdr_map <- merge_location_type(gdr)
plot_gdr_map(gdr_map, years = c(1990, 2019))
} # }
```
