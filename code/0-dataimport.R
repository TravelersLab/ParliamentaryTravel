# Initial File for Parliamentary Travel Project

setwd("~/MEGA/TravelersLab/Parliamentary\ Travel/")

library(readr)
library(dplyr)

boroughs <- read_csv("./data/parliamentary_boroughs_offkey_towns.csv")
boroughs <- rename(boroughs, parliamentary = "Parliamentary Borough")

pBoroughs <- select(boroughs, parliamentary="X")

setLatLong <- function(df, name, lat, long) {
  
}