# Suggest column edges for `pdf_read_table()`

Measures how often words on a page share a left x-coordinate; shared
left edges are usually column boundaries. Run this on a table you
haven't parsed yet to find candidate `edges` values (the `rel` column,
already relative to the table's leftmost word).

## Usage

``` r
pdf_suggest_edges(pdf_file, table_id, page, min_lines = 4, y_max = 650)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- table_id:

  Table identifier as it appears in the caption.

- page:

  Integer page number.

- min_lines:

  Minimum number of lines an x-coordinate must appear on to be reported
  as a candidate column edge.

- y_max:

  Discard words below this y-coordinate (footers).

## Value

A data frame with columns `x` (absolute), `rel` (relative to the table's
leftmost word – pass this to `edges`), `n_lines`.
