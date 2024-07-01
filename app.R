library(shiny)
library(DT)
library(dplyr)
library(slickR)
library(ggplot2)
library(plotly)
library(tidyr)
library(markdown)
library(shinythemes)

lapply(list.files(file.path('R'), full.names = TRUE), function(d){source(d)})


allJSON <- list.files(file.path('race_data'),
                      pattern = 'data.json',
                      full.names = TRUE, recursive = TRUE)


allRaces <<- lapply(allJSON, function(d){
  d <- jsonlite::fromJSON(d)
  d$breakdown <- NULL
  d$details <- NULL
  d <- as.data.frame(d)
  d
}) %>%
  dplyr::bind_rows() %>%
  mutate(race_dir = dirname(allJSON))

candidates <- unique(allRaces$type)
candidates <- candidates[candidates %in% c("run",
                                           "sprint triathlon",
                                           "standard triathlon",
                                           "aquathlon",
                                           "bike",
                                           "swim",
                                           "sprint duathlon",
                                           "triathlon")]

trends <<- allRaces %>%
  filter(!is.na(time)) %>%
  filter(!is.na(date)) %>%
  filter(type %in% candidates) %>%
  group_by(type, distance) %>%
  summarise(events_count = n()) %>%
  filter(events_count > 1)

shinyApp(ui, server)
