require(leaflet)
library(shiny)
library(ggplot2)
library(leaflet)
library(tidyverse)
library(httr)
library(scales)
cities <- read.csv("selected_cities.csv")
choices <- c("All", "Seoul", "Suzhou", "London", "New York", "Paris")
# Create a RShiny UI
shinyUI(fluidPage(
    padding = 5,
    titlePanel("Bike-sharing demand prediction app"), 
    sidebarLayout(
      mainPanel(
        leafletOutput('city_bike_map', height = 1000)
      ),
      sidebarPanel(
        selectInput(
          inputId = 'City_dropdown',
          label = 'Cities',
          choices = c('all', 'Seoul', 'New York', 'Paris', 'London', 'Suzhou')
        ),
        plotOutput('temp_line', width = 575, height = 250),
        plotOutput('bike_line', click = 'plot_click', width = 575, height = 250),
        verbatimTextOutput('bike_date_output'),
        plotOutput('humidity_pred_chart', width = 575, height = 250)
      )
    )
  )
)
