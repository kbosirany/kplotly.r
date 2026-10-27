#' @export
print.kplotly <- function(x, ...) {
  print(as_htmlwidget(x), ...)
  invisible(x)
}

#' @export
plot.kplotly <- function(x, ...) {
  print(as_htmlwidget(x), ...)
  invisible(x)
}

#' @exportS3Method knitr::knit_print
knit_print.kplotly <- function(x, ...) {
  knitr::knit_print(as_htmlwidget(x), ...)
}

#' Add layers or widget steps to a kplotly
#'
#' * `kplotly + kplotly`: appends the layers of the right-hand plot; its
#'   theme, titles, legend, palette and slider override the left ones when
#'   specified.
#' * `kplotly + <function>`: a function of the htmlwidget returning a widget
#'   (e.g. `function(w) htmlwidgets::onRender(w, js)`), stored and applied
#'   last, in order.
#'
#' @param e1 A `kplotly`.
#' @param e2 A `kplotly` or a function of an htmlwidget.
#'
#' @return A `kplotly`.
#'
#' @examples
#' d <- data.frame(t = 1:10, v = (1:10)^2)
#' kplotly(d, "t", "v", type = "point") + kplotly(d, "t", "v", type = "line")
#'
#' @export
`+.kplotly` <- function(e1, e2) {
  if (missing(e2)) stop("Cannot use `+` with a single argument.", call. = FALSE)
  if (!inherits(e1, "kplotly")) {
    stop("The left-hand side of `+` must be a kplotly.", call. = FALSE)
  }
  if (inherits(e2, "kplotly")) return(merge_kplotly(e1, e2))
  if (!is.function(e2)) {
    stop("Add a kplotly or a function of the widget to a kplotly.",
         call. = FALSE)
  }
  e1$extras <- c(e1$extras, list(e2))
  e1
}
