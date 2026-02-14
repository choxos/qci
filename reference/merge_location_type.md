# Merge with location type metadata

Joins data with the location_type dataset and optionally filters to
countries only.

## Usage

``` r
merge_location_type(data, loc_types = NULL, keep_types = "Country")
```

## Arguments

- data:

  A data.frame with a `location_name` column.

- loc_types:

  A data.frame with `location_name`, `type`, `iso3` columns. Defaults to
  the bundled
  [location_type](https://choxos.github.io/qci/reference/location_type.md)
  dataset.

- keep_types:

  Character vector of types to keep. Default `"Country"`. Use `NULL` to
  keep all types.

## Value

data.frame with `type` and `iso3` columns added, filtered to requested
types.

## Examples

``` r
data(sample_gbd)
result <- qci_pipeline(sample_gbd)
#> ℹ Cleaning and reshaping data...
#> ✔ Cleaned data: 9 locations, 3 years.
#> ℹ Computing epidemiological ratios...
#> ℹ Running PCA...
#> ℹ PCA done for "Both / Age-standardized": 74.1% variance explained (n=27).
#> ℹ PCA done for "Female / Age-standardized": 75.7% variance explained (n=27).
#> ℹ PCA done for "Male / Age-standardized": 73.2% variance explained (n=27).
#> ℹ Creating long format output...
#> ✔ QCI pipeline complete.
merged <- merge_location_type(result$wide)
```
