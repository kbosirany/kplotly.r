test_that("`+` appends layers and settings of the right side win", {
  a <- kplotly(weather, "date", "rain", theme = "bw")
  b <- kplotly(weather, "date", "temp", theme = "inrae", legend = "bottom")
  p <- a + b
  expect_length(p$layers, 2)
  expect_equal(p$theme, "inrae")
  expect_equal(p$legend, "bottom")
  expect_error(a + 1, "function")
})

test_that("named layers share colours and show each legend entry once", {
  obs <- data.frame(t = 1:3, v = 1:3)
  sim <- data.frame(t = 1:3, v = 2:4)
  p <- kplotly(obs, "t", "v", color = "Observed", type = "point") +
    kplotly(sim, "t", "v", color = "Simulated", type = "line") +
    kplotly(obs, "t", "v", color = "Observed", type = "line")
  f <- fig(p)
  expect_equal(trace_names(p), c("Observed", "Simulated", "Observed"))
  expect_equal(vapply(f$data, `[[`, TRUE, "showlegend"), c(TRUE, TRUE, FALSE))
  expect_equal(f$data[[1]]$marker$color, f$data[[3]]$line$color)
  expect_false(f$data[[1]]$marker$color == f$data[[2]]$line$color)
  expect_null(f$layout$legend$title)
})

test_that("kply_add and kplotly(p, data) inherit the aesthetics", {
  p <- kplotly(weather, "date", "temp", type = "point") |>
    kply_add(type = "line")
  expect_equal(p$layers[[2]]$mapped$y, "temp")
  q <- kplotly(kplotly(weather, "date", "temp"),
               data.frame(date = weather$date, other = 1))
  expect_length(q$layers, 2)
  expect_null(q$layers[[2]]$mapped$y)
  expect_error(kply_add(1), "kplotly")
})

test_that("functions are applied to the widget last, in order", {
  first <- function(w) {
    w$x$layout$order <- "a"
    w
  }
  second <- function(w) {
    w$x$layout$order <- paste0(w$x$layout$order, "b")
    w
  }
  p <- kplotly(weather, "date", "temp") + first + second
  expect_equal(fig(p)$layout$order, "ab")
})

test_that("modifiers set the plot options", {
  p <- kplotly(weather, "date", c("rain", "temp")) |>
    kply_labs(title = "T", y = "Value", color = "Variable") |>
    kply_theme("minimal", palette = "okabe_ito") |>
    kply_palette(c(temp = "red")) |>
    kply_legend("top")
  f <- fig(p)
  expect_equal(f$layout$title$text, "T")
  expect_equal(f$layout$legend$title$text, "Variable")
  expect_equal(f$data[[2]]$line$color, "red")
  expect_equal(f$layout$plot_bgcolor, "white")
})
