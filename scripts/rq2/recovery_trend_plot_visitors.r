library(dplyr)
library(ggplot2)
library(plotly)
library(scales)
library(tsibble)

source("scripts/load_data.r")

# Select monthly total visitor arrivals from 2020 onward
visitor_recovery <- data %>%
  filter(
    MONATSZAHL == "Gäste",
    AUSPRAEGUNG == "insgesamt",
    JAHR >= 2020,
    !is.na(WERT)
  ) %>%
  mutate(
    month_number = format(MONAT, "%m"),
    date = as.Date(paste(JAHR, month_number, "01", sep = "-"))
  ) %>%
  arrange(date) %>%
  mutate(
    hover_actual = paste0(
      "<b>", format(date, "%B %Y"), "</b>",
      "<br>Visitor arrivals: ", comma(WERT)
    )
  )

# Linear trend
visitor_model <- lm(WERT ~ as.numeric(date), data = visitor_recovery)

visitor_trend <- visitor_recovery %>%
  mutate(
    fitted_value = predict(visitor_model),
    hover_trend = paste0(
      "<b>", format(date, "%B %Y"), "</b>",
      "<br>Linear trend: ", comma(round(fitted_value))
    )
  )

p_visitors <- ggplot(visitor_recovery, aes(x = date, y = WERT)) +
  geom_line(
    aes(group = 1, text = hover_actual),
    colour = "#0065BD",
    linewidth = 0.7,
    alpha = 0.8
  ) +
  geom_point(
    aes(text = hover_actual),
    colour = "#0065BD",
    size = 2,
    alpha = 0.9
  ) +
  geom_line(
    data = visitor_trend,
    aes(
      x = date,
      y = fitted_value,
      colour = "Linear trend",
      text = hover_trend,
      group = 1
    ),
    linewidth = 1.2
  ) +
  scale_colour_manual(values = c("Linear trend" = "#F4A000")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(
    labels = label_number(scale_cut = cut_short_scale())
  ) +
  labs(x = NULL, y = NULL, colour = NULL) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank()
  )

visitor_lm <- ggplotly(
  p_visitors,
  tooltip = "text",
  dynamicTicks = TRUE
) %>%
  layout(
    title = list(
      text = "Visitor Arrivals in Munich after COVID-19",
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

    margin = list(t = 85, b = 55, l = 80, r = 30)
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

      // Handles double-click / autorange actions
      if (eventData['xaxis.autorange'] === true) {
        correcting = true;

        Plotly.relayout(el, {
          'xaxis.range': limits,
          'xaxis.autorange': false
        }).then(function() {
          correcting = false;
        });

        return;
      }

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
          ],
          'xaxis.autorange': false
        }).then(function() {
          correcting = false;
        });
      }
    });
  }
  ",
    data = as.character(range(visitor_recovery$date))
  )