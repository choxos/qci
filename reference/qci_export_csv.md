# Export QCI results to CSV

Writes QCI results to a CSV file.

## Usage

``` r
qci_export_csv(data, file)
```

## Arguments

- data:

  A data.frame of QCI results.

- file:

  Character. Output file path.

## Value

Invisible file path (for piping).

## Examples

``` r
if (FALSE) { # \dontrun{
result <- qci_pipeline(sample_gbd)
qci_export_csv(result$wide, "qci_results.csv")
} # }
```
