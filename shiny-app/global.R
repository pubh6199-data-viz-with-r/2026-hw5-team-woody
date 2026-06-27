# global.R
# Loaded once at startup; shared across all sessions.

# ── Packages ────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(bsicons)
library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)
library(fmsb)
library(leaflet)
library(sf)
library(stringr)
library(tigris)
library(janitor)
library(plotly)
library(tidyverse)
library(here)
library(tmap)
library(rsconnect)

#set wd as the 2026-hw5-team-woody folder 
getwd() 
sdoh <- read_csv("AIDSVu_County_SDOH_2023-20250726.csv")
prEP <- read_csv("AIDSVu_County_PrEP_2023_20250501.csv")
newdx <- read_csv("AIDSVu_County_NewDX_2023-20250726.csv")

#Make a value NA for data is noted as being suppressed/missing due to too low of a population size, data not shared due to a data agreement, etc

sdoh <- sdoh %>%
  mutate(across(where(is.numeric), ~ ifelse(.x %in% -9:-1, NA, .x))) %>%
  mutate(across(where(is.character), ~ ifelse(.x %in% as.character(-9:-1), NA, .x)))

prEP <- prEP %>%
  mutate(across(where(is.numeric), ~ ifelse(.x %in% -9:-1, NA, .x))) %>%
  mutate(across(where(is.character), ~ ifelse(.x %in% as.character(-9:-1), NA, .x)))

newdx <- newdx %>%
  mutate(across(where(is.numeric), ~ ifelse(.x %in% -9:-1, NA, .x))) %>%
  mutate(across(where(is.character), ~ ifelse(.x %in% as.character(-9:-1), NA, .x)))

# converting variable from camelCase into snake_case 
sdoh  <- sdoh  %>% clean_names()
prEP <- prEP %>% clean_names()
newdx <- newdx %>% clean_names()

# Use rename_with function to fix prep split in "pr_ep" to prep
prEP <- prEP %>%
  clean_names() %>%
  rename_with(
    ~ str_replace_all(.x, "pr_ep", "prep")
  )

# Rate stability is listed with a Y when they are reliable rates (i.e. those generated with a numerator of 12 or greater) and N when they are not reliable. Also rate stability is listed as -9 when rate is unavailable, suppressed, or zero.  Make NAs for rates if they are any of those scenarios 

# use the variable of interest to convert N to NA
prEP <- prEP %>%
  mutate(county_prep_rate = ifelse(county_prep_rate_stability == "N", NA, county_prep_rate))

newdx <- newdx %>% # account for rate stability 
  mutate(
    new_diagnoses_rate                                          = ifelse(new_diagnoses_rate_stability == "N", NA, new_diagnoses_rate),
    new_diagnoses_black_rate                                    = ifelse(new_diagnoses_black_rate_stability == "N", NA, new_diagnoses_black_rate),
    new_diagnoses_white_rate                                    = ifelse(new_diagnoses_white_rate_stability == "N", NA, new_diagnoses_white_rate),
    new_diagnoses_hispanic_rate                                 = ifelse(new_diagnoses_hispanic_rate_stability == "N", NA, new_diagnoses_hispanic_rate),
    new_diagnoses_asian_rate                                    = ifelse(new_diagnoses_asian_rate_stability == "N", NA, new_diagnoses_asian_rate),
    new_diagnoses_multiple_races_rate                           = ifelse(new_diagnoses_multiple_races_rate_stability == "N", NA, new_diagnoses_multiple_races_rate),
    new_diagnoses_native_hawaiian_other_pacific_islander_rate   = ifelse(new_diagnoses_native_hawaiian_other_pacific_islander_rate_stability == "N", NA, new_diagnoses_native_hawaiian_other_pacific_islander_rate),
    new_diagnoses_american_indian_alaska_native_rate            = ifelse(new_diagnoses_american_indian_alaska_native_rate_stability == "N", NA, new_diagnoses_american_indian_alaska_native_rate)
  )

# Converting geo_id and year from numeric tpo character
newdx <- newdx %>% mutate(geo_id = as.character(geo_id),
                          year = as.character(year))
prEP <- prEP %>% mutate(geo_id = as.character(geo_id),
                        year = as.character(year))
sdoh <- sdoh %>% mutate(geo_id = as.character(geo_id),
                        year = as.character(year))

# Filter  each dataset to California
newdx_ca <- newdx %>%
  filter(state == "California") %>%
  rename(geoid = geo_id) %>%
  select(-contains("heterosexual"),
         -contains ("idu"),
         -contains ("transmission"),
         -contains ("msm"))

# rename variables and delete unnecessary variables
sdoh_ca <- sdoh %>%
  filter(state == "California") %>%
  rename(geoid = geo_id, county_name = county, county_urbanicity = x2023_county_urbanicity)%>%
  select(-urbanicity_year, -sdoh_year, -unemployment_year)

# rename variable county
prep_ca <- prEP %>%
  filter(state == "California") %>%
  rename(geoid = geo_id, county_name = county) 

# Join the 3 dataset by keys

merged_data <- left_join(newdx_ca, prep_ca, by = c("year", "geoid", "state", "state_abbreviation", "county_name"))

hiv_california <- left_join(merged_data, sdoh_ca, by = c("year", "geoid", "state", "state_abbreviation", "county_name"))

# For visualization 1 download California shape files
# use "clean_names" to transform variables name in uppercase letter to lowercase
# rename some variable to match common in the HIV_California variable

counties_ca <- counties(state = "CA", cb = TRUE, year = 2023) %>%
  janitor::clean_names() %>%
  rename(
    city_name          = name,
    county_name        = namelsad,
    state_abbreviation = stusps,
    state              = state_name
  ) %>%
  mutate(
    geoid = as.character(geoid),
    geoid = str_pad(geoid, width = 5, pad = "0")
  )

hiv_california <- hiv_california %>%
  mutate(
    geoid = as.character(geoid),
    geoid = str_pad(geoid, width = 5, pad = "0")
  )

#Join the HIV_California data to california shape files

hiv_california_sf <- counties_ca  %>%
  left_join(hiv_california, 
            by = c("geoid", "state", "state_abbreviation", "county_name"))


# for visualization 1 California shape files
# use "clean_names" to transform variables name in uppercase letter to lowercase
# download California shape files
# use "clean_names" to transform variables name in uppercase letter to lowercase
# rename some variable to match common in the HIV_California variable


counties_ca <- counties(state = "CA", cb = TRUE, year = 2023) %>%
  janitor::clean_names() %>%
  rename(
    city_name          = name,
    county_name        = namelsad,
    state_abbreviation = stusps,
    state              = state_name
  ) %>%
  mutate(
    geoid = as.character(geoid),
    geoid = str_pad(geoid, width = 5, pad = "0")
  )

hiv_california_sf <- counties_ca %>%
  left_join(hiv_california,
            by = c("geoid", "state", "state_abbreviation", "county_name"))

# County choices for dropdowns 
county_choices <- sort(unique(hiv_california$county_name))

# Race rate columns 
hiv_california <- hiv_california %>%
  mutate(
    geoid = as.character(geoid),
    geoid = str_pad(geoid, width = 5, pad = "0")
  )

#Join the HIV_California data to california shape files

hiv_california_sf <- counties_ca  %>%
  left_join(hiv_california, 
            by = c("geoid", "state", "state_abbreviation", "county_name"))


# County choices for dropdowns 
county_choices <- sort(unique(hiv_california$county_name))

# visualization 2 Radar Bin new_diagnoses_cases into High / Low 

hiv_california <- hiv_california %>%
  mutate(
    new_diagnoses_cases_bin = if_else(
      new_diagnoses_cases >= median(new_diagnoses_cases, na.rm = TRUE),
      "High HIV diagnoses",
      "Low HIV diagnoses"
    ),
    new_diagnoses_cases_bin = factor(
      new_diagnoses_cases_bin,
      levels = c("Low HIV diagnoses", "High HIV diagnoses")
    ),
    .after = new_diagnoses_cases
  )

hiv_california <- hiv_california %>%
  mutate(
    county_name = str_remove(county_name, " County$"),  # e.g. "Los Angeles"
    geoid        = str_pad(as.character(geoid), width = 5, pad = "0")
  )

counties_ca <- counties(state = "CA", cb = TRUE, year = 2023) %>%
  clean_names() 


# Visualization 3 
race_cols <- c(
  "Black"              = "new_diagnoses_black_rate",
  "White"              = "new_diagnoses_white_rate",
  "Hispanic"           = "new_diagnoses_hispanic_rate",
  "Asian"              = "new_diagnoses_asian_rate",
  "Multiple Races"     = "new_diagnoses_multiple_races_rate",
  "NH / Pacific Isl."  = "new_diagnoses_native_hawaiian_other_pacific_islander_rate",
  "Amer. Indian / AN"  = "new_diagnoses_american_indian_alaska_native_rate"
  
)

# Long-format race data for Tab 3 bar chart
race_long <- hiv_california %>%
  select(county_name, all_of(unname(race_cols))) %>%
  pivot_longer(
    cols      = all_of(unname(race_cols)),
    names_to  = "race_col",
    values_to = "hiv_rate"
  ) %>%
  mutate(race = names(race_cols)[match(race_col, unname(race_cols))]) %>%
  select(county_name, race, hiv_rate)

# do state average
state_race <- race_long %>%
  group_by(race) %>%
  summarise(
    state_rate = mean(hiv_rate, na.rm = TRUE)
  )

# Pre-normalised dataset for radar (rescale numeric cols across all counties)
hiv_norm <- hiv_california %>%
  mutate(across(where(is.numeric), rescale))


# for the race ethnicity tab, there are counties that have no data to display. And so create a new vector with just counties that have some data
race_county_choices <- race_long %>%
  filter(!is.na(hiv_rate)) %>%
  pull(county_name) %>%
  unique() %>%
  sort()

tmap_mode("plot")
tm_shape(hiv_california_sf) +
  tm_polygons("county_prep_rate", palette = "Reds") +
  tm_layout(title = "County prep rate")

tmap_mode("plot")
tm_shape(hiv_california_sf) +
  tm_polygons("new_diagnoses_rate", palette = "Reds") +
  tm_layout(title = "new diagnoses rate")


# use st_transform to convert my data into crs
hiv_california_sf = sf::st_transform(hiv_california_sf, 4326)

# Create point layer only for prep rate
prep_points <- hiv_california_sf %>%
  sf::st_point_on_surface()

hiv_pal <- colorBin("Reds", domain = hiv_california_sf$new_diagnoses_rate, 
                    bins = c(0, 5, 10, 15, 20, 25, 30),
                    na.color = "gray") # using the sf object with hiv_california_sf


prep_pal <- colorBin(
  palette = "black",
  domain = hiv_california_sf$county_prep_rate,
  bins = c(0, 99, 199, 299, 399, 500),
  na.color = "gray")


leaflet(hiv_california_sf) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  
  addPolygons(fillColor = ~hiv_pal(new_diagnoses_rate ),color = "white", weight = 1, fillOpacity = 0.9,  
              
              label = ~paste0( county_name, "<br>",
                               "New Diagnosis Rate:", round(new_diagnoses_rate , 1), "<br>",
                               "New HIV cases:", new_diagnoses_cases, "<br>",
                               "County PrEP rate:" , round(county_prep_rate, 1), "<br>",
                               "County prEP Users:" , county_prep_users ) %>% lapply(htmltools::HTML)
              
  ) %>%
  
  # Dots represent county_prep_rate only
  addCircleMarkers(
    data = prep_points,
    radius = ~sqrt(county_prep_rate) / 3,
    fillColor = ~prep_pal(county_prep_rate),
    fillOpacity = 0.9,
    stroke = TRUE,
    color = "black",
    weight = 1,
  ) %>%
  addLegend(pal = hiv_pal, values = ~ new_diagnoses_rate , title = "New Diagnosis Rate", position =  "bottomright") %>% #added legend
  
  addLegend(
    pal = prep_pal,
    values = ~county_prep_rate,
    title = "County PrEP Rate",
    position = "bottomleft"
  ) %>%
  
  setView(lng = -119, 
          lat = 37, 
          zoom = 5.5
  )

# global.R
# Loaded once at startup; shared across all sessions

# ── Packages ────────────────────────────────────────────────────────────────
library(shiny)
library(bslib)
library(bsicons)
library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)
library(fmsb)
library(leaflet)
library(sf)
library(stringr)
library(tigris)
library(janitor)
library(plotly)
library(tidyverse)
library(here)
library(tmap)
library(rsconnect)

# set team woody folder as the main wd or whatever has the data files
sdoh <- read_csv("AIDSVu_County_SDOH_2023-20250726.csv")
prEP <- read_csv("AIDSVu_County_PrEP_2023_20250501.csv")
newdx <- read_csv("AIDSVu_County_NewDX_2023-20250726.csv")

#Make a value NA for data is noted as being suppressed/missing due to too low of a population size, data not shared due to a data agreement, etc

sdoh <- sdoh %>%
  mutate(across(where(is.numeric), ~ ifelse(.x %in% -9:-1, NA, .x))) %>%
  mutate(across(where(is.character), ~ ifelse(.x %in% as.character(-9:-1), NA, .x)))

prEP <- prEP %>%
  mutate(across(where(is.numeric), ~ ifelse(.x %in% -9:-1, NA, .x))) %>%
  mutate(across(where(is.character), ~ ifelse(.x %in% as.character(-9:-1), NA, .x)))

newdx <- newdx %>%
  mutate(across(where(is.numeric), ~ ifelse(.x %in% -9:-1, NA, .x))) %>%
  mutate(across(where(is.character), ~ ifelse(.x %in% as.character(-9:-1), NA, .x)))

# converting variable from camelCase into snake_case 
sdoh  <- sdoh  %>% clean_names()
prEP <- prEP %>% clean_names()
newdx <- newdx %>% clean_names()

# Use rename_with function to fix prep split in "pr_ep" to prep
prEP <- prEP %>%
  clean_names() %>%
  rename_with(
    ~ str_replace_all(.x, "pr_ep", "prep")
  )

# Rate stability is listed with a Y when they are reliable rates (i.e. those generated with a numerator of 12 or greater) and N when they are not reliable. Also rate stability is listed as -9 when rate is unavailable, suppressed, or zero.  Make NAs for rates if they are any of those scenarios 

# use the variable of interest to convert N to NA
prEP <- prEP %>%
  mutate(county_prep_rate = ifelse(county_prep_rate_stability == "N", NA, county_prep_rate))

newdx <- newdx %>%
  mutate(new_diagnoses_rate   = ifelse(new_diagnoses_rate_stability == "N", NA, new_diagnoses_rate),
         new_diagnoses_black_rate   = ifelse(new_diagnoses_black_rate_stability == "N", NA, new_diagnoses_black_rate),
         new_diagnoses_white_rate   = ifelse(new_diagnoses_white_rate_stability == "N", NA, new_diagnoses_white_rate),
         new_diagnoses_hispanic_rate = ifelse(new_diagnoses_hispanic_rate_stability == "N", NA, new_diagnoses_hispanic_rate),
         new_diagnoses_asian_rate   = ifelse(new_diagnoses_asian_rate_stability == "N", NA, new_diagnoses_asian_rate)
  )

# Converting geo_id and year from numeric tpo character
newdx <- newdx %>% mutate(geo_id = as.character(geo_id),
                          year = as.character(year))
prEP <- prEP %>% mutate(geo_id = as.character(geo_id),
                        year = as.character(year))
sdoh <- sdoh %>% mutate(geo_id = as.character(geo_id),
                        year = as.character(year))

# Filter  each dataset to California
newdx_ca <- newdx %>%
  filter(state == "California") %>%
  rename(geoid = geo_id) %>%
  select(-contains("heterosexual"),
         -contains ("idu"),
         -contains ("transmission"),
         -contains ("msm"))

# rename variables and delete unnecessary variables
sdoh_ca <- sdoh %>%
  filter(state == "California") %>%
  rename(geoid = geo_id, county_name = county, county_urbanicity = x2023_county_urbanicity)%>%
  select(-urbanicity_year, -sdoh_year, -unemployment_year)

# rename variable county
prep_ca <- prEP %>%
  filter(state == "California") %>%
  rename(geoid = geo_id, county_name = county) 

# Join the 3 dataset by keys

merged_data <- left_join(newdx_ca, prep_ca, by = c("year", "geoid", "state", "state_abbreviation", "county_name"))

hiv_california <- left_join(merged_data, sdoh_ca, by = c("year", "geoid", "state", "state_abbreviation", "county_name"))

# For visualization 1 download California shape files
# use "clean_names" to transform variables name in uppercase letter to lowercase
# rename some variable to match common in the HIV_California variable

counties_ca <- counties(state = "CA", cb = TRUE, year = 2023) %>%
  janitor::clean_names() %>%
  rename(
    city_name          = name,
    county_name        = namelsad,
    state_abbreviation = stusps,
    state              = state_name
  ) %>%
  mutate(
    geoid = as.character(geoid),
    geoid = str_pad(geoid, width = 5, pad = "0")
  )

#Join the HIV_California data to california shape files

hiv_california_sf <- counties_ca  %>%
  left_join(hiv_california, 
            by = c("geoid", "state", "state_abbreviation", "county_name"))

# County choices for dropdowns 
county_choices <- sort(unique(hiv_california$county_name))

# Race rate columns 
hiv_california <- hiv_california %>%
  mutate(
    geoid = as.character(geoid),
    geoid = str_pad(geoid, width = 5, pad = "0")
  )

#Join the HIV_California data to california shape files

hiv_california_sf <- counties_ca  %>%
  left_join(hiv_california, 
            by = c("geoid", "state", "state_abbreviation", "county_name"))

# visualization 2 Radar Bin new_diagnoses_cases into High / Low 

hiv_california <- hiv_california %>%
  mutate(
    new_diagnoses_cases_bin = if_else(
      new_diagnoses_cases >= median(new_diagnoses_cases, na.rm = TRUE),
      "High HIV diagnoses",
      "Low HIV diagnoses"
    ),
    new_diagnoses_cases_bin = factor(
      new_diagnoses_cases_bin,
      levels = c("Low HIV diagnoses", "High HIV diagnoses")
    ),
    .after = new_diagnoses_cases
  )

hiv_california <- hiv_california %>%
  mutate(
    county_name = str_remove(county_name, " County$"),  # e.g. "Los Angeles"
    geoid        = str_pad(as.character(geoid), width = 5, pad = "0")
  )

counties_ca <- counties(state = "CA", cb = TRUE, year = 2023) %>%
  clean_names() 


# Visualization 3 
race_cols <- c(
  "Black"              = "new_diagnoses_black_rate",
  "White"              = "new_diagnoses_white_rate",
  "Hispanic"           = "new_diagnoses_hispanic_rate",
  "Asian"              = "new_diagnoses_asian_rate",
  "Multiple Races"     = "new_diagnoses_multiple_races_rate",
  "NH / Pacific Isl."  = "new_diagnoses_native_hawaiian_other_pacific_islander_rate",
  "Amer. Indian / AN"  = "new_diagnoses_american_indian_alaska_native_rate"
)

# Long-format race data for Tab 3 bar chart
race_long <- hiv_california %>%
  select(county_name, all_of(unname(race_cols))) %>%
  pivot_longer(
    cols      = all_of(unname(race_cols)),
    names_to  = "race_col",
    values_to = "hiv_rate"
  ) %>%
  mutate(race = names(race_cols)[match(race_col, unname(race_cols))]) %>%
  select(county_name, race, hiv_rate)

# do state average
state_race <- race_long %>%
  group_by(race) %>%
  summarise(
    state_rate = mean(hiv_rate, na.rm = TRUE)
  )

# Pre-normalised dataset for radar (rescale numeric cols across all counties)
hiv_norm <- hiv_california %>%
  mutate(across(where(is.numeric), rescale))


# for the race ethnicity tab, there are counties that have no data to display. And so create a new vector with just counties that have some data
race_county_choices <- race_long %>%
  filter(!is.na(hiv_rate)) %>%
  pull(county_name) %>%
  unique() %>%
  sort()

tmap_mode("plot")
tm_shape(hiv_california_sf) +
  tm_polygons("county_prep_rate", palette = "Reds") +
  tm_layout(title = "County prep rate")

tmap_mode("plot")
tm_shape(hiv_california_sf) +
  tm_polygons("new_diagnoses_rate", palette = "Reds") +
  tm_layout(title = "new diagnoses rate")


# use st_transform to convert my data into crs
hiv_california_sf = sf::st_transform(hiv_california_sf, 4326)

# Create point layer only for prep rate
prep_points <- hiv_california_sf %>%
  sf::st_point_on_surface()

hiv_pal <- colorBin("Reds", domain = hiv_california_sf$new_diagnoses_rate, 
                    bins = c(0, 5, 10, 15, 20, 25, 30),
                    na.color = "gray") # using the sf object with hiv_california_sf


prep_pal <- colorBin(
  palette = "black",
  domain = hiv_california_sf$county_prep_rate,
  bins = c(0, 99, 199, 299, 399, 500),
  na.color = "gray")


leaflet(hiv_california_sf) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  
  addPolygons(fillColor = ~hiv_pal(new_diagnoses_rate ),color = "white", weight = 1, fillOpacity = 0.9,  
              
              label = ~paste0( county_name, "<br>",
                               "New Diagnosis Rate:", round(new_diagnoses_rate , 1), "<br>",
                               "New HIV cases:", new_diagnoses_cases, "<br>",
                               "County PrEP rate:" , round(county_prep_rate, 1), "<br>",
                               "County prEP Users:" , county_prep_users ) %>% lapply(htmltools::HTML)
              
  ) %>%
  
  # Dots represent county_prep_rate only
  addCircleMarkers(
    data = prep_points,
    radius = ~sqrt(county_prep_rate) / 3,
    fillColor = ~prep_pal(county_prep_rate),
    fillOpacity = 0.9,
    stroke = TRUE,
    color = "black",
    weight = 1,
  ) %>%
  addLegend(pal = hiv_pal, values = ~ new_diagnoses_rate , title = "New Diagnosis Rate", position =  "bottomright") %>% #added legend
  
  addLegend(
    pal = prep_pal,
    values = ~county_prep_rate,
    title = "County PrEP Rate",
    position = "bottomleft"
  ) %>%
  
  setView(lng = -119, 
          lat = 37, 
          zoom = 5.5
  )


