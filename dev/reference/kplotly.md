# Draw a complete interactive plot in one call

`kplotly()` builds a plotly.js graphic (reshaping, series, colours,
labels, theme, legend, range slider) from a data object and a few short
arguments, and returns a `kplotly` object. Print it to draw it, compose
it with `+`, or convert it with
[`as_htmlwidget()`](https://kbosirany.github.io/kplotly.r/dev/reference/as_htmlwidget.md).
The arguments are those of `kggplot::kggplot()`, so a call can switch
from a static to an interactive plot by changing the function name.

## Usage

``` r
kplotly(data, ...)

# Default S3 method
kplotly(
  data,
  x = NULL,
  y = NULL,
  color = NULL,
  group = NULL,
  size = NULL,
  vars = NULL,
  type = NULL,
  title = NULL,
  subtitle = NULL,
  xlab = NULL,
  ylab = NULL,
  labels = NULL,
  theme = NULL,
  palette = NULL,
  legend = NULL,
  slider = NULL,
  ...
)

# S3 method for class 'kplotly'
kplotly(data, new_data = NULL, ...)
```

## Arguments

- data:

  A data frame, or anything
  [`as_kdata()`](https://kbosirany.github.io/kplotly.r/dev/reference/as_kdata.md)
  understands (`ts`, matrix, numeric vector, named list). If a
  `kplotly`, a layer is added to it.

- ...:

  plotly.js attributes of the traces of the layer, e.g.
  `line = list(width = 1, dash = "dot")`, `opacity = 0.6`,
  `connectgaps = TRUE`.

- x, y, color, group, size:

  Aesthetics, see Details. `colour` is accepted as an alias of `color`.

- vars:

  Optional named list of aesthetics (`list(x = "a", y = "b")`), an
  alternative to the arguments above (they take precedence).

- type:

  Plot type, see
  [`kply_types()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_register_type.md).
  By default guessed from the data (line for dates and `ts`, point for
  numeric `x`, bar for a categorical `x`).

- title, subtitle:

  Plot titles.

- xlab, ylab:

  Axis titles (default: the variable names). Use `NA` to remove a title.

- labels:

  Named list of titles (`title`, `x`, `y`, `color`) for anything not
  covered by the arguments above, e.g. the legend title.

- theme:

  Theme: a name
  ([`kply_themes()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_register_theme.md))
  or a list of plotly.js layout attributes. See
  [`kply_register_theme()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_register_theme.md).

- palette:

  Colours of the series: a vector (named to fix level colours), a
  palette name
  ([`kply_palettes()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_register_theme.md))
  or a function of `n`. Default: the theme palette.

- legend:

  `"right"`, `"bottom"`, `"top"`, `"left"`, `"none"`/`FALSE`, or
  `c(x, y)` to place it inside the panel (fractions of the panel).

- slider:

  Whether to add a range slider under the x axis. By default `TRUE` for
  time series (`Date`/`POSIXct` `x`, `ts` input), `FALSE` otherwise.

- new_data:

  For the `kplotly` method: data of the new layer (default: the data of
  the first layer).

## Value

An object of class `kplotly`.

## Mapping aesthetics

`x`, `y`, `color`, `group` and `size` take column names (strings).
Special values:

- `y = c("a", "b")` or `y = "all"` plots several columns; they are
  stacked in long format and coloured by series (the pseudo-column
  `".series"` can be mapped to `color` or `group`).

- a string that is not a column, passed to `color` or `group`, creates a
  legend entry: `color = "Observed"` names the layer.

- `I("red")` (or a number, for `size`) is a fixed value, not a mapping.

- a numeric column given to `size` is rescaled to a readable range of
  marker sizes.

- `x` omitted: the first column (or the row index if `y` is given).

- `y` omitted: all the other columns.

## Extending a plot

`kplotly(p, new_data, ...)` (with `p` a kplotly), `p + kplotly(...)` and
[`kply_add()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_modify.md)
add a layer; colours stay consistent across layers and a legend entry is
shown once. Any plotly.js attribute can be set: trace attributes in
`...` (`line = list(width = 1)`, `opacity = 0.5`), layout attributes
with
[`kply_layout()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_modify.md),
and a function of the htmlwidget added with `+` is applied last.

## Examples

``` r
# scatter plot, coloured, themed: one call
kplotly(iris, "Sepal.Length", "Sepal.Width", color = "Species",
        title = "Iris", theme = "inrae")

# a time series: several columns at once, with a range slider
d <- data.frame(
  date = as.Date("2024-01-01") + 0:99,
  rain = rgamma(100, 0.5, 0.2),
  temp = 10 + 5 * sin(1:100 / 15)
)
kplotly(d, "date", "all", title = "Weather")

# the same, with the kplot / TSstudio style `vars`
kplotly(d, vars = list(x = "date", y = c("rain", "temp")), type = "point")

# superpose a second dataset: consistent colours and a shared legend
obs <- data.frame(t = 1:10, v = cumsum(rep(1, 10)))
sim <- data.frame(t = 1:10, v = cumsum(rep(1.2, 10)))
kplotly(obs, "t", "v", color = "Observed", type = "point") +
  kplotly(sim, "t", "v", color = "Simulated", type = "line")
```
