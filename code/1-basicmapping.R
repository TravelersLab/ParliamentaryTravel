library(maps)
library(mapdata)
library(ggmap)
library(dplyr)

setwd("~/MEGA/TravelersLab/Parliamentary\ Travel")

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

# Graph that makes easy to see that the lines correspond to the actual paths
qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = I("red"),
       zoom = 7, color = TRUE) + 
  geom_segment(x = plong, y = plat,
               xend = pBoroughs$long, yend= pBoroughs$lat,
               color = "pink", size = 1) +
  geom_point(aes(x=plong, y=plat), color = "blue", size = 3) 

ggsave("./figures/burgessplot_withpaths.png")

# Calculates the distance between a point and Parliament @ Westminster.
# In doing so, it provides us a measure to figure out who leaves first,
# as assuming uniform travel / time (false in individual cases, true as n -> inf)
# the group which leaves first should be the group that's the farthest away

# ASSUMPTION MADE HERE THAT DOESN'T HOLD TRUE -- England is flat, and degrees
# of latitude are constant in distance, and equivalent to degrees of longitude

# TO FIX : Using haversine formula

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
         zoom = 7, color = TRUE)+
    geom_point(aes(x=cl$c_long, y=cl$c_lat), color = "purple", shape=17, size = 4)+
    geom_point(aes(x=plong, y=plat), color = "blue", size = 3)
}

# Saves plot to file over time
for(i in 1:num_steps) {
  ggsave(sprintf("burgess_travel%03d.jpg", i), pot(i), 
         device="jpg", path="./figures/travel_over_time/")
}

library(igraph)

g<- make_undirected_graph(c(), n=length(pBoroughs$Name))
V(g)$name <- pBoroughs$Name
for(i in 1:num_steps) {
  thresh <- 0.01
  cd <- time_locs[[i]]
  for(j in 1:length(cd$c_long)) {
    long_j <- time_locs[[i]]$c_long[j]
    lat_j  <- time_locs[[i]]$c_lat[j]
    for(k in j:length(cd$c_long)){
      long_k <- time_locs[[i]]$c_long[k]
      lat_k  <- time_locs[[i]]$c_lat[k]
      distance <- sqrt( (long_j - long_k)^2 + (lat_j - lat_k)^2)
      if (distance < thresh ) {
        if(are.connected(g, j, k)) {
          e_id <- get.edge.ids(g, c(j, k))
          c_w <- get.edge.attribute(g, "w", index=e_id)
          g <- set_edge_attr(g, "w", index=e_id, value=c_w + 1)
        } else {
          if (j != k ) {
            g <- add_edges(g, c(j,k), "w" = 1)
            print(paste(as.character(j), as.character(k)))
          }
        }
      }
    }
  }
}
plot(g)

g <- delete.edges(g, E(g)[w < 5])

library(ggplot2)
qplot(E(g)$w)

library(d3Network)

df_nodes <- as_data_frame(g, "vertices")

df_links <- as_data_frame(g, "edges")
df_links <- mutate(df_links, w =  3*w)


df_links <- mutate(df_links, 
                   from_index = match(from, df_nodes$name)-1,
                   to_index   = match(to  , df_nodes$name)-1)


df_nodes$group <- components(g)$membership


d3rep <- d3ForceNetwork(Links = df_links,
               Nodes = df_nodes,
               Source="from_index",
               Target="to_index",
               Value="w",
               NodeID="name",
               file="d3rep.html",
               linkWidth = 1,
               linkDistance = "function(d){return d.value }",
               charge = -100,
               fontsize = 15,
               Group = "group"
               )



pBoroughs$group <- df_nodes$group
g_colors <- as.color(pBoroughs$group)


gbplot <- qmplot(long, lat, pBoroughs, maptype="toner-background", data = pBoroughs, color = g_colors,
       zoom = 7, color = TRUE, legend="none") + geom_point(aes(x=plong, y=plat), color = I("blue"), size = 3)+
  theme(legend.position="none")

ggsave("./figures/groups_burgesses.png", gbplot, device="png")


# And then, to produce the GIF, 
# we run `convert -delay 10 -loop 1 *jpg ../burgess_travel.gif`
# (This produces our GIF using ImageMagick on the command line)