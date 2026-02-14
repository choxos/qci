#' Export QCI results to CSV
#'
#' Writes QCI results to a CSV file.
#'
#' @param data A data.frame of QCI results.
#' @param file Character. Output file path.
#' @return Invisible file path (for piping).
#' @export
#' @examples
#' \dontrun{
#' result <- qci_pipeline(sample_gbd)
#' qci_export_csv(result$wide, "qci_results.csv")
#' }
qci_export_csv <- function(data, file) {
  data.table::fwrite(as.data.frame(data), file = file)
  cli_alert_success("Exported {.val {nrow(data)}} rows to {.file {file}}")
  invisible(file)
}

#' Export QCI results to Stata DTA format
#'
#' Writes QCI results to a Stata `.dta` file via [haven::write_dta()].
#' Requires the haven package.
#'
#' @param data A data.frame.
#' @param file Character. Output file path.
#' @return Invisible file path.
#' @export
#' @examples
#' \dontrun{
#' result <- qci_pipeline(sample_gbd)
#' qci_export_dta(result$wide, "qci_results.dta")
#' }
qci_export_dta <- function(data, file) {
  if (!requireNamespace("haven", quietly = TRUE)) {
    cli_abort(c(
      "Package {.pkg haven} is required to export .dta files.",
      "i" = "Install it with: {.code install.packages('haven')}"
    ))
  }
  haven::write_dta(as.data.frame(data), path = file)
  cli_alert_success("Exported {.val {nrow(data)}} rows to {.file {file}}")
  invisible(file)
}
