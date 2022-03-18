library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(ggplot2)
library(plotly)

# For Maps
library(broom)
library(rgdal)

# Data (wrangled)
raw_trees <- read_csv("data/processed_trees.csv")
raw_trees$BLOOM_START <- as.Date(raw_trees$BLOOM_START, format = "%d /%m /%Y")
raw_trees$BLOOM_END <- as.Date(raw_trees$BLOOM_END, format = "%d /%m /%Y")
raw_trees$CULTIVAR_NAME <- str_to_title(raw_trees$CULTIVAR_NAME)
raw_trees$COMMON_NAME <- str_to_title(raw_trees$COMMON_NAME)
raw_trees$DIAMETER_CM <- raw_trees$DIAMETER * 2.54

# geojson
url_geojson <- "https://raw.githubusercontent.com/UBC-MDS/cherry_blossom_tracker/main/data/vancouver.geojson"
geojson <- rgdal::readOGR(url_geojson)
geojson2 <- broom::tidy(geojson, region = "name")

# Setup app and layout/frontend
app <- Dash$new(external_stylesheets = list(
  "https://fonts.googleapis.com/css2?family=Montserrat:wght@300&display=swap",
  dbcThemes$BOOTSTRAP))

app$title("Vancouver Cherry Blossom Tracker")

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
  list <- lapply(
    available_indicators,
    function(available_indicator) {
      list(
        label = available_indicator,
        value = available_indicator
      )
    }
  )
  ordered_list <- list[order(sapply(list,'[[',1))]
  
  return (ordered_list)
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
  options = option_indicator(unique(raw_trees$NEIGHBOURHOOD_NAME)),
  value = list(),
  placeholder = "Select neighbourhoods",
  clearable = TRUE,
  searchable = TRUE,
  multi = TRUE
)

drop_cultivar <- dccDropdown(
  id = "filter_cultivar",
  options = option_indicator(unique(raw_trees$CULTIVAR_NAME)),
  value = list(),
  placeholder = "Select cultivars",
  clearable = TRUE,
  searchable = TRUE,
  multi = TRUE
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
                  htmlLabel("Cherry blossom tree map"),
                  dbcCol(
                    list(
                      dccLoading(
                          id = "loading-1",
                          type = "circle",
                          children = dccGraph(id = "streetmap"),
                          color = "#B665A4"
                      )
                    )
                  )
                ),
                width = 12,
                id = "row-map"
              )
            )
          ),
          dbcRow(
            list(
              dbcCol(
                list(
                  htmlLabel("Tree cultivars (types)"),
                  # Start of placeholder for GABE
                  dccLoading(
                      id = "loading-2",
                      type = "circle",
                      children = dccGraph(
                          id = "cultivar"
                      ),
                      color = "#B665A4"
                  )
                  
                  # End of placeholder
                ),
                width = 6,
                className = "chart-box"
              ),
              dbcCol(
                list(
                  htmlLabel("Blooming timeline"),
                  dccLoading(
                      id = "loading-3",
                      type = "circle",
                      children = dccGraph(
                          id = "timeline"
                      ),
                      color = "#B665A4"
                  )
                ),
                width = 6,
                className = "chart-box"
              )
            ),
            className = "row-chart"
          ),
          dbcRow(
            list(
              dbcCol(
                list(
                  htmlLabel("Tree diameters"),
                  dccLoading(
                      id = "loading-4",
                      type = "circle",
                      children = dccGraph(
                          id = "diameter"
                      ),
                      color = "#B665A4"
                  )
                ),
                width = 6,
                className = "chart-box"
              ),
              dbcCol(
                list(
                  htmlLabel("Tree density"),
                  dccLoading(
                      id = "loading-5",
                      type = "circle",
                      children = dccGraph(
                          id = "density"
                      ),
                      color = "#B665A4"
                  )
                ),
                width = 6,
                className = "chart-box"
              )
            ),
            className = "row-chart"
          )
        )
      )
    ),
    id = "content"
  )
)

# Functions
##common function for filtering
filter_trees <- function(start_date, end_date, neighbourhood, cultivar, diameter) {
    filtered_trees <- raw_trees
    
    # Filter by date
    
    filtered_trees <- filtered_trees %>%
        filter(
            ((BLOOM_START <= start_date) & (BLOOM_END >= start_date)) |
                ((BLOOM_START <= end_date) & (BLOOM_END >= end_date)) |
                ((BLOOM_START <= end_date) & (BLOOM_START >= start_date)) |
                ((BLOOM_END <= end_date) & (BLOOM_END >= start_date))
        )
    
    # Filter by neighborhood
    
    if (length(neighbourhood) != 0) {
        filtered_trees <- filtered_trees %>%
            filter(NEIGHBOURHOOD_NAME %in% neighbourhood)
    }
    
    # Filter by cultivar
    
    if (length(cultivar) != 0) {
        filtered_trees <- filtered_trees %>%
            filter(CULTIVAR_NAME %in% cultivar)
    }
    
    # Diameter slider
    
    filtered_trees <- filtered_trees %>%
        filter((DIAMETER_CM > diameter[1]) & (DIAMETER_CM < diameter[2]))
    
    return(filtered_trees)
}

# Street map
street_map_plot <- function(df) {
    # https://github.com/plotly/plotly.R/issues/1548#issuecomment-582042676
    df_list <- split(df %>%
                         select(COMMON_NAME,
                                NEIGHBOURHOOD_NAME,
                                DIAMETER,
                                TREE_ID), seq_len(nrow(df)))
    
    fig <- df %>%
        plot_ly(
            lat = ~lat,
            lon = ~lon,
            marker = list(color = "#B665A4"),
            type = 'scattermapbox',
            customdata = df_list,
            hovertemplate = paste('Type: %{customdata.COMMON_NAME}<br>',
                                  'Neighbourhood: %{customdata.NEIGHBOURHOOD_NAME}<br>',
                                  'Diameter(cm): %{customdata.DIAMETER:.2f}<br>',
                                  'Tree ID: %{customdata.TREE_ID}<extra></extra>'
            )
        )
    
    fig <- fig %>%
        layout(
            mapbox = list(
                style = 'open-street-map',
                zoom = 10,
                center = list(lat=49.24, lon =-123.11)
            )
        )
    
    return(fig)
}

# Denstiy map plot
density_plot <- function(df) {
    geojson2 <- geojson2 %>%
        left_join(df %>% count(NEIGHBOURHOOD_NAME,
                               name = "No. of trees"),
                  by = c("id" = "NEIGHBOURHOOD_NAME"))
    
    fig_cho <- ggplot() +
        geom_polygon(data = geojson2, 
                     aes(x = long, y = lat, group = group, fill = `No. of trees`)) +
        scale_fill_distiller(palette = "RdPu") +
        coord_map() +
        labs(x = "", y = "")
    
    return(ggplotly(fig_cho))
}

# Timeline Plot Code
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

# "Cultivar Count Plot Code"
bar_plot <- function(trees_count) {
    #trees_count <- trees_count %>%
    
    #select(CULTIVAR_NAME, BLOOM_START, BLOOM_END,  DIAMETER, NEIGHBOURHOOD_NAME)
    
    p <- ggplot() + 
        geom_bar(data = trees_count, aes( y = fct_rev(forcats::fct_infreq(CULTIVAR_NAME))), fill = "#F3B2D2") +
        #theme_classic() +
        theme(legend.position = "none") +
        theme(
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.line=element_blank()
        )
    
    #p <- ggplotly(p + aes(Start = Start, End = End), tooltip = c("Start", "End")) %>%
    #  layout(xaxis = list(side = "top"))
    
    return(ggplotly(p,  tooltip = 'count'))
}

# "Tree Diameter Plot Code"
diameter_plot <- function(trees_diam) {
    trees_diam <- trees_diam %>%
        drop_na(DIAMETER_CM)
    
    mean_diam <- round(mean(trees_diam$DIAMETER_CM), 2)
    
    diam <- ggplot(trees_diam) +
        aes(x = DIAMETER_CM,
            text = paste0("Mean diameter: ", mean_diam)) +
        geom_density(fill = "#F3B2D2", alpha = 0.4, size = 1, color = "#d982ad") +
        labs(y = "Density", x = "Tree diameter (cm)") +
        scale_x_continuous(limits = c(0, 150)) +
        theme(axis.text.y = element_blank())
    
    return(ggplotly(diam, tooltip = 'text'))
}

# "Cultivar Callback"
app$callback(
    output("cultivar", "figure"),
    list(
        input("picker_date", "start_date"),
        input("picker_date", "end_date"),
        input("filter_neighbourhood", "value"),
        input("filter_cultivar", "value"),
        input("slider_diameter", "value")
    ),
    function(start_date, end_date, cultivar,  neighbourhood,  diameter) {
        
        filtered_trees <- filter_trees(start_date, end_date, cultivar,  neighbourhood,  diameter)
        barplot <- bar_plot(filtered_trees)
        
        return(barplot)
    }
)

# "Diameter Callback"
app$callback(
    output("diameter", "figure"),
    list(
        input("picker_date", "start_date"),
        input("picker_date", "end_date"),
        input("filter_neighbourhood", "value"),
        input("filter_cultivar", "value"),
        input("slider_diameter", "value")
    ),
    function(start_date, end_date, neighbourhood, cultivar, diameter) {
        filtered_trees <- filter_trees(start_date, end_date, neighbourhood, cultivar, diameter)
        
        diameter <- diameter_plot(filtered_trees)
        
        return(diameter)
    }
)

# Timeline Callback
app$callback(
    output("timeline", "figure"),
    list(
        input("picker_date", "start_date"),
        input("picker_date", "end_date"),
        input("filter_neighbourhood", "value"),
        input("filter_cultivar", "value"),
        input("slider_diameter", "value")
    ),
    function(start_date, end_date, neighbourhood, cultivar, diameter) {
        filtered_trees <- filter_trees(start_date, end_date, neighbourhood, cultivar, diameter)
        
        timeline <- timeline_plot(filtered_trees)
        
        return(timeline)
    }
)

# Street map Callback
app$callback(
    output("streetmap", "figure"),
    list(
        input("picker_date", "start_date"),
        input("picker_date", "end_date"),
        input("filter_neighbourhood", "value"),
        input("filter_cultivar", "value"),
        input("slider_diameter", "value")
    ),
    function(start_date, end_date, neighbourhood, cultivar, diameter) {
        filtered_trees <- filter_trees(start_date, end_date, neighbourhood, cultivar, diameter)
        
        streetmap <- street_map_plot(filtered_trees)
        
        return(streetmap)
    }
)

# Density map Callback
app$callback(
    output("density", "figure"),
    list(
        input("picker_date", "start_date"),
        input("picker_date", "end_date"),
        input("filter_neighbourhood", "value"),
        input("filter_cultivar", "value"),
        input("slider_diameter", "value")
    ),
    function(start_date, end_date, neighbourhood, cultivar, diameter) {
        filtered_trees <- filter_trees(start_date, end_date, neighbourhood, cultivar, diameter)
        
        density <- density_plot(filtered_trees)
        
        return(density)
    }
)

# Toast Callback
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
# app$run_server(debug = T)

