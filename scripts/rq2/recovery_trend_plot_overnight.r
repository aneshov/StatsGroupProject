library(dplyr)
library(ggplot2)
library(plotly)
library(scales)

source("scripts/load_data.r")

# Monthly domestic and international overnight stays
tourism_recovery <- data %>%
  filter(
    MONATSZAHL == "Übernachtungen",
    AUSPRAEGUNG %in% c("Inland", "Ausland"),
    JAHR >= 2020,
    !is.na(WERT)
  ) %>%
  mutate(
    month_number = format(MONAT, "%m"),
    date = as.Date(paste(JAHR, month_number, "01", sep = "-")),
    tourism_type = recode(
      AUSPRAEGUNG,
      "Inland" = "Domestic tourism",
      "Ausland" = "International tourism"
    ),
    tourism_type = factor(
      tourism_type,
      levels = c("Domestic tourism", "International tourism")
    ),
    hover_actual = paste0(
      "<b>", format(date, "%B %Y"), "</b>",
      "<br>", tourism_type,
      "<br>Overnight stays: ", comma(WERT)
    )
  ) %>%
  arrange(date, tourism_type)

# Combined monthly total, used for ONE linear trend model
tourism_total <- data %>%
  filter(
    MONATSZAHL == "Übernachtungen",
    AUSPRAEGUNG == "insgesamt",
    JAHR >= 2020,
    !is.na(WERT)
  ) %>%
  mutate(
    month_number = format(MONAT, format = "%m"),
    date = as.Date(paste(JAHR, month_number, "01", sep = "-"))
  ) %>%
  arrange(date)

# Fit one model to total domestic + international overnight stays
combined_model <- lm(WERT ~ as.numeric(date), data = tourism_total)

trend_data <- tourism_total %>%
  mutate(
    fitted_value = predict(combined_model),
    hover_trend = paste0(
      "<b>", format(date, "%B %Y"), "</b>",
      "<br>Combined total linear trend",
      "<br>Fitted overnight stays: ", comma(round(fitted_value))
    )
  )

# Create the chart
p <- ggplot() +
  geom_line(
    data = tourism_recovery,
    aes(
      x = date,
      y = WERT,
      colour = tourism_type,
      group = tourism_type,
      text = hover_actual
    ),
    linewidth = 0.8,
    alpha = 0.85
  ) +
  geom_point(
    data = tourism_recovery,
    aes(
      x = date,
      y = WERT,
      colour = tourism_type,
      text = hover_actual
    ),
    size = 1.8,
    alpha = 0.9
  ) +
  geom_line(
    data = trend_data,
    aes(
      x = date,
      y = fitted_value,
      colour = "Combined linear trend",
      group = 1,
      text = hover_trend
    ),
    linewidth = 1.1,
    linetype = "dashed"
  ) +
  scale_colour_manual(
    values = c(
      "Domestic tourism" = "#0065BD",
      "International tourism" = "#F4A000",
      "Combined linear trend" = "#333333"
    )
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  scale_y_continuous(
    labels = label_number(scale_cut = cut_short_scale())
  ) +
  labs(
    title = NULL,
    x = NULL,
    y = NULL,
    colour = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    panel.grid.minor = element_blank()
  )

# Convert to interactive Plotly chart
overnight_lm <- ggplotly(
  p,
  tooltip = "text",
  dynamicTicks = TRUE
) %>%
  layout(
    title = list(
      text = "Domestic and International Overnight Stays in Munich",
      x = 0.5,
      xanchor = "center",
      font = list(size = 22)
    ),
    
    hovermode = "closest",
    
    xaxis = list(
      title = "",
      type = "date",
      tickmode = "auto",
      tickformatstops = list(
        list(
          dtickrange = list(NULL, "M12"),
          value = "%b<br>%Y"
        ),
        list(
          dtickrange = list("M12", NULL),
          value = "%Y"
        )
      )
    ),
    
    yaxis = list(
      title = "Overnight stays",
      tickformat = "~s"
    ),
    
    showlegend = TRUE,
    
    legend = list(
      orientation = "v",
      x = 0.02,
      xanchor = "left",
      y = 0.95,
      yanchor = "top",
      bgcolor = "rgba(255,255,255,0.88)",
      bordercolor = "rgba(0,0,0,0.20)",
      borderwidth = 1,
      font = list(size = 11),
      itemsizing = "constant",
      itemclick = "toggle",
      itemdoubleclick = "toggleothers"
    ),
    
    margin = list(
      t = 85,
      b = 60,
      l = 80,
      r = 30
    )
  ) %>%
  config(
    scrollZoom = TRUE,
    displayModeBar = FALSE,
    responsive = TRUE
  ) %>%
  htmlwidgets::onRender(
    "
    function(el, x, limits) {

      const minDate = new Date(limits[0]).getTime();
      const maxDate = new Date(limits[1]).getTime();
      let correcting = false;

      el.on('plotly_relayout', function(eventData) {
        if (correcting) return;

        const startValue = eventData['xaxis.range[0]'];
        const endValue = eventData['xaxis.range[1]'];

        if (startValue === undefined || endValue === undefined) return;

        const start = new Date(startValue).getTime();
        const end = new Date(endValue).getTime();

        const newStart = Math.max(start, minDate);
        const newEnd = Math.min(end, maxDate);

        if (newStart !== start || newEnd !== end) {
          correcting = true;

          Plotly.relayout(el, {
            'xaxis.range': [
              new Date(newStart).toISOString(),
              new Date(newEnd).toISOString()
            ]
          }).then(function() {
            correcting = false;
          });
        }
      });
    }
    ",
    data = as.character(range(tourism_recovery$date))
  )