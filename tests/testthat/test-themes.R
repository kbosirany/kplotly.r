test_that("themes and palettes are registered", {
  expect_true(all(c("default", "minimal", "bw", "inrae") %in% kply_themes()))
  expect_true(all(c("plotly", "inrae", "okabe_ito") %in% kply_palettes()))
})

test_that("the inrae theme brings its palette and layout", {
  f <- fig(kplotly(weather, "date", c("rain", "temp"), theme = "inrae"))
  expect_equal(f$data[[1]]$line$color, "#00a3a6")
  expect_equal(f$layout$xaxis$griddash, "dot")
})

test_that("palettes: names, vectors, named vectors and functions", {
  col <- function(p) vapply(fig(p)$data, function(tr) tr$line$color, "")
  base <- kplotly(weather, "date", c("rain", "temp"))
  expect_equal(col(kply_palette(base, "okabe_ito")), c("#E69F00", "#56B4E9"))
  expect_equal(col(kply_palette(base, c("black", "grey"))), c("black", "grey"))
  expect_equal(col(kply_palette(base, function(n) rep("blue", n))),
               c("blue", "blue"))
  expect_equal(col(kply_palette(base, c(temp = "red", "x" = "green")))[2],
               "red")
  many <- kplotly(data.frame(x = 1:12, y = 1:12, k = letters[1:12]), "x", "y",
                  color = "k", palette = c("white", "black"))
  expect_length(unique(vapply(fig(many)$data, function(t) t$marker$color, "")),
                12)
  expect_error(fig(kply_palette(base, 1)), "palette")
})

test_that("a list theme and the options are accepted", {
  f <- fig(kplotly(weather, "date", "temp", theme = list(plot_bgcolor = "red")))
  expect_equal(f$layout$plot_bgcolor, "red")
  withr::local_options(kplotly.theme = "bw", kplotly.palette = "inrae")
  g <- fig(kplotly(weather, "date", "temp", theme = NULL))
  expect_true(g$layout$xaxis$mirror)
  expect_error(fig(kplotly(weather, "date", "temp", theme = "nope")),
               "Unknown theme")
  expect_error(fig(kplotly(weather, "date", "temp", theme = 1)), "theme")
})

test_that("custom themes can be registered", {
  kply_register_palette("traffic", c("#2ecc71", "#f1c40f"))
  kply_register_theme("traffic", list(plot_bgcolor = "#fafafa"),
                      palette = "traffic")
  on.exit({
    .kply$themes$traffic <- NULL
    .kply$palettes$traffic <- NULL
  })
  f <- fig(kplotly(weather, "date", "temp", theme = "traffic"))
  expect_equal(f$data[[1]]$line$color, "#2ecc71")
  expect_error(kply_register_theme("x", "bad"), "layout")
})
