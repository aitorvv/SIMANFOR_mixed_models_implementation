#------------------------------------------------------------------------------------------#
####                           Plot SIMANFOR biomass results                            ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 31/03/2022                              #
#                              Last modification: 19/10/2023                               #
#------------------------------------------------------------------------------------------#


#### Basic steps ####

library(ggplot2)
library(viridis)
library(dplyr)
library(stringr)

setwd('')


#### Load data ####

# load information
load('1_data/simulation_results.RData')

# rename to simplify
df <- stand_evolution

# delete growth extra period on control simulations
df <- df[df$T <= 120, ]


#### Manage data before graph them ####

# column for mixture
df$Mixture <- ifelse(str_detect(df$n_scnr, 'Fsyl'), 'Psylvestris x Fsylvatica',
                     ifelse(str_detect(df$n_scnr, 'Qpyr'), 'Psylvestris x Qpyrenaica',
                                 ifelse(str_detect(df$n_scnr, 'Ppin'), 'Psylvestris x Ppinaster', 
                                        'Psylvestris x Pnigra')))

# rename scenario labels
df$n_scnr <- ifelse(str_detect(df$n_scnr, 'c12'), 'SI 12',
                     ifelse(str_detect(df$n_scnr, 'c15'), 'SI 15',
                            ifelse(str_detect(df$n_scnr, 'c18'), 'SI 18', 
                                   ifelse(str_detect(df$n_scnr, 'c21'), 'SI 21',
                                          ifelse(str_detect(df$n_scnr, 'c24'), 'SI 24', 'Control')))))


#### Graph Density among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = N, 
         group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand density evolution",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Density (trees/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines

  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/N.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph DG among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = dg, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand quadratic mean diameter evolution",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Quadratic mean diameter (cm)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/DG.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph G among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = G, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand basal area evolution",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Stand basal area (m²/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/G.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph Ho among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = Ho, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand dominant height evolution",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Dominant height (m)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/HO.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph V among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = V, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand volume evolution",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Volume over bark (m³/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/V.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph V_all among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = V_all, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand volume production (harvested included)",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Volume over bark (m³/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
    
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/V_all.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph WT among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = WT, 
                 group = n_scnr, colour = n_scnr,)) +  # group by scnr
  
  # text
  labs(title = "Stand total biomass production",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Total biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WT.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph WT_all among treatments ####

graph <- 
  ggplot(df, aes(x = T, y = WT_all, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand total biomass production (harvested included)",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Total biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_all), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_all)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WT_all.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph W divided in parts among treatments: WR ####

graph <- 
  ggplot(df, aes(x = T, y = WR, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand root biomass production",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Root biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_r), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_r)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WR.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph W divided in parts among treatments: WB ####

graph <- 
  ggplot(df, aes(x = T, y = WB, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand branches biomass production",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Branches biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_b), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_b)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WB.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph W divided in parts among treatments: WSW ####

graph <- 
  ggplot(df, aes(x = T, y = WSW, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand stem biomass production",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Stem biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_s), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_s)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WSW.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph W divided in parts among treatments: WR_all ####

graph <- 
  ggplot(df, aes(x = T, y = WR_all, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand root biomass production (harvested included)",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Root biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_r_all), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_r_all)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WR_all.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph W divided in parts among treatments: WB_all ####

graph <- 
  ggplot(df, aes(x = T, y = WB_all, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand branches biomass production (harvested included)",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Branches biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_b_all), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_b_all)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WB_all.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)


#### Graph W divided in parts among treatments: WSW_all ####

graph <- 
  ggplot(df, aes(x = T, y = WSW_all, 
                 group = n_scnr, colour = n_scnr)) +  # group by scnr
  
  # text
  labs(title = "Stand stem biomass production (harvested included)",  
       # subtitle = "",  
       x = "Stand age (years)",  
       y = "Stem biomass (tn/ha)"   
  ) +
  
  # text position and size
  theme(plot.title = element_text(size = 20, hjust = 0.5), # title  
        # plot.subtitle = element_text(size = 15, hjust = 0.5),  
        axis.title = element_text(size = 15),  # axis
        legend.title = element_text(size = 15),  # legend title
        legend.text = element_text(size = 12)) +  # legend content
  
  # set colors and legend name manually
  scale_color_viridis('Scenario', discrete = TRUE, option = "D")+
  scale_fill_viridis(discrete = TRUE) +
  
  # plot data
  geom_point() +  # points
  geom_line() +  # lines
  
  # plot carbon data
  geom_point(aes(x = T, y = CARBON_s_all), shape = 1) +  # points
  geom_line(aes(x = T, y = CARBON_s_all)) +  # lines
  
  # one graph per mixture
  facet_wrap(~ Mixture, scale = 'free')

# watch and save graph
graph
ggsave(filename = '4_figures/simulation_graphs/WSW_all.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)
