#' Convert to an htmlwidget
#'
#' `as_htmlwidget()` renders a [kplotly()] specification into an htmlwidget
#' drawn by the embedded plotly.js, which you can use in R Markdown, Quarto
#' or Shiny (`htmlwidgets::shinyRenderWidget()`), or save with [kply_save()].
#' Printing a kplotly does this implicitly.
#'
#' @param x A `kplotly` (or an htmlwidget, returned unchanged).
#' @param width,height Size of the widget, in pixels or as a CSS size
#'   (`"100%"`). Default: the width of the container and 400 pixels.
#' @param elementId Optional id of the widget element.
#' @param ... Unused.
#'
#' @return An htmlwidget of class `kplotly_widget`. Its `x` element holds the
#'   plotly.js figure: `data` (traces), `layout` and `config`.
#'
#' @examples
#' p <- kplotly(pressure, "temperature", "pressure", type = "line")
#' w <- as_htmlwidget(p)
#' class(w)
#' w$x$layout$xaxis$title
#'
#' @export
as_htmlwidget <- function(x, ...) {
  UseMethod("as_htmlwidget")
}

#' @export
#' @rdname as_htmlwidget
as_htmlwidget.htmlwidget <- function(x, ...) x

#' @export
#' @rdname as_htmlwidget
as_htmlwidget.kplotly <- function(x, width = NULL, height = NULL,
                                  elementId = NULL, ...) { # nolint
  res <- lapply(x$layers, resolve_layer)
  theme <- resolve_theme(x$theme)
  pal <- resolve_palette(x$palette %||% theme$palette)

  fig <- list(
    data = build_traces(res, pal),
    layout = build_layout(x, res, theme$layout),
    config = utils::modifyList(default_config(), x$config %||% list())
  )
  widget <- htmlwidgets::createWidget(
    name = "kplotly_widget", x = fig, width = width, height = height,
    package = "kplotly.r", elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      padding = 0, browser.fill = TRUE, defaultWidth = "100%",
      defaultHeight = 400
    )
  )

  for (e in x$extras) widget <- e(widget)
  widget
}

default_config <- function() {
  list(
    responsive = TRUE, displaylogo = FALSE, showSendToCloud = FALSE,
    modeBarButtonsToRemove = I(c("lasso2d", "select2d"))
  )
}

# Values of a data array, as plotly.js reads them: dates as ISO strings in
# their own time zone (not converted to UTC), factors as their labels. I()
# keeps an array of length one an array in JSON.
json_values <- function(v) {
  if (inherits(v, "Date")) {
    v <- format(v, "%Y-%m-%d")
  } else if (inherits(v, "POSIXt")) {
    v <- format(v, "%Y-%m-%d %H:%M:%S")
  } else if (is.factor(v)) {
    v <- as.character(v)
  }
  I(v)
}

# Levels of the colour of all the layers, so that a level has the same colour
# whatever layer it comes from. Missing values get their own level, "NA".
colour_levels <- function(res) {
  vals <- Filter(Negate(is.null), lapply(res, function(r) r$data$colour))
  if (any(vapply(vals, is.numeric, logical(1)))) {
    stop(
      "A numeric `color` column is not supported yet: convert it to a ",
      "factor (e.g. `factor(year)`).",
      call. = FALSE
    )
  }
  lv <- unique(unlist(lapply(vals, function(v) {
    if (is.factor(v)) levels(v) else unique(as.character(v))
  })))
  lv <- lv[!is.na(lv)]
  if (any(vapply(vals, anyNA, logical(1)))) lv <- c(lv, "NA")
  lv
}

as_colour_factor <- function(v, levels) {
  v <- as.character(v)
  v[is.na(v)] <- "NA"
  factor(v, levels = levels)
}

# One plotly.js trace per colour level (and group) of each layer. A legend
# entry is shown once per level, and clicking it toggles the level in every
# layer (`legendgroup`).
build_traces <- function(res, pal) {
  lv <- colour_levels(res)
  colours <- palette_values(pal, if (length(lv)) lv else ".default")
  shown <- character()
  traces <- list()
  for (r in res) {
    d <- r$data
    if (r$spec$sort) d <- d[order(d$x), , drop = FALSE]
    colour <- if (!is.null(d$colour)) as_colour_factor(d$colour, lv)
    parts <- split_rows(colour, d$group, nrow(d))
    size <- size_values(d$size)
    for (i in parts) {
      level <- if (!is.null(colour)) as.character(colour[i[1L]])
      tr <- utils::modifyList(r$spec$trace, r$spec$params)
      tr$x <- json_values(d$x[i])
      tr$y <- json_values(d$y[i])
      if (is.null(level)) {
        tr$showlegend <- FALSE
      } else {
        tr$name <- level
        tr$legendgroup <- level
        tr$showlegend <- !level %in% shown
        shown <- c(shown, level)
      }
      col <- r$fixed$colour %||% colours[[level %||% 1L]]
      for (path in r$spec$color) tr <- set_path(tr, path, col)
      if (!is.null(size)) tr <- set_path(tr, "marker.size", I(size[i]))
      if (!is.null(r$fixed$size)) {
        tr <- set_path(tr, "marker.size", r$fixed$size)
      }
      traces[[length(traces) + 1L]] <- utils::modifyList(tr, r$params)
    }
  }
  traces
}

# Row indices of each colour level and group, in the order of the levels
split_rows <- function(colour, group, n) {
  keys <- Filter(Negate(is.null), list(colour, group))
  if (!length(keys)) return(list(seq_len(n)))
  f <- interaction(keys, drop = TRUE, lex.order = TRUE)
  unname(split(seq_along(f), f))
}

# Marker sizes of a numeric column, rescaled to a readable range
size_values <- function(v) {
  if (is.null(v)) return(NULL)
  if (!is.numeric(v)) {
    stop("`size` must be a numeric column or a fixed number.", call. = FALSE)
  }
  rescale_to(v, c(4, 16))
}

# Default titles come from the layers (first one wins), then user titles;
# NA removes a title
build_labs <- function(res, explicit) {
  lab <- list()
  for (r in res) {
    for (a in names(r$labels)) {
      if (is.null(lab[[a]]) || is.na(lab[[a]])) lab[[a]] <- r$labels[[a]]
    }
  }
  lab <- utils::modifyList(lab, explicit)
  lab[!vapply(lab, function(v) length(v) == 1L && is.na(v), logical(1))]
}

build_layout <- function(x, res, theme_layout) {
  lab <- build_labs(res, x$labels)
  xv <- res[[1L]]$data$x
  slider <- x$slider %||%
    (is_time(xv) || any(vapply(res, function(r) isTRUE(r$slider), TRUE)))

  xaxis <- list(title = list(text = lab$x %||% ""))
  if (isTRUE(slider)) xaxis$rangeslider <- list(visible = TRUE)
  if (is.factor(xv)) {
    xaxis$categoryorder <- "array"
    xaxis$categoryarray <- I(levels(xv))
  }
  own <- list(
    xaxis = xaxis,
    yaxis = list(title = list(text = lab$y %||% "")),
    hovermode = if (is_time(xv)) "x unified" else "closest"
  )
  if (!is.null(lab$title)) {
    own$title <- list(text = lab$title)
    if (!is.null(lab$subtitle)) {
      own$title$subtitle <- list(text = lab$subtitle)
    }
  }
  own <- add_legend(own, x$legend, lab$colour)

  layout <- utils::modifyList(theme_layout, own)
  utils::modifyList(layout, x$layout %||% list())
}

# Position of the legend. At the top and the bottom, it is placed relative to
# the whole figure (`"container"`), so it never covers the range slider. As
# plotly.js reserves no margin for it, the widget measures it and widens the
# margin (see kplotly_widget.js); `maxheight` (a fraction of the figure)
# makes a very long legend scroll. On the left, beyond the y axis title,
# plotly.js widens the margin for it.
add_legend <- function(layout, legend, title) {
  if (isFALSE(legend) || identical(legend, "none")) {
    layout$showlegend <- FALSE
    return(layout)
  }
  pos <- if (is.null(legend) || isTRUE(legend)) "right" else legend
  if (is.numeric(pos)) {
    if (length(pos) != 2L) {
      stop("A numeric `legend` must be c(x, y).", call. = FALSE)
    }
    leg <- list(x = pos[1L], y = pos[2L], bgcolor = "rgba(255,255,255,0.7)")
  } else {
    leg <- switch(
      pos,
      right = list(),
      left = list(x = -0.12, xanchor = "right", y = 1, yanchor = "top"),
      top = list(
        orientation = "h", xanchor = "center", x = 0.5,
        yref = "container", y = 1, yanchor = "top", maxheight = 0.25
      ),
      bottom = list(
        orientation = "h", xanchor = "center", x = 0.5,
        yref = "container", y = 0, yanchor = "bottom", maxheight = 0.25
      ),
      stop(
        "`legend` must be \"right\", \"bottom\", \"top\", \"left\", ",
        "\"none\", FALSE or c(x, y).",
        call. = FALSE
      )
    )
  }
  if (!is.null(title)) leg$title <- list(text = title)
  if (length(leg)) layout$legend <- leg
  layout
}

#' Save a kplotly to an HTML file
#'
#' Thin wrapper around [htmlwidgets::saveWidget()] that accepts a `kplotly`.
#'
#' @param p A `kplotly` or an htmlwidget.
#' @param file File to save to (`.html`).
#' @param selfcontained Whether to embed everything, plotly.js included, in
#'   the file (needs pandoc).
#' @param ... Passed to [htmlwidgets::saveWidget()].
#'
#' @return The file name, invisibly.
#'
#' @export
kply_save <- function(p, file, selfcontained = TRUE, ...) {
  htmlwidgets::saveWidget(
    as_htmlwidget(p), file = file, selfcontained = selfcontained, ...
  )
  invisible(file)
}
