setwd("E:/Juan/shiny/ebola/")
library(ggmap)
library(reshape)
data <- read.table("E:/Juan/shiny/ebola/www/data10.csv", sep = ",", check.names=FALSE,dec = ",", header= TRUE)
data <- data[data[['Sources']] == 'WHO',]
cities <- unique(as.character(data$Localite))
t<- geocode(cities)
cities <- data.frame(cities)
Code <- rownames(cities)
cities<- cbind(Code=Code, cities)
rownames(cities) <- cities$Code
total <- cbind(cities, t)
data1 <- cast(data, Country+Localite~ Category, sum, value = 'Value',na.rm=TRUE)
last <- merge( data1, total, by.x = "Localite", by.y = "cities", all = TRUE)
colnames(last)[10]<-"longitude"
colnames(last)[11]<-"latitude"
last <- subset(last, select = -c(Code) )
write.csv(last, file = "data12.csv", quote = FALSE, row.names= FALSE)