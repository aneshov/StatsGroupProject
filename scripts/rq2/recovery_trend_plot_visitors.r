library(dplyr)
library(ggplot2)
library(plotly)
library(scales)
library(tsibble)

source("scripts/load_data.r")

# Monthly domestic and international visitor arrivals
visitor_recovery <- data %>%
  filter(
    MONATSZAHL == "Gäste",
    AUSPRAEGUNG %in% c("Inland", "Ausland"),
    JAHR >= 2020,
    !is.na(WERT)
  ) %>%
  mutate(
    date = as.Date(MONAT),
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
      "<br>Visitor arrivals: ", comma(WERT)
    )
  ) %>%
  arrange(date, tourism_type)

# Monthly domestic visitor arrivals, used for ONE linear trend model
visitor_domestic <- data %>%
  filter(
    MONATSZAHL == "Gäste",
    AUSPRAEGUNG == "Inland",
    JAHR >= 2020,
    !is.na(WERT)
  ) %>%
  mutate(
    date = as.Date(MONAT)
  ) %>%
  arrange(date)

# Monthly international visitor arrivals, used for ONE linear trend model
visitor_international <- data %>%
  filter(
    MONATSZAHL == "Gäste",
    AUSPRAEGUNG == "Ausland",
    JAHR >= 2020,
    !is.na(WERT)
  ) %>%
  mutate(
    date = as.Date(MONAT)
  ) %>%
  arrange(date)

# Fit one model to domestic visitor arrivals
domestic_visitor_model <- lm(WERT ~ as.numeric(date), data = visitor_domestic)

visitor_domestic_trend <- visitor_domestic %>%
  mutate(
    tourism_type = "Domestic linear trend",
    fitted_value = predict(domestic_visitor_model),
    hover_trend = paste0(
      "<b>", format(date, "%B %Y"), "</b>",
      "<br>Domestic linear trend",
      "<br>Fitted visitor arrivals: ", comma(round(fitted_value))
    )
  )

# Fit one model to international visitor arrivals
international_visitor_model <- lm(WERT ~ as.numeric(date), data = visitor_international)

visitor_international_trend <- visitor_international %>%
  mutate(
    tourism_type = "International linear trend",
    fitted_value = predict(international_visitor_model),
    hover_trend = paste0(
      "<b>", format(date, "%B %Y"), "</b>",
      "<br>International linear trend",
      "<br>Fitted visitor arrivals: ", comma(round(fitted_value))
    )
  )

# Create chart
p_visitors <- ggplot() +
  geom_line(
    data = visitor_recovery,
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
    data = visitor_recovery,
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
    data = visitor_domestic_trend,
    aes(
      x = date,
      y = fitted_value,
      colour = tourism_type,
      group = 1,
      text = hover_trend
    ),
    linewidth = 1.1,
    linetype = "dashed"
  ) +
  geom_line(
    data = visitor_international_trend,
    aes(
      x = date,
      y = fitted_value,
      colour = tourism_type,
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
      "Domestic linear trend" = "#000000",
      "International linear trend" = "#7A7A7A"
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
visitor_lm <- ggplotly(
  p_visitors,
  tooltip = "text",
  dynamicTicks = TRUE
) %>%
  layout(
    title = list(
      text = "Domestic and International Visitor Arrivals in Munich",
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
      title = "Visitor arrivals",
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
    data = as.character(range(visitor_recovery$date))
  )