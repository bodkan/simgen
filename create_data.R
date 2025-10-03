# this script creates all data for use in the tidyverse and ggplot2 chapters

library(dplyr)
library(tidyr)
library(readr)

library(sf)


# metadata table ----------------------------------------------------------

df <- read_tsv("../ibdmix-bonus/data/neo.impute.1000g.sampleInfo_clusterInfo.txt")

# get individuals to be removed from metadata and IBD data
to_remove <- filter(
  df,
  sampleId == "K1"  |  # ancient sample with no date
  country == "Europe"  # Europe is not a country, 1000GP
)$sampleId

# remove columns which are not useful, filter individuals who are not useful
df <- df %>%
  select(-c(shape, starts_with("cluster"), color, callset, colorA, shapeA)) %>%
  filter(!sampleId %in% to_remove)

# annotate with continent assigmnent
continents <- list(
  Africa = c("WestAfrica", "EastAfrica", "SouthAfrica", "CentralAfrica", "NorthAfrica"),
  Asia = c("SouthAsia", "SouthEastAsia", "EastAsia", "WesternAsia", "CentralAsia", "NorthAsia"),
  America = c("NorthAmerica", "SouthAmerica"),
  Europe = c("SouthernEurope", "WesternEurope", "NorthernEurope", "CentralEasternEurope"
  )
)
df <- df %>% mutate(continent = case_when(
  region %in% continents$Africa ~ "Africa",
  region %in% continents$Asia ~ "Asia",
  region %in% continents$America ~ "America",
  region %in% continents$Europe ~ "Europe",
), .after = region) %>%
  filter(continent == "Europe")

write_tsv(df, "files/tidy/metadata.tsv")



# relatedness information -------------------------------------------------

metadata_all <- read_tsv("files/tidy/metadata.tsv", show_col_types = FALSE)

to_keep <- metadata_all$sampleId

rel_df <-
  metadata_all %>%
  filter(flag != "0", !grepl("low|cont|age", flag)) %>%
  select(x = sampleId, flag) %>%
  mutate(y = gsub("^\\dd_rel_(.*$)", "\\1", flag) %>% gsub("^dup_(.*$)", "\\1", .),
         rel = gsub("(^\\dd)_.*", "\\1", flag) %>% gsub("(^dup)_.*", "\\1", .)) %>%
  mutate(
    rel = case_when(
      rel == "1d" ~ "1st degree",
      rel == "2d" ~ "2nd degree",
      rel == "dup" ~ "duplicate"
    )
  ) %>%
  select(x, y, rel)

rel_df <- bind_rows(rel_df, select(rel_df, y = x, x = y, rel))



# IBD table ---------------------------------------------------------------

load("~/Desktop/neo.impute.1000g.ibd.filter.strict.RData")
ibd_segments <- dd
ibd_segments <- dplyr::as_tibble(ibd_segments)
ibd_segments <- dplyr::select(ibd_segments, sample1, sample2, chrom = chromosome, start = posCmStart, end = posCmEnd)
ibd_segments <- dplyr::filter(
  ibd_segments,
    !sample1 %in% to_remove & !sample2 %in% to_remove &
    sample1 != "Denisova" & sample2 != "Denisova" &
    sample1 != "Vindija33.19" & sample2 != "Vindija33.19" &
    sample1 != "AltaiNeandertal" & sample2 != "AltaiNeandertal"
)
ibd_segments <- left_join(ibd_segments, rel_df, by = c("sample1" = "x", "sample2" = "y"))

filter(ibd_segments, chrom == 21) %>%
  readr::write_tsv(here::here("files/tidy/ibd_segments.tsv"))



# commit updates for downstream processing --------------------------------

system("git add files/tidy/ibd.tsv.gz files/tidy/metadata.tsv")
system("git commit -m 'Add metadata and subset IBD data'")
system("git push")


# big IBD summary table ---------------------------------------------------

# this is a replacement for `process_ibd()`
ibd_segments <- ibd_segments %>% mutate(length = end - start)

# this is a replacement for `process_metadata()`
process_metadata2 <- function() {
  metadata_all <- read_tsv("https://tinyurl.com/simgen-metadata", show_col_types = FALSE)

  # select a subset of columns
  metadata <- metadata_all %>%
    select(sampleId, country, continent, ageAverage, coverage, longitude, latitude) %>%
    rename(sample = sampleId, age = ageAverage, lon = longitude, lat = latitude, )

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

  return(metadata)
}
# this is a replacement for `join_metadata()`
join_metadata2 <- function(ibd, metadata) {
  cat("Joining IBD data and metadata...\n")

  # prepare metadata for IBD annotation
  metadata1 <- select(metadata, -coverage)
  metadata2 <- select(metadata, -coverage)
  colnames(metadata1) <- paste0(colnames(metadata1), "1")
  colnames(metadata2) <- paste0(colnames(metadata2), "2")

  # join based on sample1
  ibd <- inner_join(ibd, metadata1)
  # join based on sample2
  ibd <- inner_join(ibd, metadata2)

  ibd_sp <- filter(ibd, !is.na(lon1), !is.na(lon2), !is.na(lat1), !is.na(lat2)) %>%
    st_as_sf(coords = c("lon1", "lat1"), sf_column_name = "location1") %>%
    as_tibble() %>%
    st_as_sf(coords = c("lon2", "lat2"), sf_column_name = "location2") %>%
    as_tibble() %>%
    mutate(distance = as.numeric(st_distance(location1, location2, by_element = TRUE) / 1e3)) %>%
    select(-c(location1, location2))

  ibd_nonsp <- filter(ibd, is.na(lat1), is.na(lat2), is.na(lon1), is.na(lon2)) %>%
    mutate(distance = NA_real_) %>%
    select(-c(lat1, lat2, lon1, lon2))

  ibd <- rbind(ibd_nonsp, ibd_sp)

  # annotate with new columns indicating a pair of countries or time bins
  ibd <- mutate(ibd,
                country_pair = paste(country1, country2, sep = ":"),
                region_pair = paste(continent1, continent2, sep = ":"),
                time_pair = paste(age_bin1, age_bin2, sep = ":"),
                .before = chrom)

  return(ibd)
}

metadata <- process_metadata2()

# annotate missing geography with country centroid (needed just for present-day
# humans from 1000GP data)
# library(sf)
# library(rnaturalearth)
#
# country_names <- filter(metadata, continent == "Europe") %>% .$country %>% unique
# sf_countries <- ne_countries() %>%
#   filter(admin %in% country_names) %>%
#   select(country = admin, geometry) %>%
#   st_make_valid()
# st_agr(sf_countries) <- "constant"
# sf_centers <- st_centroid(sf_countries)
# metadata <- inner_join(metadata, sf_centers, by = "country")

ibd_segments <- join_metadata2(ibd_segments, metadata)

# only long segments

ibd_long <-
  ibd_segments %>%
  filter(length > 10 & age_bin1 == age_bin2) %>%
  group_by(sample1, sample2, rel, country_pair, region_pair, time_pair, distance) %>%
  summarize(n_ibd = n(), total_ibd = sum(length))

pryr::object_size(ibd_long)

write_tsv(ibd_long, here::here("files/tidy/ibd_long.tsv"))

system("git add files/tidy/ibd_long.tsv")
system("git commit -m 'Add summarized long IBD data'")
system("git push")


# even short segments

ibd_short <-
  ibd_segments %>%
  filter(age_bin1 == age_bin2) %>%
  group_by(sample1, sample2, rel, country_pair, region_pair, time_pair, distance) %>%
  summarize(n_ibd = n(), total_ibd = sum(length))

write_tsv(ibd_short, here::here("files/tidy/ibd_short.tsv"))

system("git add files/tidy/ibd_short.tsv")
system("git commit -m 'Add summarized short IBD data'")
system("git push")
