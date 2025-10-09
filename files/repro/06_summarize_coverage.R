library(dplyr)
library(readr)

# read the processed table of metadata
metadata <- read_tsv("data/processed/metadata.tsv", show_col_types = FALSE)

df_summary <-
  metadata %>%
  filter(continent == "Europe" & age > 0) %>%  # 1. filter for aDNA samples from Europe
  group_by(country, age_bin) %>%               # 2. create groupings by country and time bin
  summarize(                                   # 3. for each group compute
    avg_coverage = mean(coverage),             #   - average coverage
    n_samples = n()                            #   - number of samples
  ) %>%
  arrange(desc(n_samples))                     # 4. sort the table by the number of samples

# save the results in a new file
write_tsv(df_summary, "results/coverage_summary.tsv")