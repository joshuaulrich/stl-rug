By: Cindy Traub

This presentation will be a crash intro in spatial data formats and tools for making maps in R. We will show how to create a plot of public transportation in St. Louis based on Google transit feed data, and how to use data from a shapefile of St. Louis county municipality boundaries within R.

Slides, code, and links to data can be found here: http://libguides.wustl.edu/R/spatial
... and are reproduced below.

----

## Tools for using spatial data within R

Slides, code, and links from CT's St. Louis R User's Group Meetup talk, March 9, 2017.

###### Links

* General Transit Specification Feed (GTFS) Data for [Metro Transit - St. Louis](https://www.metrostlouis.org/developer-resources/).
* Tutorials and documentation for using [Leaflet in R](https://rstudio.github.io/leaflet/) and for the original [leaflet.js javascript library](http://leafletjs.com).
* A list of choices of [basemap styles](http://leaflet-extras.github.io/leaflet-providers/preview/index.html), together with preview images helps you decide which tile server to use.
* [St. Louis County data](http://data.stlouisco.com/) available for public download, including [municipal boundaries](http://data.stlouisco.com/datasets/municipal-boundaries).
* For a detailed presentation of how to make maps within ggplot using ggmap, see this [vignette by Robin Lovelace](https://github.com/Robinlovelace/Creating-maps-in-R/blob/master/vignettes/ggmap.Rmd).
* A description of many useful packages is available in the [Spatial Task View on CRAN](https://CRAN.R-project.org/view=Spatial).
* Robin Lovelace et. al. - [tutorial on visualizing spatial data in R](http://spatial.ly/wp-content/uploads/2013/12/intro-spatial-rl-3.pdf).
* Shapefiles from the [City of St. Louis](http://data.stlouis-mo.gov/downloads.cfm).
* Shapefile of [National Park Boundaries](https://irma.nps.gov/DataStore/Reference/Profile/2224545?lnv=True).

###### Slides and code

* [Slides: Tools for using spatial data within R](./2017MeetupSpatialR.pdf)  
Powerpoint slides from 2017-03-09 talk at Meetup.

* [RMarkdown doc with Mapping Code](./MeetupSpatialR2017.Rmd)  
R code for Meetup talk.

* [RMarkdown HTML output](./MeetupSpatialR2017.html)  

* [Leaflet basics R code](./leafletBasics.R)  
A few snippets of leaflet code.
