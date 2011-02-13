library('rjson')

rworker_args <- function () {
    fromJSON(commandArgs(trailingOnly = TRUE)[1])
}

rworker_return <- function(data) {
    cat(paste("Rworker:", toJSON(data), "\n"))
}

rworker_end <- function() {
    data <- list()
    data$success <- 1
    rworker_return(data)
}

