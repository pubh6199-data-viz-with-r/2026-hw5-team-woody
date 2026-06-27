[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jEmP5upM)
# Final Project: [Identifying California counties for targeted HIV prevention services: A County-level Analysis of HIV Burden, PrEP Coverage, and Socioeconomic Vulnerability ]

Identifying California counties for targeted HIV prevention services: A County-level Analysis of HIV burden, PrEP Coverage, and socioeconomic vulnerability"
author: "Bao Duong and Jean Jacques Brou"
date: "2026-06-25"

## 🔍 Project Overview

[Pre-exposure prophylaxis (PrEP) utilization and early diagnosis are critical HIV prevention strategies.
With limited resources, governmental agencies and local organizations may face challenges in allocating resources to populations in greatest need of HIV prevention services. 
Data-driven approaches can help inform targeted HIV interventions in communities with a high burden of HIV infections and low PrEP utilization.
This project seeks to identify potential priority counties in California for targeted HIV prevention services by 
exploring county-level patterns of HIV burden, PrEP utilization, and socioeconomic vulnerability. 

By using a radar chart, bar chart and an interactive cloropleth dashboard to present insights, we focus on the following research questions: 

1. Which county-level socioeconomic factors (e.g., percent living in poverty,  education attainment,  uninsured rate under 65 years old, and unemployment)
are associated with higher HIV diagnosis rates in California?  

2. How do  HIV diagnosis rates vary across California counties? Do counties with higher HIV diagnosis rates also have higher PrEP utilization? 

3. Do racial and ethnic disparities in HIV diagnosis rates exist across California counties?]



## 📊 Final Write-up

# # Used Shinyassistant for dashboard skeleton using prompt "Create an shinyapp skeleton where I want to have three different tabs where each tab is the below sketches. I am interested in

# Sketch 1: Do a radar chart with normalized socioeconomic variables (poverty, high school education percent, uninsured percent, and unemployment percent and HIV diagnosis. One group is high hiv reates and the other group is low hiv rates overlayed. There is a county dropdown
# For the radar tab, add boxes at the top that show the percent of pvoerty, high school education, uninsured, and unemploymenet

# Sketch 2: Geographic variation in HIV diagnosis rates by county using mainly choropleth maps with shape file. Shading will be done by diagnosis rate and then add size of dot to show PrEP use

# Sketch 3: Grouped bar chart showing average HIV diagnosis rates among different racial groups where there is a county dropdown

# I'll create a Shiny for R app skeleton with three tabs for your HIV data visualization. I'll structure it with placeholder data and logic that you can replace with your actual data.

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

Interactive Cloropleth map: 

The interactive map examine geographic variation in new HIV diagnosis rates and PrEP use by county. 
We visualize HIV new diagnoses rate per 100,000 and represented 
county PrEP use rate per 100,000 with dots to show high or low PrEP use. 
Higher new hiv diagnoses rate are concentrated in larger counties in 
the south and middle of California. Counties with higher new hiv diagnoses rate have lower PrEP use
rate compared to smaller counties with lower new hiv diagnosis rate. 
The interactive map shows that Kern county has highest new HIV diagnoses rate (29) 
compared to Imperial county with highest PrEp users rate and a lower new HIV diagnoses rate (18). 


This grouped bar chart shows the average of new HIV diagnosis rates per 100,000 among different racial groups in the State of California.
The bar chart shows a higher average rate for black and Hispanic compared to white and other minorities. 

Counties bar chart also shows the different HIV diagnosis rates by race for each county. 
For most counties, Black groups experience much higher HIV diagnosis rates where it was 
about 3-4 times more than their White counterparts. Hispanic groups had twice as high diagnosis
rates as their White Counterparts. For some counties, Multiple Races, and NH Pacific Islander  
also were at least twice as high as their White counterparts. Asian groups had less HIV diagnosis 
rates than their White counterparts.

[Click the shiny dashboard to view counties specific average] (https://bao-duong17.shinyapps.io/shiny-app/) 
 

## Limitations

We had to use 2023 as that was the most recent year available for AIDSVu for their HIV diagnosis, PrEP, and socioeconomic factors.
A good amount of the data was suppressed due to cases being too low to share in a dataset or the state department requested to not share to AIDSVu. 
The dataset also shared rates for HIV diagnosis and PrEP, but the rates had a related rate stability variable that directed us to view the rate with 
caution due to cases being too low (for example, American Indian for many counties) and so we mutated the dataset to remove those low confidence values 
from the visualizations. We also did not have PrEP rate by race and so we were unable to make a stronger analysis to consider potential interplay of 
race to PrEP to HIV diagonosis.  Finally, our chloropleth map analyzed by counties, but perhaps there was a better way to analyze rates and relationships 
more meaningfully  by population hubs in California.   

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
