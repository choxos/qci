#' Compute QCI scores via PCA
#'
#' Runs Principal Component Analysis on the four QCI ratios, stratified
#' by sex and age subgroups. Extracts PC1, normalizes to 0-100, then
#' inverts (`100 - score`) so that higher values indicate better quality
#' of care.
#'
#' @param data A data.table with the four ratio columns (`MIR`, `YLLtoYLD`,
#'   `DALtoPER`, `PERtoINC`) plus grouping columns `sex_name` and `age_name`.
#'   Typically the output of [qci_ratios()].
#' @param ratio_cols Character vector of column names for PCA input.
#'   Default `c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC")`.
#' @param group_by Character vector of columns to stratify PCA by.
#'   Default `c("sex_name", "age_name")`.
#' @param ncp Integer. Number of principal components to compute.
#'   Default `5` (FactoMineR default). Only PC1 is used for QCI.
#' @param scale.unit Logical. Whether to scale variables to unit variance
#'   before PCA. Default `TRUE`.
#' @return A list with two elements:
#'   \describe{
#'     \item{data}{The input data.table with a new `qci_score` column
#'       containing the 0-100 inverted PCA score.}
#'     \item{pca_details}{A data.frame with one row per subgroup, containing
#'       columns: sex_name, age_name, variance_explained_pc1, eigenvalue_pc1,
#'       n_observations.}
#'   }
#' @export
#' @examples
#' data(sample_gbd)
#' cleaned <- qci_clean(sample_gbd)
#' with_ratios <- qci_ratios(cleaned$wide_number)
#' result <- qci_pca(with_ratios)
#' head(result$data[, .(location_name, year, sex_name, qci_score)])
qci_pca <- function(data,
                    ratio_cols = c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC"),
                    group_by = c("sex_name", "age_name"),
                    ncp = 5,
                    scale.unit = TRUE) {

  dt <- copy(setDT(as.data.frame(data)))

  # Validate ratio columns exist
  missing <- setdiff(ratio_cols, names(dt))
  if (length(missing) > 0) {
    cli_abort("Missing ratio columns: {.field {missing}}")
  }

  # Initialize output
  dt[, qci_score := NA_real_]
  pca_details <- list()

  # Get unique subgroups
  if (length(group_by) > 0) {
    groups <- unique(dt[, group_by, with = FALSE])
  } else {
    groups <- data.table(dummy = 1L)
  }

  for (i in seq_len(nrow(groups))) {
    if (length(group_by) > 0) {
      grp <- groups[i, ]
      idx <- rep(TRUE, nrow(dt))
      for (g in group_by) {
        idx <- idx & dt[[g]] == grp[[g]]
      }
      grp_label <- paste(sapply(group_by, function(g) grp[[g]]), collapse = " / ")
    } else {
      idx <- rep(TRUE, nrow(dt))
      grp_label <- "all"
      grp <- data.frame(dummy = 1L)
    }

    pca_data <- dt[idx, ratio_cols, with = FALSE]

    # Remove rows with any NA in ratio columns
    complete_mask <- complete.cases(pca_data)
    n_complete <- sum(complete_mask)

    if (n_complete < 3) {
      cli_alert_warning("Subgroup {.val {grp_label}}: only {.val {n_complete}} complete rows. Skipping PCA.")
      detail <- as.data.frame(grp)
      detail$variance_explained_pc1 <- NA_real_
      detail$eigenvalue_pc1 <- NA_real_
      detail$n_observations <- n_complete
      pca_details[[length(pca_details) + 1]] <- detail
      next
    }

    # Run PCA
    pca_input <- as.data.frame(pca_data[complete_mask, ])
    pca_out <- FactoMineR::PCA(pca_input, graph = FALSE, ncp = ncp,
                                scale.unit = scale.unit)

    # Extract PC1 scores
    score0 <- pca_out$ind$coord[, 1]

    # Normalize to 0-100 and invert (higher = better quality of care)
    score1 <- normalize_0_100(score0)
    pca_score <- 100 - score1

    # Assign scores back (only to complete rows)
    which_idx <- which(idx)
    which_complete <- which_idx[complete_mask]
    data.table::set(dt, i = which_complete, j = "qci_score", value = pca_score)

    # Record details
    detail <- as.data.frame(grp)
    detail$variance_explained_pc1 <- pca_out$eig[1, 2]
    detail$eigenvalue_pc1 <- pca_out$eig[1, 1]
    detail$n_observations <- n_complete
    pca_details[[length(pca_details) + 1]] <- detail

    cli_alert_info("PCA done for {.val {grp_label}}: {.val {round(pca_out$eig[1, 2], 1)}}% variance explained (n={.val {n_complete}}).")
  }

  pca_details_df <- do.call(rbind, pca_details)
  if ("dummy" %in% names(pca_details_df)) pca_details_df$dummy <- NULL

  list(data = dt, pca_details = pca_details_df)
}
