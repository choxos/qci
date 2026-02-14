#' Plot QCI score distributions by sex
#'
#' Creates density plots comparing Male and Female QCI score distributions.
#' Supports comparing across two time points.
#'
#' @param data A data.frame with QCI results. Can be wide format (from
#'   pipeline output) or long format.
#' @param score_col Character. Column name containing the score to plot.
#'   Default `"qci_score"`.
#' @param years Integer vector of 1 or 2 years to compare. Default `NULL`
#'   (all years overlaid).
#' @param sex Character vector of sex categories.
#'   Default `c("Male", "Female")`.
#' @param age Character. Age group. Default `"Age-standardized"`.
#' @param alpha Numeric. Transparency for density fills. Default `0.5`.
#' @param colors Named character vector.
#'   Default `c(Male = "skyblue4", Female = "firebrick")`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' data(sample_gbd)
#' result <- qci_pipeline(sample_gbd)
#' plot_qci_distribution(result$wide, years = c(1990, 2019))
plot_qci_distribution <- function(data,
                                  score_col = "qci_score",
                                  years = NULL,
                                  sex = c("Male", "Female"),
                                  age = "Age-standardized",
                                  alpha = 0.5,
                                  colors = c(Male = "skyblue4", Female = "firebrick")) {

  dt <- as.data.frame(data)

  # Fallback score column
  if (!score_col %in% names(dt) && "val_pca_score" %in% names(dt)) {
    score_col <- "val_pca_score"
  }
  if (!score_col %in% names(dt)) {
    cli_abort("Column {.field {score_col}} not found in data.")
  }

  # Filter
  if (!is.null(sex) && "sex_name" %in% names(dt)) {
    dt <- dt[dt$sex_name %in% sex, ]
  }
  if (!is.null(age) && "age_name" %in% names(dt)) {
    dt <- dt[dt$age_name == age, ]
  }
  if (!is.null(years) && "year" %in% names(dt)) {
    dt <- dt[dt$year %in% years, ]
  }

  if (nrow(dt) == 0) {
    cli_abort("No data remaining after filtering.")
  }

  p <- ggplot2::ggplot(dt, ggplot2::aes(x = .data[[score_col]],
                                          fill = .data$sex_name)) +
    ggplot2::geom_density(alpha = alpha) +
    ggplot2::scale_fill_manual(values = colors, name = "Sex") +
    ggplot2::labs(x = "Quality of Care Index (QCI)", y = "Density") +
    ggplot2::theme_minimal()

  # Facet by year if multiple
  if ("year" %in% names(dt) && length(unique(dt$year)) > 1) {
    p <- p + ggplot2::facet_wrap(~ year)
  }

  p
}
