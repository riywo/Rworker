source('Rworker.r')

args <- rworker_args()

d <- read.csv(args$data_file, header = T)
rworker_return("some messages")
png(args$img_file)
plot(d)
null <- dev.off()

rworker_end()
    
