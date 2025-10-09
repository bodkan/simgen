library(readr)
library(dplyr)
library(ggplot2)


# ---------------------------------------------------------
# read and filter IBD segments
# ---------------------------------------------------------

ibd_sum <- read_tsv("data/processed/ibd_sum.tsv", show_col_types = FALSE)


# ---------------------------------------------------------
# plot the scatterplot of individual IBD relatedness
# ---------------------------------------------------------

ibd_unrel <- filter(ibd_sum, rel == "none")
ibd_rel <- filter(ibd_sum, rel != "none")

ggplot() +
  geom_point(data = ibd_unrel, aes(x = total_ibd, y = n_ibd), color = "lightgray", size = 0.75) +
  geom_point(data = ibd_rel, aes(x = total_ibd, y = n_ibd, color = rel, shape = rel)) +
  labs(
    x = "total IBD sequence",
    y = "number of IBD segments",
    title = "Total IBD sequence vs number of IBD segments",
    subtitle = "Both quantities computed only on IBD segments 10 cM or longer"
  ) +
  guides(
    color = guide_legend(title = "relatedness"),
    shape = guide_legend(title = "relatedness")
  ) +
  theme_minimal()


# ---------------------------------------------------------
# save all figures to a PDF
# ---------------------------------------------------------

ggsave("figures/ibd_relatedness.pdf", width = 8, height = 6)