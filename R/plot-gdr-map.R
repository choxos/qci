#' Create a choropleth map of Gender Disparity Ratio
#'
#' @param data A data.frame with at least: `iso3`, `gdr`, and optionally
#'   `year`. Use [merge_location_type()] to add `iso3` to [qci_gdr()]
#'   output.
#' @param years Integer vector. Default `NULL` (all).
#' @param breaks Numeric vector of GDR breakpoints.
#'   Default `c(0, 0.5, 0.95, 1.05, 2.0, Inf)`.
#' @param labels Character vector of labels for GDR bins.
#'   Default `c("< 0.5", "[0.5, 0.95)", "[0.95, 1.05]", "(1.05, 2.0]", "> 2.0")`.
#' @param colors Character vector of 5 colors.
#'   Default grey-to-purple scale.
#' @param title Character. Default `NULL` (auto-generated).
#' @param legend_title Character. Default `"Age-standardized GDR"`.
#' @return A ggplot2 object.
#' @export
#' @examples
#' \dontrun{
#' result <- qci_pipeline(sample_gbd)
#' gdr <- qci_gdr(result$wide)
#' gdr_map <- merge_location_type(gdr)
#' plot_gdr_map(gdr_map, years = c(1990, 2019))
#' }
plot_gdr_map <- function(data,
                         years = NULL,
                         breaks = c(0, 0.5, 0.95, 1.05, 2.0, Inf),
                         labels = c("< 0.5", "[0.5, 0.95)", "[0.95, 1.05]",
                                    "(1.05, 2.0]", "> 2.0"),
                         colors = c("#878787", "#b7b7b7", "#64c2a5", "#b1abd0", "#7f74ac"),
                         title = NULL,
                         legend_title = "Age-standardized GDR") {

  dt <- as.data.frame(data)

  if (!"gdr" %in% names(dt)) {
    cli_abort("Column {.field gdr} not found. Use {.fn qci_gdr} first.")
  }
  if (!"iso3" %in% names(dt)) {
    cli_abort("Column {.field iso3} not found. Use {.fn merge_location_type} first.")
  }

  # Filter years
  if (!is.null(years) && "year" %in% names(dt)) {
    dt <- dt[dt$year %in% years, ]
  }

  # Create bins
  dt$gdr_bin <- cut(dt$gdr, breaks = breaks, labels = labels, include.lowest = TRUE)

  # Get world map
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  world$iso <- world$iso_a3

  # Merge
  world_merged <- merge(world, dt, by.x = "iso", by.y = "iso3")

  p <- ggplot2::ggplot(data = world_merged) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data$gdr_bin)) +
    ggplot2::scale_fill_manual(values = colors, name = legend_title,
                                na.value = "grey90", drop = FALSE) +
    ggplot2::theme_void() +
    ggplot2::theme(legend.key.size = ggplot2::unit(0.4, "cm"))

  if ("year" %in% names(dt) && length(unique(dt$year)) > 1) {
    p <- p + ggplot2::facet_wrap(~ year, ncol = 1)
  }

  if (!is.null(title)) {
    p <- p + ggplot2::ggtitle(title)
  }

  p
}
