test_that("missing shares are banded", {
  expect_equal(band_missing(0, 1000), "0%")
  expect_equal(band_missing(3, 1000), "<1%")
  expect_equal(band_missing(124, 1000), "12%")
  expect_equal(band_missing(996, 1000), ">99%")
  expect_equal(band_missing(1000, 1000), "100%")
})

test_that("distinct counts are exact only for small counts", {
  expect_equal(band_distinct(3, 1000, 20), "3")
  expect_equal(band_distinct(1000, 1000, 20), "all different")
  expect_equal(band_distinct(4321, 90000, 20), "over 1,000")
})

test_that("numbers are rounded to 2 significant figures", {
  expect_equal(round_sig(c(1234567, 0.2874, 21)), c("1,200,000", "0.29", "21"))
})

test_that("rare category values are counted, not named", {
  v <- rep(c("a", "b", "c", "d"), c(50, 40, 9, 1))
  expect_equal(safe_levels(v, 10), "`a`, `b`, plus 2 rare values not shown")
  expect_equal(safe_levels(v, 10, stats = TRUE), "`a` (~50%), `b` (~40%), plus 2 rare values not shown")
  expect_equal(safe_levels(c("x", "y"), 10), "none common enough to show, 2 rare values not shown")
})

test_that("format masks keep shape and drop content", {
  expect_equal(mask_text(c("Ab-12 x", "\u00c9\u00e9\u4e2d9")), c("Aa-99 a", "Aaa9"))
  ids <- c(sprintf("AB%04d", 1:50), "odd one", "Zz9")
  expect_equal(format_mask(ids, 10), "`AA9999`, and others")
  expect_equal(format_mask(paste("note", 1:30, strrep("x", 1:30)), 10), "free text, not shown")
})

test_that("number facts need min_cell rows", {
  v <- c(1:100, -5, 0.5)
  expect_equal(safe_signs(v, 10), "positive")
  expect_equal(safe_whole(v, 10), "whole numbers")
  expect_equal(safe_percentiles(1:100, 10), "too few rows to show")
  expect_equal(safe_percentiles(1:1000, 10), "51 / 500 / 950")
})

test_that("date ranges ignore thin periods", {
  dates <- c(as.Date("2024-07-15") + 0:400, as.Date("1901-01-01"))
  expect_equal(safe_periods(dates, "%Y", 10), "2024 to 2025")
  expect_equal(safe_periods(dates, "%Y-%m", 10), "2024-07 to 2025-08")
})
