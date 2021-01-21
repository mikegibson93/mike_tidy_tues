# Tidy Tuesday 2021-01-19
# Kenya Census
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


kenya <- kenya %>%
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
         female = Female)%>%
  select(-c(Population,NumberOfHouseholds, Male, AverageHouseholdSize,Female,Intersex))

summary(kenya)

boxplot(kenya$pop100000)
