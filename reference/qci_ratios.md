# Calculate QCI component ratios

Computes the four epidemiological ratios that form the basis of the QCI:

- **MIR** = Deaths / Incidence (Mortality-to-Incidence Ratio)

- **YLLtoYLD** = YLLs / YLDs (YLL-to-YLD Ratio)

- **DALtoPER** = DALYs / Prevalence (DALY-to-Prevalence Ratio)

- **PERtoINC** = Prevalence / Incidence (Prevalence-to-Incidence Ratio)

## Usage

``` r
qci_ratios(wide_number)
```

## Arguments

- wide_number:

  A data.table in wide format for the Number metric (the `wide_number`
  element from
  [`qci_clean()`](https://choxos.github.io/qci/reference/qci_clean.md)).

## Value

The input data.table with 12 new columns appended: `MIR`, `lower_MIR`,
`upper_MIR`, `YLLtoYLD`, `lower_YLLtoYLD`, `upper_YLLtoYLD`, `DALtoPER`,
`lower_DALtoPER`, `upper_DALtoPER`, `PERtoINC`, `lower_PERtoINC`,
`upper_PERtoINC`.

## Details

Each ratio is computed for point estimates (`val`), `upper`, and `lower`
uncertainty bounds. `Inf` and `NaN` values from division by zero are
replaced with `NA`.

## Examples

``` r
data(sample_gbd)
cleaned <- qci_clean(sample_gbd)
#> ✔ Cleaned data: 9 locations, 3 years.
with_ratios <- qci_ratios(cleaned$wide_number)
head(with_ratios[, .(location_name, year, MIR, YLLtoYLD, DALtoPER, PERtoINC)])
#>    location_name  year        MIR  YLLtoYLD  DALtoPER PERtoINC
#>           <char> <int>      <num>     <num>     <num>    <num>
#> 1:         China  1990 0.15101818 10.450506 0.7062324 20.75489
#> 2:         China  1990 0.12605741  8.187540 0.5649204 22.18755
#> 3:         China  1990 0.17373700 12.850767 0.8575658 19.33898
#> 4:         China  2005 0.08362720  3.988318 0.3092202 29.98444
#> 5:         China  2005 0.06973195  3.241955 0.2620949 30.86632
#> 6:         China  2005 0.09544737  4.676373 0.3531796 29.07491
```
