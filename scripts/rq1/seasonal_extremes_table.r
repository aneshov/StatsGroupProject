library(dplyr)
library(gt)

source("scripts/rq1/prepare_seasonal_data.r")

seasonal_extremes <- seasonal_data_no_covid %>%
  group_by(MONATSZAHL, AUSPRAEGUNG) %>%
  summarise(
    highest_month = month.name[month[which.max(mean_wert)]],
    highest_value = round(max(mean_wert)),
    lowest_month = month.name[month[which.min(mean_wert)]],
    lowest_value = round(min(mean_wert)),
    .groups = "drop"
  ) %>%
  transmute(
    measure = recode(
      MONATSZAHL,
      "Gäste" = "Guests",
      "Übernachtungen" = "Overnight stays"
    ),
    origin = recode(
      AUSPRAEGUNG,
      "Inland" = "Domestic",
      "Ausland" = "International"
    ),
    highest_month,
    highest_value,
    lowest_month,
    lowest_value
  )

seasonal_extremes_table <- seasonal_extremes %>%
  gt() %>%
  tab_header(
    title = "Highest and lowest tourism months",
    subtitle = "Monthly averages excluding 2020 and 2021"
  ) %>%
  cols_label(
    measure = "Tourism measure",
    origin = "Visitor origin",
    highest_month = "Highest month",
    highest_value = "Highest average",
    lowest_month = "Lowest month",
    lowest_value = "Lowest average"
  ) %>%
  fmt_number(
    columns = c(highest_value, lowest_value),
    decimals = 0,
    use_seps = TRUE
  ) %>%
  tab_options(
    table.font.size = px(14),
    heading.title.font.size = px(18),
    heading.subtitle.font.size = px(13),
    column_labels.font.weight = "bold",
    row.striping.include_table_body = TRUE
  )
