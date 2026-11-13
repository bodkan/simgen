library(ggplot2)
library(dplyr)
library(tidyr)

library(slendr)
init_env()

Ne <- 10000
sequence_length <- 10e6
recombination_rate <- 1e-8
mutation_rate <- 1e-8
windows <- seq(0, sequence_length - 1, by = 10000)

pi_const <-
  population("pop", time = 12000, N = Ne) %>%
  resize(time = 8000, N = Ne * 1) %>%
  resize(time = 4000, N = Ne * 1) %>%
  compile_model(generation_time = 1, direction = "backward") %>%
  { msprime(., sequence_length = sequence_length, recombination_rate = recombination_rate, schedule = schedule_recording(., times = 0, list(.$populations[[1]], 25))) } %>%
  ts_mutate(mutation_rate = mutation_rate) %>%
  { ts_diversity(., sample_sets = list(ts_names(.)), mode = "branch", windows = windows) } %>%
  unnest(cols = diversity) %>%
  mutate(model = "constant")

pi_bottle <-
  population("pop", time = 12000, N = Ne) %>%
  resize(time = 8000, N = Ne / 10) %>%
  resize(time = 4000, N = Ne / 10) %>%
  compile_model(generation_time = 1, direction = "backward") %>%
  { msprime(., sequence_length = sequence_length, recombination_rate = recombination_rate, schedule = schedule_recording(., times = 0, list(.$populations[[1]], 25))) } %>%
  { ts_diversity(., sample_sets = list(ts_names(.)), mode = "branch", windows = windows) } %>%
  unnest(cols = diversity) %>%
  mutate(model = "bottleneck")

pi_expand <-
  population("pop", time = 12000, N = Ne) %>%
  resize(time = 8000, N = Ne * 10) %>%
  resize(time = 4000, N = Ne * 10) %>%
  compile_model(generation_time = 1, direction = "backward") %>%
  { msprime(., sequence_length = sequence_length, recombination_rate = recombination_rate, schedule = schedule_recording(., times = 0, list(.$populations[[1]], 25))) } %>%
  { ts_diversity(., sample_sets = list(ts_names(.)), mode = "branch", windows = windows) } %>%
  unnest(cols = diversity) %>%
  mutate(model = "expansion")

pi <-
  rbind(pi_const, pi_bottle, pi_expand)

ggplot(pi, aes(diversity, color = model)) +
  geom_density()
