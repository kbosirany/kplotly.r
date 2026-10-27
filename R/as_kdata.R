#' Convert an input object to a data frame for kplotly
#'
#' `as_kdata()` is the S3 entry point that turns whatever you hand to
#' [kplotly()] into a plain data frame. Add a method to teach kplotly a new
#' input class. A method may set the attributes `kply_x`, `kply_y` (default
#' variables to plot), `kply_type` (default plot type) and `kply_slider`
#' (range slider by default) on the result; they are only used when the call
#' does not specify `x`, `y`, `type` or `slider`.
#'
#' Built-in methods: `data.frame` (and tibbles), `ts`/`mts`, `matrix`,
#' atomic vectors (numeric, character, factor, logical), `list` of
#' equal-length vectors.
#'
#' @param x Object to convert.
#' @param ... Unused, for method extensions.
#'
#' @return A data frame.
#'
#' @examples
#' as_kdata(ts(c(1, 3, 2), start = 2000))
#' as_kdata(matrix(1:6, 3, dimnames = list(NULL, c("a", "b"))))
#' as_kdata(c(2, 4, 8))
#'
#' @export
as_kdata <- function(x, ...) {
  UseMethod("as_kdata")
}

#' @export
#' @rdname as_kdata
as_kdata.data.frame <- function(x, ...) {
  if (ncol(x) == 0L) stop("`data` has no column.", call. = FALSE)
  as.data.frame(x)
}

#' @export
#' @rdname as_kdata
as_kdata.ts <- function(x, ...) {
  tm <- as.numeric(stats::time(x))
  if (is.matrix(x)) {
    out <- as.data.frame(unclass(x), stringsAsFactors = FALSE)
    if (is.null(colnames(x))) names(out) <- paste0("V", seq_len(ncol(x)))
    out <- cbind(time = tm, out)
  } else {
    out <- data.frame(time = tm, value = as.numeric(x))
  }
  attr(out, "kply_x") <- "time"
  attr(out, "kply_type") <- "line"
  attr(out, "kply_slider") <- TRUE
  out
}

#' @export
#' @rdname as_kdata
as_kdata.matrix <- function(x, ...) {
  out <- as.data.frame(x, stringsAsFactors = FALSE)
  if (is.null(colnames(x))) names(out) <- paste0("V", seq_len(ncol(x)))
  out
}

#' @export
#' @rdname as_kdata
as_kdata.numeric <- function(x, ...) {
  out <- data.frame(index = seq_along(x), value = as.numeric(x))
  attr(out, "kply_x") <- "index"
  attr(out, "kply_y") <- "value"
  out
}

#' @export
#' @rdname as_kdata
as_kdata.list <- function(x, ...) {
  if (is.null(names(x)) || !all(nzchar(names(x)))) {
    stop("A list given to kplotly() must be fully named.", call. = FALSE)
  }
  as_kdata.data.frame(as.data.frame(x, stringsAsFactors = FALSE))
}

#' @export
#' @rdname as_kdata
as_kdata.default <- function(x, ...) {
  out <- tryCatch(
    as.data.frame(x),
    error = function(e) {
      stop(
        "Don't know how to plot an object of class '", class(x)[1L], "'. ",
        "Define a method as_kdata.", class(x)[1L], "().",
        call. = FALSE
      )
    }
  )
  as_kdata.data.frame(out)
}
