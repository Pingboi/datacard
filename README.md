# datacard

Describe the structure of a dataset without exposing the data.

`data_card()` writes a Markdown file that lists each column's name, type, missing share, categories and formats under fixed disclosure rules. You can give that file to someone who is not allowed to see the data, such as an AI assistant, so they can help you write code and plan research against the real variable names and values.

## Read this first

- The card is derived from your data. Whether it may leave your computer is a decision for whoever owns the data, not for this package. Check before you share one.
- Column names are always shown unless you `drop` them.
- Read every card before you share it. It is a short text file.

## Install

```r
## install.packages("pak")
pak::pak("Pingboi/datacard")
```

If GitHub installs are blocked, download the repository as a zip, unzip it and run:

```r
install.packages("path/to/datacard", repos = NULL, type = "source")
```

It needs `dplyr` and `stringr`.

## Use

```r
library(datacard)

data_card(
    bills,                                   ## a data frame you have already loaded
    file = "data-card.md",
    descriptions = c(amount = "dollars, GST inclusive"),
    hide = "retailer",                       ## name and type only
    drop = "internal_notes",                 ## left out completely
    keys = c("customer", "quarter")          ## are these unique per row?
)
```

Pass a named list of data frames to describe several datasets in one file. Set `stats = TRUE` to add rounded statistics.

The file looks like this:

```
## bills

- rows: about 60,000
- columns: 4
- unique on customer + quarter: yes

### customer (character)
- missing: 0%
- distinct: over 10,000
- format: `9999999999`

### tariff (character)
- missing: <1%
- distinct: 3
- values: `flat`, `mixed`, `time-of-use`

### retailer (character)
- missing: 0%
- hidden: values not profiled

### amount (numeric)
- description: dollars, GST inclusive
- missing: 2%
- distinct: over 1,000
- numbers: decimals
- sign: positive
```

## What a card can show

A value or statistic is shown only if at least `min_cell` rows (default 10) stand behind it.

| Item | Rule |
|---|---|
| Row count | Rounded to 2 significant figures. A dataset with fewer than `min_cell` rows is refused. |
| Missing share | 0%, <1%, nearest whole percent, >99% or 100%. |
| Distinct count | Exact up to `max_levels` (default 20), then "over 10", "over 100" and so on, or "all different". |
| Categories | For columns with `max_levels` or fewer distinct values: the values that each have at least `min_cell` rows. Rarer values are counted, not named. |
| Text formats | Digits become 9, letters become A or a, punctuation stays. Up to 3 formats, each with at least `min_cell` rows and at most 40 characters. Otherwise "free text, not shown". |
| Numbers | Whole numbers or decimals, and which of negative, zero and positive have at least `min_cell` rows. |
| Dates | First and last year that have at least `min_cell` rows. |
| Keys | Whether the columns you name are unique per row: yes or no. |

`stats = TRUE` adds:

| Item | Rule |
|---|---|
| Percentiles | p5, p50 and p95 to 2 significant figures, only if at least `min_cell` rows lie beyond p5 and p95. |
| Category shares | Nearest 5%. |
| Dates | First and last month that have at least `min_cell` rows. |

Never shown, in any mode: a row of data, a true minimum or maximum, a value shared by fewer than `min_cell` rows, free text.

All of these rules live in one short file, [R/disclose.R](R/disclose.R), so you can audit them. The tests in [tests/testthat/test-leaks.R](tests/testthat/test-leaks.R) plant secrets in invented data and fail if any of them reaches a card.

## Limits

- The rules reduce what a card reveals. They are not a formal disclosure control method, and they do not check whether column names or your own descriptions are sensitive.
- Small datasets and small groups are where summaries leak. Raise `min_cell` if your data owner uses a higher threshold.
- The data frame must fit in memory.
