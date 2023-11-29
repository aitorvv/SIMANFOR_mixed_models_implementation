#------------------------------------------------------------------------------------------#
####                     Get plots from IFN4 adapted to SIMANFOR                        ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 30/06/2023                              #
#                              Last modification: 16/10/2023                               #
#------------------------------------------------------------------------------------------#


#### Aim of the script ####

# That script is developed with the aim to use the 4rd Spanish National Forest
# Inventory (SFNI, IFN in spanish) to run simulations of pure plots in SIMANFOR
# Resources:
# SFNI: https://www.miteco.gob.es/es/biodiversidad/temas/inventarios-nacionales/inventario-forestal-nacional/default.aspx


#### Basic steps ####

# path
setwd('')

# libraries
library(plyr)
library(dplyr)
library(stringr)
library(tidyverse)
library(raster)
library(rgdal)
#library(oce) # utm2lonlat

# data
load('0_raw_data/IFN4/ifn4.RData')


#### Make data more comfortable ####

# skip unuseful data
trees4 <- dplyr::select(trees.if4, -c(Agente, Import, Elemento, Hcopa, NPae, CPae, VPae))
plots4_age <- dplyr::select(plots.sp.if4, c(Provincia, Estadillo, Cla, Subclase, PosEsp, Especie, Edad))
plots4_coords <- dplyr::select(maps.if4, c(Provincia, Estadillo, CoorX, CoorY, Huso))
plots4_fcc <- dplyr::select(plots.if4, c(Provincia, Estadillo, Cla, Subclase, Ano, FccTot, FccArb))

# merge plot data
plots4 <- merge(plots4_age, plots4_coords, by = c('Provincia', 'Estadillo'))
plots4 <- merge(plots4, plots4_fcc, by = c('Provincia', 'Estadillo', 'Cla', 'Subclase'))
plots4 <- plots4[!duplicated(plots4),]

rm(maps.if4, plots.if4, plots.sp.if4, trees.if4, plots4_age, plots4_coords, plots4_fcc)


#### Data management ####

# Rename variables
trees4 <- rename(trees4, c("provincia" = "Provincia",
                           "estadillo" = "Estadillo",
                           "clase" = "Cla",
                           "subclase" = "Subclase",
                           "TREE_ID_IFN4_3" = "nArbol",
                           "TREE_ID_IFN3" = "OrdenIf3",
                           "TREE_ID_IFN4" = "OrdenIf4",
                           "rumbo" = "Rumbo",
                           "distancia" = "Distanci",
                           "especie" = "Especie",
                           "dbh_1" = "Dn1",
                           "dbh_2" = "Dn2",
                           "h" = "Ht",
                           "calidad" = "Calidad",
                           "forma" = "Forma",
                           "parametros_especiales" = "ParEsp"
))

plots4 <- rename(plots4, c(
  "Province" = "Provincia", 
  "Study_Area" = "Estadillo", 
  "Class" = "Cla", 
  "Subclass" = "Subclase", 
  "AGE" = "Edad",
  "YEAR" = "Ano",
  "X_UTM" = "CoorX",
  "Y_UTM" = "CoorY",
  "Fcc" = "FccArb"
))

# create IDs
trees4$INVENTORY_ID <- 'IFN4'
plots4$INVENTORY_ID <- 'IFN4'

trees4$PLOT_ID <- paste(trees4$provincia, trees4$estadillo, trees4$clase, trees4$subclase, sep = '_')
plots4$PLOT_ID <- paste(plots4$Province, plots4$Study_Area, plots4$Class, plots4$Subclass, sep = '_') 

# original tree ID
trees4$TREE_ID <- paste(trees4$provincia, trees4$estadillo, trees4$clase, trees4$subclase, trees4$TREE_ID_IFN4_3, sep = '_')

# tree ID to compare among SFNI editions
trees4$IFN_TREE_ID <- paste(trees4$INVENTORY_ID, trees4$provincia, trees4$estadillo, trees4$clase, trees4$subclase, trees4$TREE_ID_IFN4_3, sep = '_')


#### Rescue some plots with age value ####

# read IFN3 data
ifn3_psylfsyl <- read.csv('1_data/IFN3_plots_psyl_fsyl.csv')
ifn3_psylqpyr <- read.csv('1_data/IFN3_plots_psyl_qpyr.csv')
ifn3_psylppin <- read.csv('1_data/IFN3_plots_psyl_ppin.csv')
ifn3_psylpnig <- read.csv('1_data/IFN3_plots_psyl_pnig.csv')
ifn3 <- rbind(ifn3_psylfsyl, ifn3_psylpnig, ifn3_psylppin, ifn3_psylqpyr)

# check plots without age on IFN4 and calculate it if available on IFN3
p4_to_find <- plots4[plots4$AGE == 0, ]
p4_to_find2 <- plots4[is.na(plots4$AGE), ]
p4_to_find <- p4_to_find[!is.na(p4_to_find$AGE), ]
p4_to_find <- rbind(p4_to_find, p4_to_find2)

p4_to_find$AGE <- ifelse(p4_to_find$PLOT_ID %in% ifn3$PLOT_ID, 
                         ifn3$AGE - ifn3$YEAR,  # yes 
                         '')  # no
p4_found <- p4_to_find[p4_to_find$AGE != '', ]
p4_found$AGE <- as.numeric(p4_found$AGE) + p4_found$YEAR


#### Apply filters: location, species and age ####

# filter plots with age > 10 years
plots4 <- plots4[plots4$AGE > 10, ]
plots4 <- plots4[!is.na(plots4$AGE), ]

# add plots with age obtained from IFN3
plots4 <- rbind(plots4, p4_found)
rm (ifn3, ifn3_psylfsyl, ifn3_psylpnig, ifn3_psylppin, ifn3_psylqpyr, p4_to_find, p4_to_find2, p4_found)

# filter plots in Castilla and León
cyl <- c(5, 9, 24, 34, 37, 40, 42, 47, 49) # province codes
plots4 <- plots4[plots4$Province %in% cyl, ]

# filter by species - it will be applied later, after check if the species is correct
#plots4_sp <- plots4[plots4$Especie == 43, ] # 43 = Quercus pyrenaica
#plots4_sp <- plots4_sp[!duplicated(plots4_sp$PLOT_ID), ]

# select trees on the filtered plots
trees4 <- trees4[trees4$PLOT_ID %in% plots4$PLOT_ID, ]


#### Calculate tree variables ####

# just variables that will be needed on SIMANFOR are calculated

# dbh (cm)
trees4$dbh <- (trees4$dbh_1 + trees4$dbh_2)/20

# expansion factor
trees4$expan <- with(trees4, 
                     ifelse (dbh < 7.5, 0, 
                             ifelse(dbh < 12.5, 10000/(pi*(5^2)), 
                                    ifelse(dbh < 22.5, 10000/(pi*(10^2)), 
                                           ifelse(dbh < 42.5, 10000/(pi*(15^2)),
                                                  10000/(pi*(25^2)))))))

# basal area (cm2)
trees4$g <- ((pi)/4)*(trees4$dbh^2)

# Slenderness
trees4$slenderness <- trees4$h*100/trees4$dbh

# dead (1) or alive (0) tree - clean dead trees to avoid mistakes (height = 0)
trees4$dead <- ifelse(trees4$calidad == 6, 1, 0)
trees4 <- trees4[trees4$dead == 0, ]

# delete trees without IFN3 data (dead, harvested...)
trees4 <- trees4[!is.na(trees4$dbh), ]
trees4 <- trees4[trees4$dbh != 0, ]

# check variable types
str(trees4)


#### Calculate plot variables ####

# just variables that will be needed on SIMANFOR are calculated

# variables from trees
plots4_vars <- plyr::ddply(trees4, c('PLOT_ID'), summarise,
                            SUM_DBH = sum(dbh*expan, na.rm = TRUE),
                            SUM_H = sum(h*expan, na.rm = TRUE),
                            G = sum(g*expan/10000, na.rm = TRUE),
                            N = sum(expan, na.rm = TRUE),
                            Deadwood = sum(ifelse(1 %in% dead, 1, 0))
)

plots4_vars$DBHm <- plots4_vars$SUM_DBH/plots4_vars$N
plots4_vars$Hm <- plots4_vars$SUM_H/plots4_vars$N
plots4_vars$Dg <- with(plots4_vars, 200*(G/N/pi)^0.5, na.rm=TRUE)

# functions fo Ho and Do
source('0.1_SFNI_functions.R')

# calculate Ho and join data
Ho_4 <- dominantHeight(trees4, 'PLOT_ID')
plots4_vars <- merge(plots4_vars, Ho_4, by = 'PLOT_ID')

# calculate Do and join datasets
Do_4 <- DiametroDominante(trees4, 'PLOT_ID')
plots4_vars <- merge(Do_4, plots4_vars, all = TRUE, by.x = 'IDs', by.y = 'PLOT_ID')

# join new data to the original 
plots4 <- merge(plots4, plots4_vars, all = TRUE, by.x = 'PLOT_ID', by.y = 'IDs')

# clean NAs
plots4 <- plots4[!is.na(plots4$AGE), ]
plots4 <- plots4[!is.na(plots4$N), ]
plots4 <- plots4[!is.na(plots4$X_UTM), ]

# slenderness
plots4$slenderness <- plots4$Hm*100/plots4$DBHm  # esbeltez normal
plots4$dominant_slenderness <- plots4$Ho*100/plots4$Do  # esbeltez dominante

# SDI
valor_r <- -1.605 # valor editable dependiendo de la especie (consultar bibliografía)
plots4$SDI <- plots4$N*((25/plots4$Dg)**valor_r)

# Cálculo del Índice de Hart (S)
# Índice de Hart-Becking
plots4$S <- 10000/(plots4$Ho*sqrt(plots4$N))  
# Índice de Hart-Becking para masas al tresbolillo
plots4$S_staggered <- (10000/plots4$Ho)*sqrt(2/plots4$N*sqrt(3))  

# match trees and plots
trees4 <- trees4[trees4$PLOT_ID %in% plots4$PLOT_ID, ]

# clean environment
rm(dominantHeight, DiametroDominante, valor_r, plots4_vars, Ho_4, Do_4, cyl)


#### Variables by species ####

# We calculate variables by species to set the main stand species by G criteria

# Calculate G and N by species
plots4_vars_sp <- ddply(trees4, c('PLOT_ID', 'especie'), summarise, 
                        G_sp = sum(g*expan/10000, na.rm = TRUE), 
                        N_sp = sum(expan, na.rm = TRUE)
)

# organize information by PLOT_ID and G
plots4_vars_sp <- plots4_vars_sp %>%
  arrange(PLOT_ID, -G_sp)

# N and G by species
plots_useful_IFN4 <- data.frame()
for (k in unique(plots4_vars_sp$PLOT_ID)){
  
  plots_k <- plots4_vars_sp[plots4_vars_sp$PLOT_ID %in% k,]
  
  plots_k$sp_1 <- plots_k$especie[1]
  plots_k$sp_2 <- plots_k$especie[2] 
  plots_k$sp_3 <- plots_k$especie[3] 
  plots_k$G_sp_1 <- plots_k$G_sp[1]
  plots_k$G_sp_2 <- plots_k$G_sp[2]
  plots_k$G_sp_3 <- plots_k$G_sp[3]
  plots_k$N_sp_1 <- plots_k$N_sp[1]
  plots_k$N_sp_2 <- plots_k$N_sp[2]
  plots_k$N_sp_3 <- plots_k$N_sp[3]
  
  plots_useful_IFN4 <- rbind(plots_useful_IFN4, plots_k)
}

# delete duplicated data
plots_useful_IFN4 <- plots_useful_IFN4[!duplicated(plots_useful_IFN4$PLOT_ID), ]
plots_useful_IFN4 <- dplyr::select(plots_useful_IFN4, -c(especie, N_sp, G_sp))

# merge information with original data
plots4 <- merge(plots_useful_IFN4, plots4, all = TRUE, by = 'PLOT_ID')

# clean environment
rm(plots_k, plots_useful_IFN4, plots4_vars_sp, k)


#### Last details: organize data ####

# organize data
trees4 <- dplyr::select(trees4,
                        INVENTORY_ID, PLOT_ID, IFN_TREE_ID, especie, dead, expan, dbh, 
                        g, h, slenderness, rumbo, distancia)

plots4 <- dplyr::select(plots4,
                        INVENTORY_ID, PLOT_ID, Province, Study_Area, Class, Subclass, 
                        X_UTM, Y_UTM, Huso, Deadwood, YEAR, AGE, sp_1, sp_2, sp_3, 
                        N, N_sp_1, N_sp_2, N_sp_3, DBHm, Dg, Do, G, G_sp_1, G_sp_2, G_sp_3, Hm, Ho, 
                        Fcc, FccTot, slenderness, dominant_slenderness, SDI, S, S_staggered)

# rename to use it in SIMANFOR
trees4 <- rename(trees4, c(
  "TREE_ID" = "IFN_TREE_ID", 
  "species" = "especie", 
  "bearing" = "rumbo", 
  "distance" = "distancia",  
  "height" = "h")
)

plots4 <- rename(plots4, c(
  "ID_SP1" = "sp_1",
  "ID_SP2" = "sp_2",
  "ID_SP3" = "sp_3",
  "dbh_mean" = "DBHm",
  "dg" = "Dg",
  "h_mean" = "Hm",
  "Canopy_cover" = "Fcc")
)

# delete duplicated (just in case)
plots4 <- plots4[!duplicated(plots4), ]
trees4 <- trees4[!duplicated(trees4), ]


#### Checkpoint ####

# save.image('1_data/tmp/checkpoint_before_climate.RData')
# load('1_data/tmp/checkpoint_before_climate.RData')


#### Correct IFN4 coordinates ####

# transform plot data into spatial dataframe
# ED50 / UTM zone 30N   <23030>
coord <- plots4[, c('PLOT_ID', 'Province', 'Study_Area', 'X_UTM', 'Y_UTM')]
coord$ID <- coord$PLOT_ID

# stablish CRS
CRS_28 <- "+proj=utm +zone=28 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs"
CRS_29 <- "+proj=utm +zone=29 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs"
CRS_30 <- "+proj=utm +zone=30 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs"
CRS_31 <- "+proj=utm +zone=31 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs"
## CRS_1 <- "+proj=utm +zone=30 +ellps=intl +units=m +towgs84=-87,-98,-121,0,0,0,0"  # utm gs84 
## CRS_2 <- "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"                 # wgs84 

# get "huso" column for each plot
coord$huso <- with(coord,
                   case_when( 
                     Province %in% c(38, 35) ~ 28, #huso 28: Canarias
                     Province %in% c(15, 27, 36, 32, 21)  ~ 29, #huso 29: Galicia y Huelva (casi seguro que no tiene nada en el 30)
                     Province %in% c(33, 24, 49, 37, 10, 6, 41, 11) ~ ifelse(X_UTM > 500000, 29, 30), # Husos 29 y 30: Asturias, León, Zamora, Salamanca, Extremadura (ambas provincias), Sevilla y Cádiz
                     Province %in% c(31, 39, 1, 20, 48, 47, 9, 34, 42, 5, 40, 26, 28, 2, 13, 16, 19, 45, 30, 4, 14, 18, 23, 29, 51)  ~ 30, #Huso 30: Cantabria, Pais Vasco, Castilla y León (salvo las 3 provincias leonesas), La Rioja, Madrid, Castilla La Mancha, Murcia, Andalucía (Salvo las 3 provincias más occidentales mencionadas)
                     Province %in% c(46, 12, 3, 22, 50, 44) ~ ifelse(X_UTM > 500000, 30, 31), # Huso 30 y 31: Comunidad Valenciana y Aragon
                     Province %in% c(8, 25, 17, 43, 7)  ~ 31,# huso 31:Cataluña y Baleares
                   )
)

# split df
#coord28 <- coord[coord$huso==28,]
coord29 <- coord[coord$huso==29,]
coord30 <- coord[coord$huso==30,]
#coord31 <- coord[coord$huso==31,]

# convert coordinates into coordinates point list of R
#coord.spt28 <- SpatialPointsDataFrame(coord28[,c('X_UTM','Y_UTM')], coord28, proj4string = CRS(CRS_28) )
coord.spt29 <- SpatialPointsDataFrame(coord29[,c('X_UTM','Y_UTM')], coord29, proj4string = CRS(CRS_29) )
coord.spt30 <- SpatialPointsDataFrame(coord30[,c('X_UTM','Y_UTM')], coord30, proj4string = CRS(CRS_30) )
#coord.spt31 <- SpatialPointsDataFrame(coord31[,c('X_UTM','Y_UTM')], coord31, proj4string = CRS(CRS_31) )

# transform coordinates system to WGS84
#coordLT28 <- spTransform(coord.spt28, CRS("+proj=longlat +ellps=WGS84")) # convertimos el spatial dataframe "coord.spt28" que esta en coordenadas planas a sptatial dataframe en coordenadas globales Longitud/Latitud "dataLT"
coordLT29 <- spTransform(coord.spt29, CRS("+proj=longlat +ellps=WGS84"))
coordLT30 <- spTransform(coord.spt30, CRS("+proj=longlat +ellps=WGS84"))
#coordLT31 <- spTransform(coord.spt31, CRS("+proj=longlat +ellps=WGS84"))

# join dfs
#coordLT.if3 <- rbind(coordLT28, coordLT29, coordLT30, coordLT31)
my_points <- rbind(coordLT29, coordLT30)


#### Calculate variables related with climate ####

# 1. run function to get historical climate data
source('wc_historic_monthly_data.R')

# my period of time
period <- c(2000:2020)

# run functions for month, year and period historical data
folder_path <- "/WorldClim/historical_monthly_data/"

wc_month <- wc_monthly_climate(wc_path = folder_path,
                               points = my_points, 
                               data_period = period)

wc_year <- wc_annual_climate(df = wc_month)

wc_period <- wc_average_climate(df = wc_year)


# 2. run function to get future climate data
source('wc_future_MIROC6_data.R')

# run function to get future climate data
folder_path <- 'WorldClim/MIROC6_SSP2/'
future_clima <- wc_future_climate(folder_path = folder_path, 
                                  points = my_points)

# 3. run function to estimate Martonne Aridity index
source('wc_climate_index.R')

# calculate martonne for the period of historical data
m_hist_period <- wc_martonne(df = wc_period, 
                             prec = wc_period$prec, 
                             tmean = wc_period$tmean) 

# calculate martonne for the future periods of time
m_fut_period <- wc_martonne(df = future_clima, 
                            prec = future_clima$prec, 
                            tmean = future_clima$tmean) 


# 4. clean data obtained and merge with the previous data set

# adapt historic data
m_hist_period <- dplyr::select(m_hist_period, ID, M)
m_hist_period <- rename(m_hist_period, 'MARTONNE' = 'M')

# adapt future data
m_fut_by_period <- m_per_periods(m_fut_period = m_fut_period)

# merge data with the original one
plots4 <- merge(plots4, m_hist_period, by.x = 'PLOT_ID', by.y = 'ID')
plots4 <- merge(plots4, m_fut_by_period, by.x = 'PLOT_ID', by.y = 'ID')

# skip possible empty plots
plots4 <- plots4[plots4$MARTONNE != c('', 'NA', 'NaN'), ]
trees4 <- trees4[trees4$PLOT_ID %in% plots4$PLOT_ID, ]

# clean environment
rm(coord, coord.spt29, coord.spt30, coord29, coord30, coordLT29, coordLT30, future_clima, m_fut_by_period, m_fut_period,
   m_hist_period, my_points, wc_month, wc_period, wc_year, CRS_28, CRS_29, CRS_30, CRS_31, folder_path, period, 
   m_per_periods, wc_annual_climate, wc_average_climate, wc_future_climate,
   wc_martonne, wc_monthly_climate)


#### Checkpoint ####

# save.image('1_data/tmp/checkpoint_after_climate.RData')
#load('1_data/tmp/checkpoint_after_climate.RData')


#### Filter plots: pure and mixed stands ####

# my goal is Quercus pyrenaica (code 43)

# 1. filter pure plots
#qpyr_plots4 <- plots4[plots4$ID_SP1 == 43, ]
#qpyr_trees4 <- trees4[trees4$PLOT_ID %in% qpyr_plots4$PLOT_ID, ]

# check ages and densities
#summary(qpyr_plots4$N)
#summary(qpyr_plots4$AGE)

# 2. filter mixed combinations
# species IFN codes
psyl <- 21
qpyr <- 43
species <- c(psyl, qpyr)

# filter plots
plots_psyl_qpyr <- plots4[plots4$ID_SP1 %in% species & plots4$ID_SP2 %in% species, ]

# get trees for each plot
trees_psyl_qpyr <- trees4[trees4$PLOT_ID %in% plots_psyl_qpyr$PLOT_ID, ]

#--#

# species IFN codes
fsyl <- 71
species <- c(psyl, fsyl)
plots_psyl_fsyl <- plots4[plots4$ID_SP1 %in% species & plots4$ID_SP2 %in% species, ]
trees_psyl_fsyl <- trees4[trees4$PLOT_ID %in% plots_psyl_fsyl$PLOT_ID, ]

#--#

# species IFN codes
ppin <- 26
species <- c(psyl, ppin)
plots_psyl_ppin <- plots4[plots4$ID_SP1 %in% species & plots4$ID_SP2 %in% species, ]
trees_psyl_ppin <- trees4[trees4$PLOT_ID %in% plots_psyl_ppin$PLOT_ID, ]

#--#

# species IFN codes
pnig <- 25
species <- c(psyl, pnig)
plots_psyl_pnig <- plots4[plots4$ID_SP1 %in% species & plots4$ID_SP2 %in% species, ]
trees_psyl_pnig <- trees4[trees4$PLOT_ID %in% plots_psyl_pnig$PLOT_ID, ]

rm(plot, species, fsyl, ppin, pnig, psyl, qpyr)


#### Save results ####

# all CyL plots
write.csv(plots4, '1_data/IFN4_all_cyl_plots.csv')
write.csv(trees4, '1_data/IFN4_all_cyl_trees.csv')

# mixtures
write.csv(plots_psyl_qpyr, '1_data/IFN4_psyl_qpyr_cyl_plots.csv')
write.csv(trees_psyl_qpyr, '1_data//IFN4_psyl_qpyr_cyl_trees.csv')

write.csv(plots_psyl_fsyl, '1_data/IFN4_psyl_fsyl_cyl_plots.csv')
write.csv(trees_psyl_fsyl, '1_data//IFN4_psyl_fsyl_cyl_trees.csv')

write.csv(plots_psyl_ppin, '1_data/IFN4_psyl_ppin_cyl_plots.csv')
write.csv(trees_psyl_ppin, '1_data//IFN4_psyl_ppin_cyl_trees.csv')

write.csv(plots_psyl_pnig, '1_data/IFN4_psyl_pnig_cyl_plots.csv')
write.csv(trees_psyl_pnig, '1_data//IFN4_psyl_pnig_cyl_trees.csv')

# RData
save.image('1_data/final_data.RData')
