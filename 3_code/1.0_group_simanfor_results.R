#------------------------------------------------------------------------------------------#
####                        Group SIMANFOR results on a single df                       ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 31/03/2022                              #
#                              Last modification: 25/10/2023                               #
#------------------------------------------------------------------------------------------#



#### Summary ####

# Extended explanation here: 
# https://github.com/simanfor/resultados/blob/main/analisis_resultados/analisis_resultados_SIMANFOR.R


#### Basic steps ####

# libraries
library(readxl)
library(plyr)
library(dplyr)
library(ggplot2)
library(tidyverse)

# set directory
general_dir <- "2_simanfor/output/"
setwd(general_dir)


#### Read SIMANFOR outputs (just plot information) ####

plots <- tibble()  # will contain plot data
directory <- list.dirs(path = ".")  # will contain folder names

# for each subfolder...
for (folder in directory){ 
        
  # each subfolder is stablished as main one
  specific_dir <- paste(general_dir, "substract", folder, sep = "")
  specific_dir <- gsub("substract.", "", specific_dir)
  setwd(specific_dir)
  
  # extract .xlsx files names
  files_list <- list.files(specific_dir, pattern="xlsx")
  
  # for each file...
  for (doc in files_list){
          
    # read plot data
    plot_data <- read_excel(doc, sheet = "Plots")
  
    # create a new column with its name                
    plot_data$File_name <- doc  
  
    # add information to plot df
    ifelse(length(plots) == 0, plots <- rbind(plot_data), plots <- bind_rows(plots, plot_data))
  }
}


#### Data management - stand and accumulated wood evolution ####

# make a copy of the data
df <- plots  

#-#-#-# clean the plots to use, removing outliers
source('1.1_clean_plots_manually.r')
plot_list <- manual_cleaning_IFN4_mixtures(df)
df <- df[df$Plot_ID %in% plot_list, ]

# function to round on ages on 5 years step
redondeo <- function(x, base){  
        base * round(x/base)
}                                 

# remove initial load
df <- df[!df$Action == "Initial load", ]

# fill NAs with 0 values
df[is.na(df)] <- 0

# group biomass values on 3 groups: stem (WSW), branches (WB) and roots (WR)
df$WB <- df$WTHICKB + df$WB2_7 + df$WTBL + df$WTHINB
df$WB_sp1 <- df$WTHICKB_sp1 + df$WB2_7_sp1 + df$WTBL_sp1 + df$WTHINB_sp1
df$WB_sp2 <- df$WTHICKB_sp2 + df$WB2_7_sp2 + df$WTBL_sp2 + df$WTHINB_sp2

# calculate carbon content by species
# first, carbon proportions related to total w
qpyr_carbon = 0.1841*0.4578 + 0.5427*0.4558 + 0.2732*0.4582  # bark, sapwood and heartwood proportions
ppin_carbon = 46.8/100
pnig_carbon = 46.4/100
psyl_carbon = 45.9/100
fsyl_carbon = 46.7/100

# second, carbon calculation by species
df$CARBON_sp1 <- df$CARBON_sp2 <- df$CARBON <- 0
df$CARBON_s_sp1 <- df$CARBON_s_sp2 <- df$CARBON_s <- 0
df$CARBON_b_sp1 <- df$CARBON_b_sp2 <- df$CARBON_b <- 0
df$CARBON_r_sp1 <- df$CARBON_r_sp2 <- df$CARBON_r <- 0

# total carbon
df$CARBON_sp1 <- ifelse(df$ID_sp1 == 21, df$WT_sp1*psyl_carbon, df$CARBON_sp1)  # psyl
df$CARBON_sp2 <- ifelse(df$ID_sp2 == 21, df$WT_sp2*psyl_carbon, df$CARBON_sp2)  # psyl
df$CARBON_sp1 <- ifelse(df$ID_sp1 == 26, df$WT_sp1*ppin_carbon, df$CARBON_sp1)  # ppin
df$CARBON_sp2 <- ifelse(df$ID_sp2 == 26, df$WT_sp2*ppin_carbon, df$CARBON_sp2)  # ppin
df$CARBON_sp1 <- ifelse(df$ID_sp1 == 25, df$WT_sp1*pnig_carbon, df$CARBON_sp1)  # pnig
df$CARBON_sp2 <- ifelse(df$ID_sp2 == 25, df$WT_sp2*pnig_carbon, df$CARBON_sp2)  # pnig
df$CARBON_sp1 <- ifelse(df$ID_sp1 == 43, df$WT_sp1*qpyr_carbon, df$CARBON_sp1)  # qpyr
df$CARBON_sp2 <- ifelse(df$ID_sp2 == 43, df$WT_sp2*qpyr_carbon, df$CARBON_sp2)  # qpyr
df$CARBON_sp1 <- ifelse(df$ID_sp1 == 71, df$WT_sp1*fsyl_carbon, df$CARBON_sp1)  # fsyl
df$CARBON_sp2 <- ifelse(df$ID_sp2 == 71, df$WT_sp2*fsyl_carbon, df$CARBON_sp2)  # fsyl

# stem carbon
df$CARBON_s_sp1 <- ifelse(df$ID_sp1 == 21, df$WSW_sp1*psyl_carbon, df$CARBON_s_sp1)  # psyl
df$CARBON_s_sp2 <- ifelse(df$ID_sp2 == 21, df$WSW_sp2*psyl_carbon, df$CARBON_s_sp2)  # psyl
df$CARBON_s_sp1 <- ifelse(df$ID_sp1 == 26, df$WSW_sp1*ppin_carbon, df$CARBON_s_sp1)  # ppin
df$CARBON_s_sp2 <- ifelse(df$ID_sp2 == 26, df$WSW_sp2*ppin_carbon, df$CARBON_s_sp2)  # ppin
df$CARBON_s_sp1 <- ifelse(df$ID_sp1 == 25, df$WSW_sp1*pnig_carbon, df$CARBON_s_sp1)  # pnig
df$CARBON_s_sp2 <- ifelse(df$ID_sp2 == 25, df$WSW_sp2*pnig_carbon, df$CARBON_s_sp2)  # pnig
df$CARBON_s_sp1 <- ifelse(df$ID_sp1 == 43, df$WSW_sp1*qpyr_carbon, df$CARBON_s_sp1)  # qpyr
df$CARBON_s_sp2 <- ifelse(df$ID_sp2 == 43, df$WSW_sp2*qpyr_carbon, df$CARBON_s_sp2)  # qpyr
df$CARBON_s_sp1 <- ifelse(df$ID_sp1 == 71, df$WSW_sp1*fsyl_carbon, df$CARBON_s_sp1)  # fsyl
df$CARBON_s_sp2 <- ifelse(df$ID_sp2 == 71, df$WSW_sp2*fsyl_carbon, df$CARBON_s_sp2)  # fsyl

# branches carbon
df$CARBON_b_sp1 <- ifelse(df$ID_sp1 == 21, df$WB_sp1*psyl_carbon, df$CARBON_b_sp1)  # psyl
df$CARBON_b_sp2 <- ifelse(df$ID_sp2 == 21, df$WB_sp2*psyl_carbon, df$CARBON_b_sp2)  # psyl
df$CARBON_b_sp1 <- ifelse(df$ID_sp1 == 26, df$WB_sp1*ppin_carbon, df$CARBON_b_sp1)  # ppin
df$CARBON_b_sp2 <- ifelse(df$ID_sp2 == 26, df$WB_sp2*ppin_carbon, df$CARBON_b_sp2)  # ppin
df$CARBON_b_sp1 <- ifelse(df$ID_sp1 == 25, df$WB_sp1*pnig_carbon, df$CARBON_b_sp1)  # pnig
df$CARBON_b_sp2 <- ifelse(df$ID_sp2 == 25, df$WB_sp2*pnig_carbon, df$CARBON_b_sp2)  # pnig
df$CARBON_b_sp1 <- ifelse(df$ID_sp1 == 43, df$WB_sp1*qpyr_carbon, df$CARBON_b_sp1)  # qpyr
df$CARBON_b_sp2 <- ifelse(df$ID_sp2 == 43, df$WB_sp2*qpyr_carbon, df$CARBON_b_sp2)  # qpyr
df$CARBON_b_sp1 <- ifelse(df$ID_sp1 == 71, df$WB_sp1*fsyl_carbon, df$CARBON_b_sp1)  # fsyl
df$CARBON_b_sp2 <- ifelse(df$ID_sp2 == 71, df$WB_sp2*fsyl_carbon, df$CARBON_b_sp2)  # fsyl

# roots carbon
df$CARBON_r_sp1 <- ifelse(df$ID_sp1 == 21, df$WR_sp1*psyl_carbon, df$CARBON_r_sp1)  # psyl
df$CARBON_r_sp2 <- ifelse(df$ID_sp2 == 21, df$WR_sp2*psyl_carbon, df$CARBON_r_sp2)  # psyl
df$CARBON_r_sp1 <- ifelse(df$ID_sp1 == 26, df$WR_sp1*ppin_carbon, df$CARBON_r_sp1)  # ppin
df$CARBON_r_sp2 <- ifelse(df$ID_sp2 == 26, df$WR_sp2*ppin_carbon, df$CARBON_r_sp2)  # ppin
df$CARBON_r_sp1 <- ifelse(df$ID_sp1 == 25, df$WR_sp1*pnig_carbon, df$CARBON_r_sp1)  # pnig
df$CARBON_r_sp2 <- ifelse(df$ID_sp2 == 25, df$WR_sp2*pnig_carbon, df$CARBON_r_sp2)  # pnig
df$CARBON_r_sp1 <- ifelse(df$ID_sp1 == 43, df$WR_sp1*qpyr_carbon, df$CARBON_r_sp1)  # qpyr
df$CARBON_r_sp2 <- ifelse(df$ID_sp2 == 43, df$WR_sp2*qpyr_carbon, df$CARBON_r_sp2)  # qpyr
df$CARBON_r_sp1 <- ifelse(df$ID_sp1 == 71, df$WR_sp1*fsyl_carbon, df$CARBON_r_sp1)  # fsyl
df$CARBON_r_sp2 <- ifelse(df$ID_sp2 == 71, df$WR_sp2*fsyl_carbon, df$CARBON_r_sp2)  # fsyl

# third, total carbon is calculated
df$CARBON <- df$CARBON_sp1 + df$CARBON_sp2
df$CARBON_s <- df$CARBON_s_sp1 + df$CARBON_s_sp2
df$CARBON_b <- df$CARBON_b_sp1 + df$CARBON_b_sp2
df$CARBON_r <- df$CARBON_r_sp1 + df$CARBON_r_sp2

# calculate differences per scenario step on the desired variables
# that is the first step to record losses and gains due to thinning
df <- df %>%
  group_by(File_name, Scenario_file_name) %>%
  mutate(V_diff = V - lag(V),
         WSW_diff= WSW - lag(WSW),
         WTHICKB_diff= WTHICKB - lag(WTHICKB),
         WB2_7_diff= WB2_7 - lag(WB2_7),
         WTHINB_diff= WTHINB - lag(WTHINB),
         WTBL_diff= WTBL - lag(WTBL),
         #WSTB_diff= WSTB - lag(WSTB),
         WB_diff= WB - lag(WB),
         WR_diff= WR - lag(WR),
         WT_diff= WT - lag(WT),
         CARBON_diff= CARBON - lag(CARBON),
         CARBON_s_diff= CARBON_s - lag(CARBON_s),
         CARBON_b_diff= CARBON_b - lag(CARBON_b),
         CARBON_r_diff= CARBON_r - lag(CARBON_r),
)

# skip future errors
df <- df[!is.na(df$CARBON_diff), ]

# create a new df with accumulated values
new_df <- tibble()

# for each scenario...
for(scnr in unique(df$Scenario_file_name)){
  
  # get data
  scnr <- df[df$Scenario_file_name == scnr, ]
  
  # for each plot in the scenario...
  for(plot in unique(scnr$File_name)){
    
    # get data
    plot <- scnr[scnr$File_name == plot, ]
    
    # stablish initial values for accumulated variables as 0
    all_V <- all_WSW <- all_WTHICKB <- all_WB2_7 <- all_WTHINB <- all_WTBL <- all_WB <- all_WR <- all_WT <- 0
    all_CARBON <- all_CARBON_s <- all_CARBON_b <- all_CARBON_r <- 0
    
    # for each row...
    for(row in 1:nrow(plot)){
      
      # select data
      new_row <- plot[row, ]
      
      # if it is row 1, then initial values must be taken
      if(row == 1){
        
        # get initial value
        all_V <- new_row$V
        all_WSW <- new_row$WSW
        all_WTHICKB <- new_row$WTHICKB
        all_WB2_7 <- new_row$WB2_7
        all_WTHINB <- new_row$WTHINB
        all_WTBL <- new_row$WTBL
        #all_WSTB <- new_row$WSTB
        all_WB <- new_row$WB
        all_WR <- new_row$WR
        all_WT <- new_row$WT
        all_CARBON <- new_row$CARBON
        all_CARBON_s <- new_row$CARBON_s
        all_CARBON_b <- new_row$CARBON_b
        all_CARBON_r <- new_row$CARBON_r
        
        # add value to the row
        new_row$V_all <- all_V
        new_row$WSW_all <- all_WSW
        new_row$WTHICKB_all <- all_WTHICKB
        new_row$WB2_7_all <- all_WB2_7
        new_row$WTHINB_all <- all_WTHINB
        new_row$WTBL_all <- all_WTBL
        #new_row$WSTB_all <- all_WSTB
        new_row$WB_all <- all_WB
        new_row$WR_all <- all_WR
        new_row$WT_all <- all_WT
        new_row$CARBON_all <- all_CARBON
        new_row$CARBON_s_all <- all_CARBON_s
        new_row$CARBON_b_all <- all_CARBON_b
        new_row$CARBON_r_all <- all_CARBON_r
        
      # if it is another row, then difference between rows is added in abs()
      } else {
        
        # add increment to the previous value
        all_V <- all_V + abs(new_row$V_diff)
        all_WSW <- all_WSW + abs(new_row$WSW_diff)
        all_WTHICKB <- all_WTHICKB + abs(new_row$WTHICKB_diff)
        all_WB2_7 <- all_WB2_7 + abs(new_row$WB2_7_diff)
        all_WTHINB <- all_WTHINB + abs(new_row$WTHINB_diff)
        all_WTBL <- all_WTBL + abs(new_row$WTBL_diff)
        #all_WSTB <- all_WSTB + abs(new_row$WSTB_diff)
        all_WB <- all_WB + abs(new_row$WB_diff)
        all_WR <- all_WR + abs(new_row$WR_diff)
        all_WT <- all_WT + abs(new_row$WT_diff)
        all_CARBON <- all_CARBON + abs(new_row$CARBON_diff)
        all_CARBON_s <- all_CARBON_s + abs(new_row$CARBON_s_diff)
        all_CARBON_b <- all_CARBON_b + abs(new_row$CARBON_b_diff)
        all_CARBON_r <- all_CARBON_r + abs(new_row$CARBON_r_diff)
        
        # add value to the row
        new_row$V_all <- all_V
        new_row$WSW_all <- all_WSW
        new_row$WTHICKB_all <- all_WTHICKB
        new_row$WB2_7_all <- all_WB2_7
        new_row$WTHINB_all <- all_WTHINB
        new_row$WTBL_all <- all_WTBL
        #new_row$WSTB_all <- all_WSTB
        new_row$WB_all <- all_WB
        new_row$WR_all <- all_WR
        new_row$WT_all <- all_WT
        new_row$CARBON_all <- all_CARBON
        new_row$CARBON_s_all <- all_CARBON_s
        new_row$CARBON_b_all <- all_CARBON_b
        new_row$CARBON_r_all <- all_CARBON_r
      }
      
      # add new row to a new df
      new_df <- rbind(new_df, new_row)
      
    } # row
  } # plot
} # scenario

# round ages
new_df$T <- redondeo(new_df$T, 5) 

# get scenario code
new_df$n_scnr <- substr(new_df$Scenario_file_name, 4, 15)

# delete empty rows
new_df <- new_df[!is.na(new_df$n_scnr), ]

rm(df, new_row, plot, plot_data, plots, scnr, all_V, all_WB2_7, all_WR, all_WSW,
   all_WT, all_WTBL, all_WTHICKB, all_WTHINB, all_WB, directory, doc, files_list, 
   all_WSTB, general_dir, row, specific_dir, redondeo, folder, plot_list, manual_cleaning_IFN4_mixtures, 
   all_CARBON, fsyl_carbon, pnig_carbon, ppin_carbon, psyl_carbon, qpyr_carbon, all_CARBON_b, all_CARBON_r, all_CARBON_s)


#### Mean accumulated stand evolution ####

# mean values by scenario and year
stand_evolution <- ddply(new_df, c('n_scnr', 'T'), summarise, 
                          
                          # general variables                         
                          N = mean(N, na.rm = TRUE),                  
                          dg = mean(dg, na.rm = TRUE),
                          Ho = mean(Ho, na.rm = TRUE),  
                          V = mean(V, na.rm = TRUE), 
                          G = mean(G, na.rm = TRUE),
                          
                          # biomass classification - stand variables
                          WSW = mean(WSW, na.rm = TRUE),
                          WTHICKB = mean(WTHICKB, na.rm = TRUE),
                          WB2_7 = mean(WB2_7, na.rm = TRUE),
                          WTHINB = mean(WTHINB, na.rm = TRUE),
                          WTBL = mean(WTBL, na.rm = TRUE),
                          #WSTB = mean(WSTB, na.rm = TRUE), 
                          WB = mean(WB, na.rm = TRUE), 
                          WR = mean(WR, na.rm = TRUE),
                          WT = mean(WT, na.rm = TRUE), 
                          CARBON = mean(CARBON, na.rm = TRUE), 
                          CARBON_s = mean(CARBON_s, na.rm = TRUE), 
                          CARBON_b = mean(CARBON_b, na.rm = TRUE), 
                          CARBON_r = mean(CARBON_r, na.rm = TRUE), 
                          
                          # all accumulated stand variables
                          WSW_all = mean(WSW_all, na.rm = TRUE),
                          WTHICKB_all = mean(WTHICKB_all, na.rm = TRUE),
                          WB2_7_all = mean(WB2_7_all, na.rm = TRUE),
                          WTHINB_all = mean(WTHINB_all, na.rm = TRUE),
                          WTBL_all = mean(WTBL_all, na.rm = TRUE),
                          #WSTB_all = mean(WSTB_all, na.rm = TRUE),
                          WB_all = mean(WB_all, na.rm = TRUE),
                          WR_all = mean(WR_all, na.rm = TRUE),
                          WT_all = mean(WT_all, na.rm = TRUE),
                          CARBON_all = mean(CARBON_all, na.rm = TRUE),
                          CARBON_s_all = mean(CARBON_s_all, na.rm = TRUE),
                          CARBON_b_all = mean(CARBON_b_all, na.rm = TRUE),
                          CARBON_r_all = mean(CARBON_r_all, na.rm = TRUE),
                          V_all = mean(V_all, na.rm = TRUE)
)


#### Save results ####

save.image('../../1_data/simulation_results.RData')
