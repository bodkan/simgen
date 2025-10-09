# Silence annoying startup information
suppressPackageStartupMessages({
library(dplyr)
library(readr)
})

cat("Beginning data processing!\n")
cat("--------------------\n")

# Yes we originally put this code in separate functions and we could also
# do it here as well. But let's keep things simple for the purpose of this
# exercise.

# processing metadata -----------------------------------------------------


cat("Processing raw metadata...\n")

metadata <- read_tsv("data/raw/metadata.tsv", show_col_types = FALSE)

# select a subset of columns
metadata <- metadata %>%
  select(sampleId, country, continent, ageAverage, coverage, longitude, latitude) %>%
  rename(sample = sampleId, age = ageAverage)

# replace missing ages of present-day individuals with 0
metadata <- mutate(metadata, age = if_else(is.na(age), 0, age))
# ignore archaic individuals
metadata <- filter(metadata, !sample %in% c("Vindija33.19", "AltaiNeandertal", "Denisova"))

# bin individuals according to their age
metadata$age_bin <- cut(metadata$age, breaks = seq(0, 50000, by = 10000), dig.lab = 10)
bin_levels <- levels(metadata$age_bin)

metadata <- metadata %>%
  mutate(
    age_bin = as.character(age_bin),
    age_bin = if_else(is.na(age_bin), "present-day", age_bin),
    age_bin = factor(age_bin, levels = c("present-day", bin_levels))
  )

write_tsv(metadata, "data/processed/metadata.tsv")


# processing IBD segments -------------------------------------------------

cat("Processing table of IBD segments of chromosome 21...\n")

# read the raw IBD segment coordinates (from where we originally downloaded
# them from), and process them accordingly by adding a new `length` column
ibd_segments <-
  read_tsv("data/raw/ibd_segments.tsv", show_col_types = FALSE) %>%
  mutate(length = end - start)


# merging IBD table with metadata -----------------------------------------

cat("Joining IBD data and metadata...\n")

# prepare metadata for IBD annotation
metadata1 <- select(metadata, -coverage, -longitude, -latitude)
metadata2 <- select(metadata, -coverage, -longitude, -latitude)
colnames(metadata1) <- paste0(colnames(metadata1), "1")
colnames(metadata2) <- paste0(colnames(metadata2), "2")

# merge in metadata based on sample1 and sample2 columns
ibd_merged <-
  ibd_segments %>%
  inner_join(metadata1, by = "sample1") %>%
  inner_join(metadata2, by = "sample2")

# annotate with new columns indicating a pair of countries or time bins
ibd_merged <- mutate(
  ibd_merged,
  country_pair = paste(country1, country2, sep = ":"),
  region_pair = paste(continent1, continent2, sep = ":"),
  time_pair = paste(age_bin1, age_bin2, sep = ":"),
  .before = chrom
)

write_tsv(ibd_merged, "data/processed/ibd_merged.tsv")


# processing IBD summary data ---------------------------------------------

cat("Downloading processed IBD summary table...\n")

# Because we have the (already processed) IBD summary data for the entire genome
# (not just chromosome 21) on the internet, we just download and save them in
# their proper location

ibd_sum <- read_tsv("http://tinyurl.com/simgen-ibd-sum", show_col_types = FALSE)
write_tsv(ibd_sum, "data/processed/ibd_sum.tsv")

cat("--------------------\n")
cat("All data successfully processed!\n")