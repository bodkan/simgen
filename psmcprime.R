library(ggplot2)
library(dplyr)
library(tidyr)

library(slendr)
init_env()

Ne <- 10000
sequence_length <- 10e6
recombination_rate <- 1e-8
windows <- seq(0, sequence_length - 1, by = 10000)

pi_const <-
  population("pop", time = 10000, N = Ne) %>%
  compile_model(generation_time = 1, direction = "backward") %>%
  msprime(sequence_length = sequence_length, recombination_rate = recombination_rate) %>%
  { ts_diversity(., sample_sets = list(ts_names(.)), mode = "branch", windows = windows) } %>%
  unnest(cols = diversity) %>%
  mutate(model = "constant")

pi_bottle <-
  population("pop", time = 10000, N = Ne) %>%
  resize(time = 5000, N = Ne / 2) %>%
  compile_model(generation_time = 1, direction = "backward") %>%
  msprime(sequence_length = sequence_length, recombination_rate = recombination_rate) %>%
  { ts_diversity(., sample_sets = list(ts_names(.)), mode = "branch", windows = windows) } %>%
  unnest(cols = diversity) %>%
  mutate(model = "bottleneck")

pi_expand <-
  population("pop", time = 10000, N = Ne) %>%
  resize(time = 5000, N = Ne * 2) %>%
  compile_model(generation_time = 1, direction = "backward") %>%
  msprime(sequence_length = sequence_length, recombination_rate = recombination_rate) %>%
  { ts_diversity(., sample_sets = list(ts_names(.)), mode = "branch", windows = windows) } %>%
  unnest(cols = diversity) %>%
  mutate(model = "expansion")

pi <- rbind(pi_const, pi_bottle, pi_expand)

ggplot(pi, aes(diversity, fill = model)) +
  geom_histogram()
