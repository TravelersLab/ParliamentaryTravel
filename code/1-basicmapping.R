library(maps)
library(mapdata)
library(ggmap)

# maps english boroughs
qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = I("red"),
       zoom = 7, color = TRUE)

# Saves burgess plot
ggsave("./figures/burgessplot.png")
