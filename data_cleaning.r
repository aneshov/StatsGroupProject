library(readr)
library(dplyr)
library(visdat)
library(tsibble)

dat <- read_csv("data/raw/tourism.csv")

glimpse(dat)

vis_dat(dat)

# remove contents with "Summe" in MONAT column
dat_clean <- dat %>%
  filter(MONAT != "Summe")

# Convert to YYYYMM string to proper year-month object, using date wouldn't be accurate since we don't know when it was recorded
dat_clean <- dat_clean %>%
  mutate(MONAT = yearmonth(as.character(MONAT), format = "%Y%m"))
