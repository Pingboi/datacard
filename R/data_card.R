#' Write a data card: the structure of a dataset without the data
#'
#' Describes each column of a data frame (name, type, missing share, categories,
#' formats) in a Markdown file. A value is shown only if at least `min_cell`
#' rows share it. No row, minimum or maximum is ever written.
#'
#' Read the file before you share it. Column names are always shown unless you
#' `drop` them.
#'
#' @param x A data frame, or a named list of data frames.
#' @param file Path of the Markdown file to write.
#' @param name Label for the dataset when `x` is a single data frame.
#' @param descriptions Named character vector of column meanings and units,
#'   such as `c(price = "cents per kWh, GST inclusive")`.
#' @param hide Columns to report as name, type and missing share only.
#' @param drop Columns to leave out completely, name included.
#' @param keys Columns to test as a unique row identifier.
#' @param stats If `TRUE`, add rounded percentiles, category shares and month
#'   ranges.
#' @param min_cell Smallest number of rows that may stand behind a shown value.
#' @param max_levels Columns with this many distinct values or fewer are treated
#'   as categories.
#'
#' @return The lines of the card, invisibly.
#' @export
#'
#' @examples
#' bills <- data.frame(
#'   customer = sprintf("C%05d", 1:200),
#'   tariff = rep(c("flat", "time-of-use"), c(150, 50)),
#'   amount = round(runif(200, 50, 900), 2)
#' )
#' data_card(bills, file = tempfile(fileext = ".md"), keys = "customer")
data_card <- function(x, file = "data-card.md", name = NULL, descriptions = NULL,
                      hide = NULL, drop = NULL, keys = NULL, stats = FALSE,
                      min_cell = 10, max_levels = 20) {
  if (is.data.frame(x)) {
    symbol <- substitute(x)
    if (is.null(name)) name <- if (is.name(symbol)) as.character(symbol) else "dataset"
    x <- stats::setNames(list(x), name)
  }
  if (any(keys %in% drop)) stop("`keys` cannot include a dropped column.", call. = FALSE)

  sections <- Map(card_dataset, x, names(x), MoreArgs = list(
    descriptions = descriptions, hide = hide, drop = drop, keys = keys,
    stats = stats, min_cell = min_cell, max_levels = max_levels
  ))
  lines <- c(card_header(stats, min_cell, max_levels), unlist(sections, use.names = FALSE))

  writeLines(enc2utf8(lines), file, useBytes = TRUE)
  message("Data card written to ", normalizePath(file), "\nRead it before you share it.")
  invisible(lines)
}

card_header <- function(stats, min_cell, max_levels) {
  c(
    "# Data card",
    "",
    paste0(
      "Made with datacard ", packageVersion("datacard"), " on ", Sys.Date(),
      ". Settings: min_cell = ", min_cell, ", max_levels = ", max_levels, ", stats = ", stats, "."
    ),
    "",
    "This file describes the structure of a dataset. It contains no rows from the data.",
    "",
    "How to read it:",
    "",
    "- Row counts are rounded to 2 significant figures. Missing shares and distinct counts are banded.",
    paste("- A value is listed only if at least", min_cell, "rows share it. Rarer values are counted, not named."),
    "- Formats replace every digit with 9 and every letter with A or a.",
    paste("- Number and date facts (sign, decimals, years) count only when at least", min_cell, "rows support them."),
    if (stats) "- Percentiles are rounded to 2 significant figures. Category shares are to the nearest 5%.",
    "- No minimum, maximum or example row is shown.",
    "- Descriptions were typed by the data owner. Anything not stated here is unknown, so ask instead of assuming.",
    ""
  )
}

card_dataset <- function(df, label, descriptions, hide, drop, keys, stats, min_cell, max_levels) {
  if (nrow(df) < min_cell) {
    stop(label, " has fewer than ", min_cell, " rows, so no card was written.", call. = FALSE)
  }
  df <- as.data.frame(df)[setdiff(names(df), drop)]

  key_line <- if (length(keys) && all(keys %in% names(df))) {
    duplicated_keys <- anyDuplicated(do.call(paste, c(df[keys], sep = "\r"))) > 0
    paste0("- unique on ", paste(keys, collapse = " + "), ": ", if (duplicated_keys) "no" else "yes")
  }

  columns <- lapply(names(df), function(column) {
    c(
      "",
      paste0("### ", column, " (", class(df[[column]])[1], ")"),
      if (column %in% names(descriptions)) paste("- description:", descriptions[[column]]),
      profile_column(df[[column]], column %in% hide, stats, min_cell, max_levels)
    )
  })

  c(
    paste("##", label),
    "",
    paste("- rows: about", round_sig(nrow(df))),
    paste("- columns:", ncol(df)),
    key_line,
    unlist(columns),
    ""
  )
}
