`%||%` <- function(x, y) if (is.null(x)) y else x

# Constant factor of length n (cheap: no character vector is allocated)
const_factor <- function(label, n) {
  structure(rep.int(1L, n), levels = as.character(label), class = "factor")
}

# Aesthetics understood by kplotly (US spelling "color" is normalised)
std_aes <- c("x", "y", "colour", "group", "size")

# Aesthetics that are read as columns of the data and never as a legend entry
# or a fixed value
position_aes <- c("x", "y")

norm_aes_names <- function(nm) {
  if (is.null(nm)) return(nm)
  sub("^color$", "colour", nm)
}

# Normalise a named list: US -> UK spelling, drop NULL entries
norm_list <- function(x) {
  if (!length(x)) return(list())
  names(x) <- norm_aes_names(names(x))
  x[!vapply(x, is.null, logical(1))]
}

is_time <- function(x) inherits(x, c("Date", "POSIXt"))

# Linear rescaling of a numeric vector to `range` (constant input -> middle)
rescale_to <- function(x, range) {
  r <- base::range(x, na.rm = TRUE, finite = TRUE)
  if (!all(is.finite(r)) || r[1L] == r[2L]) {
    return(ifelse(is.na(x), NA_real_, mean(range)))
  }
  range[1L] + (x - r[1L]) / (r[2L] - r[1L]) * (range[2L] - range[1L])
}

# Set `value` at a dotted path of a nested list: set_path(l, "line.color", v)
set_path <- function(l, path, value) {
  keys <- strsplit(path, ".", fixed = TRUE)[[1L]]
  if (length(keys) == 1L) {
    l[[keys]] <- value
    return(l)
  }
  l[[keys[1L]]] <- set_path(
    l[[keys[1L]]] %||% list(), paste(keys[-1L], collapse = "."), value
  )
  l
}
