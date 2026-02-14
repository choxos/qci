# Validate GBD data columns

Checks that a data.frame has the required columns for QCI computation.

## Usage

``` r
validate_gbd_columns(data, required = NULL)
```

## Arguments

- data:

  A data.frame to validate.

- required:

  Character vector of required column names. If NULL, uses the standard
  GBD columns.

## Value

Invisible TRUE. Side effect: aborts on failure.
