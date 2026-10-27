# Convert to an htmlwidget

`as_htmlwidget()` renders a
[`kplotly()`](https://kbosirany.github.io/kplotly.r/dev/reference/kplotly.md)
specification into an htmlwidget drawn by the embedded plotly.js, which
you can use in R Markdown, Quarto or Shiny
([`htmlwidgets::shinyRenderWidget()`](https://rdrr.io/pkg/htmlwidgets/man/htmlwidgets-shiny.html)),
or save with
[`kply_save()`](https://kbosirany.github.io/kplotly.r/dev/reference/kply_save.md).
Printing a kplotly does this implicitly.

## Usage

``` r
as_htmlwidget(x, ...)

# S3 method for class 'htmlwidget'
as_htmlwidget(x, ...)

# S3 method for class 'kplotly'
as_htmlwidget(x, width = NULL, height = NULL, elementId = NULL, ...)
```

## Arguments

- x:

  A `kplotly` (or an htmlwidget, returned unchanged).

- ...:

  Unused.

- width, height:

  Size of the widget, in pixels or as a CSS size (`"100%"`). Default:
  the width of the container and 400 pixels.

- elementId:

  Optional id of the widget element.

## Value

An htmlwidget of class `kplotly_widget`. Its `x` element holds the
plotly.js figure: `data` (traces), `layout` and `config`.

## Examples

``` r
p <- kplotly(pressure, "temperature", "pressure", type = "line")
w <- as_htmlwidget(p)
class(w)
#> [1] "kplotly_widget" "htmlwidget"    
w$x$layout$xaxis$title
#> $text
#> [1] "temperature"
#> 
```
