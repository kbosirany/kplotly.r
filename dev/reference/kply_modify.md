# Modify a kplotly

Pipe-friendly setters. Each returns a modified `kplotly`; unspecified
arguments are left unchanged.

## Usage

``` r
kply_add(p, data = NULL, ...)

kply_labs(p, title = NULL, subtitle = NULL, x = NULL, y = NULL, ...)

kply_theme(p, theme, palette = NULL)

kply_palette(p, palette)

kply_legend(p, legend)

kply_slider(p, slider = TRUE)

kply_layout(p, ...)

kply_config(p, ...)
```

## Arguments

- p:

  A `kplotly`.

- data:

  Data of the new layer (default: the data of the first layer).

- ...:

  For `kply_add()`: arguments of
  [`kplotly()`](https://kbosirany.github.io/kplotly.r/dev/reference/kplotly.md)
  (aesthetics, `type`, trace attributes, ...). For `kply_labs()`: legend
  titles such as `color = "Species"`. For `kply_layout()` and
  `kply_config()`: plotly.js layout or configuration attributes
  (`hovermode = "closest"`, `yaxis = list(type = "log")`,
  `locale = "fr"`...).

- title, subtitle, x, y:

  Titles. `NA` removes a title.

- theme, palette, legend, slider:

  See
  [`kplotly()`](https://kbosirany.github.io/kplotly.r/dev/reference/kplotly.md).

## Value

A `kplotly`.

## Details

`kply_add()` appends a layer. Aesthetics you do not give (`x`, `y`,
`color`...) are inherited from the first layer when they refer to
columns that exist in the new data; `type` is guessed again.

`kply_layout()` and `kply_config()` set any plotly.js layout or
configuration attribute; they are applied last, over the theme and the
settings of kplotly (lists are merged).

## Examples

``` r
d <- data.frame(date = as.Date("2024-01-01") + 0:59, v = cumsum(rnorm(60)))
kplotly(d, "date", "v", type = "point") |>
  kply_add(type = "line") |>
  kply_labs(title = "Random walk", y = "Level") |>
  kply_theme("inrae") |>
  kply_legend("bottom") |>
  kply_slider(FALSE) |>
  kply_layout(yaxis = list(zeroline = TRUE))
```
