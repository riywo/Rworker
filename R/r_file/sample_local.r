source('Rworker.r')

d <- read.csv(args$data, header = T)
rworker_log("read.csv finished:")

png(args$img)
plot(d)
null <- dev.off()
rworker_log(paste("plot finished:", args$img))

