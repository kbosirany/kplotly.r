
<!-- README.md is generated from README.Rmd. Please edit that file, then
run devtools::build_readme(). -->

# kplotly.r

<!-- badges: start -->

[![R-CMD-check](https://github.com/kbosirany/kplotly.r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kbosirany/kplotly.r/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/kbosirany/kplotly.r/graph/badge.svg)](https://app.codecov.io/gh/kbosirany/kplotly.r)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: AGPL
v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

<!-- badges: end -->

Site: <https://kbosirany.github.io/kplotly.r/> (development version:
[/dev](https://kbosirany.github.io/kplotly.r/dev/))

An interactive plot with several series, a shared legend and a range
slider quickly costs a dozen lines of `plot_ly()` / `add_trace()` /
`layout()` calls and long-format bookkeeping. **kplotly.r** draws a
complete interactive plot in one short call, and plots stay composable
through the `kplotly` S3 class. It is the plotly.js counterpart of
[kggplot](https://github.com/kbosirany/kggplot), with the same
arguments: changing `kggplot(` into `kplotly(` turns a static plot into
an interactive one.

plotly.js is embedded (the “cartesian” bundle): kplotly.r only depends
on htmlwidgets, not on the plotly R package and its dependencies.

## Installation

``` r
# install.packages("pak")
pak::pak("kbosirany/kplotly.r")
```

## Example

``` r
library(kplotly.r)

# A time series: several columns, a range slider and a unified hover
weather <- data.frame(date = as.Date("2024-01-01") + 0:364)
weather$rain <- rgamma(365, 0.4, 0.1)
weather$temp <- 12 + 8 * sin(1:365 / 58 - 1.5)
kplotly(weather, "date", c("rain", "temp"), title = "Weather")

# kplot / TSstudio style calls
kplotly(weather, vars = list(x = "date", y = "all"), type = "point")

# Superpose layers: shared colours, one legend entry per level
obs <- data.frame(t = 1:20, v = (1:20)^1.2 + rnorm(20))
sim <- data.frame(t = 1:20, v = (1:20)^1.2)
kplotly(obs, "t", "v", color = "Observed", type = "point", theme = "inrae") +
  kplotly(sim, "t", "v", color = "Simulated", type = "line")

# Any plotly.js layout attribute, and the htmlwidget for Shiny
p <- kplotly(iris, "Sepal.Length", "Sepal.Width", color = "Species") |>
  kply_layout(hovermode = "x")
as_htmlwidget(p)
```

See `vignette("kplotly")` (“Get started”) for the full tour.

Branch, version and release conventions are those of
[kpkg.r](https://github.com/kbosirany/kpkg.r):
`vignette("workflow", package = "kpkg.r")`.
