#!/usr/bin/env R

#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'


#' recursiveCorPlot - corplot
#'
#' This is an example function named 'recursiveCorPlot'
#' which makes a clustered correlation plot using recursive correlation as
#' distance metric.
#' Some useful keyboard shortcuts for package authoring:
#'
#' @param normalised_correlation_data VST transformed or TMP read count table (rownames set to genes)
#' @param labels Matching labels (T, F, NA) for the genes (rownames set to same genes)
#' @param font_scale size of font
#' @param legend_scale size of legend blocks
#' @param method hclust method (see hclust for help)
#' @param return_h_object when T, return the h-clust object
#' @return nothing, or h-clust object if return_h_object was set to TRUE
#' @export
recursiveCorPlot <- function(normalised_correlated_data, labels, font_scale , legend_scale , method="ward.D2", return_h_object = FALSE) {
  col2 <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582",
                             "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE",
                             "#4393C3", "#2166AC", "#053061"))


  # remove duplicate entries:
  plt <- normalised_correlated_data %>%
    tibble::rownames_to_column('__hugo_symbol__') %>%
    dplyr::filter(!duplicated(`__hugo_symbol__`)) %>%
    tibble::column_to_rownames('__hugo_symbol__')


  #h <- hclust(dist(plt %>% as.matrix %>% t() %>%  scale %>% t() %>% as.matrix), method = method ) # Euclidean distance based clustering

  # determine correlation
  plt <- plt %>%
    as.matrix %>%
    t() %>%
    cor()


  # find order by taking correlation of the correlation
  h <- hclust( as.dist(1 - cor(plt)), method = method ) # recursive cor-based cluastering !!!
  #h <- hclust( as.dist(1 - plt) , method = method ) # regular cor-based clustering

  o <- h$labels[h$order] %>% rev()

  ph <- ggdendro::ggdendrogram(h, rotate = TRUE, theme_dendro = FALSE) +
    ggdendro::theme_dendro()

  # re-order to cor-cor clustering order and transform from data.frame into matrix
  plt <- plt %>%
    as.data.frame %>%
    dplyr::select(o) %>%
    t() %>%
    as.data.frame %>%
    dplyr::select(o) %>%
    t() %>%
    as.matrix


  # to test:
  # corrplot::corrplot(plt)



  # add x and y co-ordinates later on to melted table
  o.join <- data.frame(name = o, i = 1:length(o))

  plt.expanded2 <- reshape2::melt(plt) %>%
    dplyr::rename(y = Var1) %>%
    dplyr::rename(x = Var2) %>%
    dplyr::mutate(x = as.factor(x)) %>%
    dplyr::mutate(y = as.factor(y)) %>%
    dplyr::left_join(o.join %>% dplyr::rename(x.order = i), by=c('x' = 'name'))%>%
    dplyr::left_join(o.join %>% dplyr::mutate(i = nrow(.) - i + 1  ) %>% dplyr::rename(y.order = i), by=c('y' = 'name'))

  rm(o.join)



  p1 <- ggplot(plt.expanded2,
               aes( x = x.order, y = y.order,
                    radius = ((abs(value) * 0.7) + 0.3) / 2 - 0.05 ,  # [0.3 , 0.8] + 0.2 smoothened from lwd/border
                    fill=value,
                    col=value,
                    label=x)
  ) +
    geom_tile( col="gray", fill="white", lwd=0.15) +
    scale_fill_gradientn( colours = col2(200), na.value = "grey50", limits = c(-1,1) , guide="none") + # guide = "colourbar",
    scale_color_gradientn( colours = col2(200), na.value = "grey50", limits = c(-1,1) , guide="none" ) +
    geom_circle(radius.fixed = T) + # from THIS repo
    scale_x_discrete(labels = NULL, breaks = NULL) +
    theme(legend.position = 'bottom',
          axis.text.y = element_text(size = font_scale, angle = 0, hjust = 1, vjust = 0.5), # used to be [3,6] reduce font size here, should become argument
          axis.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5, color="gray80"),

          text = element_text(size=13),

          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_blank()
    ) +
    labs(y = NULL, x=NULL, main=NULL) +
    ggplot2::coord_fixed() +
    scale_y_continuous(name=NULL, breaks = length(o):1, labels = o)



  plt <- data.frame(gid = o, i = 1:length(o)) %>%
    dplyr::left_join(labels %>%
                       tibble::rownames_to_column('gid'), by=c('gid' = 'gid')) %>%
    reshape2::melt(id.vars = c('gid','i'))  %>%
    dplyr::mutate(variable = factor(variable, levels = rev(colnames(labels))))


  p2 <- ggplot(plt , aes(x = i , y = variable , fill=value, label=gid)) +
    geom_tile(col='white',lwd=0.15) +
    #scale_x_discrete(position = "bottom")  +
    scale_x_discrete(labels = NULL, breaks = NULL) +
    theme(axis.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5),
          axis.text.y = element_text(size = font_scale, angle = 0, hjust = 1, vjust = 0.5),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_blank()
    ) +
    guides(fill="none") +
    ggplot2::coord_fixed(ratio = legend_scale) + # used to be 2.75
    labs(x=NULL, y=NULL) +
    scale_fill_manual(values=c('TRUE'='red','FALSE'='gray98'))
  #scale_fill_manual(values=c('TRUE'='gray40','FALSE'='gray95'))


  #(p2 / p1) / ph

  #(p2 + plot_layout(guides = 'collect') ) /
  #(p1 + (ph))


  layout <- '
A#
BC'
  wrap_plots(A = p2, B = p1, C = (ph + plot_spacer () )  , design = layout)

  if(return_h_object) {
    return(h) # return clust object
  } else {
    return(wrap_plots(A = p2, B = p1, C = (ph + plot_spacer () )  , design = layout))
  }
}


