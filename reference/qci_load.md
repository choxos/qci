# Load GBD CSV data

Reads one or more GBD CSV export files and combines them into a single
data.table. Handles the row-number column that GBD exports include as
the first unnamed column. Uses
[`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html)
for speed.

## Usage

``` r
qci_load(files, ...)
```

## Arguments

- files:

  Character vector of file paths to GBD CSV exports. Can be a single
  file or multiple files to be row-bound.

- ...:

  Additional arguments passed to
  [`data.table::fread()`](https://rdrr.io/pkg/data.table/man/fread.html).

## Value

A data.table with standard GBD columns: measure_id, measure_name,
location_id, location_name, sex_id, sex_name, age_id, age_name,
cause_id, cause_name, metric_id, metric_name, year, val, upper, lower.

## Examples

``` r
f <- system.file("extdata", "sample_gbd_data.csv", package = "qci")
gbd <- qci_load(f)
#> ℹ Loaded 486 rows from 1 file(s).
head(gbd)
#>    measure_id                       measure_name location_id location_name
#>         <int>                             <char>       <int>        <char>
#> 1:          3 YLDs (Years Lived with Disability)          67         Japan
#> 2:          3 YLDs (Years Lived with Disability)          67         Japan
#> 3:          3 YLDs (Years Lived with Disability)          67         Japan
#> 4:          3 YLDs (Years Lived with Disability)           6         China
#> 5:          3 YLDs (Years Lived with Disability)           6         China
#> 6:          3 YLDs (Years Lived with Disability)           6         China
#>    sex_id sex_name age_id         age_name cause_id       cause_name metric_id
#>     <int>   <char>  <int>           <char>    <int>           <char>     <int>
#> 1:      1     Male     27 Age-standardized      644 Orofacial clefts         3
#> 2:      2   Female     27 Age-standardized      644 Orofacial clefts         3
#> 3:      3     Both     27 Age-standardized      644 Orofacial clefts         3
#> 4:      1     Male     27 Age-standardized      644 Orofacial clefts         3
#> 5:      2   Female     27 Age-standardized      644 Orofacial clefts         3
#> 6:      3     Both     27 Age-standardized      644 Orofacial clefts         3
#>    metric_name  year      val    upper    lower
#>         <char> <int>    <num>    <num>    <num>
#> 1:        Rate  1990 2.674029 3.940510 1.640714
#> 2:        Rate  1990 2.779096 4.130920 1.715965
#> 3:        Rate  1990 2.723352 4.026659 1.692504
#> 4:        Rate  1990 3.612208 5.409820 2.235131
#> 5:        Rate  1990 4.225407 6.288380 2.609528
#> 6:        Rate  1990 3.910120 5.860485 2.417979
```
