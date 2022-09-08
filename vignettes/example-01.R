#!/usr/bin/env R

# devtools::document()


# load libs ----

library(dplyr)

devtools::install_github("yhoogstrate/recursiveCorPlot")
library(recursiveCorPlot)

# example 1 ----

set.seed(1+3*3+7)
example.data <-
  data.frame(
    smpl1 = c(5.50,5.05,5.27,6.30,0.47,-0.38),
    smpl2 = c(6.60,6.69,6.36,7.51,-0.52,-0.34),
    smpl3 = c(4.20,4.35,4.08,4.67,1.88,2.57),
    smpl4 = c(1.50,1.89,1.44,1.59,4.63,3.82),
    smpl5 = c(2.20,2.20,2.16,2.50,3.95,3.17),
    smpl6 = c(5.50,5.79,5.30,6.25,0.48,1.25)
  ) %>%
  `rownames<-`(paste0("gene",1:nrow(.))) %>%
  rbind(gene7 = runif(6) * 20) %>%
  as.data.frame


example.metadata <- example.data %>%
  dplyr::select(smpl1) %>%
  dplyr::mutate(smpl1 = NULL, plot = c(rep(T,6), F))


recursiveCorPlot(example.data, example.metadata, 12 , 1)
recursiveCorPlot(example.data, example.metadata, 12 , 1, caption=paste0("n=",nrow(example.data)," samples; n=",ncol(example.data)," genes"))


# equivalent:
# install.packages('corrplot')
# corrplot::corrplot(cor(t(example.data)))


# example 2 ----


data('G.SAM.corrected.DE.genes.VST', package = 'recursiveCorPlot')
data('G.SAM.corrected.DE.labels', package = 'recursiveCorPlot')
recursiveCorPlot(G.SAM.corrected.DE.genes.VST, G.SAM.corrected.DE.labels, 3 , 3)


recursiveCorPlot(G.SAM.corrected.DE.genes.VST, G.SAM.corrected.DE.labels %>% dplyr::select(endothelial, neuron, oligodendrocyte), 3 , 3)


