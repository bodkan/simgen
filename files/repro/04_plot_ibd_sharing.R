library(readr)
library(dplyr)
library(ggplot2)


# ---------------------------------------------------------
# read and filter IBD segments
# ---------------------------------------------------------

ibd_merged <- read_tsv("/tmp/asdf/data/processed/ibd_merged.tsv", show_col_types = FALSE) %>%
  filter(length > 5, time_pair == "present-day:present-day")


# ---------------------------------------------------------
# plot individual histograms
# ---------------------------------------------------------

# plot pairs within Europe
p_europe <-
  ibd_merged %>%
  filter(region_pair == "Europe:Europe") %>%
  ggplot(aes(length, fill = country_pair)) +
  geom_histogram() +
  labs(x = "IBD segment length [centimorgans]",
       title = "Distribution of lengths longer than 5 cM in Europe") +
  coord_cartesian(xlim = c(0, 50)) +
  facet_wrap(~country_pair)

# plot pairs within Americas
p_america <-
  ibd_merged %>%
  filter(region_pair == "America:America") %>%
  ggplot(aes(length, fill = country_pair)) +
  geom_histogram() +
  labs(x = "IBD segment length [centimorgans]",
       title = "Distribution of lengths longer than 5 cM in the Americas") +
  coord_cartesian(xlim = c(0, 50)) +
  facet_wrap(~country_pair)

# plot pairs within Asia
p_asia <-
  ibd_merged %>%
  filter(region_pair == "Asia:Asia") %>%
  ggplot(aes(length, fill = country_pair)) +
  geom_histogram() +
  labs(x = "IBD segment length [centimorgans]",
       title = "Distribution of lengths longer than 5 cM in Asia") +
  coord_cartesian(xlim = c(0, 50)) +
  facet_wrap(~country_pair)

# plot pairs within Africa
p_africa <- ibd_merged %>%
  filter(region_pair == "Africa:Africa") %>%
  ggplot(aes(length, fill = country_pair)) +
  geom_histogram() +
  labs(x = "IBD segment length [centimorgans]",
       title = "Distribution of lengths longer than 5 cM in Africa") +
  coord_cartesian(xlim = c(0, 50)) +
  facet_wrap(~country_pair)

# ---------------------------------------------------------
# save all figures to a PDF
# ---------------------------------------------------------

pdf("figures/ibd_sharing.pdf", width = 10, height = 6)

print(p_europe)
print(p_america)
print(p_asia)
print(p_africa)

dev.off()