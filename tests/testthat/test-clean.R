test_that("qci_clean produces wide_rate and wide_number", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_clean(gbd, loc_types = loc)

  expect_type(result, "list")
  expect_named(result, c("wide_rate", "wide_number"))
  expect_s3_class(result$wide_rate, "data.table")
  expect_s3_class(result$wide_number, "data.table")
})

test_that("qci_clean standardizes measure names", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_clean(gbd, loc_types = loc)

  # Check that wide columns use shortened names
  expect_true("val_DALYs" %in% names(result$wide_number))
  expect_true("val_YLDs" %in% names(result$wide_number))
  expect_true("val_YLLs" %in% names(result$wide_number))
})

test_that("qci_clean removes excluded location_ids", {
  set.seed(42)
  gbd <- create_test_gbd()
  gbd$location_id[gbd$location_name == "CountryA"] <- 533L
  loc <- create_test_location_type()
  loc$location_id[loc$location_name == "CountryA"] <- 533L
  result <- qci_clean(gbd, loc_types = loc, exclude_location_ids = 533L)

  expect_false("CountryA" %in% result$wide_number$location_name)
})

test_that("qci_clean filters to age categories", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_clean(gbd, loc_types = loc, age_categories = "Age-standardized")

  expect_true(all(result$wide_number$age_name == "Age-standardized"))
})

test_that("qci_clean correctly separates Rate and Number", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_clean(gbd, loc_types = loc)

  # Both should have data
  expect_gt(nrow(result$wide_rate), 0)
  expect_gt(nrow(result$wide_number), 0)
})
