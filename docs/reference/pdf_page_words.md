# Per-page word coordinates for a PDF, with convenience columns

Thin, cached wrapper around
[`pdftools::pdf_data()`](https://docs.ropensci.org/pdftools/reference/pdftools.html).
Adds `x2` (right edge), `yc` (vertical centre) and `cx` (horizontal
centre) to each page's word data frame, which
[`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md)
relies on for clustering words into lines and columns.

## Usage

``` r
pdf_page_words(pdf_file, page)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- page:

  Integer page number (1-based, matching PDF page order).

## Value

A data frame of words on that page.

## Details

Results are cached per PDF path for the life of the R session, because a
single document is usually queried for several tables in a row and
`pdf_data()` re-parses the whole file every time it is called.
