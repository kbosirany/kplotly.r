#' Plot types
#'
#' A *type* maps a short name (`"point"`, `"line"`, `"bar"`, ...) to the
#' attributes of a plotly.js trace plus defaults. Types live in a registry,
#' so you can add your own with `kply_register_type()`. The names are those
#' of kggplot.
#'
#' Built-in types: `point`, `line`, `step`, `area` and `bar` (alias `col`).
#'
#' @param name Name of the type.
#' @param trace Named list of plotly.js trace attributes defining the type,
#'   e.g. `list(type = "scatter", mode = "lines")`.
#' @param params Default trace attributes, overridden by the arguments of the
#'   call (e.g. `list(line = list(width = 1))`).
#' @param color Paths of the trace attributes that receive the colour of the
#'   series, e.g. `c("marker.color", "line.color")`.
#' @param sort If `TRUE`, the data are sorted by `x` before drawing (lines).
#'
#' @return `kply_register_type()` returns `name` invisibly; `kply_types()` a
#'   character vector of the registered types.
#'
#' @examples
#' kply_types()
#' kply_register_type(
#'   "linepoint", list(type = "scatter", mode = "lines+markers"),
#'   color = c("marker.color", "line.color"), sort = TRUE
#' )
#' kplotly(pressure, "temperature", "pressure", type = "linepoint")
#'
#' @export
kply_register_type <- function(name, trace, params = list(),
                               color = c("marker.color", "line.color"),
                               sort = FALSE) {
  stopifnot(
    is.character(name), length(name) == 1L, is.list(trace),
    !is.null(trace$type), is.list(params), is.character(color)
  )
  .kply$types[[name]] <- list(
    trace = trace, params = params, color = color, sort = isTRUE(sort)
  )
  invisible(name)
}

#' @export
#' @rdname kply_register_type
kply_types <- function() names(.kply$types)

get_type <- function(type) {
  if (!is.character(type) || length(type) != 1L) {
    stop("`type` must be a single string.", call. = FALSE)
  }
  spec <- .kply$types[[type]]
  if (is.null(spec)) {
    stop(
      "Unknown plot type '", type, "'. Available: ",
      paste(kply_types(), collapse = ", "), ".",
      call. = FALSE
    )
  }
  spec
}

# Pick a sensible type from the shape of the data
infer_type <- function(src, x, y) {
  hint <- attr(src, "kply_type")
  if (!is.null(hint)) return(hint)
  xv <- if (length(x) == 1L && x %in% names(src)) src[[x]]
  if (is_time(xv)) return("line")
  if (is.null(xv) || is.numeric(xv)) "point" else "bar"
}

register_builtin_types <- function() {
  reg <- kply_register_type
  reg("point", list(type = "scatter", mode = "markers"),
      color = "marker.color")
  reg("line", list(type = "scatter", mode = "lines"),
      color = "line.color", sort = TRUE)
  reg("step", list(type = "scatter", mode = "lines", line = list(shape = "hv")),
      color = "line.color", sort = TRUE)
  reg("area", list(type = "scatter", mode = "lines", fill = "tozeroy"),
      color = "line.color", sort = TRUE)
  reg("bar", list(type = "bar"), color = "marker.color")
  reg("col", list(type = "bar"), color = "marker.color")
}
