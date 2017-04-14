### install.packages("leaflet")
# to install the development version from Github, run
# devtools::install_github("rstudio/leaflet")

## Adapted from R leaflet tutorial
# https://rstudio.github.io/leaflet/choropleths.html


library(leaflet)
m <- leaflet() %>%
addTiles() %>%  # Add default OpenStreetMap map tiles
addMarkers(lng=-90.2489464, lat=38.6362105, popup="CIC@CET")
m  # Print the map

### Limit zooming on map to keep focus on metro area
m <- leaflet(options = leafletOptions(minZoom = 9, maxZoom = 18)) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-90.24677, lat=38.63621, popup="CIC@CET")
m  # Print the map



library(maps)
mapStates = map("state", fill = TRUE, plot = FALSE)
leaflet(data = mapStates) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)

# with providers
leaflet(data = mapStates) %>% addProviderTiles(provider="Stamen.Toner") %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)

# notice states with multiple pieces
mapStates$names


states <- geojsonio::geojson_read("us-states.geojson", what = "sp")
class(states)
names(states)
states$name


m <- leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addTiles()
m
m %>% addPolygons()

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

m %>% addPolygons(
  fillColor = ~pal(density),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7)

# devtools::install_github("rstudio/leaflet")
#### need devtools version to get highlighting to work

m %>% addPolygons(
fillColor = ~pal(density),
weight = 2,
opacity = 1,
color = "white",
dashArray = "3",
fillOpacity = 0.7,
highlight = highlightOptions(
weight = 5,
color = "#666",
dashArray = "",
fillOpacity = 0.7,
bringToFront = TRUE))


mylabels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)

mylabels


m <- m %>% addPolygons(
  fillColor = ~pal(density),
  weight = 2,
  opacity = 1,
  color = "white",
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#666",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = mylabels,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto"))
m


m %>% addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
                position = "bottomright")


#########

# Adapted from http://leafletjs.com/examples/choropleth/us-states.js
states <- geojsonio::geojson_read("us-states.geojson", what = "sp")

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

mylabels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) %>% lapply(htmltools::HTML)

leaflet(states) %>%
  setView(-96, 37.8, 4) %>%
  addProviderTiles("Stamen.Toner") %>%
  addPolygons(
    fillColor = ~pal(density),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = mylabels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto")) %>%
  addLegend(pal = pal, values = ~density, opacity = 0.7, title = NULL,
            position = "bottomright")


