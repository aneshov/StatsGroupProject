library(dplyr)
library(ggplot2)
library(plotly)

source("scripts/rq1/prepare_seasonal_data.r")

baseline_data <- seasonal_data_no_covid %>%
  select(
    month,
    MONATSZAHL,
    AUSPRAEGUNG,
    baseline_wert = mean_wert
  )

plot_data <- bind_rows(
  "All years" = seasonal_data,
  "Without COVID-19" = seasonal_data_no_covid,
  "COVID-19 only" = seasonal_data_only_covid,
  .id = "period"
) %>%
  left_join(
    baseline_data,
    by = c("month", "MONATSZAHL", "AUSPRAEGUNG")
  ) %>%
  mutate(
    period = factor(
      period,
      levels = c(
        "All years",
        "Without COVID-19",
        "COVID-19 only"
      )
    ),
    measure = factor(
      recode(
        MONATSZAHL,
        "Gäste" = "Guests",
        "Übernachtungen" = "Overnight stays"
      ),
      levels = c("Guests", "Overnight stays")
    ),
    origin = recode(
      AUSPRAEGUNG,
      "Inland" = "Domestic",
      "Ausland" = "International"
    ),
    series = paste(origin, period, sep = " — "),
    change_from_baseline = 100 * (mean_wert / baseline_wert - 1)
  )

covid_comparison_plot <- ggplot(
  plot_data,
  aes(
    x = month,
    y = mean_wert,
    color = series,
    group = series,
    text = paste0(
      "Measure: ", measure,
      "<br>Origin: ", origin,
      "<br>Period: ", period,
      "<br>Month: ", month.name[month],
      "<br>Average: ", scales::comma(round(mean_wert)),
      "<br>Difference from non-COVID baseline: ",
      scales::percent(change_from_baseline / 100, accuracy = 0.1)
    )
  )
) +
  geom_line(linewidth = 0.9) +
  facet_wrap(
    ~measure,
    scales = "free_y",
    ncol = 2
  ) +
  scale_x_continuous(
    breaks = 1:12,
    labels = month.abb,
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ",")
  ) +
  scale_color_manual(
    values = c(
      "International — All years" = "#4E79A7",
      "International — Without COVID-19" = "#86BCDB",
      "International — COVID-19 only" = "#2F5D8A",
      "Domestic — All years" = "#F28E2B",
      "Domestic — Without COVID-19" = "#FFBE7D",
      "Domestic — COVID-19 only" = "#E86A17"
    )
  ) +
  labs(
    title = "Monthly tourism patterns in Munich",
    subtitle = "Hover for details; click legend entries to hide or show series",
    x = "Month",
    y = "Average tourism activity",
    color = "Origin and period"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold", size = 10),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 8),
    axis.text.x = element_text(size = 7, angle = 45, hjust = 1),
    legend.position = "bottom",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    plot.title = element_text(size = 13),
    plot.subtitle = element_text(size = 9),
    plot.title.position = "plot",
    plot.margin = margin(8, 8, 8, 8),
    panel.spacing.x = grid::unit(0.3, "lines")
  )

interactive_plot <- ggplotly(
  covid_comparison_plot,
  tooltip = "text",
  dynamicTicks = FALSE,
  height = 520
)

interactive_plot <- plotly::layout(
  interactive_plot,
  autosize = TRUE,
  hovermode = "closest",
  margin = list(l = 55, r = 10, b = 135, t = 70),
  legend = list(
    orientation = "h",
    x = 0.5,
    xanchor = "center",
    y = -0.25,
    yanchor = "top",
    font = list(size = 10),
    groupclick = "togglegroup",
    itemclick = "toggle",
    itemdoubleclick = "toggleothers"
  )
)

interactive_plot <- plotly::config(
  interactive_plot,
  displaylogo = FALSE,
  responsive = TRUE
)
