# Add layers or widget steps to a kplotly

- `kplotly + kplotly`: appends the layers of the right-hand plot; its
  theme, titles, legend, palette and slider override the left ones when
  specified.

- `kplotly + <function>`: a function of the htmlwidget returning a
  widget (e.g. `function(w) htmlwidgets::onRender(w, js)`), stored and
  applied last, in order.

## Usage

``` r
# S3 method for class 'kplotly'
e1 + e2
```

## Arguments

- e1:

  A `kplotly`.

- e2:

  A `kplotly` or a function of an htmlwidget.

## Value

A `kplotly`.

## Examples

``` r
d <- data.frame(t = 1:10, v = (1:10)^2)
kplotly(d, "t", "v", type = "point") + kplotly(d, "t", "v", type = "line")
```
