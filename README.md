# Statistical Analysis of Munich's Tourism

This dataset contains monthly aggregated counts of tourist arrivals ("Gäste") and overnight stays ("Übernachtungen") in Munich, Germany, recorded from 2006 to 2026. The data is split by domestic ("Inland") and international ("Ausland") visitors

[![Dataset](https://img.shields.io/badge/Data-M%C3%BCnchen%20Open%20Data%20Portal-005a9c?logo=opendata&logoColor=white)](https://opendata.muenchen.de/dataset/monatszahlen-tourismus/resource/4f00274a-ef75-41e5-b5c1-15f22c9f8a12)
[![License: dl-de/by-2-0](https://img.shields.io/badge/License-dl--de%2Fby--2.0-blue.svg)](https://www.govdata.de/dl-de/by-2-0)
[![Website](https://img.shields.io/badge/Website-Live%20Project-2ea44f?logo=githubpages&logoColor=white)](https://aneshov.github.io/StatsGroupProject/)

## Variable Dictionary

| Variable | Type | Description |
|------------------------|------------------------|------------------------|
| `_id` | numeric | Unique row identifier |
| `MONATSZAHL` | character | Type of tourism metric (`Gäste` = guest arrivals, `Übernachtungen` = overnight stays) |
| `AUSPRAEGUNG` | character | Origin of the visitors (`Inland` = domestic, `Ausland` = international, `insgesamt` = total) |
| `JAHR` | numeric | Year of observation |
| `MONAT` | character | Month of observation in `YYYYMM` format, or `Summe` for annual totals |
| `WERT` | numeric | The absolute count of tourists or stays for the given month/year |
| `VORJAHRESWERT` | numeric | The count recorded in the exact same month of the previous year |
| `VERAEND_VORMONAT_PROZENT` | numeric | Percentage change compared to the immediate previous month |
| `VERAEND_VORJAHRESMONAT_PROZENT` | numeric | Percentage change compared to the same month in the previous year |
| `ZWOELF_MONATE_MITTELWERT` | numeric | 12-month rolling average |

## Research Questions

1. How do monthly tourism patterns in Munich vary across the year, and which months show the highest and lowest tourism activity?
2. How did Munich tourism change during the COVID-19 period, and how did domestic and international tourism recover afterwards?

## Group Members

| Name | GitHub username |
|------|-----------------|
|Aleksandar Neshov       |aneshov                |
|Alexander Toropov       |Ell3x                  |
|Dinh Marcus Nguyen      |MarcuZSz               |

## Repository Structure

```text
StatsGroupProject/               # files regarding the overall project
├── .github/
│   └── workflows/               # GitHub Actions workflow to render and deploy the website
├── data/                        # Original and cleaned data used for analysis and visualisations
│   ├── raw/                     
│   ├── processed/               
├── pages/                       # qmd files for the website
├── renv/                        # Project-specific R package environment
└── scripts/                     # scripts in R eg. data_cleaning etc.

```

## How to reproduce

```bash
git clone https://github.com/aneshov/StatsGroupProject
cd StatsGroupProject
```

```r
renv::restore()   # if using renv, otherwise install packages manually
```
