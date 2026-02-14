# Prepare location_type dataset from the original .dta files
# Run this script from the package root directory

library(haven)

# Read the original location_type.dta
lt <- haven::read_dta("previous_codes/data/location_type.dta")

# Clean column names
location_type <- data.frame(
  location_id = as.integer(lt$location_id),
  location_name = as.character(lt$location_name),
  type = as.character(lt$type),
  iso3 = as.character(lt$iso3_countries),
  stringsAsFactors = FALSE
)

# Clean up type names
location_type$type <- trimws(location_type$type)
location_type$iso3 <- trimws(location_type$iso3)

# Set empty iso3 to NA
location_type$iso3[location_type$iso3 == ""] <- NA_character_

usethis::use_data(location_type, overwrite = TRUE)
