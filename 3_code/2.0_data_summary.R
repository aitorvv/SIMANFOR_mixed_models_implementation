#------------------------------------------------------------------------------------------#
####                           Initial data summary by group                            ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 26/07/2023                              #
#                              Last modification: 25/10/2023                               #
#------------------------------------------------------------------------------------------#


#### Basic steps ####

library(qwraps2)

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


#### Summarise data ####

our_summary <-
  list(
    "AGE (years)" =
      list("min"       = ~ min(AGE),
           "max"       = ~ max(AGE),
           "mean (sd)" = ~ qwraps2::mean_sd(AGE)),
    "N (trees/ha)" =
      list("min"       = ~ min(N),
           "max"       = ~ max(N),
           "mean (sd)" = ~ qwraps2::mean_sd(N)),
    "DG (cm)" =
         list("min"       = ~ min(dg),
              "max"       = ~ max(dg),
              "mean (sd)" = ~ qwraps2::mean_sd(dg)),
    "G (m²/ha)" =
         list("min"       = ~ min(G),
              "max"       = ~ max(G),
              "mean (sd)" = ~ qwraps2::mean_sd(G)),
    "Ho (m)" =
      list("min"       = ~ min(Ho),
           "max"       = ~ max(Ho),
           "mean (sd)" = ~ qwraps2::mean_sd(Ho))
  )

# summary by groups
df_summary <- summary_table(dplyr::group_by(df, Mixture), our_summary)
df_summary

# export results
write.csv(df_summary, '4_figures/summary_table.csv')
