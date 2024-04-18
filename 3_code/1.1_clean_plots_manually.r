#------------------------------------------------------------------------------------------#
####                       Explore and clean outliers from plots                        ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 25/10/2022                              #
#                              Last modification: 25/10/2023                               #
#------------------------------------------------------------------------------------------#

manual_cleaning_IFN4_mixtures <- function(df){
    
  # filter initial conditions
  df <- df[df$Action == "Initial load", ]
  df <- df[!duplicated(df$Plot_ID), ]
  
  ## split by mixture
  # PsylFsyl not needed, just 2 plots
  df_fsyl <- df[grep('Fsyl', df$Scenario_file_name), ]
  
  # PsylQpyr
  df_qpyr <- df[grep('Qpyr', df$Scenario_file_name), ]
  
  # clean by N and T
  df_qpyr <- df_qpyr[df_qpyr$N > 400 & df_qpyr$N < 2300, ]
  
  # PsylPpin
  df_ppin <- df[grep('Ppin', df$Scenario_file_name), ]
  
  # clean by N and T
  df_ppin <- df_ppin[df_ppin$N > 300 & df_ppin$N < 1500, ]
  df_ppin <- df_ppin[df_ppin$T < 95, ]
  
  # PsylPnig
  df_pnig <- df[grep('Pnig', df$Scenario_file_name), ]
  
  # clean by N
  df_pnig <- df_pnig[df_pnig$N > 300, ]
  
  # regroup them in a cleaned df 
  final_df <- rbind(df_fsyl, df_qpyr, df_pnig, df_ppin)

  # clean by AGE
  # final_df <- final_df[final_df$T < 60, ]
  
  # get list of plot_id
  final_plots <- final_df$Plot_ID
  
  return(final_plots)  
}