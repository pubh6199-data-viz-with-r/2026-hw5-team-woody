# ui.R
ui <- page_navbar(
  title = "HIV Diagnosis Analysis Dashboard — California",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
 
  # ── Tab 1: Choropleth Map ─────────────────────────────────────────────────
  nav_panel(
    "Geographic Variation",
    
    layout_sidebar(
      sidebar = sidebar(
        h5(
          "Identifying California counties for targeted HIV prevention services:
        A County-level Analysis of HIV burden, PrEP Coverage, and
        socioeconomic vulnerability"
        ),
        
        p(
          "This map displays county-level HIV diagnosis rates and PrEP utilization
        across California counties."
        ),
        
        hr(),
        
        p(strong("Data Sources:")),
        
        tags$ul(
          tags$li("AIDSVu County New Diagnoses Dataset, 2023"),
          tags$li("AIDSVu County PrEP Dataset, 2023"),
          tags$li("U.S. Census TIGER/Line county shapefiles")
        ),
        
        hr()
      ),
      
      card(
        card_header(
          "Choropleth Map: HIV Diagnosis Rates and PrEP Use by County"
        ),
        full_screen = TRUE,
        leafletOutput("choropleth_map", height = "650px"),
        card_footer(
          style = "font-size:0.78rem; color:#888;",
          "Rates are reported per 100,000 population. Counties with suppressed
        or unreliable estimates are omitted from the map."
        )
      )
    )
  ),
  
  # ── Tab 2: Radar Chart ────────────────────────────────────────────────────
  nav_panel(
    "Socioeconomic Factors",
    layout_sidebar(
      sidebar = sidebar(
        selectInput(
          "county_radar",
          "Select County:",
          choices  = sort(unique(hiv_california$county_name)),
          selected = sort(unique(hiv_california$county_name))[1]
        ),
        hr(),
        p("This radar chart compares normalized socioeconomic variables between
           high and low HIV diagnosis rate groups for the selected county.",
          style = "font-size:0.82rem; color:#666;")
      ),
      
      # Value boxes
      layout_columns(
        col_widths = c(3, 3, 3, 3),
        value_box(
          title    = "Poverty Rate",
          value    = textOutput("poverty_value"),
          showcase = bsicons::bs_icon("piggy-bank"),
          theme    = "primary"
        ),
        value_box(
          title    = "< HS Education",
          value    = textOutput("education_value"),
          showcase = bsicons::bs_icon("mortarboard"),
          theme    = "success"
        ),
        value_box(
          title    = "Uninsured Rate",
          value    = textOutput("uninsured_value"),
          showcase = bsicons::bs_icon("heart-pulse"),
          theme    = "warning"
        ),
        value_box(
          title    = "Unemployment Rate",
          value    = textOutput("unemployment_value"),
          showcase = bsicons::bs_icon("briefcase"),
          theme    = "danger"
        )
      ),
      
      # Radar chart
      card(
        card_header("Radar Chart: Socioeconomic Variables by HIV Diagnosis Rate Group"),
        plotOutput("radar_plot", height = "500px"),
        card_footer(
          style = "font-size:0.78rem; color:#888;",
          "Variables normalized 0–1 across all California counties.
           Red = High HIV Rate group; Blue = Low HIV Rate group.Source: AIDSVU 2023 New Diagnosis Dataset"
        )
      )
    )
  ),
  
  # ── Tab 3: Race/Ethnicity Bar Chart ───────────────────────────────────────
  nav_panel(
    "Racial Demographics",
    layout_sidebar(
      sidebar = sidebar(
        selectInput(
          "county_bar",
          "Select County:",
          choices  = race_county_choices,
          selected = race_county_choices[1]  # autoselects first option
        ),
        hr(),
        p("This chart shows average HIV diagnosis rates (per 100,000) across
           racial and ethnic groups for the selected county.",
          style = "font-size:0.82rem; color:#666;")
      ),
      card(
        card_header("Average HIV Diagnosis Rates by Race/Ethnicity"),
        plotOutput("bar_chart", height = "500px"),
        card_footer(
          style = "font-size:0.78rem; color:#888;",
          "Rates shown per 100,000 population. Source: AIDSVU 2023 New Diagnosis Dataset."
        )
      )
    )
  )
)