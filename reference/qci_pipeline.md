# Run the complete QCI pipeline

A convenience function that chains all processing steps: load (optional)
-\> clean -\> compute ratios -\> PCA -\> merge with Rate data -\> create
long format output.

## Usage

``` r
qci_pipeline(
  data,
  loc_types = NULL,
  keep_types = "Country",
  age_categories = "Age-standardized",
  exclude_location_ids = 533L,
  ratio_cols = c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC"),
  verbose = TRUE
)
```

## Arguments

- data:

  A data.frame of raw GBD data. If a character vector of file paths,
  [`qci_load()`](https://choxos.github.io/qci/reference/qci_load.md) is
  called first.

- loc_types:

  Location type metadata. `NULL` uses the bundled dataset.

- keep_types:

  Character vector of location types. Default `"Country"`.

- age_categories:

  Character vector of age groups. Default `"Age-standardized"`.

- exclude_location_ids:

  Integer vector. Default `533`.

- ratio_cols:

  Character vector of ratio column names for PCA. Default
  `c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC")`.

- verbose:

  Logical. Print progress messages. Default `TRUE`.

## Value

A list with elements:

- wide:

  data.table in wide format. Contains Rate columns, Number columns
  (suffixed `_Number`), the 4 ratios, and `qci_score`.

- long:

  data.table in long format with columns: location_id, location_name,
  year, sex_name, age_name, measure, value, upper, lower.

- pca_details:

  data.frame of variance explained per subgroup.

## Details

This is the primary user-facing function for computing QCI from raw GBD
data.

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
head(result$wide[, .(location_name, year, sex_name, qci_score)])
#> Key: <location_name, year, sex_name>
#>    location_name  year sex_name qci_score
#>           <char> <int>   <char>     <num>
#> 1:     Australia  1990     Both  99.96851
#> 2:     Australia  1990   Female  99.96648
#> 3:     Australia  1990     Male  99.94012
#> 4:     Australia  2005     Both 100.00000
#> 5:     Australia  2005   Female  99.91433
#> 6:     Australia  2005     Male  99.97438
```
