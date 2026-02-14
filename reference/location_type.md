# Location type metadata

Mapping of GBD location identifiers to location type (Country, WHO
Region, World Bank Income Level, SDI, etc.) and ISO3 codes. Used to
filter data to country-level observations and to join ISO3 codes for
mapping.

## Usage

``` r
location_type
```

## Format

A data.frame with columns:

- location_id:

  Integer. GBD location identifier.

- location_name:

  Character. GBD location name.

- type:

  Character. Location classification (e.g., "Country", "WHO Regions",
  "SDI", "World Bank Income Levels").

- iso3:

  Character. ISO 3166-1 alpha-3 country code (NA for non-country
  locations).
