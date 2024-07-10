#!/usr/bin/env R

#   devtools::document() - run prior to running the following:
#   roxygen2::roxygenise()
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'


#' recursiveCorPlot - corplot
#' @importFrom rlang .data
#'
#' @description
#' This is a function named 'recursiveCorPlot'
#' which makes a clustered correlation plot using recursive correlation as
#' distance metric.
#' Some useful keyboard shortcuts for package authoring:
#'
#' @param normalised_correlated_data VST transformed or TMP read count table (rownames set to genes)
#' @param labels Matching labels (T, F, NA) for the genes (rownames set to same genes)
#' @param font_scale size of font
#' @param legend_scale size of legend blocks
#' @param method hclust method (see hclust for help)
#' @param return_h_object when T, return the h-clust object
#' @param caption caption (string) to be included
#' @return nothing, or h-clust object if return_h_object was set to TRUE
#' @export
recursiveCorPlot <- function(normalised_correlated_data, labels, font_scale , legend_scale , method="ward.D2", return_h_object = FALSE, caption=NULL) {
  col2 <- grDevices::colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582",
                             "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE",
                             "#4393C3", "#2166AC", "#053061"))


  # remove duplicate entries:
  plt <- normalised_correlated_data |>
    tibble::rownames_to_column('__hugo_symbol__') |>
    dplyr::filter(!duplicated(.data$`__hugo_symbol__`)) |>
    tibble::column_to_rownames('__hugo_symbol__')


  #h <- hclust(dist(plt |> as.matrix |> t() |>  scale |> t() %>% as.matrix), method = method ) # Euclidean distance based clustering

  # determine correlation
  plt <- plt |>
    base::as.matrix() |>
    base::t()

  # find order by taking correlation of the correlation
  h <- stats::hclust(stats::as.dist(1 - stats::cor(plt)), method = method ) # recursive cor-based cluastering !!!
  #h <- stats::hclust( stats::as.dist(1 - plt) , method = method ) # regular cor-based clustering

  # @todo dplyr::arrange()
  o <- h$labels[h$order] |>
    base::rev()

  ph <- ggdendro::ggdendrogram(h, rotate = TRUE, theme_dendro = FALSE) +
    ggdendro::theme_dendro()

  # re-order to cor-cor clustering order and transform from data.frame into matrix
  plt <- plt |>
    base::as.data.frame() |>
    dplyr::select(dplyr::all_of(o)) |>
    base::t() |>
    base::as.data.frame() |>
    dplyr::select(dplyr::all_of(o)) |>
    base::t() |>
    base::as.matrix()


  # to test:
  # corrplot::corrplot(plt)



  # add x and y co-ordinates later on to melted table
  o.join <- base::data.frame(name = o, i = 1:length(o))

  plt.expanded2 <- reshape2::melt(plt) |>
    dplyr::rename(y = .data$`Var1`) |>
    dplyr::rename(x = .data$`Var2`) |>
    dplyr::mutate(x = as.factor(.data$`x`)) |>
    dplyr::mutate(y = as.factor(.data$`y`)) |>
    dplyr::left_join(o.join |> dplyr::rename(x.order = .data$`i`), by = c("x" = "name")) |>
    dplyr::left_join(o.join |> dplyr::mutate(i = dplyr::n() - .data$i + 1) |> dplyr::rename(y.order = .data$i), by = c("y" = "name"))

  base::rm(o.join)



  p1 <- ggplot2::ggplot(plt.expanded2, ggplot2::aes(
      x = .data$x.order,
      y = .data$y.order,
      radius = ((abs(.data$value) * 0.7) + 0.3) / 2 - 0.05,
      # [0.3 , 0.8] + 0.2 smoothened from lwd/border
      fill = .data$value,
      col = .data$value,
      label = .data$x
    )
  ) +
    ggplot2::geom_tile(col = "gray", fill = "white", lwd = 0.15) +
    ggplot2::scale_fill_gradientn(colours = col2(200), na.value = "grey50", limits = c(-1, 1), guide = "none") + # guide = "colourbar",
    ggplot2::scale_color_gradientn(colours = col2(200), na.value = "grey50", limits = c(-1, 1), guide = "none") +
    geom_circle(radius.fixed = T) + # from THIS repo
    ggplot2::scale_x_discrete(labels = NULL, breaks = NULL) +
    ggplot2::theme(
      legend.position = "bottom",
      axis.text.y = ggplot2::element_text(size = font_scale, angle = 0, hjust = 1, vjust = 0.5), # used to be [3,6] reduce font size here, should become argument
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 0, vjust = 0.5, color = "gray80"),
      text = ggplot2::element_text(size = 13),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    ) +
    ggplot2::labs(y = NULL, x = NULL, main = NULL) +
    ggplot2::coord_fixed() +
    ggplot2::scale_y_continuous(name = NULL, breaks = base::length(o):1, labels = o)



  plt <- base::data.frame(gid = o, i = 1:length(o)) |>
    dplyr::left_join(labels |> tibble::rownames_to_column("gid"), by = c("gid" = "gid")) |>
    reshape2::melt(id.vars = c("gid", "i")) |>
    dplyr::mutate(variable = factor(.data$variable, levels = base::rev(base::colnames(labels))))


  p2 <- ggplot2::ggplot(plt, ggplot2::aes(
    x = .data$i,
    y = .data$variable,
    fill = .data$value,
    label = .data$gid
  )) +
    ggplot2::geom_tile(col = "white", lwd = 0.15) +
    # scale_x_discrete(position = "bottom")  +
    ggplot2::scale_x_discrete(labels = NULL, breaks = NULL) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 90, hjust = 0, vjust = 0.5),
      axis.text.y = ggplot2::element_text(size = font_scale, angle = 0, hjust = 1, vjust = 0.5),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank()
    ) +
    ggplot2::guides(fill = "none") +
    ggplot2::coord_fixed(ratio = legend_scale) + # used to be 2.75
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::scale_fill_manual(values = c("TRUE" = "red", "FALSE" = "gray98"))
  # scale_fill_manual(values=c('TRUE'='gray40','FALSE'='gray95'))


  #(p2 / p1) / ph

  #(p2 + plot_layout(guides = 'collect') ) /
  #(p1 + (ph))




  if(return_h_object) {
    return(h) # return clust object
  } else {
    layout <- '
A#
BC'

    return(
patchwork::wrap_plots(
  A = p2,
  B = p1,
  C = (ph + patchwork::plot_spacer()),
  design = layout) +
  patchwork::plot_annotation(
    caption = caption
  )
    )
  }
}


