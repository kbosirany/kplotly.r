# Plot types

A *type* maps a short name (`"point"`, `"line"`, `"bar"`, ...) to the
attributes of a plotly.js trace plus defaults. Types live in a registry,
so you can add your own with `kply_register_type()`. The names are those
of kggplot.

## Usage

``` r
kply_register_type(
  name,
  trace,
  params = list(),
  color = c("marker.color", "line.color"),
  sort = FALSE
)

kply_types()
```

## Arguments

- name:

  Name of the type.

- trace:

  Named list of plotly.js trace attributes defining the type, e.g.
  `list(type = "scatter", mode = "lines")`.

- params:

  Default trace attributes, overridden by the arguments of the call
  (e.g. `list(line = list(width = 1))`).

- color:

  Paths of the trace attributes that receive the colour of the series,
  e.g. `c("marker.color", "line.color")`.

- sort:

  If `TRUE`, the data are sorted by `x` before drawing (lines).

## Value

`kply_register_type()` returns `name` invisibly; `kply_types()` a
character vector of the registered types.

## Details

Built-in types: `point`, `line`, `step`, `area` and `bar` (alias `col`).

## Examples

``` r
kply_types()
#> [1] "point" "line"  "step"  "area"  "bar"   "col"  
kply_register_type(
  "linepoint", list(type = "scatter", mode = "lines+markers"),
  color = c("marker.color", "line.color"), sort = TRUE
)
kplotly(pressure, "temperature", "pressure", type = "linepoint")
```
