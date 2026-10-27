# Themes and palettes

A kplotly *theme* bundles plotly.js layout attributes (fonts,
background, grid, axes) and (optionally) a colour palette under one
name, so `kplotly(..., theme = "inrae")` styles the whole plot. Register
your own with `kply_register_theme()` and `kply_register_palette()`.

## Usage

``` r
kply_register_theme(name, layout = list(), palette = NULL)

kply_register_palette(name, colors)

kply_themes()

kply_palettes()
```

## Arguments

- name:

  Name of the theme or palette.

- layout:

  Named list of plotly.js layout attributes, merged under the attributes
  set by kplotly (titles, legend, slider).

- palette:

  Colours of the theme: a character vector of colours, the name of a
  registered palette, or `NULL`.

- colors:

  Character vector of colours (or a function of `n`).

## Value

`kply_register_*()` return `name` invisibly; `kply_themes()` and
`kply_palettes()` return the registered names.

## Details

A `theme` argument accepted by
[`kplotly()`](https://kbosirany.github.io/kplotly.r/dev/reference/kplotly.md)
can be a registered name or a list of plotly.js layout attributes. Set
`options(kplotly.theme = )` and `options(kplotly.palette = )` to change
the defaults session-wide.

Built-in themes: `default` (plotly.js defaults), `minimal` (white
background, light grid), `bw` (white background, framed panel) and
`inrae` (colours of the INRAE graphic charter). Built-in palettes:
`plotly` (the plotly.js default colours), `inrae` and `okabe_ito`.

## Examples

``` r
kply_themes()
#> [1] "default" "minimal" "bw"      "inrae"  
kply_register_palette("traffic", c("#2ecc71", "#f1c40f", "#e74c3c"))
kply_register_theme(
  "traffic", list(plot_bgcolor = "#fafafa"), palette = "traffic"
)
kplotly(iris, "Sepal.Length", "Sepal.Width", color = "Species",
        theme = "traffic")
```
