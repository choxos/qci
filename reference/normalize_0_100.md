# Normalize scores to 0-100 range

Applies min-max normalization: `100 * (x - min(x)) / (max(x) - min(x))`.

## Usage

``` r
normalize_0_100(x)
```

## Arguments

- x:

  Numeric vector.

## Value

Numeric vector scaled to \[0, 100\].
