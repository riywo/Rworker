source('Rworker.r')

file <- rworker_download(args$data)
rworker_log(paste("Download finished:", file))

d <- read.csv(file, header = T)
rworker_log("read.csv finished:")

png(args$img)
plot(d)
null <- dev.off()
rworker_log(paste("plot finished:", args$img))

status <- rworker_upload(args$upload_uri, args$upload_key, args$img)
rworker_log(paste("upload finished:", status, args$upload_uri, args$upload_key, args$img))

