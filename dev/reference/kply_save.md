# Save a kplotly to an HTML file

Thin wrapper around
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
that accepts a `kplotly`.

## Usage

``` r
kply_save(p, file, selfcontained = TRUE, ...)
```

## Arguments

- p:

  A `kplotly` or an htmlwidget.

- file:

  File to save to (`.html`).

- selfcontained:

  Whether to embed everything, plotly.js included, in the file (needs
  pandoc).

- ...:

  Passed to
  [`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html).

## Value

The file name, invisibly.
