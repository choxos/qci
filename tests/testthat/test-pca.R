test_that("qci_pca returns scores in 0-100 range", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  with_ratios <- qci_ratios(cleaned$wide_number)
  result <- qci_pca(with_ratios)

  scores <- result$data$qci_score[!is.na(result$data$qci_score)]
  expect_true(all(scores >= 0 & scores <= 100))
})

test_that("qci_pca returns pca_details", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  with_ratios <- qci_ratios(cleaned$wide_number)
  result <- qci_pca(with_ratios)

  expect_true("pca_details" %in% names(result))
  expect_true("variance_explained_pc1" %in% names(result$pca_details))
  expect_true(all(result$pca_details$variance_explained_pc1 > 0, na.rm = TRUE))
})

test_that("qci_pca stratifies by sex and age", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  with_ratios <- qci_ratios(cleaned$wide_number)
  result <- qci_pca(with_ratios)

  # Should have entries for each sex
  expect_true("sex_name" %in% names(result$pca_details))
  expect_true(length(unique(result$pca_details$sex_name)) > 1)
})
