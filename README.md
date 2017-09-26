# Parliamentary Travel

This repository tries to explain my process in analyzing the travel data of Burgesses and Knights of the Shire to Parliaments in the late Medieval period, as part of the [Travelers Lab](http://travelerslab.research.wesleyan.edu) at Wesleyan University.

## Goals of the Project

Our aim is to try to quantify, in an approximated way, how 'close' various important members of the Medieval English society were to each other, by trying to see which groups of people would have met while traveling from place to place, through analysis of travel logs, manifests, road networks, etc, and plugging that analysis into the various models of travel we produce as part of the lab.

My project is specifically looking at the travel patterns of Burgesses (IE borough representatives to Parliament), and Knights of the Shire (themselves representatives to the Parliament as well). Through analyzing these travel patterns, we can see who would have been travelling on the same roads at the same time, and in doing so can 'weight' this contact to see how much communication there was between the different people within these groups from different geographic constituencies.

---

## Now, down to the nitty gritty

The R files are as follows :

### `code/0-dataimport.R`

In this file, I clean the data given to me on the Parliamentary Boroughs from which the Burgesses originate, and I add lat/long data to it programmatically using the R function `geocode` from `ggmap`, which queries the `Google Maps API` to obtain the data.

### `code/1-basicmapping.R`

Right now, this just has me doing basic mapping using `ggmap`; this will be filled in more later, as I do more research on exactly how to map things using both `ggmap` and `ggplot`, as well as when I have more input regarding road structures.

![Burgess Geoplot](/figures/burgessplot.png?raw=true "Plot of Burgess Locations")

---

Additionally, I have put all data files within the data directory, within which `DataDict.md` explains what each column responds to (where known).

