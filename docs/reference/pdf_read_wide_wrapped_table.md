# Read a wide table whose cells wrap across several text lines

For tables where a plain line-by-line read breaks down because a single
record spans multiple lines (a long etiology or jurisdiction name wraps)
and/or columns are centred rather than left-aligned. Each word on the
page is assigned to the column whose header centre it is nearest to,
then to the row ("anchor") whose first-column entry is closest in y –
this keeps tall wrapped cells attached to the correct record even when
the first column itself does not wrap.

## Usage

``` r
pdf_read_wide_wrapped_table(pdf_file, page, col_labels, line_gap = 14)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- page:

  Integer page number.

- col_labels:

  A named list, one entry per output column, where each entry is a list
  of `c(prefix, k)` pairs: "the k-th header word (left to right) that
  starts with `prefix`". More than one pair per column is useful when a
  header's wording differs across pages, or when poppler splits a long
  header word in two (e.g. `"Hospitalizati"`

  - `"ons"`) – just key on the unambiguous prefix.

- line_gap:

  Minimum vertical gap, in points, between consecutive text lines in the
  same column before they are treated as belonging to different records.

## Value

A data frame, one row per record, columns named as in `col_labels`.
