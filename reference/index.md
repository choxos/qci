# Package index

## Pipeline

Core functions for computing QCI from GBD data

- [`qci_pipeline()`](https://choxos.github.io/qci/reference/qci_pipeline.md)
  : Run the complete QCI pipeline
- [`qci_load()`](https://choxos.github.io/qci/reference/qci_load.md) :
  Load GBD CSV data
- [`qci_clean()`](https://choxos.github.io/qci/reference/qci_clean.md) :
  Clean and filter GBD data for QCI computation
- [`qci_ratios()`](https://choxos.github.io/qci/reference/qci_ratios.md)
  : Calculate QCI component ratios
- [`qci_pca()`](https://choxos.github.io/qci/reference/qci_pca.md) :
  Compute QCI scores via PCA
- [`qci_gdr()`](https://choxos.github.io/qci/reference/qci_gdr.md) :
  Calculate Gender Disparity Ratio (GDR)

## Visualization

Publication-ready plots and maps

- [`plot_qci_map()`](https://choxos.github.io/qci/reference/plot_qci_map.md)
  : Create a choropleth map of QCI scores
- [`plot_gdr_map()`](https://choxos.github.io/qci/reference/plot_gdr_map.md)
  : Create a choropleth map of Gender Disparity Ratio
- [`plot_qci_trend()`](https://choxos.github.io/qci/reference/plot_qci_trend.md)
  : Plot QCI trends over time
- [`plot_qci_distribution()`](https://choxos.github.io/qci/reference/plot_qci_distribution.md)
  : Plot QCI score distributions by sex
- [`plot_qci_scatter()`](https://choxos.github.io/qci/reference/plot_qci_scatter.md)
  : Scatter plot of Male vs Female QCI by region

## Utilities

Helper and export functions

- [`merge_location_type()`](https://choxos.github.io/qci/reference/merge_location_type.md)
  : Merge with location type metadata
- [`qci_export_csv()`](https://choxos.github.io/qci/reference/qci_export_csv.md)
  : Export QCI results to CSV
- [`qci_export_dta()`](https://choxos.github.io/qci/reference/qci_export_dta.md)
  : Export QCI results to Stata DTA format

## Data

Bundled datasets

- [`sample_gbd`](https://choxos.github.io/qci/reference/sample_gbd.md) :
  Sample GBD export data
- [`location_type`](https://choxos.github.io/qci/reference/location_type.md)
  : Location type metadata
