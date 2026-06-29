# Project Title

> Replace this with a short description of your project and dataset.

## Research Questions

1. How do monthly tourism patterns in Munich vary across the year, and which months show the highest and lowest tourism activity?
2. How did Munich tourism change during the COVID-19 period, and how did domestic and international tourism recover afterwards?
3. How do domestic and international tourism differ in their long-term trends and seasonal patterns?

## Dataset

- **Source:** https://opendata.muenchen.de/dataset/monatszahlen-tourismus/resource/4f00274a-ef75-41e5-b5c1-15f22c9f8a12
- **Licence:** Datenlizenz Deutschland Namensnennung 2.0 (dl-by-de)
- **Description:** The dataset contains monthly counts of guests and overnight stays in Munich, split by domestic and international visitors.
  
                    The key variables are:

                    MONATSZAHL: metric type (guests or overnight stays)
                    AUSPRAEGUNG: visitor origin (domestic / international)
                    JAHR: year of observation
                    MONAT: month of observation
                    WERT: the monthly count



## Group Members

| Name | GitHub username |
|------|----------------|
|Aleksandar Neshov      |aneshov                |
|Alexander Toropov      |Ell3x                |
|Dinh Marcus Nguyen      |MarcuZSz                |

## Repository Structure

```
data/raw/        read-only raw data and licence documentation
data/processed/  cleaned data produced by code/02_clean.R
code/            numbered R scripts (01 download → 02 clean → 03 EDA → 04 analysis)
docs/            rendered Quarto website output (auto-generated, do not edit)
proposal.qmd     W07 project proposal
report.qmd       final analysis report
```

## How to reproduce

```r
# 1. Install dependencies
renv::restore()   # if using renv, otherwise install packages manually

# 2. Run the pipeline in order
source("code/01_download.R")
source("code/02_clean.R")
source("code/03_eda.R")
source("code/04_analysis.R")

# 3. Render the website
quarto::quarto_render()
```
