# SIMANFOR mixed models implementation

*A repository with the original data, code and results of: **Mixed forest model parameterization and integration into simulation platforms as a tool for decision-making processes***

---

# Mixed forest model parameterization and integration into simulation platforms as a tool for decision-making processes

DOI: 

---

## Abstract

Mixed forests are crucial to climate resilience in Mediterranean ecosystems and show great potential for mitigating the effects of climate change. Proper parameterization and integration of mixed-forest models into simulation platforms are needed to understand how mixed forests influence delivery of important environmental services. In this study, a climate-sensitive growth model for mixed forests was implemented on SIMANFOR, offering parameterizations for a total of 29 species mixtures. After describing this upgrade and its potential applications, a case study is presented that demonstrates mixed-model performance using data from the Spanish Fourth National Forest Inventory (SNFI4) and previously developed silviculture scenarios as starting points. The case study analyzed four different mixtures of Pinus sylvestris with Pinus nigra, Pinus pinaster, Fagus sylvatica, and Quercus pyrenaica, which were selected for their complementarity, productivity, and resource-use efficiency. All simulations were done on the SIMANFOR platform. The results show that thinned mixed stands exhibited higher quadratic mean diameter, biomass and carbon content compared to unthinned stands. The differences observed in biomass and carbon allocation among silvicultural scenarios were consistent in all mixtures. Case studies like this one show how simulations can play a crucial role in understanding the potential of different mixtures and in orientating forest management guidelines. The model implemented on SIMANFOR is ready to use on the cloud service. 

---

## Repository Contents

- :floppy_disk: **1_data**:
    
    - :sunny: climate data obtained from [WorldClim data](https://www.worldclim.org/data/index.html)
        
    - :deciduous_tree: tree and plot data obtained from [SFNI3 and 4 data](https://www.miteco.gob.es/es/biodiversidad/temas/inventarios-nacionales/inventario-forestal-nacional/cuarto_inventario.html)


- :seedling: **2_simanfor** contains inputs and outputs for all the simulations developed with [SIMANFOR](www.simanfor.es). Check out them! There are a lot of metrics unexplored in this paper :wood: :maple_leaf:

- :computer: **3_code**:


| Script Name     | Purpose               | Input                    | Output                   |
|-----------------|-----------------------|--------------------------|--------------------------|
| `0.0_SFNI4_data_curation.r` `0.1_SFNI_functions` *code to extract data from WorldClim not attached*| Uses the original SFNI4 data to adapt them to the SIMANFOR requirements| [SFNI4 data](https://www.miteco.gob.es/es/biodiversidad/temas/inventarios-nacionales/inventario-forestal-nacional/cuarto_inventario.html), [WorldClim data](https://www.worldclim.org/data/index.html), `1_data/IFN3_plots*` | `1_data/IFN4_*` data
| `1.0_group_simanfor_results.r`| Reads all the SIMANFOR outputs, complete the calculations and organize them to be graph | `2_simanfor/output/*` | `1_data/simulation_results.RData` |
| `1.1_clean_plots_manually.r` | Function created to delete plots that cause noise on the final results | - | - |
| `1.2_graph_simanfor_results.r` | Code to make graphs of all the interesting variables | `1_data/simulation_results.RData` | `4_figures/simulation_graphs/*` |
| `2.0_data_summary.r` | Code to create a data summary of the principal variable with the used plots | `1_data/simulation_results.RData` | `4_figures/summary_table.csv` |
| `2.1_location_map.r` | Code to draw a map with the plot locations | `1_data/simulation_results.RData` | `IFN4_plots_map_*` |

- :bar_chart: **4_figures**: graphs and figures used on the article

- :books: **5_bibliography**: recopilation of all the references used on the article

---

:link: About us:

[Aitor Vázquez Veloso](https://github.com/aitorvv): 
[ORCID](https://orcid.org/0000-0003-0227-506X) \\
[Researchgate](https://www.researchgate.net/profile/Aitor_Vazquez_Veloso) \\
[LinkedIn](https://www.linkedin.com/in/aitorvazquezveloso/) \\
[Twitter](https://twitter.com/aitorvv) \\
[iuFOR](http://sostenible.palencia.uva.es/users/aitorvv)


[Felipe Bravo Oviedo](https://github.com/Felipe-Bravo): 
[ORCID](https://orcid.org/0000-0001-7348-6695) \\
[Researchgate](https://www.researchgate.net/profile/Felipe-Bravo-11) \\
[LinkedIn](https://www.linkedin.com/in/felipebravooviedo) \\
[Twitter](https://twitter.com/fbravo_SFM) \\
[iuFOR](http://sostenible.palencia.uva.es/users/fbravo)

---


[SIMANFOR mixed models implementation](https://github.com/aitorvv/SIMANFOR_mixed_models_implementation) 