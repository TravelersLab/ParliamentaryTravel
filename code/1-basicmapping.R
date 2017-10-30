library(maps)
library(mapdata)
library(ggmap)
library(dplyr)

# maps english boroughs
qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = I("red"),
       zoom = 7, color = TRUE)

# Saves burgess plot
ggsave("./figures/burgessplot.png")


# Parliamentary Longitude and Latitude
plat <- 51.500637
plong<- -0.127499

# Plots of english boroughs with parliament
dev.off()
qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = I("red"),
       zoom = 7, color = TRUE) + geom_point(aes(x=plong, y=plat), color = "blue", size = 3)

lineDF <- select(pBoroughs, Name, long, lat)
lineDF <- mutate(lineDF, 
                 m = ((lat - plat) / (long - plong)),
                 b = lat - m * long
                 )

# Graph that makes easy to see that the lines correspond to the actual paths
qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = I("red"),
       zoom = 7, color = TRUE)+ 
  geom_abline(slope = lineDF$m, intercept = lineDF$b, color = "green", size = 0.2) +
  geom_segment(x = plong, y = plat,
             xend = pBoroughs$x, yend= pBoroughs$y,
             color = "pink", size = 1) +
  geom_point(aes(x=plong, y=plat), color = "blue", size = 3) 






