# Turns one column into the bullet lines of its card entry. Every value shown
# goes through a rule in disclose.R.

profile_column <- function(x, hidden, stats, min_cell, max_levels) {
  if (!is.atomic(x)) return("- not profiled: not a simple column")

  v <- x[!is.na(x)]
  missing <- paste("- missing:", band_missing(length(x) - length(v), length(x)))
  if (hidden) return(c(missing, "- hidden: values not profiled"))
  if (!length(v)) return(missing)

  distinct <- n_distinct(v)
  detail <- if (distinct <= max_levels) {
    paste("- values:", safe_levels(v, min_cell, stats))
  } else if (is.numeric(v)) {
    c(
      paste("- numbers:", safe_whole(v, min_cell)),
      paste("- sign:", safe_signs(v, min_cell)),
      if (stats) paste("- p5 / p50 / p95:", safe_percentiles(v, min_cell))
    )
  } else if (inherits(v, c("Date", "POSIXt"))) {
    if (stats) paste("- months:", safe_periods(v, "%Y-%m", min_cell))
    else paste("- years:", safe_periods(v, "%Y", min_cell))
  } else {
    paste("- format:", format_mask(v, min_cell))
  }

  c(missing, paste("- distinct:", band_distinct(distinct, length(v), max_levels)), detail)
}
