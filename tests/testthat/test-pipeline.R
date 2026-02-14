test_that("qci_pipeline runs end-to-end on test data", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_pipeline(gbd, loc_types = loc, verbose = FALSE)

  expect_type(result, "list")
  expect_named(result, c("wide", "long", "pca_details"))
})

test_that("qci_pipeline wide output has qci_score", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_pipeline(gbd, loc_types = loc, verbose = FALSE)

  expect_true("qci_score" %in% names(result$wide))
  scores <- result$wide$qci_score[!is.na(result$wide$qci_score)]
  expect_true(all(scores >= 0 & scores <= 100))
})

test_that("qci_pipeline long format has correct measures", {
  set.seed(42)
  gbd <- create_test_gbd()
  loc <- create_test_location_type()
  result <- qci_pipeline(gbd, loc_types = loc, verbose = FALSE)

  measures <- unique(result$long$measure)
  expect_true("Deaths" %in% measures)
  expect_true("Incidence" %in% measures)
  expect_true("pca_score" %in% measures)
})

test_that("qci_pipeline accepts file paths", {
  f <- system.file("extdata", "sample_gbd_data.csv", package = "qci")
  skip_if(f == "", message = "Sample data not found")
  result <- qci_pipeline(f, verbose = FALSE)

  expect_type(result, "list")
  expect_gt(nrow(result$wide), 0)
})
