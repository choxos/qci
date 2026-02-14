test_that("qci_ratios computes all 4 ratios correctly", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  result <- qci_ratios(cleaned$wide_number)

  expect_true(all(c("MIR", "YLLtoYLD", "DALtoPER", "PERtoINC") %in% names(result)))
  expect_true(all(c("lower_MIR", "upper_MIR") %in% names(result)))
})

test_that("qci_ratios handles division by zero", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  # Set some incidence to zero
  cleaned$wide_number$val_Incidence[1] <- 0
  result <- qci_ratios(cleaned$wide_number)

  # Should be NA, not Inf
  expect_true(is.na(result$MIR[1]))
  expect_true(is.na(result$PERtoINC[1]))
})

test_that("qci_ratios preserves existing columns", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  cleaned <- qci_clean(gbd, loc_types = loc)
  original_cols <- names(cleaned$wide_number)
  result <- qci_ratios(cleaned$wide_number)

  expect_true(all(original_cols %in% names(result)))
})
