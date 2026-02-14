# Sample GBD export data

A small subset of GBD 2019 data for orofacial clefts (cause_id 644)
containing 10 countries, 3 years (1990, 2005, 2019), all 6 measures,
Rate and Number metrics, all 3 sex categories, and the
"Age-standardized" age group. Suitable for testing and examples.

## Usage

``` r
sample_gbd
```

## Format

A data.frame with approximately 1,080 rows and 16 columns:

- measure_id:

  Integer. GBD measure identifier.

- measure_name:

  Character. One of: "YLLs (Years of Life Lost)", "YLDs (Years Lived
  with Disability)", "DALYs (Disability-Adjusted Life Years)", "Deaths",
  "Incidence", "Prevalence".

- location_id:

  Integer. GBD location identifier.

- location_name:

  Character. Country or region name.

- sex_id:

  Integer. 1 = Male, 2 = Female, 3 = Both.

- sex_name:

  Character. "Male", "Female", or "Both".

- age_id:

  Integer. GBD age group identifier.

- age_name:

  Character. Age group label.

- cause_id:

  Integer. GBD cause identifier.

- cause_name:

  Character. Disease/condition name.

- metric_id:

  Integer. 1 = Number, 2 = Percent, 3 = Rate.

- metric_name:

  Character. "Number", "Percent", or "Rate".

- year:

  Integer. Calendar year.

- val:

  Numeric. Point estimate.

- upper:

  Numeric. Upper uncertainty bound.

- lower:

  Numeric. Lower uncertainty bound.

## Source

GBD Results Tool <https://vizhub.healthdata.org/gbd-results/>
