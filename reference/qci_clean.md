# Clean and filter GBD data for QCI computation

Performs the standard data preparation steps:

1.  Remove specified location IDs (e.g., 533 for Melanesia aggregate)

2.  Standardize measure names (shorten verbose GBD names)

3.  Filter to specified countries using location_type metadata

4.  Filter to specified age categories

5.  Filter to Rate metric and reshape to wide format

## Usage

``` r
qci_clean(
  data,
  loc_types = NULL,
  keep_types = "Country",
  age_categories = "Age-standardized",
  exclude_location_ids = 533L
)
```

## Arguments

- data:

  A data.frame or data.table of raw GBD data (output of
  [`qci_load()`](https://choxos.github.io/qci/reference/qci_load.md)).

- loc_types:

  A data.frame of location metadata. If `NULL`, uses the bundled
  [location_type](https://choxos.github.io/qci/reference/location_type.md)
  dataset.

- keep_types:

  Character vector of location types to retain. Default `"Country"`. Use
  `NULL` to skip location type filtering.

- age_categories:

  Character vector of age groups to include. Default
  `"Age-standardized"`.

- exclude_location_ids:

  Integer vector of location_ids to exclude. Default `533`.

## Value

A list with two data.table elements:

- wide_rate:

  Wide-format data for Rate metric, used for the final merged output.

- wide_number:

  Wide-format data used for ratio/PCA computation. Uses Rate data
  (ratios of rates equal ratios of numbers).

Each has columns like `val_Deaths`, `val_Incidence`, `upper_Deaths`,
`lower_Deaths`, etc.

## Examples

``` r
data(sample_gbd)
cleaned <- qci_clean(sample_gbd)
#> ✔ Cleaned data: 9 locations, 3 years.
names(cleaned)
#> [1] "wide_rate"   "wide_number"
```
