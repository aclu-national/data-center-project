# ============================================================
# Data Center Project: Census Data Extraction
# Census tract-level racial demographics
# ============================================================

# Author: Cierra Oliveira
# Date: 2026-10-15

# ============================================================

# Load Packages
library(tidycensus)
library(tidyverse)
library(dplyr)

# check for API key
stopifnot("CENSUS_API_KEY not found." = nzchar(Sys.getenv("CENSUS_API_KEY")))

# TO DO: 
# instructions for API key

# Pull Race and Ethnicity Data
# 2020 Decennial Census, table P2
race_vars <- c(
  total         = "P2_001N",
  hispanic      = "P2_002N",
  white_nh      = "P2_005N",
  black_nh      = "P2_006N",
  aian_nh       = "P2_007N",
  asian_nh      = "P2_008N",
  nhpi_nh       = "P2_009N",
  other_nh      = "P2_010N",
  two_or_more_nh = "P2_011N"
)

# for now, use all 50 states
states <- state.abb

# pull tract level data for all states
tracts_2020 <- map_dfr(
  states,
  ~ get_decennial(
    geography = "tract",
    variables = race_vars,
    state = .x,
    year = 2020,
    output = "wide"
  )
)

# calculate percentages
tracts_2020 <- tracts_2020 |>
  mutate(across(hispanic:two_or_more_nh, ~ .x / total * 100, .names = "pct_{.col}"))

# parse tract names
tracts_2020 <- tracts_2020 |>
  separate_wider_delim(
    cols_remove = FALSE,
    cols = NAME,
    delim = ", ",
    names = c("tract", "county", "state")
  )


# kept tract number only
tracts_2020 <- tracts_2020 |>
  mutate(
    tract  = str_remove(tract, "^Census Tract ")
  )

# save tract data
write.csv(tracts_2020, "census_tract_temp.csv")
