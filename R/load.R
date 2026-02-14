#' Load GBD CSV data
#'
#' Reads one or more GBD CSV export files and combines them into a single
#' data.table. Handles the row-number column that GBD exports include as
#' the first unnamed column. Uses [data.table::fread()] for speed.
#'
#' @param files Character vector of file paths to GBD CSV exports. Can be
#'   a single file or multiple files to be row-bound.
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A data.table with standard GBD columns: measure_id, measure_name,
#'   location_id, location_name, sex_id, sex_name, age_id, age_name,
#'   cause_id, cause_name, metric_id, metric_name, year, val, upper, lower.
#' @export
#' @examples
#' f <- system.file("extdata", "sample_gbd_data.csv", package = "qci")
#' gbd <- qci_load(f)
#' head(gbd)
qci_load <- function(files, ...) {
  if (!is.character(files)) {
    cli_abort("Expected file path(s) as character vector.")
  }

  missing <- files[!file.exists(files)]
  if (length(missing) > 0) {
    cli_abort(c(
      "File(s) not found:",
      "x" = "{.file {missing}}"
    ))
  }

  dts <- lapply(files, function(f) {
    dt <- fread(f, ...)
    # Drop unnamed row-index column (GBD exports include "V1" or "")
    unnamed_cols <- names(dt)[grepl("^V1$|^$", names(dt))]
    if (length(unnamed_cols) > 0) {
      dt[, (unnamed_cols) := NULL]
    }
    dt
  })

  result <- rbindlist(dts, use.names = TRUE, fill = TRUE)
  validate_gbd_columns(result)
  cli_alert_info("Loaded {.val {nrow(result)}} rows from {.val {length(files)}} file(s).")
  result
}
