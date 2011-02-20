library('rjson')

args <- fromJSON(commandArgs(trailingOnly = TRUE)[1])

rworker_return <- function(method, data) {
    cat(paste("Rworker::", method, " ", toJSON(data), "\n", sep = ''))
}

rworker_log <- function(data) {
    cat(paste("Rworker::Log ", data, "\n", sep = ''))
}

rworker_upload <- function(uri, key, file) {
    data <- list()
    data$uri <- uri
    data$key <- key
    data$file <- file

    rworker_return("Upload", data)

    result <- rworker_wait_message()
    result$status
}

rworker_download <- function(uri) {
    data <- list()
    data$uri <- uri

    rworker_return("Download", data)

    result <- rworker_wait_message()
    result$file
}

rworker_wait_message <- function() {
    # 他のプロセスからの書き込みが混ざるとうまくいかない可能性あり
    message <- readLines(fifo(args$fifo, open = 'read', blocking = TRUE), n=1)
    rworker_log(paste("1 message received [", message, "]"))

    fromJSON(message)
}

