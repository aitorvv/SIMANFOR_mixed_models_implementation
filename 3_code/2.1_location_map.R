#------------------------------------------------------------------------------------------#
####                              Plot IFN4 plot locations                              ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 26/07/2023                              #
#                              Last modification: 25/10/2023                               #
#------------------------------------------------------------------------------------------#


#### Basic steps ####

library(ggplot2)
library(dplyr)
library(sf) # geometry
library(sp) # some functions for geometry
library(oce) # utm2lonlat
library(eurostat) # maps

setwd('')


#### Load data ####

PsylFsyl <- read.csv('1_data/IFN4_psyl_fsyl_cyl_plots.csv')
PsylQpyr <- read.csv('1_data/IFN4_psyl_qpyr_cyl_plots.csv')
PsylPpin <- read.csv('1_data/IFN4_psyl_ppin_cyl_plots.csv')
PsylPnig <- read.csv('1_data/IFN4_psyl_pnig_cyl_plots.csv')

load('1_data/simulation_results.RData')


#### Manage data: clean and merge ####

# consider just plots finally showed on the results
PsylFsyl <- PsylFsyl[PsylFsyl$PLOT_ID %in% unique(new_df$Plot_ID), ]
PsylQpyr <- PsylQpyr[PsylQpyr$PLOT_ID %in% unique(new_df$Plot_ID), ]
PsylPpin <- PsylPpin[PsylPpin$PLOT_ID %in% unique(new_df$Plot_ID), ]
PsylPnig <- PsylPnig[PsylPnig$PLOT_ID %in% unique(new_df$Plot_ID), ]

# column for mixture
PsylFsyl$Mixture <- 'Psylvestris x Fsylvatica'
PsylQpyr$Mixture <- 'Psylvestris x Qpyrenaica'
PsylPpin$Mixture <- 'Psylvestris x Ppinaster'
PsylPnig$Mixture <- 'Psylvestris x Pnigra'

# merge them
df <- rbind(PsylFsyl, PsylQpyr, PsylPnig, PsylPpin)


#### Manage data: arrange coordinates ####

# calculate longitude and latitude
lonlat <- utm2lonlat(easting = df$X_UTM,
                     northing = df$Y_UTM,
                     zone = df$Huso, 
                     hemisphere = 'N',
                     km = FALSE)

# add them to the previous dataset
df$Longitude <- tibble(lonlat$longitude)
df$Latitude <- tibble(lonlat$latitude)

# create a SpatialPointsDataFrame1
coordinates(df) <- c("Longitude", "Latitude")
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")  

# transform to WGS84
my_points <- st_as_sf(df, coords = c("Longitude", "Latitude"), 
                      crs = 4326, # WGS84
                      agr = "constant")


#### Get shape data ####

# shape all Europe
shp_0 <- get_eurostat_geospatial(resolution = 10, 
                                 nuts_level = 1, # big regions
                                 year = 2021,
                                 crs = 4326) # WGS84

# shape Spain
shp_es <- shp_0[shp_0$CNTR_CODE == 'ES', ]

# check it
shp_es %>% 
  ggplot() +
  geom_sf()

# get small regions
shp_regions  <- get_eurostat_geospatial(
  resolution = 10,
  nuts_level = 2, # medium regions
  year = 2021,
  crs = 4326) # WGS84

# get regions from Spain
shp_es_regions <- shp_regions[shp_regions$CNTR_CODE == 'ES', ]

# plot Spain regions
shp_es_regions %>% 
  ggplot() +
  geom_sf(size = 0.2, color = "blue") + # border line
  scale_x_continuous(limits = c(-10, 5)) +
  scale_y_continuous(limits = c(36, 45)) +
  labs(
    title = "Site locations",
    #subtitle = "Annual % of change, 2020 vs 2019",
    #caption = "Data: Eurostat tec00115"
  ) +
  theme_void() # skip borders of the plot

# get provinces
shp_small_regions  <- get_eurostat_geospatial(
  resolution = 10,
  nuts_level = 3, # province regions
  year = 2021,
  crs = 4326) # WGS84

# get regions from Spain
shp_cyl_regions <- shp_small_regions[shp_small_regions$CNTR_CODE == 'ES', ]

# get regions from CyL
shp_cyl_regions <- shp_cyl_regions[shp_cyl_regions$NAME_LATN %in% c('Ávila', 'Zamora', 'Salamanca', 'León',
                                                                    'Palencia', 'Valladolid', 'Burgos', 'Soria', 'Segovia'), ]

# plot Spain regions
shp_cyl_regions %>% 
  ggplot() +
  geom_sf(size = 0.2, color = "blue") + # border line
  scale_x_continuous(limits = c(-10, 5)) +
  scale_y_continuous(limits = c(36, 45)) +
  labs(
    title = "Site locations",
    #subtitle = "Annual % of change, 2020 vs 2019",
    #caption = "Data: Eurostat tec00115"
  ) +
  theme_void() # skip borders of the plot


#### Plot points and map ####

# map Spain
map <- ggplot(shp_es_regions) +
  geom_sf(size = 0.2, color = "black", fill = 'lightgray') + # border line
  #geom_sf_text(aes(label = NAME_LATN), size = 3, family = 'sans', # text for each plot
  #             nudge_x = 0.05, nudge_y = - 0.05) + # distance between point and label
  geom_sf(data = my_points, size = 1, shape = 23, fill = "darkred", color = 'darkred') + # points
  labs(title = "SFNI4 plot locations for each mixture in Spain" # title
       #subtitle = "Annual % of change, 2020 vs 2019",
       #caption = "Data: Eurostat tec00115"
  ) +
  scale_x_continuous(limits = c(-9, 3)) +
  scale_y_continuous(limits = c(36, 44)) +
  #theme_void() + # skip borders of the plot
  theme(plot.title = element_text(hjust = 0.5, face = 'bold')) + # center title
  theme(panel.grid.major = element_line(colour = gray(0.5), linetype = "dashed", size = 0.15), 
        panel.background = element_rect(fill = "aliceblue"), # outside map style
        panel.border = element_rect(fill = NA)) +
  facet_wrap(~ Mixture) # divide into several graphs

# watch and save graph
map
ggsave(filename = '4_figures/IFN4_plots_map_Spain.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)

# map CyL
map <- ggplot(shp_cyl_regions) +
  geom_sf(size = 0.2, color = "black", fill = 'lightgray') + # border line
  #geom_sf_text(aes(label = NAME_LATN), size = 3, family = 'sans', # text for each plot
  #             nudge_x = 0.05, nudge_y = - 0.05) + # distance between point and label
  geom_sf(data = my_points, size = 1, shape = 23, fill = "darkred", color = 'darkred') + # points
  labs(title = "SFNI4 plot locations for each mixture in Castilla y León" # title
       #subtitle = "Annual % of change, 2020 vs 2019",
       #caption = "Data: Eurostat tec00115"
  ) +
  scale_x_continuous(limits = c(-7, -1.8)) +
  scale_y_continuous(limits = c(40.2, 43.2)) +
  #theme_void() + # skip borders of the plot
  theme(plot.title = element_text(hjust = 0.5, face = 'bold')) + # center title
  theme(panel.grid.major = element_line(colour = gray(0.5), linetype = "dashed", size = 0.15), 
        panel.background = element_rect(fill = "aliceblue"), # outside map style
        panel.border = element_rect(fill = NA)) +
  facet_wrap(~ Mixture) # divide into several graphs

# watch and save graph
map
ggsave(filename = '4_figures/IFN4_plots_map_CyL.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)
