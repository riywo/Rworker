library('rjson')

args <- fromJSON(commandArgs(trailingOnly = TRUE)[1])

rworker_return <- function(method, data) {
    cat(paste("Rworker::", method, " ", toJSON(data), "\n", sep = ''))
}

rworker_log <- function(data) {
    cat(paste("Rworker::Log ", data, "\n", sep = ''))
}

rworker_upload <- function(url, key, file) {
    data <- list()
    data$url <- url
    data$key <- key
    data$file <- file

    rworker_return("Upload", data)

    result <- rworker_wait_message()
    result$status
}

rworker_download <- function(url) {
    data <- list()
    data$url <- url

    rworker_return("Download", data)

    result <- rworker_wait_message()
    result$file
}

rworker_wait_message <- function() {
    fifo <- fifo(args$fifo, open = 'read', blocking = TRUE)
    message <- readLines(fifo, n=1)
    rworker_log(paste("1 message received [", message, "]"))
    close(fifo)

    fromJSON(message)
}

