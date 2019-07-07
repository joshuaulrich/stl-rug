R Package to Generate Forecasts of Federal Reserve Economic Data (FRED)
=======================================================================

This repository is an R package that contains funcitonality to generate
forecasts of FRED data. It retrieves the chosen data from FRED, generates a
forecast series, appends it to the original data, and writes the output to a
database table. This is a very rough, incomplete example (it still relies on
user adjustment for series frequency, for example), but it serves as a
demonstration of how to take a script (`main_original.R`) and convert it into a
package structure instead (with `main.R` as the caller).

How to Use
----------

1. Install the package via `devtools::install()`, or `make install`, from the
   repo top-level.

1. In `main.R`, populate a FRED series ID, its frequency, and its forecast
   length (`h`). You can search for valid FRED series IDs
   [here](https://fred.stlouisfed.org/tags/series).

1. Run `main.R`. The written DB table will be named "fcast_<fred_id>".

You can review what this package code looked like as a non-package script by
inspecting the `main_original.R` file.

Slides for Package Development Reference
----------------------------------------

Please review [this presentation
deck](https://docs.google.com/presentation/d/1Y6KmN16cZoBc28FBvph4r-BJiJl1APIW9vLxrrq6Nj8/edit?usp=sharing)
for a concise guide of how an R package is structured. A static version of
this presentation is also located one level up in this repository, at the
`r_packages` folder top-level.
