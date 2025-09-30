library(ggplot2) # the star of the day!

library(dplyr)
library(tidyr)
library(readr)

process_ibd <- function() {
  cat("Downloading and processing IBD data...\n")

  gz_file <- tempfile()
  download.file("https://tinyurl.com/simgen-ibd", gz_file, mode = "wb", quiet = TRUE)
  ibd_all <- read_tsv(gz_file, show_col_types = FALSE)

  ibd <- ibd_all %>% mutate(length = end - start)

  return(ibd)
}

process_metadata <- function() {
  cat("Downloading and processing metadata...\n")

  metadata_all <- read_tsv("https://tinyurl.com/simgen-metadata", show_col_types = FALSE)

  # select a subset of columns
  metadata <- metadata_all %>%
    select(sampleId, popId, country, continent, ageAverage, coverage, longitude, latitude) %>%
    rename(sample = sampleId, population = popId, age = ageAverage)

  # replace missing ages of present-day individuals with 0
  metadata <- mutate(metadata, age = if_else(is.na(age), 0, age))
  # ignore archaic individuals
  metadata <- filter(metadata, !sample %in% c("Vindija33.19", "AltaiNeandertal", "Denisova"))

  # bin individuals according to their age
  metadata$age_bin <- cut(metadata$age, breaks = c(0, 10000, 20000, 30000, 40000, 50000), dig.lab = 10)
  bin_levels <- levels(metadata$age_bin)

  metadata <- metadata %>%
    mutate(
      age_bin = as.character(age_bin),
      age_bin = if_else(is.na(age_bin), "present-day", age_bin),
      age_bin = factor(age_bin, levels = c("present-day", bin_levels))
    )

  return(metadata)
}

join_metadata <- function(ibd, metadata) {
  cat("Joining IBD data and metadata...\n")

  # prepare metadata for IBD annotation
  metadata1 <- select(metadata, -population, -coverage)
  metadata2 <- select(metadata, -population, -coverage)
  colnames(metadata1) <- paste0(colnames(metadata1), "1")
  colnames(metadata2) <- paste0(colnames(metadata2), "2")

  # join based on sample1
  ibd <- inner_join(ibd, metadata1)
  # join based on sample2
  ibd <- inner_join(ibd, metadata2)

  # annotate with new columns indicating a pair of countries or time bins
  ibd <- mutate(ibd,
                country_pair = paste(country1, country2, sep = ":"),
                region_pair = paste(region1, region2, sep = ":"),
                time_pair = paste(age_bin1, age_bin2, sep = ":"),
                .before = chrom)

  # drop columns which are not needed anymore
  ibd <- select(ibd, -c(country1, country2, continent1, continent2, age1, age2))

  return(ibd)
}