test_that("default card shows structure and common categories", {
    bills <- fake_bills()
    card <- card_text(bills, keys = "account", descriptions = c(amount = "dollars, GST inclusive"))
    expect_match(card, "## bills", fixed = TRUE)
    expect_match(card, "- rows: about 500", fixed = TRUE)
    expect_match(card, "- unique on account: yes", fixed = TRUE)
    expect_match(card, "- values: `Alpha`, `Beta`, plus 1 rare value not shown", fixed = TRUE)
    expect_match(card, "- format: `AA999999`", fixed = TRUE)
    expect_match(card, "- description: dollars, GST inclusive", fixed = TRUE)
    expect_match(card, "- years: 2024 to 2025", fixed = TRUE)
    expect_match(card, "- values: `FALSE`, `TRUE`", fixed = TRUE)
    expect_no_match(card, "p5 / p50 / p95", fixed = TRUE)
})

test_that("stats adds rounded percentiles, shares and months", {
    card <- card_text(fake_bills(), stats = TRUE)
    expect_match(card, "- p5 / p50 / p95: ", fixed = TRUE)
    expect_match(card, "`Alpha` (~60%), `Beta` (~40%)", fixed = TRUE)
    expect_match(card, "- months: 2024-07 to 2025-12", fixed = TRUE)
})

test_that("hide keeps the name, drop removes it", {
    card <- card_text(fake_bills(), hide = "retailer", drop = c("notes", "dropped_col"))
    expect_match(card, "### retailer (character)\n- missing: 0%\n- hidden: values not profiled", fixed = TRUE)
    expect_no_match(card, "Alpha", fixed = TRUE)
    expect_no_match(card, "notes", fixed = TRUE)
    expect_match(card, "- columns: 7", fixed = TRUE)
})

test_that("a list of data frames gives one section each", {
    card <- card_text(list(bills = fake_bills(), cars = mtcars), name = NULL)
    expect_match(card, "## bills", fixed = TRUE)
    expect_match(card, "## cars", fixed = TRUE)
})

test_that("unsafe requests stop", {
    expect_error(card_text(head(fake_bills(), 5)), "fewer than 10 rows")
    expect_error(card_text(fake_bills(), keys = "account", drop = "account"), "dropped column")
})

test_that("a dataset passed as an expression is not labelled with the expression", {
    card <- card_text(as.data.frame(fake_bills()))
    expect_match(card, "## dataset", fixed = TRUE)
})
