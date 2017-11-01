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

# Creates lines for the various paths of the groups
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
             xend = pBoroughs$long, yend= pBoroughs$lat,
             color = "pink", size = 1) +
  geom_point(aes(x=plong, y=plat), color = "blue", size = 3) 

ggsave("./figures/burgessplot_withpaths.png")

# Calculates the distance between a point and Parliament @ Westminster.
# In doing so, it provides us a measure to figure out who leaves first,
# as assuming uniform travel / time (false in individual cases, true as n -> inf)
# the group which leaves first should be the group that's the farthest away
pBoroughs <- mutate(pBoroughs, 
                    distance = sqrt( (plong - long)^2 + (plat - lat)^2),
                    start_t = max(pBoroughs$distance) - distance
                    )

# Sets 'final time' to be the distance of the farthest party 
# (IE they'll be the ones travelling the longest)
t_f <- max(pBoroughs$distance)

# Creates a vector of 'time steps',

num_steps <- 100
t_step <- seq(0, t_f, t_f / (num_steps - 1))


# Calculates the position of a given party, in the 'as the crow flies' 
# travel model, through a weighted average based on how long the party
# has been travelling.

# Assumes 0 <= t <= tf

# Inputs:
# tf: Final Time (aka longest distance needed to travel)
# ts: Start Time (IE when the group should leave to get to London at Parl Time)
# t : Current Time (IE some t in t_step)
# long_s, lat_s: Starting Longitude + Latitude (IE location of Borough)
# plong, plat  : Longitude + Latitude of Westminster

# Outputs:
# loc, an object with $long as the current longitude, $lat as current latitude
calculateLongLat <- function(tf, ts, t, long_s, lat_s, plong, plat) {
  if(t < ts) {
    c_long <- long_s
    c_lat  <- lat_s
    return( c(c_long, c_lat))
  }
  
  scale <- (tf - t) / (tf - ts)
  c_long <- scale * long_s + (1 - scale) * plong
  c_lat  <- scale * lat_s  + (1 - scale) * plat
  return( c(c_long, c_lat))
}

# Passes sanity checks so far
ex1 <- calculateLongLat(10, 0, 7, 10, 10, 0, 0)
ex2 <- calculateLongLat(10, 0, 5, 10, 10, 0, 0) 


