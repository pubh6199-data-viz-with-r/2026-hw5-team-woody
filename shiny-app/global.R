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

hiv_california <- read.csv("hiv_california.csv")
getwd()
ls()

# ── Step 1: Bin new_diagnoses_cases into High / Low (from your Rmd) ───────
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

# ── Step 2: Add county_label + pad geoid ─────────────────────────────────
hiv_california <- hiv_california %>%
  mutate(
    county_label = str_remove(county_name, " County$"),  # e.g. "Los Angeles"
    geoid        = str_pad(as.character(geoid), width = 5, pad = "0")
  )

# ── Step 3: Download CA shapefile & join (from your Rmd) ──────────────────
counties_ca <- counties(state = "CA", cb = TRUE, year = 2023) %>%
  clean_names() %>%
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

# ── Step 4: Derived objects used across tabs ───────────────────────────────

# County choices for dropdowns — county_label already set above
county_choices <- sort(unique(hiv_california$county_label))

# Race rate columns → named lookup for Tab 3
race_cols <- c(
  "Black"              = "new_diagnoses_black_rate",
  "White"              = "new_diagnoses_white_rate",
  "Hispanic"           = "new_diagnoses_hispanic_rate",
  "Asian"              = "new_diagnoses_asian_rate",
  "Amer. Indian / AN"  = "new_diagnoses_american_indian_alaska_native_rate",
  "Multiple Races"     = "new_diagnoses_multiple_races_rate",
  "NH / Pacific Isl."  = "new_diagnoses_native_hawaiian_other_pacific_islander_rate"
)

# Long-format race data for Tab 3 bar chart
race_long <- hiv_california %>%
  select(county_label, all_of(unname(race_cols))) %>%
  pivot_longer(
    cols      = all_of(unname(race_cols)),
    names_to  = "race_col",
    values_to = "hiv_rate"
  ) %>%
  mutate(race = names(race_cols)[match(race_col, unname(race_cols))]) %>%
  select(county_label, race, hiv_rate)

# Pre-normalised dataset for radar (rescale numeric cols across all counties)
hiv_norm <- hiv_california %>%
  mutate(across(where(is.numeric), rescale))
