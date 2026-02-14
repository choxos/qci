test_that("qci_gdr computes Female/Male ratio", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  with_ratios <- qci_ratios(cleaned$wide_number)
  pca_result <- qci_pca(with_ratios)
  gdr <- qci_gdr(pca_result$data)

  expect_true("gdr" %in% names(gdr))
  expect_true("qci_female" %in% names(gdr))
  expect_true("qci_male" %in% names(gdr))
  expect_true(all(gdr$gdr > 0, na.rm = TRUE))
})

test_that("qci_gdr categorization thresholds work", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  with_ratios <- qci_ratios(cleaned$wide_number)
  pca_result <- qci_pca(with_ratios)
  gdr <- qci_gdr(pca_result$data)

  expect_true("gdr_category" %in% names(gdr))
  valid_cats <- c("low", "equal", "high")
  non_na_cats <- gdr$gdr_category[!is.na(gdr$gdr_category)]
  expect_true(all(non_na_cats %in% valid_cats))
})
