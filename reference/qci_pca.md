# Compute QCI scores via PCA

Runs Principal Component Analysis on the four QCI ratios, stratified by
sex and age subgroups. Extracts PC1, normalizes to 0-100, then inverts
(`100 - score`) so that higher values indicate better quality of care.

## Usage

``` r
qci_pca(
  data,
  ratio_cols = c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC"),
  group_by = c("sex_name", "age_name"),
  ncp = 5,
  scale.unit = TRUE
)
```

## Arguments

- data:

  A data.table with the four ratio columns (`MIR`, `YLLtoYLD`,
  `DALtoPER`, `PERtoINC`) plus grouping columns `sex_name` and
  `age_name`. Typically the output of
  [`qci_ratios()`](https://choxos.github.io/qci/reference/qci_ratios.md).

- ratio_cols:

  Character vector of column names for PCA input. Default
  `c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC")`.

- group_by:

  Character vector of columns to stratify PCA by. Default
  `c("sex_name", "age_name")`.

- ncp:

  Integer. Number of principal components to compute. Default `5`
  (FactoMineR default). Only PC1 is used for QCI.

- scale.unit:

  Logical. Whether to scale variables to unit variance before PCA.
  Default `TRUE`.

## Value

A list with two elements:

- data:

  The input data.table with a new `qci_score` column containing the
  0-100 inverted PCA score.

- pca_details:

  A data.frame with one row per subgroup, containing columns: sex_name,
  age_name, variance_explained_pc1, eigenvalue_pc1, n_observations.

## Examples

``` r
data(sample_gbd)
cleaned <- qci_clean(sample_gbd)
#> ✔ Cleaned data: 9 locations, 3 years.
with_ratios <- qci_ratios(cleaned$wide_number)
result <- qci_pca(with_ratios)
#> ℹ PCA done for "Both / Age-standardized": 74.1% variance explained (n=27).
#> ℹ PCA done for "Female / Age-standardized": 75.7% variance explained (n=27).
#> ℹ PCA done for "Male / Age-standardized": 73.2% variance explained (n=27).
head(result$data[, .(location_name, year, sex_name, qci_score)])
#>    location_name  year sex_name qci_score
#>           <char> <int>   <char>     <num>
#> 1:         China  1990     Both 11.209011
#> 2:         China  1990   Female 19.019548
#> 3:         China  1990     Male  2.425957
#> 4:         China  2005     Both 53.875599
#> 5:         China  2005   Female 53.221197
#> 6:         China  2005     Male 55.349268
```
