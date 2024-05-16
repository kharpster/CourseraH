# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(city_weather_bike_df)
  return(city_weather_bike_df)
}

# Create a RShiny server
shinyServer(function(input, output){
  # Define a city list
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  # Test generate_city_weather_bike_data() function
   city_weather_bike_df <- test_weather_data_generation()
  # Create another data frame called `cities_max_bike` with each row contains city location info and max bike
  # prediction for the city
  cities_max_bike <- city_weather_bike_df %>% group_by(CITY_ASCII, LNG, LAT, LABEL, DETAILED_LABEL, BIKE_PREDICTION_LEVEL) %>% summarize(max_bikes = max(BIKE_PREDICTION))
  # Observe drop-down event

  # Then render output plots with an id defined in ui.R
  

  # If All was selected from dropdown, then render a leaflet map with circle markers
  # and popup weather LABEL for all five cities
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), levels = c("small", "medium", "large"))
  city_weather_bike_df <- test_weather_data_generation()
  
  # Create another data frame called `cities_max_bike` with each row containing city location info and max bike prediction for the city
  # Observe drop-down event
  observeEvent(input$city_dropdown, {
    if (input$city_dropdown != 'all') {
      # Render the city overview map
      leafletProxy("city_bike_map") %>% clearMarkers()
      index = which(cities_max_bike$CITY_ASCII == input$city_dropdown)
      leafletProxy("city_bike_map") %>% addCircles(
        lng = cities_max_bike$LNG[index],
        lat = cities_max_bike$LAT[index],
        popup = cities_max_bike$DETAILED_LABEL[index]
      )
      
      output$temp_line <- renderPlot({
        ggplot(
          subset(city_weather_bike_df, CITY_ASCII == input$city_dropdown),
          aes(
            x = FORECASTDATETIME,
            y = TEMPERATURE,
            label = TEMPERATURE,
            group = 1
          )
        ) +
          geom_line(color = "yellow", size = 1.5) +
          geom_point() +
          geom_text() +
          theme(axis.text.x = element_blank())
      })
      
      output$bike_line <- renderPlot({
        ggplot(
          subset(city_weather_bike_df, CITY_ASCII == input$city_dropdown),
          aes(
            x = FORECASTDATETIME,
            y = BIKE_PREDICTION,
            label = TEMPERATURE,
            group = 1
          )
        ) +
          geom_line(color = "light blue", size = 1.5, linetype = "dashed") +
          geom_point})}
                 # If just one specific city was selected, then render a leaflet map with one marker
  # on the map and a popup with DETAILED_LABEL displayed
  else {addCircleMarkers(data = cities_max_bike, lng = cities_max_bike$LNG, lat = cities_max_bike$LAT, 
                         popup = cities_max_bike$LABEL,
                         radius= ~ifelse(cities_max_bike$BIKE_PREDICTION_LEVEL=='small', 6,
                                         ifelse(cities_max_bike$BIKE_PREDICTION_LEVEL=='medium',10, 12),
                         color = ~color_levels(cities_max_bike$BIKE_PREDICTION_LEVEL)))
    
    output$temp_line <- renderPlot({
      ggplot(
        city_weather_bike_df,
        aes(
          x = FORECASTDATETIME,
          y = TEMPERATURE,
          label = TEMPERATURE,
          group = 1
        )
      ) +
        geom_line(color = "yellow", size = 1.5) +
        geom_point() +
        geom_text() +
        theme(axis.text.x = element_blank())
    })
    
    output$bike_line <- renderPlot({
      ggplot(
        city_weather_bike_df,
        aes(
          x = FORECASTDATETIME,
          y = BIKE_PREDICTION,
          label = TEMPERATURE,
          group = 1
        )
      ) +
        geom_line(color = "light blue", size = 1.5, linetype = "dashed") +
        geom_point})}})})
  
