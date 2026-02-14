test_that("standardize_measure_names shortens all 3 names", {
  input <- c("DALYs (Disability-Adjusted Life Years)",
             "YLDs (Years Lived with Disability)",
             "YLLs (Years of Life Lost)",
             "Deaths", "Incidence", "Prevalence")
  result <- qci:::standardize_measure_names(input)
  expect_equal(result, c("DALYs", "YLDs", "YLLs", "Deaths", "Incidence", "Prevalence"))
})

test_that("normalize_0_100 produces correct range", {
  result <- qci:::normalize_0_100(c(1, 5, 10))
  expect_equal(min(result), 0)
  expect_equal(max(result), 100)
  expect_equal(result[2], 100 * (5 - 1) / (10 - 1))
})

test_that("normalize_0_100 handles constant input", {
  result <- qci:::normalize_0_100(c(5, 5, 5))
  expect_true(all(result == 50))
})

test_that("validate_gbd_columns errors on missing columns", {
  df <- data.frame(x = 1)
  expect_error(qci:::validate_gbd_columns(df), "Missing required columns")
})

test_that("validate_measures errors on missing measures", {
  df <- data.frame(measure_name = c("Deaths", "Incidence"))
  expect_error(qci:::validate_measures(df), "Missing required measures")
})

test_that("validate_measures passes with all measures", {
  df <- data.frame(measure_name = c("DALYs", "YLDs", "YLLs",
                                     "Deaths", "Incidence", "Prevalence"))
  expect_invisible(qci:::validate_measures(df))
})
