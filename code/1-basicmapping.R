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
# long_s, lat_s: Starting pos(IE long/lat  of Borough)
# plong, plat  : Pos in Dim (IE long/lat of Westminster)

# Outputs:
# loc, an object with $long as the current longitude, $lat as current latitude
calculateLongLat <- function(tf, ts, t, long_s, lat_s, plong, plat) {
  logic_vector <- ts <= t
  int_vector <- as.numeric(logic_vector)
  c_int_vector <- 1 - int_vector
  scale <- (tf - t) / (tf - ts)
  
  long_if_set_out <- scale * long_s + (1-scale) * plong
  lat_if_set_out  <- scale * lat_s  + (1-scale) * plat
  
  c_long <- int_vector * long_if_set_out + c_int_vector * long_s
  c_lat  <- int_vector * lat_if_set_out  + c_int_vector * lat_s
  return(list("c_long" = c_long, "c_lat" = c_lat))
}

# Passes sanity checks so far
ex1 <- calculateLongLat(10, 0, 7, 10, 10, 0, 0)
ex2 <- calculateLongLat(10, 0, 5, 10, 10, 0, 0)

# Vector to track location over time
time_locs <- c()

# Foor loop, to calculate the locations over time
for(i in 1:num_steps) {
  time_locs[[i]] <-calculateLongLat(t_f, pBoroughs$start_t, t_step[i], pBoroughs$long, pBoroughs$lat, plong, plat)
}

# Plots the locations @ given time step i (where 1 <= i < num_steps)
pot <- function(i) {
  cl <- time_locs[[i]]
  qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = I("red"),
         zoom = 7, color = TRUE) + geom_point(aes(x=cl$c_long, y=cl$c_lat), color = "purple", shape=17, size = 4)
}

# Saves plot to file over time
for(i in 1:num_steps) {
  ggsave(sprintf("burgess_travel%03d.jpg", i), pot(i), 
         device="jpg", path="./figures/travel_over_time/")
}

# And then, to produce the GIF, 
# we run `convert -delay 10 -loop 1 *jpg burgess_travel.gif`
# (This produces our GIF using ImageMagick on the command line)
