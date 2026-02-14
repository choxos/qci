#' Plot QCI trends over time
#'
#' Creates line plots of QCI over years, stratified by sex. When multiple
#' locations are present, automatically facets by location for readability.
#'
#' @param data A data.frame with columns: `year`, `qci_score`, `sex_name`,
#'   `location_name`, `age_name`.
#' @param locations Character vector of location names. Default `NULL` (all).
#' @param sex Character vector of sex categories to include.
#'   Default `c("Male", "Female", "Both")`.
#' @param age Character. Default `"Age-standardized"`.
#' @param colors Named character vector.
#'   Default `c(Male = "skyblue4", Female = "firebrick", Both = "grey30")`.
#' @param facet_by Character. Column to facet by. When `NULL` (default),
#'   auto-facets by `location_name` if more than one location is present.
#'   Set to `FALSE` to disable auto-faceting.
#' @param free_y Logical. Free y-axis scales in facets. Default `FALSE`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' data(sample_gbd)
#' result <- qci_pipeline(sample_gbd)
#' plot_qci_trend(result$wide)
plot_qci_trend <- function(data,
                           locations = NULL,
                           sex = c("Male", "Female", "Both"),
                           age = "Age-standardized",
                           colors = c(Male = "skyblue4", Female = "firebrick",
                                      Both = "grey30"),
                           facet_by = NULL,
                           free_y = FALSE) {

  dt <- as.data.frame(data)

  # Determine score column
  score_col <- if ("qci_score" %in% names(dt)) "qci_score" else "val_pca_score"
  if (!score_col %in% names(dt)) {
    cli_abort("No QCI score column found.")
  }

  # Filter
  if (!is.null(locations)) {
    dt <- dt[dt$location_name %in% locations, ]
  }
  if (!is.null(sex) && "sex_name" %in% names(dt)) {
    dt <- dt[dt$sex_name %in% sex, ]
  }
  if (!is.null(age) && "age_name" %in% names(dt)) {
    dt <- dt[dt$age_name == age, ]
  }

  if (nrow(dt) == 0) {
    cli_abort("No data remaining after filtering.")
  }

  # Auto-facet by location when multiple locations present
  n_locations <- length(unique(dt$location_name))
  if (is.null(facet_by) && n_locations > 1) {
    facet_by <- "location_name"
  }

  p <- ggplot2::ggplot(dt, ggplot2::aes(x = .data$year, y = .data[[score_col]],
                                          group = interaction(.data$location_name,
                                                              .data$sex_name),
                                          color = .data$sex_name)) +
    ggplot2::geom_line(linewidth = 1, alpha = 0.8) +
    ggplot2::geom_point(size = 2) +
    ggplot2::scale_color_manual(values = colors, name = "Sex") +
    ggplot2::labs(x = "Year", y = "Quality of Care Index (QCI)") +
    ggplot2::theme_minimal()

  if (!isFALSE(facet_by) && !is.null(facet_by) && facet_by %in% names(dt)) {
    scales_arg <- if (free_y) "free_y" else "fixed"
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet_by)),
                                  scales = scales_arg)
  }

  p
}
