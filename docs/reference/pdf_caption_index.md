# Index simple table captions ("Table N.")

A lighter-weight sibling of
[`pdf_table_index()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_table_index.md)
for reports that caption tables inline as plain prose, e.g.
`"Table 8."`, rather than as a standalone heading line. Looks for the
pattern anywhere within the page text rather than requiring it to be the
whole line.

## Usage

``` r
pdf_caption_index(pdf_file, pattern = "Table [0-9]+\\.")
```

## Arguments

- pdf_file:

  Path to a PDF file.

- pattern:

  Regular expression identifying a caption, default matches
  `"Table <digits>."`.

## Value

A data frame with columns `page`, `table`. Note that a caption can
appear on the page before the table body actually starts.
