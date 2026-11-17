secrets <- c(
  "SECRETCO", "987654", "990000", "55555", "56000", "hardship", "called",
  "HIDEME", "dropped_col", "1901", "AC0", "AC1", "AC2"
)

for (stats in c(FALSE, TRUE)) {
  test_that(paste("no planted secret reaches the card, stats =", stats), {
    bills <- fake_bills()
    card <- card_text(bills, hide = "region", drop = "dropped_col", keys = "account", stats = stats)
    for (secret in secrets) expect_no_match(card, secret, fixed = TRUE)
    for (account in bills$account) expect_no_match(card, account, fixed = TRUE)
  })
}
