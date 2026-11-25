# Read a simple "count (percent)" table from a PDF page

For tables where each row is a single text line: a label followed by one
or more `count (percent)` pairs, ending in a "Total" row. This covers
the common case where
[`pdftools::pdf_text()`](https://docs.ropensci.org/pdftools/reference/pdftools.html)
alone preserves row structure because nothing wraps across lines.

## Usage

``` r
pdf_read_count_pct_table(
  pdf_file,
  page,
  header_pat,
  col_names,
  stop_pat = "^\\s*Total"
)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- page:

  Integer page number.

- header_pat:

  Regular expression identifying the header line; the table body is read
  starting on the next line.

- col_names:

  Character vector naming the count/percent column pairs, e.g.
  `c("outbreaks", "cases")` yields columns `outbreaks_n`,
  `outbreaks_pct`, `cases_n`, `cases_pct`.

- stop_pat:

  Regular expression for the row that ends the table (inclusive);
  defaults to a line starting with "Total".

## Value

A data frame with one row per table row (including the Total row),
columns `label` plus `<name>_n`/`<name>_pct` for each entry in
`col_names`.
