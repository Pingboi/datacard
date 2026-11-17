# Invented data with planted secrets. Nothing here comes from a real dataset.
fake_bills <- function() {
  set.seed(1)
  n <- 500
  data.frame(
    account = sprintf("AC%06d", sample(1e5, n)),
    retailer = rep(c("Alpha", "Beta", "SECRETCO"), c(300, 197, 3)),
    amount = c(round(runif(n - 2, 50, 900), 2), 987654.32, -55555.5),
    visits = sample(0:400, n, replace = TRUE),
    notes = paste("customer", seq_len(n), "called about hardship"),
    bill_date = c(as.Date("2024-07-01") + sample(0:540, n - 1, replace = TRUE), as.Date("1901-02-03")),
    region = rep(c("HIDEME_north", "HIDEME_south"), each = n / 2),
    dropped_col = seq_len(n),
    flag = rep(c(TRUE, FALSE, NA), c(250, 245, 5))
  )
}

card_text <- function(...) {
  path <- tempfile(fileext = ".md")
  suppressMessages(data_card(..., file = path))
  paste(readLines(path, encoding = "UTF-8"), collapse = "\n")
}
