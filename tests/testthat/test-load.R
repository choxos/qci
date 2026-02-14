test_that("qci_load reads sample CSV correctly", {
  f <- system.file("extdata", "sample_gbd_data.csv", package = "qci")
  skip_if(f == "", message = "Sample data not found")
  result <- qci_load(f)
  expect_s3_class(result, "data.table")
  expect_true(all(c("measure_name", "location_name", "val") %in% names(result)))
  expect_gt(nrow(result), 0)
})

test_that("qci_load errors on missing file", {
  expect_error(qci_load("nonexistent_file.csv"), "not found")
})

test_that("qci_load errors on non-character input", {
  expect_error(qci_load(42), "character vector")
})
