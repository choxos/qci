#' Standardize GBD measure names
#'
#' Converts verbose GBD measure names to short forms.
#'
#' @param x Character vector of measure_name values.
#' @return Character vector with shortened names.
#' @keywords internal
standardize_measure_names <- function(x) {
  x[x == "DALYs (Disability-Adjusted Life Years)"] <- "DALYs"
  x[x == "YLDs (Years Lived with Disability)"] <- "YLDs"
  x[x == "YLLs (Years of Life Lost)"] <- "YLLs"
  x
}

#' Normalize scores to 0-100 range
#'
#' Applies min-max normalization: `100 * (x - min(x)) / (max(x) - min(x))`.
#'
#' @param x Numeric vector.
#' @return Numeric vector scaled to \[0, 100\].
#' @keywords internal
normalize_0_100 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (rng[2] == rng[1]) return(rep(50, length(x)))
  100 * (x - rng[1]) / (rng[2] - rng[1])
}

#' Validate GBD data columns
#'
#' Checks that a data.frame has the required columns for QCI computation.
#'
#' @param data A data.frame to validate.
#' @param required Character vector of required column names. If NULL, uses
#'   the standard GBD columns.
#' @return Invisible TRUE. Side effect: aborts on failure.
#' @keywords internal
validate_gbd_columns <- function(data, required = NULL) {
  if (is.null(required)) {
    required <- c("measure_id", "measure_name", "location_id", "location_name",
                   "sex_id", "sex_name", "age_id", "age_name", "cause_id",
                   "cause_name", "metric_id", "metric_name", "year",
                   "val", "upper", "lower")
  }

  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols) > 0) {
    cli_abort(c(
      "Missing required columns in GBD data:",
      "x" = "Missing: {.field {missing_cols}}",
      "i" = "Expected columns from GBD Results Tool export."
    ))
  }
  invisible(TRUE)
}

#' Check for required measures
#'
#' Verifies that data contains all 6 GBD measures needed for QCI.
#'
#' @param data A data.frame with a measure_name column.
#' @return Invisible TRUE. Side effect: aborts on failure.
#' @keywords internal
validate_measures <- function(data) {
  required_measures <- c("DALYs", "YLDs", "YLLs", "Deaths", "Incidence", "Prevalence")
  present <- unique(data$measure_name)
  # Also check for verbose versions
  present_std <- standardize_measure_names(present)
  missing <- setdiff(required_measures, present_std)
  if (length(missing) > 0) {
    cli_abort(c(
      "Missing required measures for QCI computation:",
      "x" = "Missing: {.field {missing}}",
      "i" = "QCI requires all 6 measures: {.field {required_measures}}"
    ))
  }
  invisible(TRUE)
}

#' Merge with location type metadata
#'
#' Joins data with the location_type dataset and optionally filters to
#' countries only.
#'
#' @param data A data.frame with a `location_name` column.
#' @param loc_types A data.frame with `location_name`, `type`, `iso3` columns.
#'   Defaults to the bundled [location_type] dataset.
#' @param keep_types Character vector of types to keep.
#'   Default `"Country"`. Use `NULL` to keep all types.
#' @return data.frame with `type` and `iso3` columns added, filtered to
#'   requested types.
#' @export
#' @examples
#' data(sample_gbd)
#' result <- qci_pipeline(sample_gbd)
#' merged <- merge_location_type(result$wide)
merge_location_type <- function(data, loc_types = NULL, keep_types = "Country") {
  if (is.null(loc_types)) {
    loc_types <- qci::location_type
  }
  # Merge
  result <- merge(data, loc_types, by = "location_name", all.x = FALSE,
                  suffixes = c("", ".loc"))
  # Remove duplicate location_id if present
  if ("location_id.loc" %in% names(result)) {
    result$location_id.loc <- NULL
  }
  # Filter by type

if (!is.null(keep_types)) {
    result <- result[result$type %in% keep_types, ]
  }
  result
}
