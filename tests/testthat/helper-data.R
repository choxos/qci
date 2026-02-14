# Helper: Create minimal fixture data for tests

create_test_gbd <- function() {
  countries <- c("CountryA", "CountryB", "CountryC", "CountryD", "CountryE")
  measures <- c("Deaths", "Incidence", "Prevalence",
                "DALYs (Disability-Adjusted Life Years)",
                "YLDs (Years Lived with Disability)",
                "YLLs (Years of Life Lost)")
  measure_ids <- c(1L, 6L, 5L, 2L, 3L, 4L)
  metrics <- c("Rate", "Number")
  metric_ids <- c(3L, 1L)
  sexes <- c("Male", "Female", "Both")
  sex_ids <- c(1L, 2L, 3L)
  years <- c(1990L, 2019L)

  rows <- list()
  i <- 1L
  for (loc in seq_along(countries)) {
    for (m in seq_along(measures)) {
      for (mt in seq_along(metrics)) {
        for (s in seq_along(sexes)) {
          for (y in years) {
            rows[[i]] <- data.frame(
              measure_id = measure_ids[m],
              measure_name = measures[m],
              location_id = 100L + loc,
              location_name = countries[loc],
              sex_id = sex_ids[s],
              sex_name = sexes[s],
              age_id = 27L,
              age_name = "Age-standardized",
              cause_id = 644L,
              cause_name = "Test Cause",
              metric_id = metric_ids[mt],
              metric_name = metrics[mt],
              year = y,
              val = runif(1, 0.1, 100),
              upper = runif(1, 50, 200),
              lower = runif(1, 0.01, 50),
              stringsAsFactors = FALSE
            )
            i <- i + 1L
          }
        }
      }
    }
  }
  do.call(rbind, rows)
}

# Create a matching location_type for test countries
create_test_location_type <- function() {
  data.frame(
    location_id = 101L:105L,
    location_name = c("CountryA", "CountryB", "CountryC", "CountryD", "CountryE"),
    type = rep("Country", 5),
    iso3 = c("AAA", "BBB", "CCC", "DDD", "EEE"),
    stringsAsFactors = FALSE
  )
}
