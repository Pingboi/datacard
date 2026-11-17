# Disclosure rules. Everything a data card says about the values in a column
# comes from one of these functions. Read this file to audit what can be shown.
#
# The principle: a value or statistic is shown only if at least `min_cell` rows
# stand behind it. Counts are rounded or banded.

# Rounding and bands ----------------------------------------------------------

round_sig <- function(x, digits = 2) {
  vapply(signif(x, digits), format, "", big.mark = ",", scientific = FALSE)
}

band_missing <- function(n_missing, n) {
  share <- n_missing / n
  case_when(
    n_missing == 0 ~ "0%",
    n_missing == n ~ "100%",
    share < 0.01 ~ "<1%",
    share > 0.99 ~ ">99%",
    TRUE ~ paste0(round(share * 100), "%")
  )
}

band_distinct <- function(n_distinct, n, max_levels) {
  case_when(
    n_distinct <= max_levels ~ as.character(n_distinct),
    n_distinct == n ~ "all different",
    TRUE ~ paste("over", round_sig(10^floor(log10(n_distinct)), 1))
  )
}

band_share <- function(share) {
  pct <- round(share * 20) * 5
  if_else(pct == 0, "<5%", paste0("~", pct, "%"))
}

tick <- function(x) if_else(x == "", "(empty)", paste0("`", x, "`"))

# Categories: values shared by at least min_cell rows --------------------------

safe_levels <- function(v, min_cell, stats = FALSE) {
  tally <- tibble(value = v) |>
    count(value) |>
    mutate(share = n / sum(n))
  common <- filter(tally, n >= min_cell)
  rare <- nrow(tally) - nrow(common)

  shown <- tick(as.character(common$value))
  if (stats) shown <- paste0(shown, " (", band_share(common$share), ")")
  hidden <- if (rare > 0) paste(rare, "rare", if (rare == 1) "value" else "values", "not shown")

  if (!nrow(common)) return(paste("none common enough to show,", hidden))
  paste(c(shown, if (rare > 0) paste("plus", hidden)), collapse = ", ")
}

# Text: digits become 9, letters become A or a, punctuation stays --------------

mask_text <- function(x) {
  str_replace_all(x, c(
    "[\\p{L}--[\\p{Lu}\\p{Ll}]]" = "a",
    "\\p{Lu}" = "A",
    "\\p{Ll}" = "a",
    "\\p{N}" = "9",
    "\\s" = " "
  ))
}

format_mask <- function(v, min_cell, max_shown = 3, max_width = 40) {
  v <- as.character(v)
  u <- unique(v)
  tally <- tibble(mask = mask_text(u)[match(v, u)]) |> count(mask, sort = TRUE)
  common <- filter(tally, n >= min_cell, str_length(mask) <= max_width) |> head(max_shown)

  if (!nrow(common)) return("free text, not shown")
  paste(c(tick(common$mask), if (nrow(tally) > nrow(common)) "and others"), collapse = ", ")
}

# Numbers ---------------------------------------------------------------------

safe_whole <- function(v, min_cell) {
  if (sum(v != round(v)) >= min_cell) "decimals" else "whole numbers"
}

safe_signs <- function(v, min_cell) {
  rows <- c(negative = sum(v < 0), zero = sum(v == 0), positive = sum(v > 0))
  paste(names(rows)[rows >= min_cell], collapse = ", ")
}

# p5 and p95 need min_cell rows beyond them, so small columns get no percentiles
safe_percentiles <- function(v, min_cell) {
  if (length(v) * 0.05 < min_cell) return("too few rows to show")
  paste(round_sig(quantile(v, c(0.05, 0.5, 0.95), names = FALSE)), collapse = " / ")
}

# Dates: first and last period (year or month) with at least min_cell rows ------

safe_periods <- function(v, period_format, min_cell) {
  tally <- tibble(period = format(v, period_format)) |>
    count(period) |>
    filter(n >= min_cell)

  if (!nrow(tally)) return("too few rows per period to show")
  paste(unique(c(first(tally$period), last(tally$period))), collapse = " to ")
}
