library('ggplot2')
source('Rworker.r')

rworker_log("Download start")
file <- rworker_download(args$data)
rworker_log(paste("Download finished:", file))

rworker_log("read.csv start")
d <- read.csv(file, header = T)
rworker_log("read.csv finished")

rworker_log(("plot start")
temp <- tempfile()
png(temp)
qplot(carat, price, data = d, colour = clarity, log = "xy")
null <- dev.off()
rworker_log(paste("plot finished:", temp))

rworker_log("upload start")
status <- rworker_upload(args$upload_url, args$upload_key, temp)
rworker_log(paste("upload finished:", status, args$upload_url, args$upload_key, temp))
