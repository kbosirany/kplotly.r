# A layer = source data + how to read it. The heavy work (reshaping to long
# format, standardising column names) is done lazily by resolve_layer() when the
# plot is built, so settings added later still see every column. The logic is
# that of kggplot, so both packages read a call the same way.

# Decide what a user-supplied aesthetic value means:
#  * column name(s)                -> "col"   (mapped to data)
#  * other string for colour/group -> "const" (a legend entry, e.g. a layer
#    name such as "Observed")
#  * I("red"), numbers, other strings -> "fixed" (plain trace attribute)
classify_aes <- function(name, value, cols) {
  if (inherits(value, "AsIs")) {
    class(value) <- setdiff(class(value), "AsIs")
    return(list(kind = "fixed", value = value))
  }
  if (is.character(value) || is.factor(value)) {
    return(classify_chr(name, as.character(value), cols))
  }
  if (name %in% position_aes) {
    stop("`", name, "` must be column name(s) of the data.", call. = FALSE)
  }
  list(kind = "fixed", value = value)
}

classify_chr <- function(name, value, cols) {
  if (all(value %in% cols) || (name == "y" && identical(value, "all"))) {
    return(list(kind = "col", value = value))
  }
  if (name %in% position_aes) {
    stop(
      "Column(s) not found in data for `", name, "`: ",
      paste(setdiff(value, cols), collapse = ", "),
      ". Available: ", paste(setdiff(cols, ".series"), collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!name %in% c("colour", "group")) {
    return(list(kind = "fixed", value = value))
  }
  if (length(value) != 1L) {
    stop("`", name, "` must be a single column or label.", call. = FALSE)
  }
  list(kind = "const", value = value)
}

new_layer <- function(source, args, type = NULL, params = list()) {
  cols <- c(names(source), ".series")
  kinds <- lapply(names(args), function(a) classify_aes(a, args[[a]], cols))
  names(kinds) <- names(args)
  pick <- function(kind) {
    sel <- Filter(function(cl) cl$kind == kind, kinds)
    lapply(sel, function(cl) cl$value)
  }
  if (!is.null(type)) get_type(type) # validate early
  list(
    source = source, mapped = pick("col"), const = pick("const"),
    fixed = pick("fixed"), params = params, type = type
  )
}

others_of <- function(mapped) mapped[setdiff(names(mapped), position_aes)]

# x and y columns: explicit, else the hints of as_kdata(), else the first
# column against all the others
default_xy <- function(src, mapped) {
  cols <- names(src)
  others <- unlist(others_of(mapped))
  x <- mapped[["x"]]
  y <- mapped[["y"]]
  if (is.null(x) && is.null(y)) {
    x <- attr(src, "kply_x") %||% cols[1L]
    y <- attr(src, "kply_y") %||% setdiff(cols, c(x, others))
  }
  if (identical(y, "all")) y <- setdiff(cols, c(x, others))
  list(x = x, y = if (length(y)) y)
}

# What a layer plots: type, x and y. Checks that the type gets what it needs.
plan_layer <- function(layer) {
  xy <- default_xy(layer$source, layer$mapped)
  type <- layer$type %||% infer_type(layer$source, xy$x, xy$y)
  if (is.null(xy$y)) {
    stop("Plot type '", type, "' needs a `y` variable.", call. = FALSE)
  }
  list(
    spec = get_type(type), x = xy$x %||% ".index", y = xy$y
  )
}

# Stack the y columns of `d` in long format. Returns the data (rows repeated
# once per y column), the stacked values, the series factor and the number of
# rows.
stack_y <- function(d, y, keep_cols) {
  n0 <- nrow(d)
  k <- length(y)
  if (k == 1L) {
    return(list(d = d, val = d[[y]], series = const_factor(y, n0), n = n0))
  }
  val <- unlist(lapply(y, function(cn) d[[cn]]), use.names = FALSE)
  d <- d[setdiff(names(d), setdiff(y, keep_cols))]
  d <- d[rep.int(seq_len(n0), k), , drop = FALSE]
  series <- structure(rep(seq_len(k), each = n0), levels = y, class = "factor")
  list(d = d, val = val, series = series, n = n0 * k)
}

x_values <- function(layer, d, st, pl) {
  if (identical(pl$x, ".index")) {
    return(rep.int(seq_len(nrow(layer$source)), nlevels(st$series)))
  }
  d[[pl$x]]
}

# Standardised columns (x, y, colour...) of a layer
std_columns <- function(layer, d, st, pl) {
  out <- list(x = x_values(layer, d, st, pl), y = st$val)
  others <- others_of(layer$mapped)
  for (a in names(others)) {
    cn <- others[[a]]
    if (length(cn) != 1L) {
      stop("`", a, "` must be a single column.", call. = FALSE)
    }
    out[[a]] <- if (cn == ".series") st$series else d[[cn]]
  }
  for (a in names(layer$const)) out[[a]] <- const_factor(layer$const[[a]], st$n)
  out
}

# Colour by series when several y are stacked and nothing is mapped to
# colour; group by series x colour otherwise.
add_series_aes <- function(out, series) {
  k <- nlevels(series)
  used <- k > 1L && is.null(out$colour)
  if (used) out$colour <- series
  key <- out$group
  if (is.null(key) && !used) key <- out$colour
  if (k > 1L && !is.null(key)) {
    out$group <- interaction(series, key, drop = TRUE)
  }
  list(out = out, used = used)
}

# Default axis and legend titles; NA means "no title"
layer_labels <- function(layer, pl, series_used) {
  k <- length(pl$y)
  lab <- list(
    x = if (identical(pl$x, ".index")) "Index" else pl$x,
    y = if (k == 1L) pl$y else "value"
  )
  colour <- layer$mapped[["colour"]]
  if (!is.null(colour)) {
    lab$colour <- if (colour == ".series") NA_character_ else colour
  }
  if (!is.null(layer$const$colour) || series_used) lab$colour <- NA_character_
  lab
}

# Turn a layer into standardised long data + labels
resolve_layer <- function(layer) {
  cols <- names(layer$source)
  pl <- plan_layer(layer)
  others <- unlist(others_of(layer$mapped))
  ref <- unique(c(pl$x, pl$y, others))
  d <- as.data.frame(layer$source)[ref[ref %in% cols]]
  st <- stack_y(d, pl$y, c(pl$x, others))

  ser <- add_series_aes(std_columns(layer, st$d, st, pl), st$series)
  out <- ser$out
  out$.series <- st$series
  attr(out, "row.names") <- .set_row_names(st$n)
  class(out) <- "data.frame"

  list(
    data = out, labels = layer_labels(layer, pl, ser$used),
    fixed = layer$fixed, params = layer$params, spec = pl$spec,
    slider = attr(layer$source, "kply_slider")
  )
}
