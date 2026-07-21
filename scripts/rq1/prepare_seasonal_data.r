library(dplyr)
library(ggplot2)
library(plotly)
library(tsibble)
library(gt)

toursim_data <- readRDS("data/processed/tourism_clean.rds")

summarise_seasonal_data <- function(data) {
  data %>%
    filter(AUSPRAEGUNG %in% c("Inland", "Ausland")) %>%
    mutate(month = as.integer(format(MONAT, format = "%m"))) %>%
    group_by(month, MONATSZAHL, AUSPRAEGUNG) %>%
    summarise(
      mean_wert = mean(WERT, na.rm = TRUE),
      .groups = "drop"
    )
}

seasonal_data <- toursim_data %>%
  summarise_seasonal_data()

seasonal_data_no_covid <- toursim_data %>%
  filter(!JAHR %in% c(2020, 2021)) %>%
  summarise_seasonal_data()

seasonal_data_only_covid <- toursim_data %>%
  filter(JAHR %in% c(2020, 2021)) %>%
  summarise_seasonal_data()
