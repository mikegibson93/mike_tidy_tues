# Tidy Tuesday 2021-01-19
# Kenya Census
# Kenya
library(reshape2)
library(rnaturalearth)
library(sp)
library(sf)
library(raster)
library(rgdal)
library(dplyr)
library(cowplot)
library(extrafont)
library(here)
library(tidyverse)
library(rgeos)

rm(list=ls())
remotes::install_github("Shelmith-Kariuki/rKenyaCensus")

# create a markdown table for the readme
rKenyaCensus::DataCatalogue %>% 
  knitr::kable()

# grab 3 tables of interest
crops <- rKenyaCensus::V4_T2.21
gender <- rKenyaCensus::V1_T2.2
households <- rKenyaCensus::V1_T2.3


## Fixing naming conventions

gender$County
households$County
households<-households %>% mutate(County = str_trim(County, side = c("right")))

households$County = ifelse(households$County=="Kenya","Total",households$County)
households$County = ifelse(households$County=="TanaRiver","Tana River",households$County)
households$County = ifelse(households$County=="WestPokot","West Pokot",households$County)
households$County = ifelse(households$County=="HomaBay","Homa Bay",households$County)
households$County = ifelse(households$County=="NairobiCity","Nairobi City",households$County)

gender$County
households$County


households <- inner_join(households, gender, by = "County")
rm(gender)

names(crops)[names(crops) == "SubCounty"] <- "County"


crops$County
households$County

crops<-crops %>% mutate(County = str_to_title(County))
crops$County = ifelse(crops$County=="Nairobi","Nairobi City",crops$County)
crops$County = ifelse(crops$County=="Kenya","Total",crops$County)

kenya<- inner_join(households, crops, by = "County")

rm(crops,households)


kenya <-as.data.frame(kenya) %>%
  mutate(numHH1000 = NumberOfHouseholds/1000, 
         pop100000 = Population/10^6, 
         pro_male = Male/Total, 
         pro_female = Female/Total,
         pro_farming = Farming/NumberOfHouseholds,
         pro_tea = Tea/Farming,
         pro_coffee = Coffee/Farming,
         pro_avocado = Avocado/Farming,
         pro_citrus = Citrus/Farming,
         pro_Mango = Mango/Farming,
         pro_coco = Coconut/Farming,
         pro_maca = Macadamia/Farming,
         pro_cashew = `Cashew Nut`/Farming,
         pro_khat = `Khat (Miraa)`/Farming,
         avg_HH_size = AverageHouseholdSize,
         male = Male,
         female = Female)

summary(kenya)

boxplot(kenya$pop100000)

africa <- ne_countries(continent = "Africa")

dir<-"~/Dropbox/tidy_tuesdays/2021_01_19"
shapefilepath<-paste(dir,"Shapefile",sep="/")

# Kenya county: https://data.humdata.org/dataset/47-counties-of-kenya
kenya <- readOGR(shapefilepath)
crs(kenya) <- crs(africa)
kenya_sf <- st_as_sf(kenya)
africa_sf <- st_as_sf(africa)

k.col <- ifelse(africa_sf$sovereignt == "Kenya", "#CC0101", "grey30")

kenya_map <- 
  ggplot(africa_sf) +
  geom_sf(fill = k.col, color = "grey70") +
  theme(plot.background = element_rect(fill = "transparent")) 

kenya_map
