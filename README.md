[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jEmP5upM)
# Final Project: [Insert Project Title]

Identifying California counties for targeted HIV prevention services: A County-level Analysis of HIV burden, PrEP Coverage, and socioeconomic vulnerability"
author: "Bao Duong and Jean Jacques Brou"
date: "2026-06-25"

## 🔍 Project Overview

The goal of this project is to collaboratively analyze and visualize the 2024 AIDSVu county-level dataset, with a focus on counties
California HIV diagnoses rates and prEP utilization. Specifically, we will examine whether counties with higher HIV diagnosis rates also demonstrate
higher levels of PrEP use and other sociodemographic factors, which may indicate targeted prevention efforts or greater access to HIV prevention services.
Finally, the project will explore racial and ethnic disparities in HIV diagnosis rates across California counties. 

## 📊 Final Write-up

# # Used Shinyassistant for dashboard skeleton using prompt "Create an shinyapp skeleton where I want to have three different tabs where each tab is the below sketches. I am interested in

# Sketch 1: Do a radar chart with normalized socioeconomic variables (poverty, high school education percent, uninsured percent, and unemployment percent and HIV diagnosis. One group is high hiv reates and the other group is low hiv rates overlayed. There is a county dropdown
# For the radar tab, add boxes at the top that show the percent of pvoerty, high school education, uninsured, and unemploymenet

# Sketch 2: Geographic variation in HIV diagnosis rates by county using mainly choropleth maps with shape file. Shading will be done by diagnosis rate and then add size of dot to show PrEP use

# Sketch 3: Grouped bar chart showing average HIV diagnosis rates among different racial groups where there is a county dropdown

# I'll create a Shiny for R app skeleton with three tabs for your HIV data visualization. I'll structure it with placeholder data and logic that you can replace with your actual data.

The final write-up, including code and interpretation of the visualizations, is available here:

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
