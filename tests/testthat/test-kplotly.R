test_that("several y columns give one trace per series", {
  p <- kplotly(weather, "date", c("rain", "temp"))
  f <- fig(p)
  expect_length(f$data, 2)
  expect_equal(trace_names(p), c("rain", "temp"))
  expect_equal(f$layout$yaxis$title$text, "value")
  expect_equal(f$layout$xaxis$title$text, "date")
})

test_that("`vars` and y = \"all\" are understood (kplot style calls)", {
  p <- kplotly(weather, vars = list(x = "day", y = "all"), type = "point")
  expect_equal(trace_names(p), c("date", "rain", "temp"))
  q <- kplotly(weather, vars = list(x = "date", y = c("rain", "temp")))
  expect_equal(trace_names(q), c("rain", "temp"))
  expect_error(kplotly(weather, vars = list(z = "a")), "Unknown aesthetic")
})

test_that("x and y default to the first column against the others", {
  expect_equal(trace_names(kplotly(weather)), c("rain", "temp", "day"))
  expect_equal(fig(kplotly(c(3, 1, 2)))$data[[1]]$y, I(c(3, 1, 2)))
})

test_that("the type is guessed from x and can be set", {
  type_of <- function(p) {
    tr <- fig(p)$data[[1]]
    paste(tr$type, tr$mode %||% "")
  }
  expect_equal(type_of(kplotly(weather, "date", "temp")), "scatter lines")
  expect_equal(type_of(kplotly(weather, "day", "temp")), "scatter markers")
  expect_equal(type_of(kplotly(iris, "Species", "Sepal.Length")), "bar ")
  expect_equal(type_of(kplotly(weather, "day", "temp", type = "bar")), "bar ")
  st <- fig(kplotly(weather, "day", "temp", type = "step"))$data[[1]]
  expect_equal(st$line$shape, "hv")
  ar <- fig(kplotly(weather, "day", "temp", type = "area"))$data[[1]]
  expect_equal(ar$fill, "tozeroy")
  expect_error(kplotly(weather, "day", "temp", type = "nope"), "Unknown")
})

test_that("dates are sent as local ISO strings, NA as missing values", {
  f <- fig(kplotly(weather, "date", "rain"))
  expect_equal(unclass(f$data[[1]]$x[1:2]), c("2024-01-01", "2024-01-02"))
  expect_true(is.na(f$data[[1]]$y[3]))
  t <- as.POSIXct("2024-05-01 12:30:00", tz = "Europe/Paris") + 0:1 * 3600
  g <- fig(kplotly(data.frame(t = t, v = 1:2), "t", "v"))
  expect_equal(unclass(g$data[[1]]$x[1]), "2024-05-01 12:30:00")
  json <- htmlwidgets:::toJSON(fig(kplotly(data.frame(a = 1, b = 2), "a", "b")))
  expect_match(json, "\"x\":[1]", fixed = TRUE)
  rain <- htmlwidgets:::toJSON(fig(kplotly(weather, "date", "rain"))$data)
  expect_match(rain, "[0,2,null,5", fixed = TRUE)
})

test_that("lines are sorted by x, points are not", {
  d <- data.frame(x = c(3, 1, 2), y = c(30, 10, 20))
  expect_equal(fig(kplotly(d, "x", "y", type = "line"))$data[[1]]$y,
               I(c(10, 20, 30)))
  expect_equal(fig(kplotly(d, "x", "y", type = "point"))$data[[1]]$y,
               I(c(30, 10, 20)))
})

test_that("colour, group and size map columns or fixed values", {
  p <- kplotly(iris, "Sepal.Length", "Sepal.Width", color = "Species",
               size = "Petal.Width")
  f <- fig(p)
  expect_equal(trace_names(p), levels(iris$Species))
  expect_equal(f$layout$legend$title$text, "Species")
  expect_true(all(f$data[[1]]$marker$size >= 4))
  red <- fig(kplotly(weather, "day", "temp", color = I("red"), size = 3))
  expect_equal(red$data[[1]]$marker$color, "red")
  expect_equal(red$data[[1]]$marker$size, 3)
  g <- fig(kplotly(data.frame(x = 1:4, y = 1:4, g = c(1, 1, 2, 2)), "x", "y",
                   group = "g", type = "line"))
  expect_length(g$data, 2)
  expect_false(g$data[[1]]$showlegend)
  expect_error(fig(kplotly(weather, "day", "temp", color = "day")), "factor")
  expect_error(fig(kplotly(weather, "day", "temp", size = "date")), "numeric")
})

test_that("missing colour values get their own level", {
  d <- data.frame(x = 1:3, y = 1:3, k = c("a", NA, "b"))
  expect_equal(trace_names(kplotly(d, "x", "y", color = "k")),
               c("a", "b", "NA"))
})

test_that("errors are clear", {
  expect_error(kplotly(weather, "nope", "temp"), "not found")
  expect_error(kplotly(weather, 1, "temp"), "column name")
  expect_error(kplotly(weather, "day", "temp", color = c("a", "b")),
               "single")
  expect_error(fig(kplotly(data.frame(a = 1:3), "a")), "needs a `y`")
})

test_that("trace attributes in ... are merged last", {
  f <- fig(kplotly(weather, "date", "temp", line = list(width = 1),
                   opacity = 0.5))
  expect_equal(f$data[[1]]$line$width, 1)
  expect_equal(f$data[[1]]$opacity, 0.5)
  expect_false(is.null(f$data[[1]]$line$color))
})

test_that("custom types can be registered", {
  kply_register_type("linepoint", list(type = "scatter",
                                       mode = "lines+markers"))
  on.exit(.kply$types$linepoint <- NULL)
  tr <- fig(kplotly(weather, "day", "temp", type = "linepoint"))$data[[1]]
  expect_equal(tr$mode, "lines+markers")
  expect_false(is.null(tr$marker$color) || is.null(tr$line$color))
})
