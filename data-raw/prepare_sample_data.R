# Prepare sample_gbd dataset from the full GBD CSV
# Run this script from the package root directory

library(data.table)

# Read full data
full_data <- fread("previous_codes/data/merged_GBD 2019_Orofacial clefts.csv")

# Drop row index column
if ("V1" %in% names(full_data)) full_data[, V1 := NULL]

# Select 10 representative countries across income levels/regions
sample_countries <- c(
  "United States",    # High-income North America
  "United Kingdom",   # Western Europe
  "Japan",            # High-income Asia Pacific
  "Brazil",           # Tropical Latin America
  "India",            # South Asia
  "China",            # East Asia
  "Nigeria",          # Western Sub-Saharan Africa
  "Egypt",            # North Africa and Middle East
  "Australia",        # Australasia
  "Ethiopia"          # Eastern Sub-Saharan Africa
)

# Filter
sample_gbd <- full_data[
  location_name %in% sample_countries &
  age_name == "Age-standardized" &
  year %in% c(1990, 2005, 2019) &
  metric_name %in% c("Rate", "Number"),
]

# Convert to data.frame
sample_gbd <- as.data.frame(sample_gbd)

usethis::use_data(sample_gbd, overwrite = TRUE)

# Also save as CSV for inst/extdata
dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
write.csv(sample_gbd, "inst/extdata/sample_gbd_data.csv", row.names = FALSE)

# Generate pre-computed result
library(qci)
qci_result_sample <- qci_pipeline(sample_gbd)
usethis::use_data(qci_result_sample, overwrite = TRUE)
