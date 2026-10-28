test_that("the range slider is on for time series only, unless set", {
  slider <- function(p) isTRUE(fig(p)$layout$xaxis$rangeslider$visible)
  expect_true(slider(kplotly(weather, "date", "temp")))
  expect_false(slider(kplotly(weather, "day", "temp")))
  expect_true(slider(kplotly(weather, "day", "temp", slider = TRUE)))
  expect_false(slider(kplotly(weather, "date", "temp", slider = FALSE)))
  expect_false(slider(kplotly(weather, "date", "temp") |> kply_slider(FALSE)))
})

test_that("the hover is unified along time axes", {
  expect_equal(fig(kplotly(weather, "date", "temp"))$layout$hovermode,
               "x unified")
  expect_equal(fig(kplotly(weather, "day", "temp"))$layout$hovermode,
               "closest")
})

test_that("titles can be set or removed", {
  f <- fig(kplotly(weather, "date", "temp", title = "T", subtitle = "S",
                   xlab = NA, ylab = "Temperature"))
  expect_equal(f$layout$title$text, "T")
  expect_equal(f$layout$title$subtitle$text, "S")
  expect_equal(f$layout$xaxis$title$text, "")
  expect_equal(f$layout$yaxis$title$text, "Temperature")
  expect_null(fig(kplotly(weather, "date", "temp"))$layout$title)
})

test_that("the legend can be moved or removed", {
  leg <- function(legend) {
    fig(kplotly(weather, "date", c("rain", "temp"), legend = legend))$layout
  }
  expect_false(leg("none")$showlegend)
  expect_false(leg(FALSE)$showlegend)
  expect_null(leg(NULL)$legend)
  expect_equal(leg("bottom")$legend$orientation, "h")
  # a long horizontal legend scrolls instead of covering the plot
  expect_equal(leg("bottom")$legend$maxheight, 0.25)
  expect_equal(leg("top")$legend$maxheight, 0.25)
  expect_null(leg("right")$legend$maxheight)
  expect_equal(leg("top")$legend$yanchor, "top")
  expect_equal(leg("left")$legend$xanchor, "right")
  expect_equal(leg(c(0.1, 0.9))$legend$x, 0.1)
  expect_error(leg("middle"), "legend")
  expect_error(leg(c(1, 2, 3)), "c\\(x, y\\)")
})

test_that("categories keep the order of the factor levels", {
  d <- data.frame(k = factor(c("b", "a"), c("b", "a")), n = 1:2)
  expect_equal(fig(kplotly(d, "k", "n"))$layout$xaxis$categoryarray,
               I(c("b", "a")))
})

test_that("the widget embeds plotly.js and a light configuration", {
  w <- as_htmlwidget(kplotly(weather, "date", "temp"))
  expect_s3_class(w, "kplotly_widget")
  dep <- htmlwidgets:::getDependency("kplotly_widget", "kplotly.r")
  names <- vapply(dep, `[[`, "", "name")
  expect_true("plotly.js-cartesian" %in% names)
  expect_false(w$x$config$displaylogo)
  expect_false(w$x$config$showSendToCloud)
  expect_identical(as_htmlwidget(w), w)
})

test_that("kply_layout and kply_config are applied last", {
  p <- kplotly(weather, "date", "temp", theme = "bw") |>
    kply_layout(hovermode = "closest", yaxis = list(type = "log")) |>
    kply_config(locale = "fr")
  f <- fig(p)
  expect_equal(f$layout$hovermode, "closest")
  expect_equal(f$layout$yaxis$type, "log")
  expect_true(f$layout$yaxis$showline)
  expect_equal(f$layout$yaxis$title$text, "temp")
  expect_equal(f$config$locale, "fr")
})

test_that("kply_save writes an HTML file", {
  file <- tempfile(fileext = ".html")
  on.exit(unlink(file))
  expect_equal(
    kply_save(kplotly(weather, "date", "temp"), file, selfcontained = FALSE),
    file
  )
  expect_true(file.exists(file))
})
