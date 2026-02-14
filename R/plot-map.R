#' Create a choropleth map of QCI scores
#'
#' Plots QCI scores on a world map using natural earth geometries.
#' Supports faceting by year and custom color scales with quantile-based
#' breaks.
#'
#' @param data A data.frame with at least: `iso3`, `qci_score` (or a column
#'   specified by `fill_var`), and optionally `year` for faceting.
#'   Use [merge_location_type()] to add `iso3` to pipeline output.
#' @param fill_var Character. Column name to map to fill color.
#'   Default `"qci_score"`.
#' @param years Integer vector of years to display. Default `NULL` (all).
#' @param sex Character. Sex to filter to. Default `"Both"`.
#' @param age Character. Age group to filter to.
#'   Default `"Age-standardized"`.
#' @param n_quantiles Integer. Number of quantile bins for the color scale.
#'   Default `5`.
#' @param colors Character vector of colors for the quantile bins, from
#'   lowest to highest. Default red-to-green scale.
#' @param title Character. Plot title. Default `NULL` (auto-generated).
#' @param legend_title Character. Legend title.
#'   Default `"Age-standardized QCI (%)"`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' result <- qci_pipeline(sample_gbd)
#' map_data <- merge_location_type(result$wide)
#' plot_qci_map(map_data, years = c(1990, 2019))
#' }
plot_qci_map <- function(data,
                         fill_var = "qci_score",
                         years = NULL,
                         sex = "Both",
                         age = "Age-standardized",
                         n_quantiles = 5,
                         colors = c("#a40227", "#f56c42", "#dfbf72", "#a7da68", "#1a9850"),
                         title = NULL,
                         legend_title = "Age-standardized QCI (%)") {

  dt <- as.data.frame(data)

  # Validate

  if (!fill_var %in% names(dt)) {
    cli_abort("Column {.field {fill_var}} not found in data.")
  }
  if (!"iso3" %in% names(dt)) {
    cli_abort("Column {.field iso3} not found. Use {.fn merge_location_type} first.")
  }

  # Filter
  if ("sex_name" %in% names(dt) && !is.null(sex)) {
    dt <- dt[dt$sex_name == sex, ]
  }
  if ("age_name" %in% names(dt) && !is.null(age)) {
    dt <- dt[dt$age_name == age, ]
  }
  if (!is.null(years) && "year" %in% names(dt)) {
    dt <- dt[dt$year %in% years, ]
  }

  if (nrow(dt) == 0) {
    cli_abort("No data remaining after filtering.")
  }

  # Compute quantile breaks
  qvals <- quantile(dt[[fill_var]], probs = seq(0, 1, 1 / n_quantiles), na.rm = TRUE)
  dt$quantile_bin <- cut(dt[[fill_var]], breaks = qvals, include.lowest = TRUE)

  # Get world map
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  world$iso <- world$iso_a3

  # Merge
  world_merged <- merge(world, dt, by.x = "iso", by.y = "iso3")

  # Build plot
  p <- ggplot2::ggplot(data = world_merged) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data$quantile_bin)) +
    ggplot2::scale_fill_manual(values = colors, name = legend_title,
                                na.value = "grey90") +
    ggplot2::theme_void() +
    ggplot2::theme(legend.key.size = ggplot2::unit(0.4, "cm"))

  # Facet by year if multiple
  if ("year" %in% names(dt) && length(unique(dt$year)) > 1) {
    p <- p + ggplot2::facet_wrap(~ year, ncol = 1)
  }

  if (!is.null(title)) {
    p <- p + ggplot2::ggtitle(title)
  }

  p
}
