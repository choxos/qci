#' Scatter plot of Male vs Female QCI by region
#'
#' Creates a scatter plot with Male QCI on x-axis and Female QCI on
#' y-axis, colored by region or custom grouping. Includes a diagonal
#' reference line (y = x).
#'
#' @param data A data.frame with columns: `location_name`, `qci_score`
#'   (or column specified by `score_var`), `sex_name`, `year`, `age_name`.
#'   Should include both Male and Female rows.
#' @param score_var Character. Column name for the score.
#'   Default `"qci_score"`.
#' @param year Integer. Single year to plot. Required.
#' @param age Character. Default `"Age-standardized"`.
#' @param color_by Character. Column name to color points by (e.g.,
#'   `"type"`). Default `NULL` (no color grouping).
#' @param point_size Numeric. Point size. Default `2`.
#' @param show_diagonal Logical. Show y = x line. Default `TRUE`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' result <- qci_pipeline(sample_gbd)
#' map_data <- merge_location_type(result$wide)
#' plot_qci_scatter(map_data, year = 2019, color_by = "type")
#' }
plot_qci_scatter <- function(data,
                             score_var = "qci_score",
                             year,
                             age = "Age-standardized",
                             color_by = NULL,
                             point_size = 2,
                             show_diagonal = TRUE) {

  dt <- as.data.frame(data)

  # Fallback score column
  if (!score_var %in% names(dt) && "val_pca_score" %in% names(dt)) {
    score_var <- "val_pca_score"
  }

  # Filter
  dt <- dt[dt$year == year, ]
  if ("age_name" %in% names(dt)) {
    dt <- dt[dt$age_name == age, ]
  }
  dt <- dt[dt$sex_name %in% c("Male", "Female"), ]

  if (nrow(dt) == 0) {
    cli_abort("No data remaining after filtering.")
  }

  # Pivot to wide
  id_cols <- setdiff(names(dt), c("sex_name", "sex_id", score_var))
  dt_wide <- tidyr::pivot_wider(dt, id_cols = dplyr::all_of(id_cols),
                                 names_from = "sex_name",
                                 values_from = dplyr::all_of(score_var))

  if (!all(c("Male", "Female") %in% names(dt_wide))) {
    cli_abort("Both Male and Female data required for scatter plot.")
  }

  p <- ggplot2::ggplot(dt_wide, ggplot2::aes(x = .data$Male, y = .data$Female))

  if (!is.null(color_by) && color_by %in% names(dt_wide)) {
    p <- p + ggplot2::geom_point(ggplot2::aes(color = .data[[color_by]]),
                                  size = point_size) +
      ggplot2::labs(color = color_by)
  } else {
    p <- p + ggplot2::geom_point(size = point_size, color = "steelblue")
  }

  if (show_diagonal) {
    p <- p + ggplot2::geom_abline(slope = 1, intercept = 0,
                                   linetype = "dashed", color = "grey50")
  }

  p <- p +
    ggplot2::labs(x = paste("Male QCI (", year, ")"),
                  y = paste("Female QCI (", year, ")"),
                  title = paste("Male vs Female QCI -", year)) +
    ggplot2::theme_minimal() +
    ggplot2::coord_equal()

  p
}
