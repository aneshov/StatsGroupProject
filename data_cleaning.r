library(readr)
library(dplyr)
library(visdat)
library(tsibble)
library(skimr)

dat <- read_csv("data/raw/tourism.csv")

glimpse(dat)

vis_dat(dat)

# remove contents with "Summe" in MONAT column
dat_clean <- dat %>%
  filter(MONAT != "Summe")

# Convert to YYYYMM string to proper year-month object, using date wouldn't be accurate since we don't know when it was recorded
dat_clean <- dat_clean %>%
  mutate(MONAT = yearmonth(as.character(MONAT), format = "%Y%m"))

skim(dat_clean)

# remove NA from dataset, no record yet of still on going year 2026
dat_clean <- dat_clean %>%
  filter(!is.na(WERT))

# create processed folder for cleaned dataset
write_csv(dat_clean, "data/processed/tousrism_clean.csv")

# save as RDS file for preserving exact column types without need of reformating for analysis
saveRDS(dat_clean, "data/processed/tourism_clean.rds")

# for loading: dat_clean <- readRDS("data/processed/tourism_clean.rds")