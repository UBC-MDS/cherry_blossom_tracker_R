library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(plotly)

# Data (wrangled)
raw_trees <- read_csv("data/processed_trees.csv")
raw_trees$BLOOM_START <- as.Date(raw_trees$BLOOM_START, format = "%d /%m /%Y")
raw_trees$BLOOM_END <- as.Date(raw_trees$BLOOM_END, format = "%d /%m /%Y")
raw_trees$CULTIVAR_NAME <- str_to_title(raw_trees$CULTIVAR_NAME)
raw_trees$COMMON_NAME <- str_to_title(raw_trees$COMMON_NAME)

# Setup app and layout/frontend
app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

# Header navigation component
toast <- htmlDiv(
  list(
    dbcButton(
      "About",
      id = "simple-toast-toggle",
      color = "#B665A4",
      className = "mb-3",
      n_clicks = 0,
    )
  )
)

navbar <- dbcNavbarSimple(
  children = list(toast),
  brand = "Vancouver Cherry Blossom Tracker",
  brand_href = "#",
  color = "#B665A4",
  dark = TRUE,
)

# Set option list for menu filters
option_indicator <- function(available_indicators) {
  lapply(
    available_indicators,
    function(available_indicator) {
      list(
        label = available_indicator,
        value = available_indicator
      )
    }
  )
}

# Menu filters
date_picker <- dccDatePickerRange(
  id = "picker_date",
  start_date = as.Date("01/01/2022", format = "%d /%m /%Y"),
  end_date = as.Date("30/05/2022", format = "%d /%m /%Y"),
  min_date_allowed = as.Date("01/01/2022", format = "%d /%m /%Y"),
  max_date_allowed = as.Date("30/05/2022", format = "%d /%m /%Y"),
  start_date_placeholder_text = "Start date",
  end_date_placeholder_text = "End date",
)

drop_hood <- dccDropdown(
  id = "filter_neighbourhood",
  value = "all_neighbourhoods",
  options = c(
    list(list(label = "All neighbourhoods", value = "all_neighbourhoods")),
    option_indicator(unique(raw_trees$NEIGHBOURHOOD_NAME))
  )
)

drop_cultivar <- dccDropdown(
  id = "filter_cultivar",
  value = "all_cultivars",
  options = c(
    list(list(label = "All cultivars", value = "all_cultivars")),
    option_indicator(unique(raw_trees$CULTIVAR_NAME))
  )
)

range_slider <- dccRangeSlider(
  id = "slider_diameter",
  min = 0,
  max = 150,
  value = list(0, 100),
  marks = list(
    "0" = "0cm",
    "150" = "150cm"
  ),
  tooltip = list(placement = "bottom", always_visible = TRUE),
)

app$layout(
  dbcContainer(
    list(
      # About
      dbcToast(
        list(
          htmlA(
            "GitHub",
            href = "https://github.com/UBC-MDS/cherry_blossom_tracker",
            style = list(color = "white", "text-decoration" = "underline"),
          ),
          htmlP(
            "The dashboard was created by Katia Aristova, Gabriel Fairbrother, Chaoran Wang, TZ Yan. It is licensed under the terms of the GNU General Public License v3.0 license. You can find more information in our GitHub repo."
          ),
          htmlA(
            "Data",
            href = "https://opendata.vancouver.ca/explore/dataset/street-trees/",
            style = list(color = "white", "text-decoration" = "underline"),
          ),
          htmlP(
            "The dataset was created by the City of Vancouver and accessed via Vancouver Open Data website."
          ),
          htmlA(
            "Logo",
            href = "https://thenounproject.com/icon/cherry-blossoms-2818017/",
            style = list(color = "white", "text-decoration" = "underline"),
          ),
          htmlP(
            "The cherry blossom logo Cherry Blossoms by Olena Panasovska from NounProject.com"
          )
        ),
        id = "simple-toast",
        header = "About",
        icon = "primary",
        dismissable = TRUE,
        is_open = FALSE
      ),
      # Logo
      dbcContainer(
        dbcContainer(
          list(
            dbcRow(
              list(
                dbcCol(
                  htmlDiv(
                    htmlImg(src = "assets/logo.png", height = "70px")
                  ),
                  id = "logo-img",
                  width = 1,
                  style = list("padding-top" = "5px")
                ),
                dbcCol(
                  navbar,
                  style = list(padding = "0"),
                  width = 11
                )
              )
            )
          ),
          id = "header"
        ),
        id = "header-back"
      ),
      # Navigation Background
      dbcContainer(
        list(
          # Menu bar
          dbcContainer(
            list(
              dbcRow(
                list(
                  dbcCol(
                    list(
                      htmlLabel("Bloom date"),
                      date_picker
                    ),
                    width = 3
                  ),
                  dbcCol(
                    list(
                      htmlLabel("Neighbourhood"),
                      drop_hood
                    ),
                    width = 3
                  ),
                  dbcCol(
                    list(
                      htmlLabel("Tree cultivar (type)"),
                      drop_cultivar
                    ),
                    width = 3
                  ),
                  dbcCol(
                    list(
                      htmlLabel("Tree diameter"),
                      range_slider
                    ),
                    width = 3
                  )
                ),
                id = "menu-bar"
              )
            )
          )
        ),
        id = "nav-back"
      ),
      # Charts
      dbcContainer(
        list(
          dbcRow(
            list(
              dbcCol(
                list(
                  htmlLabel("Blooming timeline"),
                  dccGraph(
                    id = "timeline"
                  )
                )
              )
            )
          )
        )
      )
    ),
    id = "content"
  )
)

# Chart function

timeline_plot <- function(trees_timeline) {
  trees_timeline <- trees_timeline %>%
    filter_at(vars(BLOOM_START, BLOOM_END), any_vars(!is.na(.))) %>%
    distinct(CULTIVAR_NAME, .keep_all = TRUE) %>%
    select(CULTIVAR_NAME, BLOOM_START, BLOOM_END)

  trees_timeline <- trees_timeline %>%
    gather(key = date_type, value = date, -CULTIVAR_NAME) %>%
    inner_join(trees_timeline, by = "CULTIVAR_NAME") %>%
    rename(Start = BLOOM_START, End = BLOOM_END)

  p <- ggplot() +
    geom_line(data = trees_timeline, aes(x = date, y = reorder(CULTIVAR_NAME, -as.numeric(Start)), size = "blue", color = "blue")) +
    scale_color_manual(values = c("#F3B2D2")) +
    scale_x_date(position = "top") +
    theme_classic() +
    theme(legend.position = "none") +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.line=element_blank()
    )

  p <- ggplotly(p + aes(Start = Start, End = End), tooltip = c("Start", "End")) %>% 
    layout(xaxis = list(side = "top"))

  return(p)
}

app$callback(
  output("timeline", "figure"),
  list(
    input("picker_date", "start_date"),
    input("picker_date", "end_date"),
    input("filter_cultivar", "value")
  ),
  function(start_date, end_date, cultivar) {
    # Date input Cleanup
    
    # 
    # if (start_date == "None") {
    #   start_date <- "2022-01-01"
    # }
    #
    # if (end_date == "None") {
    #   end_date <- "2022-05-30"
    # }

    # start_date <- as.Date(start_date)
    # end_date <- as.Date(end_date)

    filtered_trees <- raw_trees

    # Filter by date

    filtered_trees <- filtered_trees %>%
      filter(
        ((BLOOM_START <= start_date) & (BLOOM_END >= start_date)) |
          ((BLOOM_START <= end_date) & (BLOOM_END >= end_date)) |
          ((BLOOM_START <= end_date) & (BLOOM_START >= start_date)) |
          ((BLOOM_END <= end_date) & (BLOOM_END >= start_date))
      )

    # Filter by cultivar
    
    if (cultivar != "all_cultivars") {
      filtered_trees <- filtered_trees %>%
        filter(CULTIVAR_NAME == cultivar)
    }

    timeline <- timeline_plot(filtered_trees)

    return(timeline)
  }
)

app$callback(
  output("simple-toast", "is_open"),
  list(input("simple-toast-toggle", "n_clicks")),
  function(n) {
    if (n > 0) {
      return(TRUE)
    }
    return(FALSE)
  }
)

app$run_server(host = '0.0.0.0')
