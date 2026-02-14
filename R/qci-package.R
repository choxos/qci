#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom data.table setDT dcast melt patterns := .SD .N setnames
#' @importFrom data.table data.table rbindlist fread copy set
#' @importFrom rlang abort warn inform .data
#' @importFrom stats quantile as.formula complete.cases
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_warning cli_abort
## usethis namespace: end
NULL

# Suppress R CMD check NOTEs for data.table column references
utils::globalVariables(c(
  "MIR", "YLLtoYLD", "DALtoPER", "PERtoINC",
  "val_Deaths", "val_Incidence", "val_YLLs", "val_YLDs",
  "val_DALYs", "val_Prevalence",
  "lower_Deaths", "lower_Incidence", "lower_YLLs", "lower_YLDs",
  "lower_DALYs", "lower_Prevalence",
  "upper_Deaths", "upper_Incidence", "upper_YLLs", "upper_YLDs",
  "upper_DALYs", "upper_Prevalence",
  "lower_MIR", "upper_MIR", "lower_YLLtoYLD", "upper_YLLtoYLD",
  "lower_DALtoPER", "upper_DALtoPER", "lower_PERtoINC", "upper_PERtoINC",
  "qci_score", "qci_female", "qci_male", "gdr", "gdr_category",
  "val_pca_score", "measure", "year"
))
