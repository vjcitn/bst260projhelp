# Collapse a lined word data frame to one text string per line

Collapse a lined word data frame to one text string per line

## Usage

``` r
pdf_line_text(w)
```

## Arguments

- w:

  A word data frame that has been through
  [`pdf_add_lines()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_add_lines.md).

## Value

A named character vector, names are line numbers (as strings), values
are the words on that line joined by a single space, in left-to-right
order.
