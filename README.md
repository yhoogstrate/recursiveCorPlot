# recursiveCorPlot

---

You can install *recursiveCorPlot* from Github using `devtools::install_github("yhoogstrate/recursiveCorPlot")`.

## Introduction

Using recursive correlation clustering provides considerably more natural clusters using RNA-seq data.


## Examples

| Example with G-SAM DE Genes: |
|---------------------------------------------|
| `data('G.SAM.corrected.DE.genes.VST', package = 'recursiveCorPlot')` |
| <img src="https://github.com/yhoogstrate/recursiveCorPlot/raw/master/extern/cor_cor_.png" width="85%">  |
| Above: recursive correlation based clustering |
| |
| <img src="https://github.com/yhoogstrate/recursiveCorPlot/raw/master/extern/cor.png" width="85%">  |
| Above: regular 1 - correlation based clustering |
| |
| <img src="https://github.com/yhoogstrate/recursiveCorPlot/raw/master/extern/scale_euclidean.png" width="85%">  |
| Above: scaled Euclidean distance based clustering |

## Method

For classical hierarchical clustering of RNA-seq data, the use of Eucledian distances as distance metric often result in unnatural clusters. For example, if the clustering contains genes with only a few samples with strong up-regulation by hyper-amplifications, these will weigh heavily at the Eucledian distance(s). This distance metric is therefore sensitive to outliers. Instead, correlation based clustering (distance = 1 – correlation(m)) is more common for RNA-seq data, where spearman's rank can be used to more aggressively suppress outliers. We observed some genes, relatively rich in zero counts, of which the correlation to all other genes are somewhat lower, but the correlations consistently went in the same direction as other genes within a cluster. Since the directions of the correlation are consistent with other genes but the data didn't seem powerful enough, we took the correlation of the correlation as the distance metric: 1 – correlation(correlation(m)). This distance metric was clustered hierarchically using the "ward.D2"" method, showing neat natural clusters.


