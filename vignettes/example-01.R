#!/usr/bin/env R

library(dplyr)

example.data <-
  data.frame(
    s1 = c(5.50,5.05,5.27,6.30,0.47,-0.38),
    s2 = c(6.60,6.69,6.36,7.51,-0.52,-0.34),
    s3 = c(4.20,4.35,4.08,4.67,1.88,2.57),
    s4 = c(1.50,1.89,1.44,1.59,4.63,3.82),
    s5 = c(2.20,2.20,2.16,2.50,3.95,3.17),
    s6 = c(5.50,5.79,5.30,6.25,0.48,1.25)
  ) %>%
  `rownames<-`(paste0("gene",1:nrow(.)))


library(recursiveCorPlot)

example.metadata <- example.data %>%
  dplyr::select(s1) %>%
  dplyr::mutate(s1 = NULL, plot = T)

recursiveCorPlot(example.data, example.metadata, 12 , 1)

