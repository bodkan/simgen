# This script simulates a part of a larger pipeline, which could be used
# to download various data sets from the internet, or otherwise copy it
# from elsewhere.

library(readr)

cat("Beginning the download process!\n")
cat("--------------------\n")

# Download original metadata table ----------------------------------------

cat("Downloading metadata...\n")

metadata <- read_tsv("https://tinyurl.com/simgen-metadata", show_col_types = FALSE)

write_tsv(metadata, "data/raw/metadata.tsv")



# Download IBD segments ---------------------------------------------------

cat("Downloading IBD segments...\n")

# Download IBD data and save them to their proper location in the overall
# project file structure (these are example data from just chromosome 21!)
ibd_segments <- read_tsv("https://tinyurl.com/simgen-ibd-segments", show_col_types = FALSE)

write_tsv(ibd_segments, "data/raw/ibd_segments.tsv")

cat("--------------------\n")
cat("All raw data downloaded!\n")