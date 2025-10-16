suppressPackageStartupMessages({
library(dplyr)
library(readr)
})

process_ibd <- function() {
  cat("Downloading and processing IBD data...\n")

  ibd_segments <- read_tsv("https://tinyurl.com/simgen-ibd-segments",
                           show_col_types = FALSE)

  ibd <- ibd_segments %>% mutate(length = end - start)

  return(ibd)
}

process_metadata <- function(bin_step) {
  cat("Downloading and processing metadata...\n")

  metadata_all <- read_tsv("https://tinyurl.com/simgen-metadata", show_col_types = FALSE)

  # select a subset of columns
  metadata <- metadata_all %>%
    select(sampleId, country, continent, ageAverage, coverage, longitude, latitude, hgYMajor) %>%
    rename(sample = sampleId, age = ageAverage, y_haplo = hgYmajor)

  # replace missing ages of present-day individuals with 0
  metadata <- mutate(metadata, age = if_else(is.na(age), 0, age))
  # ignore archaic individuals
  metadata <- filter(metadata, !sample %in% c("Vindija33.19", "AltaiNeandertal", "Denisova"))

  # bin individuals according to their age
  metadata$age_bin <- cut(metadata$age, breaks = seq(0, 50000, by = bin_step), dig.lab = 10)
  bin_levels <- levels(metadata$age_bin)

  metadata <- metadata %>%
    mutate(
      age_bin = as.character(age_bin),
      age_bin = if_else(is.na(age_bin), "present-day", age_bin),
      age_bin = factor(age_bin, levels = c("present-day", bin_levels))
    )

  return(metadata)
}

join_metadata <- function(ibd_segments, metadata) {
  cat("Joining IBD data and metadata...\n")

  # prepare metadata for IBD annotation
  metadata1 <- select(metadata, -coverage, -longitude, -latitude, -y_haplo)
  metadata2 <- select(metadata, -coverage, -longitude, -latitude, -y_haplo)
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

  return(ibd_merged)
}