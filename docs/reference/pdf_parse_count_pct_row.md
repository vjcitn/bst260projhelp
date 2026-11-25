# Parse a "label N (pct) N (pct) ..." table row

Handles the common report idiom of a row label followed by one or more
`count` or `count (percent)` tokens, e.g.
`"Groundwater system 32 (62)"`. Footnote marks (`*`, daggers) are
stripped before parsing.

## Usage

``` r
pdf_parse_count_pct_row(line)
```

## Arguments

- line:

  A single line of text.

## Value

A list with `label` (character), `n` (integer vector) and `pct` (integer
vector, `NA` where no percentage was present), or `NULL` if the line
doesn't match the expected shape.
