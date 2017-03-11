# https://github.com/ropenscilabs/tabulizer
# https://www.rdocumentation.org/packages/tabulizer/versions/0.1.22/topics/extract_tables?
# https://ropensci.org/tutorials/tabulizer_tutorial.html

# https://github.com/ropenscilabs/tabulizer#installation
# install.packages("ghit")
# ghit::install_github(c("leeper/tabulizerjars", "leeper/tabulizer"), INSTALL_opts = "--no-multiarch", dependencies = c("Depends", "Imports"))

library("tabulizer")

f <- "http://www.usda.gov/oce/commodity/wasde/Secretary_Briefing.pdf"
d <- "C:/Users/thats/Documents/R/Secretary_Briefing.pdf"
download.file(f, d, mode = "wb")

x <- extract_tables(file = d, pages = 2, guess = TRUE, method = "matrix")
x[[1]][5,2]

y <- extract_tables(file = d, pages = 2, guess = TRUE, method = "data.frame")
yE <- y[[1]]
yM <- yE$X2015.16[[5]]
yE[5,2]