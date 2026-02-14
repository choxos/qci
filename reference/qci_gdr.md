# Calculate Gender Disparity Ratio (GDR)

Computes GDR = Female QCI / Male QCI for each location, year, and age
group. Classifies the ratio into categories based on thresholds.

## Usage

``` r
qci_gdr(data, low_threshold = 0.95, high_threshold = 1.05)
```

## Arguments

- data:

  A data.frame or data.table containing at minimum: `location_name` (or
  `location_id`), `year`, `sex_name`, `age_name`, `qci_score`. Typically
  the `data` element from
  [`qci_pca()`](https://choxos.github.io/qci/reference/qci_pca.md)
  output, or the `wide` element from
  [`qci_pipeline()`](https://choxos.github.io/qci/reference/qci_pipeline.md).

- low_threshold:

  Numeric. GDR below this value is classified `"low"`. Default `0.95`.

- high_threshold:

  Numeric. GDR above this value is classified `"high"`. Default `1.05`.

## Value

A data.table with columns: `location_id`, `location_name`, `year`,
`age_name`, `qci_female`, `qci_male`, `gdr`, `gdr_category`.

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
gdr <- qci_gdr(result$wide)
head(gdr)
#> Key: <location_id, location_name, year, age_name>
#>    location_id location_name  year         age_name qci_female  qci_male
#>          <int>        <char> <int>           <char>      <num>     <num>
#> 1:           6         China  1990 Age-standardized   19.01955  2.425957
#> 2:           6         China  2005 Age-standardized   53.22120 55.349268
#> 3:           6         China  2019 Age-standardized   83.53537 92.311271
#> 4:          67         Japan  1990 Age-standardized   98.90032 98.579658
#> 5:          67         Japan  2005 Age-standardized   98.57262 99.512890
#> 6:          67         Japan  2019 Age-standardized   94.94150 99.428526
#>          gdr gdr_category
#>        <num>       <char>
#> 1: 7.8400189         high
#> 2: 0.9615519        equal
#> 3: 0.9049315          low
#> 4: 1.0032528        equal
#> 5: 0.9905512        equal
#> 6: 0.9548718        equal
```
