#' Calculate QCI component ratios
#'
#' Computes the four epidemiological ratios that form the basis of the QCI:
#' \itemize{
#'   \item **MIR** = Deaths / Incidence (Mortality-to-Incidence Ratio)
#'   \item **YLLtoYLD** = YLLs / YLDs (YLL-to-YLD Ratio)
#'   \item **DALtoPER** = DALYs / Prevalence (DALY-to-Prevalence Ratio)
#'   \item **PERtoINC** = Prevalence / Incidence (Prevalence-to-Incidence Ratio)
#' }
#'
#' Each ratio is computed for point estimates (`val`), `upper`, and `lower`
#' uncertainty bounds. `Inf` and `NaN` values from division by zero are
#' replaced with `NA`.
#'
#' @param wide_number A data.table in wide format for the Number metric
#'   (the `wide_number` element from [qci_clean()]).
#' @return The input data.table with 12 new columns appended:
#'   `MIR`, `lower_MIR`, `upper_MIR`,
#'   `YLLtoYLD`, `lower_YLLtoYLD`, `upper_YLLtoYLD`,
#'   `DALtoPER`, `lower_DALtoPER`, `upper_DALtoPER`,
#'   `PERtoINC`, `lower_PERtoINC`, `upper_PERtoINC`.
#' @export
#' @examples
#' data(sample_gbd)
#' cleaned <- qci_clean(sample_gbd)
#' with_ratios <- qci_ratios(cleaned$wide_number)
#' head(with_ratios[, .(location_name, year, MIR, YLLtoYLD, DALtoPER, PERtoINC)])
qci_ratios <- function(wide_number) {
  if (is.null(wide_number)) {
    cli_abort("wide_number is NULL. Ensure qci_clean() produced Number metric data.")
  }

  dt <- copy(setDT(as.data.frame(wide_number)))

  # Check required columns
  required <- c("val_Deaths", "val_Incidence", "val_YLLs", "val_YLDs",
                 "val_DALYs", "val_Prevalence",
                 "lower_Deaths", "lower_Incidence", "lower_YLLs", "lower_YLDs",
                 "lower_DALYs", "lower_Prevalence",
                 "upper_Deaths", "upper_Incidence", "upper_YLLs", "upper_YLDs",
                 "upper_DALYs", "upper_Prevalence")
  missing <- setdiff(required, names(dt))
  if (length(missing) > 0) {
    cli_abort(c(
      "Missing columns in wide_number:",
      "x" = "Missing: {.field {missing}}",
      "i" = "Expected wide-format data from qci_clean()."
    ))
  }

  # MIR: Deaths / Incidence
  dt[, MIR := val_Deaths / val_Incidence]
  dt[, lower_MIR := lower_Deaths / lower_Incidence]
  dt[, upper_MIR := upper_Deaths / upper_Incidence]

  # YLLtoYLD: YLLs / YLDs
  dt[, YLLtoYLD := val_YLLs / val_YLDs]
  dt[, lower_YLLtoYLD := lower_YLLs / lower_YLDs]
  dt[, upper_YLLtoYLD := upper_YLLs / upper_YLDs]

  # DALtoPER: DALYs / Prevalence
  dt[, DALtoPER := val_DALYs / val_Prevalence]
  dt[, lower_DALtoPER := lower_DALYs / lower_Prevalence]
  dt[, upper_DALtoPER := upper_DALYs / upper_Prevalence]

  # PERtoINC: Prevalence / Incidence
  dt[, PERtoINC := val_Prevalence / val_Incidence]
  dt[, lower_PERtoINC := lower_Prevalence / lower_Incidence]
  dt[, upper_PERtoINC := upper_Prevalence / upper_Incidence]

  # Replace Inf and NaN with NA
  ratio_cols <- c("MIR", "lower_MIR", "upper_MIR",
                   "YLLtoYLD", "lower_YLLtoYLD", "upper_YLLtoYLD",
                   "DALtoPER", "lower_DALtoPER", "upper_DALtoPER",
                   "PERtoINC", "lower_PERtoINC", "upper_PERtoINC")
  for (col in ratio_cols) {
    vals <- dt[[col]]
    vals[is.infinite(vals) | is.nan(vals)] <- NA_real_
    data.table::set(dt, j = col, value = vals)
  }

  n_na <- sum(is.na(dt$MIR))
  if (n_na > 0) {
    cli_alert_warning("{.val {n_na}} rows have NA ratios (division by zero).")
  }

  dt
}
