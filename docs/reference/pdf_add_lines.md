# Group words on a page into text lines

Words are sorted by vertical centre then x, and a new line starts
whenever the vertical centre jumps by more than `tol`. The default
tolerance (4pt) is chosen to sit between the offset of a superscript
footnote marker from its baseline (about 3pt) and the pitch between
ordinary text lines (about 8pt or more); re-check it for documents with
unusually tight or loose line spacing.

## Usage

``` r
pdf_add_lines(w, tol = 4)
```

## Arguments

- w:

  A word data frame from
  [`pdf_page_words()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_page_words.md).

- tol:

  Numeric vertical-centre tolerance, in points.

## Value

`w` with an added integer `line` column.
