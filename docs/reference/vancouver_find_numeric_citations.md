# Find numbered in-text citations in a PDF, for cross-checking

Looks for a word followed by `(N)` or `(N, M)` and punctuation, which is
how Vancouver-style citations typically read; deliberately excludes
matches like `"Other 1 (2)"` where the preceding token is itself a digit
(a table cell, not a citation), by requiring the word before the
parenthesis to start with a letter.

## Usage

``` r
vancouver_find_numeric_citations(pdf_file, max_ref)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- max_ref:

  Only keep hits whose number(s) are between 1 and `max_ref`; typically
  `length(vancouver_ref_entries(...))`.

## Value

A data frame with columns `page`, `cited` (the matched text) and
`numbers` (comma-separated reference numbers). Review the hits rather
than trusting them blindly – the regex is a heuristic.
