[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jEmP5upM)
# Final Project: [Identifying California counties for targeted HIV prevention services: A County-level Analysis of HIV Burden, PrEP Coverage, and Socioeconomic Vulnerability ]

Authors: [Jean Jacques Brou, Bao Duong]  
Course: PUBH 6199 – Visualizing Data with R  
Date: [2026-06-25]

## 🔍 Project Overview

[Pre-exposure prophylaxis (PrEP) utilization and early diagnosis are critical HIV prevention strategies.
With limited resources, governmental agencies and local organizations may face challenges in allocating resources to populations in greatest need of HIV prevention services. 
Data-driven approaches can help inform targeted HIV interventions in communities with a high burden of HIV infections and low PrEP utilization.
This project seeks to identify potential priority counties in California for targeted HIV prevention services by 
exploring county-level patterns of HIV burden, PrEP utilization, and socioeconomic vulnerability. 

By using three visualizations and an interactive dashboard to present insights, we focus on the following research questions: 

1. Which county-level socioeconomic factors (e.g., percent living in poverty,  education attainment,  uninsured rate under 65 years old, and unemployment)
are associated with higher HIV diagnosis rates in California?  

2. How do  HIV diagnosis rates vary across California counties? Do counties with higher HIV diagnosis rates also have higher PrEP utilization? 

3. Do racial and ethnic disparities in HIV diagnosis rates exist across California counties?]



## 📊 Final Write-up

The final write-up, including code and interpretation of the visualizations, is available here:

## Data

We use 2023 AIDSVu Data collected by state and local health departments, and de-duplicated and processed by the U.S. 
Centers for Disease Control and Prevention (CDC) to meet data quality standards for comparability and reliability. 
All 50 states, the District of Columbia (DC), and U.S. territories collect comparable confidential, 
name-based case reports of HIV infection and social determinants of health. 

We downloaded the Social Determinants of Health, County New Diagnoses, and County PrEP Data. 
We restricted our analysis to California, remove unnecessary variables and merged the three data by keys 
such: "year", "geoid", "state", "state_abbreviation", "county_name". We downloaded 2023 California shape files 
and merged it to the clean data. 


## Interpretation

Interactive map: 

The interactive map examine geographic variation in HIV diagnosis rates by county. 
We visualize HIV new diagnoses rate per 100,000 and represented 
county PrEP use rate per 100,000 with dots. Higher new hiv diagnoses rate are concentrated in larger counties in 
the south and middle of California. Counties with higher new hiv diagnoses rate have lower PrEP use
rate compared to smaller counties with lower new hiv diagnosis rate. 
The interactive map shows that Kern county has highest new HIV diagnoses rate (29) 
compared to Imperial county with highest PrEp users rate and a lower new HIV diagnoses rate (18). 



Bar Chart: The bar chart explore racial and ethnic disparities in HIV infection across California counties.
We visualize the mean rate of new hiv diagnoses by race/ethnicity in California. 
The bar chart shows a higher mean rate for black and Hispanic compared to white and other minorities. 




Shiny Dashboard: 


## Limitations

The data visualizations was limited to 2023 due to unavailability of 2024 and 2025 dataset of interest on AIDSVu. 
-Missing data
-missing variable of interest
-

👉 [**View the write-up website**](https://pubh6199-data-viz-with-r.github.io/hw6-YOUR-TEAM-NAME/)

## 📂 Repository Structure

```plaintext
.
├── _quarto.yml          # Quarto configuration file
├── .gitignore           # Files to ignore in git
├── data/                # Cleaned data files used in project
├── .Rproj               # RStudio project file
├── index.qmd            # Main Quarto file for final write-up
├── scratch/             # Scratch files for exploratory analysis         
├── shiny-app/           # Shiny app folder (if used)
│   ├── app.R
|   ├── www/             # Static files for Shiny app (CSS, JS, images)
│   └── app-data/        # Data files for Shiny app
├── docs/                # Rendered site (auto-generated)
└── README.md            # This file
```

## 🛠 How to Run the Code

### To render the write-up:

1. Open the `.Rproj` file in RStudio.
2. Open `index.qmd`.
3. Click **Render**. The updated html will be saved in the `docs/` folder.

### To run the Shiny app (if applicable):

```r
shiny::runApp("shiny-app")
```

> ⚠️ Make sure any necessary data files are in `shiny-app/app-data/`.

## 🔗 Shiny App Link

If your project includes a Shiny app, you can access it here:

👉 [https://yourusername.shinyapps.io/your-app-name](https://yourusername.shinyapps.io/your-app-name)

## 📦 Packages Used

- `tidyverse`
- `ggplot2`
- `quarto`
- `shiny` (if applicable)

## ✅ To-Do or Known Issues

[Optional section for you to note improvements or bugs.]
