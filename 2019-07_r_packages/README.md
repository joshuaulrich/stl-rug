By: Ryan Price

[R](https://www.r-project.org) makes scripting solutions to our data problems incredibly easy. A few lines of code can automate almost anything you can do in Excel, for example. But soon enough in everyone's R journey, they find that their R work is plagued by some of the same issues as their Excel work. Work is spread across a bunch of loose scripts (or one giant one), things break that used to work, fifty-line [`magrittr`](https://cran.r-project.org/package=magrittr) pipelines are impossible to debug, and on and on.

Enter: R package development, an R-native way to solve those pain points. R packages are NOT just for publishing to [CRAN](https://cran.r-project.org)! They can be used any way that you already use R scripts, R Markdown reports, and Shiny Apps, but they can be significantly more robust and easier to debug (once you get the hang of them). R packages are also fundamental to engaging in the "DevOps transformation" buzzterm for R users. They allow your code to be tested, deployed, and managed by continuous integration and deployment tooling, and helps shift the responsibility of "productionalizing" your code from strictly IT to a cross-team effort.

In this workshop-style talk, I hope to scratch the bare minimum of R package development, and to inspire R users to incorporate the practice into their workflows. We will do this by migrating an existing script to an equivalent package structure.

This will be an interactive, follow-along workshop. To make the best use of the time we have together, please make sure you have the following installed/set up in advance:

A recent version of R (>= 3.3.0)

A recent version of the [RStudio IDE](https://www.rstudio.com/products/rstudio/download/)

The following R packages (at least): [`devtools`](https://cran.r-project.org/package=devtools), [`roxygen2`](https://cran.r-project.org/package=roxygen2), [`testthat`](https://cran.r-project.org/package=testthat) (I will also be using some packages from the [`tidyverse`](https://cran.r-project.org/package=tidyverse) and [`forecast`](https://cran.r-project.org/package=forecast) packages in the example package)

[Rtools for Windows](https://cran.r-project.org/bin/windows/Rtools), or a C/Fortran R dev bundle for macOS/Unix-alike [e.g. for Debian-based systems like Ubuntu, you would need the system packages `r-base-dev`, `libssl-dev`, `libcurl4-openssl-dev`,`libgit2-dev`, `libssh2-1-dev`, and `libxml2-dev`; basically whatever you'd need to install the above reqs successfully (i.e. whatever helps to stop throwing 'ANTICONF ERROR's on package install)]

Patience and an open mind :) package development can be frustrating at first, but well worth it!

A developer can create & maintain R packages however they please, even without the listed tidyverse-adjacent R packages (they just make it easier; R can do package development on its own out-of-the-box), but I will be using the above tools for the workshop.
