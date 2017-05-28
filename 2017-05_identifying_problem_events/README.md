By: Ryan Metcalf
Ryan Metcalf
Daugherty Business Solutions

Ryan will share his experience of performing analysis to find event sequences in data, and then creating an application to allow business users to explore the same data.

Ryan built a shiny app that provides users with summary data on problem events in operational data. The app also allows the user to target and mine for event sequences leading up to a problem event.

R packages covered are: [dplyr](https://CRAN.R-project.org/package=dplyr), [datatable](https://CRAN.R-project.org/package=datatable), [xts](https://CRAN.R-project.org/package=xts), and [shiny](https://CRAN.R-project.org/package=shiny).

In order to run the shiny app, you need to:
1. Clone this repo, or download the following files and put them in one directory:
    - [DISTRIBUTION.csv](./DISTRIBUTION.csv)
    - [machine_error_subset.R](./machine_error_subset.R)
    - [server.R](./server.R)
    - [ui.R](./ui.R) 
2. Load the data and all the app functions by executing the machine_error_subset.R script.
3. Put the ui.R and server.R files in the same directory.
4. Set your working directory to the folder you put the ui.R and server.R files in.
5. On the command line, execute `runapp()`.

