.onLoad <- function(libname, pkgname) {
    # Stop if not run from correct directory
    if (!file.exists("./main.R")) {
        stop(paste0("Script entrypoint 'main.R' requires that your working directory is the R package top-level directory.\n",
                    "       Please run from top-level package directory that contains 'main.R'"))
    }
    loggit::setLogFile("loggit.json", confirm = FALSE)
}
