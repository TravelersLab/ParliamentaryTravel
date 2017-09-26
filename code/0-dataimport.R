# Initial File for Parliamentary Travel Project

setwd("~/MEGA/TravelersLab/Parliamentary\ Travel/")

library(readr)
library(dplyr)
library(ggmap)

# Loads in base data
boroughs <- read_csv("./data/parliamentary_boroughs_offkey_towns.csv")
boroughs <- rename(boroughs, parliamentary = "Parliamentary Borough")

# Loads in all data of parliamentary boroughs
pBoroughs <- filter(boroughs, parliamentary=="X")
# Drops all Longitude / Latitude data (it was incomplete anyway)
pBoroughs <- select(pBoroughs, -Latitude, -Longitude)

# adds UK to the name
pBoroughs <- mutate(pBoroughs, nameUK = paste(Name, ", UK", sep=''))
# creates geocode vector pbll for storing geocode output
pbll <- geocode(pBoroughs$nameUK)
pbll$name <- pBoroughs$nameUK

#adds pbll output to the pBoroughs dataset
pBoroughs$long <- pbll$lon
pBoroughs$lat  <- pbll$lat

#drops nameUK column
pBoroughs$nameUK <- NULL

# Saves data to disk (as parliamentary_boroughs_long_lat.csv)
write_csv(pBoroughs, "./data/parliamentary_boroughs.csv")


# Individual Code if you run into rate limit problems

# pBoroughs <- mutate(pBoroughsLongLat, 
#                     lon = ifelse(is.na(lon),
#                                   geocode(name)[1],
#                                   lon)) -> ASK QUESTION ABOUT THIS TO KABACOFF / PAVEL

# bodminLonLat  <- geocode("Bodmin, UK")
# dunwichLonLat <- geocode("Dunwich, UK")
# launcestonLonLat <- geocode("Launceston, UK")
# melcomberegisLonLat <- geocode("Melcombe Regis, UK")
# shrewsburyLonLat <- geocode("Shrewsbury, UK")
# 
# pBoroughsLongLat[7, "lon"] <- bodminLonLat[1]
# pBoroughsLongLat[7, "lat"] <- bodminLonLat[2]
# pBoroughsLongLat[26, "lon"] <- dunwichLonLat[1]
# pBoroughsLongLat[26, "lat"] <- dunwichLonLat[2]
# pBoroughsLongLat[42, "lon"] <- launcestonLonLat[1]
# pBoroughsLongLat[42, "lat"] <- launcestonLonLat[2]
# pBoroughsLongLat[55, "lon"] <- melcomberegisLonLat[1]
# pBoroughsLongLat[55, "lat"] <- melcomberegisLonLat[2]
# pBoroughsLongLat[76, "lon"] <- shrewsburyLonLat[1]
# pBoroughsLongLat[76, "lat"] <- shrewsburyLonLat[2]
