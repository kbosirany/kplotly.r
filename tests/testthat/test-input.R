test_that("as_kdata handles the built-in input classes", {
  ts1 <- as_kdata(ts(c(1, 3, 2), start = 2000))
  expect_equal(names(ts1), c("time", "value"))
  expect_true(attr(ts1, "kply_slider"))
  mts <- as_kdata(ts(matrix(1:6, 3), start = 2000))
  expect_equal(names(mts), c("time", "Series 1", "Series 2"))
  expect_equal(names(as_kdata(matrix(1:4, 2))), c("V1", "V2"))
  expect_equal(attr(as_kdata(c(2, 4)), "kply_y"), "value")
  expect_equal(nrow(as_kdata(list(a = 1:3, b = 3:1))), 3)
  expect_error(as_kdata(list(1, 2)), "named")
  expect_error(as_kdata(data.frame()), "no column")
  expect_error(as_kdata(function() 1), "as_kdata.function")
})

test_that("a ts is drawn as a line with a range slider", {
  f <- fig(kplotly(AirPassengers))
  expect_equal(f$data[[1]]$mode, "lines")
  expect_true(f$layout$xaxis$rangeslider$visible)
})
