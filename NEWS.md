# kplotly.r 0.0.0.9000

* A horizontal legend (`legend = "bottom"` or `"top"`) no longer covers the
  plot and the range slider when it has many entries: plotly.js reserves no
  margin for a legend anchored to the figure, so the widget now measures it
  and widens the margin on its side. A legend taller than a quarter of the
  figure scrolls (`maxheight`).

* First version: the plotly.js counterpart of kggplot, with the same
  arguments, so a call switches from a static to an interactive plot by
  changing the function name.
* plotly.js 4.1.2 is embedded (the "cartesian" bundle, 1.5 MB): the package
  only depends on htmlwidgets, not on the plotly R package and its
  dependencies (ggplot2, dplyr, tidyr, data.table...).
* `kplotly()` draws a complete interactive plot in one call: several `y`
  columns (or `"all"`) stacked and coloured by series, colours shared across
  layers, legend entries shown once and toggling a level in every layer,
  titles, themes, palettes, legend position. The `vars` argument of kplot is
  accepted.
* Time series (`Date`/`POSIXct` `x`, `ts` input) get a range slider
  (`slider = TRUE`) and a unified hover by default.
* Layer types: `point`, `line`, `step`, `area`, `bar` (alias `col`), guessed
  from the data when omitted. Themes: `default`, `minimal`, `bw`, `inrae`.
  Palettes: `plotly`, `inrae`, `okabe_ito`. All in extensible registries.
* Composition: `+` between two `kplotly` objects, `kplotly(p, data)`,
  `kply_add()`, and functions of the widget added with `+`. Modifiers:
  `kply_labs()`, `kply_theme()`, `kply_palette()`, `kply_legend()`,
  `kply_slider()`, `kply_layout()`, `kply_config()`, `kply_save()`.
