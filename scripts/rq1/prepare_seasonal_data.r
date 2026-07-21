library(dplyr)

source("scripts/load_data.r")

summarise_seasonal_data <- function(tourism_data) {
  tourism_data %>%
    filter(AUSPRAEGUNG %in% c("Inland", "Ausland")) %>%
    mutate(month = as.integer(format(MONAT, format = "%m"))) %>%
    group_by(month, MONATSZAHL, AUSPRAEGUNG) %>%
    summarise(
      mean_wert = mean(WERT, na.rm = TRUE),
      .groups = "drop"
    )
}

seasonal_data <- data %>%
  summarise_seasonal_data()

seasonal_data_no_covid <- data %>%
  filter(!JAHR %in% c(2020, 2021)) %>%
  summarise_seasonal_data()

seasonal_data_only_covid <- data %>%
  filter(JAHR %in% c(2020, 2021)) %>%
  summarise_seasonal_data()
