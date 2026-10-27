#' Themes and palettes
#'
#' A kplotly *theme* bundles plotly.js layout attributes (fonts, background,
#' grid, axes) and (optionally) a colour palette under one name, so
#' `kplotly(..., theme = "inrae")` styles the whole plot. Register your own
#' with `kply_register_theme()` and `kply_register_palette()`.
#'
#' A `theme` argument accepted by [kplotly()] can be a registered name or a
#' list of plotly.js layout attributes. Set `options(kplotly.theme = )` and
#' `options(kplotly.palette = )` to change the defaults session-wide.
#'
#' Built-in themes: `default` (plotly.js defaults), `minimal` (white
#' background, light grid), `bw` (white background, framed panel) and
#' `inrae` (colours of the INRAE graphic charter). Built-in palettes:
#' `plotly` (the plotly.js default colours), `inrae` and `okabe_ito`.
#'
#' @param name Name of the theme or palette.
#' @param layout Named list of plotly.js layout attributes, merged under the
#'   attributes set by kplotly (titles, legend, slider).
#' @param palette Colours of the theme: a character vector of colours, the
#'   name of a registered palette, or `NULL`.
#' @param colors Character vector of colours (or a function of `n`).
#'
#' @return `kply_register_*()` return `name` invisibly; `kply_themes()` and
#'   `kply_palettes()` return the registered names.
#'
#' @examples
#' kply_themes()
#' kply_register_palette("traffic", c("#2ecc71", "#f1c40f", "#e74c3c"))
#' kply_register_theme(
#'   "traffic", list(plot_bgcolor = "#fafafa"), palette = "traffic"
#' )
#' kplotly(iris, "Sepal.Length", "Sepal.Width", color = "Species",
#'         theme = "traffic")
#'
#' @export
kply_register_theme <- function(name, layout = list(), palette = NULL) {
  stopifnot(is.character(name), length(name) == 1L)
  if (!is.list(layout)) {
    stop("`layout` must be a list of plotly.js layout attributes.",
         call. = FALSE)
  }
  .kply$themes[[name]] <- list(layout = layout, palette = palette)
  invisible(name)
}

#' @export
#' @rdname kply_register_theme
kply_register_palette <- function(name, colors) {
  stopifnot(is.character(name), length(name) == 1L)
  stopifnot(is.character(colors) || is.function(colors))
  .kply$palettes[[name]] <- colors
  invisible(name)
}

#' @export
#' @rdname kply_register_theme
kply_themes <- function() names(.kply$themes)

#' @export
#' @rdname kply_register_theme
kply_palettes <- function() names(.kply$palettes)

register_builtin_palettes <- function() {
  kply_register_palette(
    "plotly",
    c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b",
      "#e377c2", "#7f7f7f", "#bcbd22", "#17becf")
  )
  kply_register_palette(
    "inrae",
    c("#00a3a6", "#9dc544", "#423089", "#ed6e6c", "#c4c0b3", "#9ed6e3",
      "#797870")
  )
  kply_register_palette(
    "okabe_ito",
    c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00",
      "#CC79A7", "#999999")
  )
}

register_builtin_themes <- function() {
  axis <- function(...) list(xaxis = list(...), yaxis = list(...))
  kply_register_theme("default", palette = "plotly")
  kply_register_theme(
    "minimal",
    c(
      list(paper_bgcolor = "white", plot_bgcolor = "white"),
      axis(gridcolor = "#ebebeb", zeroline = FALSE)
    ),
    palette = "plotly"
  )
  kply_register_theme(
    "bw",
    c(
      list(paper_bgcolor = "white", plot_bgcolor = "white"),
      axis(
        gridcolor = "#ebebeb", zeroline = FALSE, showline = TRUE,
        linecolor = "#333333", mirror = TRUE
      )
    ),
    palette = "plotly"
  )
  kply_register_theme("inrae", theme_inrae(), palette = "inrae")
}

# Colours of the INRAE graphic charter v4.2 (April 2024, p. 14-15), as in the
# theme "inrae" of kggplot: complementary greys for the text, the grid and the
# frame. The charter (p. 16) sets Raleway for titles and Avenir Next Pro
# Condensed for the text; no font is forced, the browser falls back on its
# sans-serif font when they are not installed.
theme_inrae <- function() {
  pal <- .kply$palettes[["inrae"]]
  axis <- list(
    gridcolor = pal[5L], griddash = "dot", zeroline = FALSE,
    showline = TRUE, linecolor = pal[7L], mirror = TRUE,
    tickfont = list(color = pal[7L])
  )
  list(
    font = list(family = "'Avenir Next Condensed', sans-serif"),
    title = list(
      font = list(family = "Raleway, sans-serif", size = 20, weight = "bold")
    ),
    paper_bgcolor = "white", plot_bgcolor = "white",
    xaxis = axis, yaxis = axis
  )
}

# Resolve `theme` to list(layout = <list>, palette = <colours>)
resolve_theme <- function(theme = NULL) {
  theme <- theme %||% getOption("kplotly.theme", "default")
  if (is.list(theme)) return(list(layout = theme, palette = NULL))
  if (!is.character(theme) || length(theme) != 1L) {
    stop("`theme` must be a name or a list of layout attributes.",
         call. = FALSE)
  }
  entry <- .kply$themes[[theme]]
  if (is.null(entry)) {
    stop(
      "Unknown theme '", theme, "'. Registered: ",
      paste(kply_themes(), collapse = ", "), ".",
      call. = FALSE
    )
  }
  entry
}

# Resolve a palette spec to a character vector or a function
resolve_palette <- function(palette) {
  palette <- palette %||% getOption("kplotly.palette", "plotly")
  if (is.function(palette)) return(palette)
  if (!is.character(palette)) {
    stop(
      "`palette` must be colours, a palette name or a function.",
      call. = FALSE
    )
  }
  is_name <- length(palette) == 1L && is.null(names(palette))
  if (is_name && !is.null(.kply$palettes[[palette]])) {
    return(.kply$palettes[[palette]])
  }
  palette
}

# Colours for `levels` (named by level), from a vector or a function. A named
# vector fixes the colour of its levels; the others take the next colours.
palette_values <- function(pal, levels) {
  n <- length(levels)
  if (is.function(pal)) return(stats::setNames(pal(n), levels))
  if (!is.null(names(pal))) {
    rest <- setdiff(levels, names(pal))
    free <- unname(pal[!names(pal) %in% levels])
    if (length(rest)) {
      cols <- palette_values(if (length(free)) free else "grey50", rest)
      pal <- c(pal, cols)
    }
    return(pal[levels])
  }
  if (n <= length(pal)) {
    cols <- pal[seq_len(n)]
  } else {
    cols <- grDevices::colorRampPalette(pal)(n)
  }
  stats::setNames(cols, levels)
}
