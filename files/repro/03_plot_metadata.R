library(ggplot2)
library(dplyr)
library(readr)

metadata <- read_tsv("data/processed/metadata.tsv", show_col_types = FALSE)

# create the barplot of counts of individuals in each age bin
p_counts_bar <- metadata %>%
  ggplot(aes(x = age_bin)) +
  geom_bar() +
  xlab("Time period [years before present]") +
  ylab("Number of individuals") +
  ggtitle("Distribution of sample counts in each time period")

# create a variation of the same barplot, with y-axis on the log-scale
p_counts_bar_log <- p_counts_bar + scale_y_log10()

# create a histogram of coverages in each age bin
p_cov_hist <- metadata %>%
  ggplot(aes(coverage, fill = age_bin)) +
  geom_histogram() +
  facet_wrap(~ age_bin, scales = "free_y")

# create an empty PDF file
pdf("figures/metadata.pdf", width = 8, height = 6)

# add figures to the PDF
print(p_counts_bar)
print(p_counts_bar_log)
print(p_cov_hist)

# close the PDF file
dev.off()