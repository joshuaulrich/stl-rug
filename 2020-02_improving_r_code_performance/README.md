Improving R Code Performance

By: Ehsan Jahanpour

[R](https://www.r-project.org) was initially developed for data analysis and statistics in 1993. Since then, it has gained a lot of use from academia & industry. The user-friendly & open-source [RStudio](https://rstudio.com/) IDE made the programming language even more popular. Nowadays, there are a lot of applications, dashboards and APIs are developed in R using [shiny](https://cran.r-project.org/package=shiny), [plotly](https://cran.r-project.org/package=plotly), [plumber](https://cran.r-project.org/package=plumber) and lot of other packages.

However, as data size getting bigger and messier, we would need to use additional techniques and packages to improve the coding and pay more attention to how R interacts with our system resources. In this meetup, I will explain different programming techniques for reading in and searching through datasets as they get bigger. Also, I will discuss on how [profiling](https://en.wikipedia.org/wiki/Profiling_(computer_programming)) can be useful in R to find the bottlenecks and pay attention to the part of the script that matters the most.

As a meetup spoiler, I will use the [profvis](https://cran.r-project.org/package=profvis) package for profiling and evaluating the performance of `read.table()` vs [data.table's](https://cran.r-project.org/package=data.table) `fread()` for reading datasets and for-loops vs “apply family” vs [foreach](https://cran.r-project.org/package=foreach) package for looping over objects.

The presentation and supporting files are at https://github.com/ejahanpour/GoodBadUglyInR and the movie shiny app I will use to search in the movies are at https://github.com/ejahanpour/MovieSearchShiny.



