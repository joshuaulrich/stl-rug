By: Ryan J. Price

The use cases for [ETL](https://en.wikipedia.org/wiki/Extract,_transform,_load) (extract, transform, load) have rapidly evolved along with the needs of businesses and researchers in the twenty-plus years since the Kimball Group first released [The Data Warehouse Toolkit](https://amzn.to/2NM1RWe) and popularized the need for well-designed ETL processes. The demand for flexibility and expressiveness in data transformation systems has outpaced many SQL-based RDBMS. Communities around tools like [R](https://www.r-project.org), [Python](https://www.python.org/), and [Julia](https://julialang.org/) have rapidly developed robust solutions to these problems.

R often carries a reputation for being a language and software purely for statistical analysis. While loosely true, this also makes R a fantastic native candidate for a tabular data transformation engine. "ETL" need not carry the legacy connotation of "force everything into a star schema, in a data warehouse, using SQL". You can use R and its fantastic library of packages to design robust, production-ready data pipelines leading to and from nearly any system, easily applying any transformation logic in between.

This presentation will be a demonstration of how to design R packages as data transformation and pipeline systems, and how to incorporate business logic into them. We will walk through defining functions that read, clean, manipulate, and write out disparate data sets, and then compose those functions into "main" production scripts.

I will also show you how to wrap your functions around calls to `loggit()`, a [JSON logging package](https://cran.r-project.org/package=loggit) I wrote to capture failures in data and business logic validation. The transformations I will be demonstrating will likely rely on the tidyverse suite of packages, but you can just as well design these pipelines using any libraries of your choosing (data.table, base/stats, etc).

How-to
======

In order to properly follow along with this example, you will need the following
installed:

1. R, and the `devtools` package
1. Required system dependencies for the R package `RPostgres`, which vary by
   platform.
1. RStudio
1. Docker
1. Command-line shell capable of running Bourne shell scripts (e.g. `bash`), to
   launch the target DB Docker container from the included `docker-run.sh`
   script.

Installation
------------

1. Clone in the git repo, and navigate to the appropriate subfolder:

    ```sh
    git clone https://github.com/ryapric/stl_rug.git && cd stl_rug/etl/
    ```

1. Start the Docker container for the target PostgreSQL DB:

    ```sh
    sh docker-run.sh
    ```

1. Pop open a terminal and run `devtools::install()` while inside the package
   directory to install all needed dependencies, and the package itself:

    ```sh
    cd pipeline1/ && Rscript -e 'devtools::install()'
    ```

1. Run the "entrypoint" script to execute the pipeline defined by the R package,
   and hopefully ignore the annoying `RPostgres` warning about unclosed
   connections:

    ```sh
    Rscript main.R
    ```

At any time, you can open RStudio to explore the package contents. In order to
run `main.R`, however, make sure your working directory is set to the package
top-level! (not exactly best-practice; just for this example)

Dataset attribution
-------------------

Data used in the included example SQLite database can be found at & attributed
to [this Kaggle dataset page](https://www.kaggle.com/gregorut/videogamesales).
