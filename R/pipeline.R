#' Run the complete QCI pipeline
#'
#' A convenience function that chains all processing steps:
#' load (optional) -> clean -> compute ratios -> PCA -> merge with
#' Rate data -> create long format output.
#'
#' This is the primary user-facing function for computing QCI from raw
#' GBD data.
#'
#' @param data A data.frame of raw GBD data. If a character vector of
#'   file paths, [qci_load()] is called first.
#' @param loc_types Location type metadata. `NULL` uses the bundled dataset.
#' @param keep_types Character vector of location types.
#'   Default `"Country"`.
#' @param age_categories Character vector of age groups.
#'   Default `"Age-standardized"`.
#' @param exclude_location_ids Integer vector. Default `533`.
#' @param ratio_cols Character vector of ratio column names for PCA.
#'   Default `c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC")`.
#' @param verbose Logical. Print progress messages. Default `TRUE`.
#' @return A list with elements:
#'   \describe{
#'     \item{wide}{data.table in wide format. Contains Rate columns, Number
#'       columns (suffixed `_Number`), the 4 ratios, and `qci_score`.}
#'     \item{long}{data.table in long format with columns: location_id,
#'       location_name, year, sex_name, age_name, measure, value, upper,
#'       lower.}
#'     \item{pca_details}{data.frame of variance explained per subgroup.}
#'   }
#' @export
#' @examples
#' data(sample_gbd)
#' result <- qci_pipeline(sample_gbd)
#' head(result$wide[, .(location_name, year, sex_name, qci_score)])
qci_pipeline <- function(data,
                         loc_types = NULL,
                         keep_types = "Country",
                         age_categories = "Age-standardized",
                         exclude_location_ids = 533L,
                         ratio_cols = c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC"),
                         verbose = TRUE) {

  # Step 1: Load if file paths
  if (is.character(data)) {
    if (verbose) cli_alert_info("Loading data from file(s)...")
    data <- qci_load(data)
  }

  # Step 2: Clean
  if (verbose) cli_alert_info("Cleaning and reshaping data...")
  cleaned <- qci_clean(data,
                       loc_types = loc_types,
                       keep_types = keep_types,
                       age_categories = age_categories,
                       exclude_location_ids = exclude_location_ids)

  # Step 3: Compute ratios
  if (verbose) cli_alert_info("Computing epidemiological ratios...")
  with_ratios <- qci_ratios(cleaned$wide_number)

  # Step 4: PCA
  if (verbose) cli_alert_info("Running PCA...")
  pca_result <- qci_pca(with_ratios, ratio_cols = ratio_cols)
  output_data <- pca_result$data

  # Step 5: Rename ratio columns to val_ prefix for consistency
  output_data <- copy(output_data)
  setnames(output_data, "MIR", "val_MIR", skip_absent = TRUE)
  setnames(output_data, "YLLtoYLD", "val_YLLtoYLD", skip_absent = TRUE)
  setnames(output_data, "DALtoPER", "val_DALtoPER", skip_absent = TRUE)
  setnames(output_data, "PERtoINC", "val_PERtoINC", skip_absent = TRUE)
  setnames(output_data, "qci_score", "val_pca_score", skip_absent = TRUE)

  # Step 6: Merge Rate data with Number data
  wide <- NULL
  if (!is.null(cleaned$wide_rate)) {
    wide <- merge(cleaned$wide_rate, output_data,
                  by = c("location_name", "year", "sex_name", "age_name"),
                  suffixes = c("", "_Number"))
    # Add qci_score alias for convenience
    if ("val_pca_score" %in% names(wide)) {
      wide[, qci_score := val_pca_score]
    }
  } else {
    wide <- output_data
    if ("val_pca_score" %in% names(wide)) {
      wide[, qci_score := val_pca_score]
    }
  }

  # Step 7: Create long format
  if (verbose) cli_alert_info("Creating long format output...")
  long <- .create_long_format(wide)

  if (verbose) cli_alert_success("QCI pipeline complete.")

  list(
    wide = wide,
    long = long,
    pca_details = pca_result$pca_details
  )
}


#' Create long format from wide QCI data
#' @param wide_data Wide format data.table.
#' @return Long format data.table.
#' @keywords internal
.create_long_format <- function(wide_data) {
  dt <- copy(setDT(as.data.frame(wide_data)))

  id_vars <- c("location_id", "location_name", "year", "sex_name", "age_name")
  # Only keep id_vars that exist
  id_vars <- intersect(id_vars, names(dt))

  # Melt val columns
  val_cols <- grep("^val_", names(dt), value = TRUE)
  val_cols <- val_cols[!grepl("Number", val_cols)]
  if (length(val_cols) == 0) return(data.table())

  long1 <- melt(dt, id.vars = id_vars, measure.vars = val_cols,
                variable.name = "measure", value.name = "value")
  long1[, measure := gsub("^val_", "", measure)]

  # Melt upper columns
  upper_cols <- grep("^upper_", names(dt), value = TRUE)
  upper_cols <- upper_cols[!grepl("Number", upper_cols)]
  if (length(upper_cols) > 0) {
    long2 <- melt(dt, id.vars = id_vars, measure.vars = upper_cols,
                  variable.name = "measure", value.name = "upper")
    long2[, measure := gsub("^upper_", "", measure)]
  } else {
    long2 <- NULL
  }

  # Melt lower columns
  lower_cols <- grep("^lower_", names(dt), value = TRUE)
  lower_cols <- lower_cols[!grepl("Number", lower_cols)]
  if (length(lower_cols) > 0) {
    long3 <- melt(dt, id.vars = id_vars, measure.vars = lower_cols,
                  variable.name = "measure", value.name = "lower")
    long3[, measure := gsub("^lower_", "", measure)]
  } else {
    long3 <- NULL
  }

  # Merge
  merge_by <- c(id_vars, "measure")
  result <- long1
  if (!is.null(long2)) {
    result <- merge(result, long2, by = merge_by, all.x = TRUE)
  }
  if (!is.null(long3)) {
    result <- merge(result, long3, by = merge_by, all.x = TRUE)
  }

  result[]
}
