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
