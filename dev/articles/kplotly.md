# Get started with kplotly.r

[`kplotly()`](https://kbosirany.github.io/kplotly.r/dev/reference/kplotly.md)
draws an interactive plotly.js graphic from a single call and returns a
`kplotly` object that you can compose, modify, or turn into an
htmlwidget. Its arguments are those of `kggplot::kggplot()`: switching a
call from a static to an interactive plot is a matter of changing the
function name.

plotly.js is embedded in the package (the “cartesian” bundle), so
kplotly.r only depends on htmlwidgets, not on the plotly R package.

## Time series

A `Date` or `POSIXct` `x` gives a line, a range slider under the x axis
and a hover that shows every series at the hovered date. Several `y`
columns (or `"all"`) are stacked and coloured by series.

``` r

set.seed(1)
weather <- data.frame(date = as.Date("2024-01-01") + 0:364)
weather$rain <- rgamma(365, 0.4, 0.1)
weather$temp <- 12 + 8 * sin(1:365 / 58 - 1.5) + rnorm(365)
kplotly(weather, "date", c("rain", "temp"), title = "Weather in 2024")
```

The `vars` argument of kplot and TSstudio style calls is accepted, and
`slider` turns the range slider on or off:

``` r

kplotly(weather, vars = list(x = "date", y = "all"), type = "point",
        slider = FALSE)
```

A `ts` object works too:

``` r

kplotly(AirPassengers, title = "Air passengers", theme = "minimal")
```

## Types, colours and sizes

The type is guessed from `x` (line for dates, point for numbers, bar for
categories) or set with `type`:
[`kply_types()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_register_type.md)
lists them.

``` r

kply_types()
#> [1] "point" "line"  "step"  "area"  "bar"   "col"
kplotly(iris, "Sepal.Length", "Sepal.Width", color = "Species",
        size = "Petal.Width", theme = "bw")
```

A string that is not a column names the layer in the legend, and
[`I()`](https://rdrr.io/r/base/AsIs.html) gives a fixed value:

``` r

obs <- data.frame(t = 1:20, v = (1:20)^1.2 + rnorm(20))
sim <- data.frame(t = 1:20, v = (1:20)^1.2)
kplotly(obs, "t", "v", color = "Observed", type = "point") +
  kplotly(sim, "t", "v", color = I("black"), type = "line")
```

## Composing plots

`+` superposes plots: colours are shared and a legend entry is shown
once; clicking it hides the level in every layer.

``` r

kplotly(obs, "t", "v", color = "Observed", type = "point") +
  kplotly(sim, "t", "v", color = "Simulated", type = "line") +
  kplotly(obs, "t", "v", color = "Observed", type = "line",
          line = list(dash = "dot"))
```

Pipe-friendly modifiers change a plot afterwards:

``` r

kplotly(weather, "date", "temp") |>
  kply_add(type = "point", opacity = 0.4) |>
  kply_labs(title = "Temperature", y = "°C") |>
  kply_theme("inrae") |>
  kply_legend("bottom")
```

## Themes and palettes

``` r

kply_themes()
#> [1] "default" "minimal" "bw"      "inrae"
kply_palettes()
#> [1] "plotly"    "inrae"     "okabe_ito"
kplotly(weather, "date", c("rain", "temp"), theme = "inrae")
```

`palette` takes a palette name, colours (named to fix the colour of a
level) or a function of `n`.

## Going further with plotly.js

Any plotly.js attribute is reachable:

- trace attributes in the `...` of
  [`kplotly()`](https://kbosirany.github.io/kplotly.r/dev/reference/kplotly.md)
  (`line = list(width = 1)`, `opacity`, `connectgaps`…);
- layout attributes with
  [`kply_layout()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_modify.md),
  configuration with
  [`kply_config()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_modify.md);
- a function of the htmlwidget added with `+`, applied last
  (e.g. [`htmlwidgets::onRender()`](https://rdrr.io/pkg/htmlwidgets/man/onRender.html)).

``` r

kplotly(weather, "date", "rain", type = "bar") |>
  kply_layout(yaxis = list(type = "log")) |>
  kply_config(locale = "fr")
```

[`as_htmlwidget()`](https://kbosirany.github.io/kplotly.r/dev/reference/as_htmlwidget.md)
returns the widget, for Shiny
([`htmlwidgets::shinyRenderWidget()`](https://rdrr.io/pkg/htmlwidgets/man/htmlwidgets-shiny.html))
or to save it;
[`kply_save()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_save.md)
writes an HTML file.

## Extending kplotly.r

Types, themes and palettes live in registries:

``` r

kply_register_type(
  "linepoint", list(type = "scatter", mode = "lines+markers"),
  color = c("marker.color", "line.color"), sort = TRUE
)
kply_register_palette("traffic", c("#2ecc71", "#f1c40f", "#e74c3c"))
kply_register_theme("traffic", list(plot_bgcolor = "#fafafa"),
                    palette = "traffic")
kplotly(pressure, "temperature", "pressure", type = "linepoint",
        theme = "traffic")
```

A new input class needs an
[`as_kdata()`](https://kbosirany.github.io/kplotly.r/dev/reference/as_kdata.md)
method returning a data frame.
