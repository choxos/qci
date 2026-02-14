#' Sample GBD export data
#'
#' A small subset of GBD 2019 data for orofacial clefts (cause_id 644)
#' containing 10 countries, 3 years (1990, 2005, 2019), all 6 measures,
#' Rate and Number metrics, all 3 sex categories, and the
#' "Age-standardized" age group. Suitable for testing and examples.
#'
#' @format A data.frame with approximately 1,080 rows and 16 columns:
#' \describe{
#'   \item{measure_id}{Integer. GBD measure identifier.}
#'   \item{measure_name}{Character. One of: "YLLs (Years of Life Lost)",
#'     "YLDs (Years Lived with Disability)",
#'     "DALYs (Disability-Adjusted Life Years)",
#'     "Deaths", "Incidence", "Prevalence".}
#'   \item{location_id}{Integer. GBD location identifier.}
#'   \item{location_name}{Character. Country or region name.}
#'   \item{sex_id}{Integer. 1 = Male, 2 = Female, 3 = Both.}
#'   \item{sex_name}{Character. "Male", "Female", or "Both".}
#'   \item{age_id}{Integer. GBD age group identifier.}
#'   \item{age_name}{Character. Age group label.}
#'   \item{cause_id}{Integer. GBD cause identifier.}
#'   \item{cause_name}{Character. Disease/condition name.}
#'   \item{metric_id}{Integer. 1 = Number, 2 = Percent, 3 = Rate.}
#'   \item{metric_name}{Character. "Number", "Percent", or "Rate".}
#'   \item{year}{Integer. Calendar year.}
#'   \item{val}{Numeric. Point estimate.}
#'   \item{upper}{Numeric. Upper uncertainty bound.}
#'   \item{lower}{Numeric. Lower uncertainty bound.}
#' }
#' @source GBD Results Tool <https://vizhub.healthdata.org/gbd-results/>
"sample_gbd"

#' Location type metadata
#'
#' Mapping of GBD location identifiers to location type (Country, WHO Region,
#' World Bank Income Level, SDI, etc.) and ISO3 codes. Used to filter
#' data to country-level observations and to join ISO3 codes for mapping.
#'
#' @format A data.frame with columns:
#' \describe{
#'   \item{location_id}{Integer. GBD location identifier.}
#'   \item{location_name}{Character. GBD location name.}
#'   \item{type}{Character. Location classification (e.g., "Country",
#'     "WHO Regions", "SDI", "World Bank Income Levels").}
#'   \item{iso3}{Character. ISO 3166-1 alpha-3 country code (NA for
#'     non-country locations).}
#' }
"location_type"

