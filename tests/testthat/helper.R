# Build the figure for real: catches errors that only appear at render time
fig <- function(p) as_htmlwidget(p)$x

trace_names <- function(p) {
  vapply(fig(p)$data, function(tr) tr$name %||% NA_character_, "")
}

weather <- data.frame(
  date = as.Date("2024-01-01") + 0:9,
  rain = c(0, 2, NA, 5, 1, 0, 0, 3, 8, 1),
  temp = 10:19,
  day = 1:10
)
