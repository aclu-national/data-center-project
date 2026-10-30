# ============================================================
# Data Center Project: Merge Data Center Location and Census Tract
# ============================================================

# Author: Cierra Oliveira
# Date: 2026-10-30

# ============================================================

# import Packages
library(tidycensus)
library(sf)
library(dplyr)

# read in data
tracts = read.csv("~/ACLU/Data_Center_Project/data/census_tracts.csv")
data_centers_raw = read.csv('~/ACLU/Data_Center_Project/data/cleaned_dcx-facilities-2026-10-30.csv')

# standardize data center columns
# TODO : change when using new dataset

data_centers <- data_centers_raw |>
  rename(     
    facility_name = name,
    lon           = lng
  )

# make id for each data center
data_centers <- data_centers |>
  mutate(id = row_number())

# keep only relevant columns
cols <- c('id', 'facility_name', 'status', 'type', 'state', 'lat', 'lon')
data_centers <- data_centers |>
  select(all_of(cols))

# drop rows with missing lat and lon
data_centers <- data_centers %>% filter(!is.na(lat) & !is.na(lon))

# ============================================================
# get spatial points for all data centers
data_centers_sf <- st_as_sf(data_centers, coords = c('lon', 'lat'), crs = 4326)

# get census tract boundaries
tract_boundaries <- map_dfr(
  states,
  ~ get_decennial(
    geography = "tract",
    variables = "P2_001N",
    state = .x,
    year = 2020,
    geometry = TRUE
  )
)

# transform boundaries to same CRS format
tract_boundaries <- st_transform(
  tract_boundaries,
  st_crs(data_centers_sf)
)

# match data center location to  tract
df <- st_join(
  data_centers_sf,
  tract_boundaries 
  |> select(GEOID)) |>
  st_drop_geometry()

# save
#write.csv(df, '~/ACLU/Data_Center_Project/data/data_center_w_census_tract.csv')

