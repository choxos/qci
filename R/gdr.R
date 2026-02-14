#' Calculate Gender Disparity Ratio (GDR)
#'
#' Computes GDR = Female QCI / Male QCI for each location, year, and
#' age group. Classifies the ratio into categories based on thresholds.
#'
#' @param data A data.frame or data.table containing at minimum:
#'   `location_name` (or `location_id`), `year`, `sex_name`, `age_name`,
#'   `qci_score`. Typically the `data` element from [qci_pca()] output,
#'   or the `wide` element from [qci_pipeline()].
#' @param low_threshold Numeric. GDR below this value is classified `"low"`.
#'   Default `0.95`.
#' @param high_threshold Numeric. GDR above this value is classified `"high"`.
#'   Default `1.05`.
#' @return A data.table with columns: `location_id`, `location_name`, `year`,
#'   `age_name`, `qci_female`, `qci_male`, `gdr`, `gdr_category`.
#' @export
#' @examples
#' data(sample_gbd)
#' result <- qci_pipeline(sample_gbd)
#' gdr <- qci_gdr(result$wide)
#' head(gdr)
qci_gdr <- function(data, low_threshold = 0.95, high_threshold = 1.05) {
  dt <- copy(setDT(as.data.frame(data)))

  # Check required columns
  score_col <- if ("qci_score" %in% names(dt)) "qci_score" else "val_pca_score"
  if (!score_col %in% names(dt)) {
    cli_abort("Data must contain a {.field qci_score} or {.field val_pca_score} column.")
  }
  if (!"sex_name" %in% names(dt)) {
    cli_abort("Data must contain a {.field sex_name} column.")
  }

  # Filter to Male and Female only
  dt_sex <- dt[dt$sex_name %in% c("Male", "Female"), ]

  if (nrow(dt_sex) == 0) {
    cli_abort("No Male or Female data found.")
  }

  # Determine grouping columns
  id_cols <- intersect(c("location_id", "location_name", "year", "age_name"), names(dt_sex))

  # Pivot wider
  dt_wide <- dcast(dt_sex, as.formula(paste(paste(id_cols, collapse = " + "), "~ sex_name")),
                   value.var = score_col)

  if (!all(c("Female", "Male") %in% names(dt_wide))) {
    cli_abort("Both Male and Female data required for GDR computation.")
  }

  # Compute GDR
  setnames(dt_wide, c("Female", "Male"), c("qci_female", "qci_male"))
  dt_wide[, gdr := qci_female / qci_male]

  # Categorize
  dt_wide[, gdr_category := ifelse(gdr < low_threshold, "low",
                                    ifelse(gdr > high_threshold, "high", "equal"))]

  # Replace Inf/NaN
  dt_wide[is.infinite(gdr) | is.nan(gdr), gdr := NA_real_]
  dt_wide[is.na(gdr), gdr_category := NA_character_]

  dt_wide[]
}
