#!/usr/bin/env Rscript

library(optparse)
library(tibble)
library(readr)

# compose the command-line argument parser
parser <- OptionParser()
parser <- add_option(parser, "--p_init", type = "double", help = "Initial allele frequency")
parser <- add_option(parser, "--Ne", type = "integer", help = "Effective population size")
parser <- add_option(parser, "--generations", type = "integer", help = "Simulation length in generations")
parser <- add_option(parser, "--output", type = "character", help = "Name of the output file")

# extract command-line arguments given
args <- parse_args(parser)

# check that arguments which are mandatory were given
if (is.null(args$p_init)) {
  stop("Initial allele frequency is required")
}
if (is.null(args$Ne)) {
  stop("Effective population size is required")
}
if (is.null(args$generations)) {
  stop("Simulation length is required")
}
if (is.null(args$output)) {
  stop("Simulation length is required")
}

# extract arguments into their own variables for less typing later
p_init <- args$p_init
Ne <- args$Ne
generations <- args$generations
output <- args$output

# this is our function
simulate_trajectory <- function(p_init, Ne, generations) {
  trajectory <- c(p_init)

  # for each generation...
  for (gen in seq_len(generations - 1)) {
    # ... based on the allele frequency in the current generation...
    p_current <- trajectory[gen]
    # ... compute the frequency in the next generation...
    n_next <- rbinom(Ne, 1, p_current)
    p_next <- sum(n_next) / Ne
    # ... and save it in the trajectory vector
    trajectory[gen + 1] <- p_next
  }

  df <- tibble(
    p_init = p_init,
    Ne = Ne,
    time = generations,
    frequency = trajectory
  )

  df
}

# run the simulation using our function parameters
df <- simulate_trajectory(p_init, Ne, generations)

# save the table in a file
write_tsv(df, output)