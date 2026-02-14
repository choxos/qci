# Export QCI results to Stata DTA format

Writes QCI results to a Stata `.dta` file via
[`haven::write_dta()`](https://haven.tidyverse.org/reference/read_dta.html).
Requires the haven package.

## Usage

``` r
qci_export_dta(data, file)
```

## Arguments

- data:

  A data.frame.

- file:

  Character. Output file path.

## Value

Invisible file path.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- qci_pipeline(sample_gbd)
qci_export_dta(result$wide, "qci_results.dta")
} # }
```
