# server.R

server <- function(input, output, session) {
  
  # (Tab 1) Create county summary stats for value boxes 
  county_stats <- reactive({
    req(input$county_radar) # Stops execution if no county has been selected yet
    
    hiv_california %>%
      filter(county_name == input$county_radar) %>%
      summarise(
        poverty      = mean(percent_living_in_poverty,               na.rm = TRUE),
        education    = mean(percent_less_than_high_school_education,  na.rm = TRUE),
        uninsured    = mean(percent_uninsured_under_65_years_old,    na.rm = TRUE),
        unemployment = mean(percent_unemployed,                       na.rm = TRUE)
      )
  })
  
  # Display county statistics in value boxes
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
  
  # (Tab 1) Radar Chart 
  output$radar_plot <- renderPlot({
    req(input$county_radar)
    
    # Group means from pre-normalised data 
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
      filter(county_name == input$county_radar) %>%
      summarise(
        Poverty          = mean(percent_living_in_poverty,               na.rm = TRUE),
        `< HS Education` = mean(percent_less_than_high_school_education,  na.rm = TRUE),
        Uninsured        = mean(percent_uninsured_under_65_years_old,    na.rm = TRUE),
        Unemployed       = mean(percent_unemployed,                       na.rm = TRUE)
      )
    
    # Build fmsb data frame by converting the column of binned variable to row names into standard df
    radar_df <- radar_data %>%
      tibble::column_to_rownames("new_diagnoses_cases_bin") %>%
      as.data.frame()
    
    county_df           <- as.data.frame(county_row)
    rownames(county_df) <- input$county_radar
    
    # max 1 or 0 
    radar_df <- rbind(
      max    = rep(1, ncol(radar_df)),
      min    = rep(0, ncol(radar_df)),
      radar_df,
      county_df
    )
    
    # Colours: High HIV diagnosis group = red, Low HIV diagnosis group  = blue, county = green dashed
    group_labels <- rownames(radar_df[-c(1, 2), ]) # Shinyassistant did this to temporarily drop max and min? 
    n            <- length(group_labels)
    col_vec      <- c("#E74C3C", "#3498DB", "#27AE60")
    fill_vec     <- c(
      scales::alpha("#3498d8", 0.10), # make this more transparent 
      scales::alpha("#e74c3c", 0.10),
      scales::alpha("#27AE60", 0.30)
    )
    lty_vec <- c(1, 1, 2)[seq_len(n)]
    
    # Maximize canvas area to prevent text running off
    
    par(mar = c(1, 1, 3, 1))
    radarchart(
      radar_df,
      axistype    = 1,
      pcol        = col_vec,
      pfcol       = fill_vec,
      plwd        = c(2, 2, 2.5),
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
  
  # Tab 2: Chloropleth Map hold
  
  output$choropleth_map <- renderLeaflet({
    
    leaflet(hiv_california_sf) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      
      # HIV choropleth layer
      addPolygons(
        fillColor = ~hiv_pal(new_diagnoses_rate),
        color = "white",
        weight = 1,
        fillOpacity = 0.9,
        
        label = ~lapply(
          paste0(
            "<strong>", county_name, "</strong><br>",
            "New Diagnosis Rate: ",
            round(new_diagnoses_rate, 1), "<br>",
            "New HIV Cases: ",
            new_diagnoses_cases, "<br>",
            "County PrEP Rate: ",
            round(county_prep_rate, 1), "<br>",
            "County PrEP Users: ",
            county_prep_users
          ),
          htmltools::HTML
        )
      ) %>%
      
      # PrEP dots
      addCircleMarkers(
        data = prep_points,
        radius = ~sqrt(county_prep_rate) / 2,
        fillColor = "black",
        fillOpacity = 0.8,
        stroke = FALSE
      ) %>%
      
      # HIV legend
      addLegend(
        pal = hiv_pal,
        values = ~new_diagnoses_rate,
        title = "New HIV Diagnosis Rate",
        position = "bottomright"
      ) %>%
      
      # Zoom to California
      setView(
        lng = -119,
        lat = 37,
        zoom = 5.5
      )
    
  })
  
  # Tab 3: Race/Ethnicity Bar Chart 
  output$bar_chart <- renderPlot({
    req(input$county_bar) # Stops execution if no county has been selected yet 
    
    # Keeps only rows matching the user-selected county and where hiv_rate is not NA (removes suppressed/missing groups)
    
    plot_df <- race_long %>%
      filter(county_name == input$county_bar, !is.na(hiv_rate)) %>%
      mutate(race = factor(race, levels = c(
        "Black", "Hispanic", "White", "Asian", "Multiple Races", "NH / Pacific Isl.", "Amer. Indian / AN"
      )))
    
    validate(
      need(nrow(plot_df) > 0,
           paste0("All race/ethnicity rates are suppressed for ",
                  input$county_bar, " County (too few of cases per group where numerator is less than 12)."))
    )
    
    ggplot(plot_df, aes(x = race, y = hiv_rate, fill = race)) +
      geom_col(width = 0.68, show.legend = FALSE) + # legend not needed with x axis 
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
      scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +  #wrap labels
      scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
      labs(
        title    = paste("HIV Diagnosis Rates by Race/Ethnicity —",
                         input$county_bar, "County"),
        subtitle = "Diagnoses per 100,000 population (2023).",
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
  
  output$state_bar_chart <- renderPlot({
    plot_state <- state_race %>%
      mutate(race = factor(race, levels = c(
        "Black", "Hispanic", "White", "Asian",
        "Multiple Races", "NH / Pacific Isl.", "Amer. Indian / AN"
      )))
    ggplot(plot_state, aes(x = race, y = state_rate, fill = race)) +
      geom_col(width = 0.68, show.legend = FALSE) +
      geom_text(
        aes(label = round(state_rate, 1)),
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
      scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +  #wrap labels
      scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
      labs(
        title    = "HIV Diagnosis Rates by Race/Ethnicity — California",
        subtitle = "Statewide average diagnoses per 100,000 population (2023).",
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
