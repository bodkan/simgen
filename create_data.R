# this script creates all data for use in the tidyverse and ggplot2 chapters

library(dplyr)
library(tidyr)
library(readr)



# metadata table ----------------------------------------------------------

df <- read_tsv("../ibdmix-bonus/data/neo.impute.1000g.sampleInfo_clusterInfo.txt")

# remove columns which are not useful, filter individuals who are not useful
df <- df %>%
  select(-c(shape, starts_with("cluster"), color, callset, colorA, shapeA)) %>%
  filter(sampleId != "K1",    # ancient sample with no date
         country != "Europe") # Europe is not a country, 1000GP

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
), .after = region)

write_tsv(df, "files/tidy/metadata.tsv")



# relatedness information -------------------------------------------------

metadata_all <- read_tsv("files/tidy/metadata.tsv", show_col_types = FALSE)

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
ibd_orig <- dd
ibd_orig <- dplyr::as_tibble(ibd_orig)
ibd_orig <- dplyr::select(ibd_orig, sample1, sample2, chrom = chromosome, start = posCmStart, end = posCmEnd)
ibd_orig <- dplyr::filter(
  ibd_orig,
  sample1 != "K1" & sample2 != "K1" &  # individual without age
    sample1 != "Denisova" & sample2 != "Denisova" &
    sample1 != "Vindija33.19" & sample2 != "Vindija33.19" &
    sample1 != "AltaiNeandertal" & sample2 != "AltaiNeandertal"
)
ibd_orig <- left_join(ibd_orig, rel_df, by = c("sample1" = "x", "sample2" = "y"))

filter(ibd_orig, chrom == 21) %>%
  readr::write_tsv(here::here("files/tidy/ibd.tsv.gz"))



# commit updates for downstream processing --------------------------------

system("git add files/tidy/ibd.tsv.gz files/tidy/metadata.tsv")
system("git commit -m 'Add metadata and subset IBD data'")
system("git push")


# big IBD summary table ---------------------------------------------------

ibd_orig <- ibd_orig %>% mutate(length = end - start)

source(here::here("files/repro/ibd_utils.R"))

metadata <- process_metadata()
# ibd_all <- process_ibd()
ibd_all <- ibd_orig

ibd_all <- join_metadata(ibd_all, metadata)

ibd_sum <-
  ibd_all %>%
  filter(length > 10 & age_bin1 == age_bin2) %>%
  group_by(sample1, sample2, rel) %>%
  summarize(n_ibd = n(), total_ibd = sum(length))

write_tsv(ibd_sum, here::here("files/tidy/ibd_sum.tsv"))

system("git add files/tidy/ibd_sum.tsv")
system("git commit -m 'Add summarized IBD data'")
system("git push")