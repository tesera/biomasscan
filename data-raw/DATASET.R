## code to prepare `DATASET` dataset goes here
# The CSV files were downloaded from https://apps-scf-cfs.rncan.gc.ca/calc/en/biomass-calculator
# on July 11 2023
library(tidyverse)

# Tree-level, height and DBH
# For now, focus on only English names
allo_tree_dbh_height <- read_csv('data-raw/Tree-level allometric equations dbh-height.csv',
                                 skip = 5L) |>
    rename(Species = Species_en,
           Component = Component_en) |>
    select(Species, Component, a, b, c)

# Tree-level, DBH only
# For now, focus on only English names
allo_tree_dbh <- read_csv('data-raw/Tree-level allometric equations dbh.csv',
                          skip = 6L) |>
    rename(Species = Species_en,
           Component = Component_en) |>
    select(Species, Component, a, b)

# Plot level, basal area
# For now, focus on only English names
allo_plot_basal_area <- read_csv('data-raw/Plot-level allometric equations.csv',
                                 skip = 9L)

usethis::use_data(allo_tree_dbh_height,
                  allo_tree_dbh,
                  allo_plot_basal_area,
                  overwrite = TRUE,
                  internal = TRUE)
