# server.R

server <- function(input, output, session) {
  
  # ── Reactive: county summary stats for value boxes (Tab 1) ───────────────
  county_stats <- reactive({
    req(input$county_radar)
    
    hiv_california %>%
      filter(county_label == input$county_radar) %>%
      summarise(
        poverty      = mean(percent_living_in_poverty,               na.rm = TRUE),
        education    = mean(percent_less_than_high_school_education,  na.rm = TRUE),
        uninsured    = mean(percent_uninsured_under_65_years_old,    na.rm = TRUE),
        unemployment = mean(percent_unemployed,                       na.rm = TRUE)
      )
  })
  
  # ── Value boxes (Tab 1) ───────────────────────────────────────────────────
  output$poverty_value <- renderText({
    paste0(round(county_stats()$poverty, 1), "%")
  })
  
  output$education_value <- renderText({
    paste0(round(county_stats()$education, 1), "%")
  })
  
  output$uninsured_value <- renderText({
    paste0(round(county_stats()$uninsured, 1), "%")
  })
  
  output$unemployment_value <- renderText({
    paste0(round(county_stats()$unemployment, 1), "%")
  })
  
  # ── Tab 1: Radar Chart ────────────────────────────────────────────────────
  output$radar_plot <- renderPlot({
    req(input$county_radar)
    
    # Group means from pre-normalised data (your Rmd approach)
    radar_data <- hiv_norm %>%
      filter(!is.na(new_diagnoses_cases_bin)) %>%
      group_by(new_diagnoses_cases_bin) %>%
      summarise(
        Poverty          = mean(percent_living_in_poverty,               na.rm = TRUE),
        `< HS Education` = mean(percent_less_than_high_school_education,  na.rm = TRUE),
        Uninsured        = mean(percent_uninsured_under_65_years_old,    na.rm = TRUE),
        Unemployed       = mean(percent_unemployed,                       na.rm = TRUE)
      )
    
    # Selected county row (normalised)
    county_row <- hiv_norm %>%
      filter(county_label == input$county_radar) %>%
      summarise(
        Poverty          = mean(percent_living_in_poverty,               na.rm = TRUE),
        `< HS Education` = mean(percent_less_than_high_school_education,  na.rm = TRUE),
        Uninsured        = mean(percent_uninsured_under_65_years_old,    na.rm = TRUE),
        Unemployed       = mean(percent_unemployed,                       na.rm = TRUE)
      )
    
    # Build fmsb data frame (your Rmd approach: column_to_rownames → rbind max/min)
    radar_df <- radar_data %>%
      tibble::column_to_rownames("new_diagnoses_cases_bin") %>%
      as.data.frame()
    
    county_df           <- as.data.frame(county_row)
    rownames(county_df) <- input$county_radar
    
    radar_df <- rbind(
      max    = rep(1, ncol(radar_df)),
      min    = rep(0, ncol(radar_df)),
      radar_df,
      county_df
    )
    
    # Colours: High = red, Low = blue, county = green dashed
    group_labels <- rownames(radar_df[-c(1, 2), ])
    n            <- length(group_labels)
    col_vec      <- c("#E74C3C", "#3498DB", "#27AE60")[seq_len(n)]
    fill_vec     <- c(
      scales::alpha("#E74C3C", 0.25),
      scales::alpha("#3498DB", 0.25),
      scales::alpha("#27AE60", 0.30)
    )[seq_len(n)]
    lty_vec <- c(1, 1, 2)[seq_len(n)]
    
    par(mar = c(1, 1, 3, 1))
    radarchart(
      radar_df,
      axistype    = 1,
      pcol        = col_vec,
      pfcol       = fill_vec,
      plwd        = c(2, 2, 2.5)[seq_len(n)],
      plty        = lty_vec,
      cglcol      = "grey80",
      cglty       = 1,
      axislabcol  = "grey30",
      caxislabels = seq(0, 1, 0.2),
      vlcex       = 0.88,
      title       = paste("Socioeconomic Profile —", input$county_radar, "")
    )
    
    legend(
      "bottomright",
      legend = group_labels,
      col    = col_vec,
      lty    = lty_vec,
      lwd    = 2,
      bty    = "n",
      cex    = 0.85
    )
  })
  
  # ── Tab 2: Choropleth Map (sf shapefile from your Rmd) ───────────────────
  pal <- colorNumeric(
    palette  = "YlOrRd",
    domain   = hiv_california_sf$new_diagnoses_rate,
    na.color = "#CCCCCC"
  )
  
  output$choropleth_map <- renderLeaflet({
    # Transform to WGS84 for Leaflet
    map_sf <- st_transform(hiv_california_sf, crs = 4326)
    
    leaflet(map_sf) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor   = ~pal(new_diagnoses_rate),
        fillOpacity = 0.75,
        color       = "#FFFFFF",
        weight      = 1,
        smoothFactor = 0.5,
        highlightOptions = highlightOptions(
          weight      = 2.5,
          color       = "#2C3E50",
          fillOpacity = 0.9,
          bringToFront = TRUE
        ),
        label = ~lapply(paste0(
          "<b>", county_name, "</b><br>",
          "HIV Rate: ",
          ifelse(is.na(new_diagnoses_rate),
                 "<i>Suppressed</i>",
                 paste0(new_diagnoses_rate, " per 100k")), "<br>",
          "PrEP Users: ",
          ifelse(is.na(county_prep_users), "<i>Suppressed</i>", county_prep_users)
        ), htmltools::HTML)
      ) %>%
      addLegend(
        pal      = pal,
        values   = ~new_diagnoses_rate,
        title    = "HIV Rate<br>(per 100k)",
        position = "bottomright",
        opacity  = 0.85,
        na.label = "Suppressed"
      )
  })
  
  # PrEP bubble overlay — added/removed reactively
  observe({
    req(input$map_overlay, input$bubble_scale)
    
    map_sf     <- st_transform(hiv_california_sf, crs = 4326)
    centroids  <- st_centroid(map_sf)
    coords     <- st_coordinates(centroids)
    prep_data  <- map_sf %>%
      mutate(lon = coords[, 1], lat = coords[, 2]) %>%
      filter(!is.na(county_prep_users))
    
    if (input$map_overlay == "Show PrEP Users") {
      leafletProxy("choropleth_map", data = prep_data) %>%
        clearGroup("prep_bubbles") %>%
        addCircleMarkers(
          lng         = ~lon,
          lat         = ~lat,
          radius      = ~sqrt(county_prep_users) * input$bubble_scale * 0.20,
          fillColor   = "#2980B9",
          fillOpacity = 0.50,
          color       = "#1A5276",
          weight      = 1,
          group       = "prep_bubbles",
          label = ~lapply(paste0(
            "<b>", county_name, "</b><br>",
            "PrEP Users: ", county_prep_users
          ), htmltools::HTML)
        )
    } else {
      leafletProxy("choropleth_map") %>%
        clearGroup("prep_bubbles")
    }
  })
  
  # ── Tab 3: Race/Ethnicity Bar Chart ───────────────────────────────────────
  output$bar_chart <- renderPlot({
    req(input$county_bar)
    
    plot_df <- race_long %>%
      filter(county_label == input$county_bar, !is.na(hiv_rate)) %>%
      mutate(race = factor(race, levels = c(
        "Black", "Hispanic", "White", "Asian",
        "Amer. Indian / AN", "Multiple Races", "NH / Pacific Isl."
      )))
    
    validate(
      need(nrow(plot_df) > 0,
           paste0("All race/ethnicity rates are suppressed for ",
                  input$county_bar, " County (fewer than 5 cases per group)."))
    )
    
    ggplot(plot_df, aes(x = race, y = hiv_rate, fill = race)) +
      geom_col(width = 0.68, show.legend = FALSE) +
      geom_text(
        aes(label = round(hiv_rate, 1)),
        vjust = -0.45, size = 4, colour = "#333333"
      ) +
      scale_fill_manual(values = c(
        "Black"              = "#C0392B",
        "Hispanic"           = "#E67E22",
        "White"              = "#2980B9",
        "Asian"              = "#8E44AD",
        "Amer. Indian / AN"  = "#16A085",
        "Multiple Races"     = "#7F8C8D",
        "NH / Pacific Isl."  = "#D4AC0D"
      )) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
      labs(
        title    = paste("HIV Diagnosis Rates by Race/Ethnicity —",
                         input$county_bar, "County"),
        subtitle = "Diagnoses per 100,000 population (2023). Suppressed groups omitted.",
        x        = NULL,
        y        = "Rate per 100,000"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title         = element_text(face = "bold", size = 14),
        plot.subtitle      = element_text(colour = "#666666", size = 11),
        panel.grid.major.x = element_blank(),
        axis.text.x        = element_text(face = "bold"),
        plot.background    = element_rect(fill = "#FAFAFA", colour = NA)
      )
  })
  
}
