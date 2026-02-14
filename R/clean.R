#' Clean and filter GBD data for QCI computation
#'
#' Performs the standard data preparation steps:
#' 1. Remove specified location IDs (e.g., 533 for Melanesia aggregate)
#' 2. Standardize measure names (shorten verbose GBD names)
#' 3. Filter to specified countries using location_type metadata
#' 4. Filter to specified age categories
#' 5. Filter to Rate metric and reshape to wide format
#'
#' @param data A data.frame or data.table of raw GBD data (output of
#'   [qci_load()]).
#' @param loc_types A data.frame of location metadata. If `NULL`, uses the
#'   bundled [location_type] dataset.
#' @param keep_types Character vector of location types to retain.
#'   Default `"Country"`. Use `NULL` to skip location type filtering.
#' @param age_categories Character vector of age groups to include.
#'   Default `"Age-standardized"`.
#' @param exclude_location_ids Integer vector of location_ids to exclude.
#'   Default `533`.
#' @return A list with two data.table elements:
#'   \describe{
#'     \item{wide_rate}{Wide-format data for Rate metric, used for the
#'       final merged output.}
#'     \item{wide_number}{Wide-format data used for ratio/PCA computation.
#'       Uses Rate data (ratios of rates equal ratios of numbers).}
#'   }
#'   Each has columns like `val_Deaths`, `val_Incidence`, `upper_Deaths`,
#'   `lower_Deaths`, etc.
#' @export
#' @examples
#' data(sample_gbd)
#' cleaned <- qci_clean(sample_gbd)
#' names(cleaned)
qci_clean <- function(data,
                      loc_types = NULL,
                      keep_types = "Country",
                      age_categories = "Age-standardized",
                      exclude_location_ids = 533L) {

  dt <- copy(setDT(as.data.frame(data)))

  # Validate
  validate_gbd_columns(dt)
  validate_measures(dt)

  # Step 1: Exclude location IDs
  if (!is.null(exclude_location_ids) && length(exclude_location_ids) > 0) {
    dt <- dt[!dt$location_id %in% exclude_location_ids, ]
  }

  # Step 2: Standardize measure names
  dt$measure_name <- standardize_measure_names(dt$measure_name)

  # Step 3: Filter to specified location types
  if (!is.null(keep_types)) {
    if (is.null(loc_types)) {
      loc_types <- qci::location_type
    }
    valid_locations <- loc_types$location_name[loc_types$type %in% keep_types]
    dt <- dt[dt$location_name %in% valid_locations, ]

    if (nrow(dt) == 0) {
      cli_abort("No data remaining after filtering to location types: {.val {keep_types}}")
    }
  }

  # Step 4: Filter age categories
  dt <- dt[dt$age_name %in% age_categories, ]
  if (nrow(dt) == 0) {
    cli_abort("No data remaining after filtering to age categories: {.val {age_categories}}")
  }

  # Step 5: Use Rate metric for both wide datasets

  # Note: For Age-standardized data, only Rate metric is available from GBD.
  # Ratios computed from rates are mathematically equivalent to ratios from
  # numbers (denominators cancel), so this is valid for QCI computation.
  dt_rate <- dt[dt$metric_name == "Rate", ]

  if (nrow(dt_rate) == 0) {
    cli_abort("No Rate metric data found.")
  }

  # Step 6: Reshape to wide format
  cast_formula <- location_id + location_name + year + sex_name + age_name ~ measure_name

  wide_rate <- dcast(setDT(copy(dt_rate)), cast_formula,
                     value.var = c("val", "upper", "lower"))

  # wide_number uses the same Rate data (ratios are scale-invariant)
  wide_number <- dcast(setDT(copy(dt_rate)), cast_formula,
                       value.var = c("val", "upper", "lower"))

  cli_alert_success("Cleaned data: {.val {length(unique(dt$location_name))}} locations, {.val {length(unique(dt$year))}} years.")

  list(wide_rate = wide_rate, wide_number = wide_number)
}
