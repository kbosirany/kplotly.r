#' Modify a kplotly
#'
#' Pipe-friendly setters. Each returns a modified `kplotly`; unspecified
#' arguments are left unchanged.
#'
#' `kply_add()` appends a layer. Aesthetics you do not give (`x`, `y`,
#' `color`...) are inherited from the first layer when they refer to columns
#' that exist in the new data; `type` is guessed again.
#'
#' `kply_layout()` and `kply_config()` set any plotly.js layout or
#' configuration attribute; they are applied last, over the theme and the
#' settings of kplotly (lists are merged).
#'
#' @param p A `kplotly`.
#' @param data Data of the new layer (default: the data of the first layer).
#' @param ... For `kply_add()`: arguments of [kplotly()] (aesthetics, `type`,
#'   trace attributes, ...). For `kply_labs()`: legend titles such as
#'   `color = "Species"`. For `kply_layout()` and `kply_config()`: plotly.js
#'   layout or configuration attributes (`hovermode = "closest"`,
#'   `yaxis = list(type = "log")`, `locale = "fr"`...).
#' @param title,subtitle,x,y Titles. `NA` removes a title.
#' @param theme,palette,legend,slider See [kplotly()].
#'
#' @return A `kplotly`.
#'
#' @examples
#' d <- data.frame(date = as.Date("2024-01-01") + 0:59, v = cumsum(rnorm(60)))
#' kplotly(d, "date", "v", type = "point") |>
#'   kply_add(type = "line") |>
#'   kply_labs(title = "Random walk", y = "Level") |>
#'   kply_theme("inrae") |>
#'   kply_legend("bottom") |>
#'   kply_slider(FALSE) |>
#'   kply_layout(yaxis = list(zeroline = TRUE))
#'
#' @name kply_modify
NULL

#' @export
#' @rdname kply_modify
kply_add <- function(p, data = NULL, ...) {
  check_kplotly(p)
  dots <- list(...)
  first <- p$layers[[1L]]
  given <- c(norm_aes_names(names(dots)), names(norm_list(dots$vars)))
  new_src <- if (is.null(data)) first$source else as_kdata(data)
  for (a in setdiff(names(first$mapped), given)) {
    if (all(first$mapped[[a]] %in% c(names(new_src), ".series", "all"))) {
      dots[[a]] <- first$mapped[[a]]
    }
  }
  layer_plot <- do.call(kplotly, c(list(new_src), dots))
  merge_kplotly(p, layer_plot)
}

#' @export
#' @rdname kply_modify
kply_labs <- function(p, title = NULL, subtitle = NULL, x = NULL, y = NULL,
                      ...) {
  check_kplotly(p)
  new <- norm_list(c(
    list(title = title, subtitle = subtitle, x = x, y = y), list(...)
  ))
  p$labels <- utils::modifyList(p$labels, new)
  p
}

#' @export
#' @rdname kply_modify
kply_theme <- function(p, theme, palette = NULL) {
  check_kplotly(p)
  p$theme <- theme
  if (!is.null(palette)) p$palette <- palette
  p
}

#' @export
#' @rdname kply_modify
kply_palette <- function(p, palette) {
  check_kplotly(p)
  p$palette <- palette
  p
}

#' @export
#' @rdname kply_modify
kply_legend <- function(p, legend) {
  check_kplotly(p)
  p$legend <- legend
  p
}

#' @export
#' @rdname kply_modify
kply_slider <- function(p, slider = TRUE) {
  check_kplotly(p)
  p$slider <- slider
  p
}

#' @export
#' @rdname kply_modify
kply_layout <- function(p, ...) {
  check_kplotly(p)
  p$layout <- utils::modifyList(p$layout %||% list(), list(...))
  p
}

#' @export
#' @rdname kply_modify
kply_config <- function(p, ...) {
  check_kplotly(p)
  p$config <- utils::modifyList(p$config %||% list(), list(...))
  p
}

check_kplotly <- function(p) {
  if (!inherits(p, "kplotly")) {
    stop("`p` must be a kplotly object.", call. = FALSE)
  }
}

# Combine two kplotlys: layers are appended, settings given on the right
# override those on the left.
merge_kplotly <- function(a, b) {
  a$layers <- c(a$layers, b$layers)
  a$labels <- utils::modifyList(a$labels, b$labels)
  for (nm in c("theme", "palette", "legend", "slider")) {
    if (!is.null(b[[nm]])) a[[nm]] <- b[[nm]]
  }
  a$layout <- utils::modifyList(a$layout, b$layout)
  a$config <- utils::modifyList(a$config, b$config)
  a$extras <- c(a$extras, b$extras)
  a
}
