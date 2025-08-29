# This script contains everything that's required to solve every exercise
# in the activity based on the solutions provided in the exercises.qmd file.

install.packages(c("optparse",
                   "slendr", "combinat", "cowplot", "dplyr", "readr", "admixr",
                   "sf", "stars", "rnaturalearth",
                   "ggrepel", "viridis", "tidyr", "ggplot2", "rmarkdown", "yaml", "smartsnp"))

library(slendr)
setup_env(agree = TRUE)
