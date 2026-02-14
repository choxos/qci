# Changelog

## qci 0.1.0

- Initial release.
- Complete pipeline from raw GBD CSV exports to normalized QCI scores
  ([`qci_pipeline()`](https://choxos.github.io/qci/reference/qci_pipeline.md)).
- Modular functions:
  [`qci_load()`](https://choxos.github.io/qci/reference/qci_load.md),
  [`qci_clean()`](https://choxos.github.io/qci/reference/qci_clean.md),
  [`qci_ratios()`](https://choxos.github.io/qci/reference/qci_ratios.md),
  [`qci_pca()`](https://choxos.github.io/qci/reference/qci_pca.md),
  [`qci_gdr()`](https://choxos.github.io/qci/reference/qci_gdr.md).
- Five visualization functions:
  [`plot_qci_map()`](https://choxos.github.io/qci/reference/plot_qci_map.md),
  [`plot_gdr_map()`](https://choxos.github.io/qci/reference/plot_gdr_map.md),
  [`plot_qci_trend()`](https://choxos.github.io/qci/reference/plot_qci_trend.md),
  [`plot_qci_distribution()`](https://choxos.github.io/qci/reference/plot_qci_distribution.md),
  [`plot_qci_scatter()`](https://choxos.github.io/qci/reference/plot_qci_scatter.md).
- Gender Disparity Ratio (GDR) analysis.
- Export to CSV and Stata .dta formats.
- Bundled sample GBD data and location type metadata.
- Getting started vignette.
