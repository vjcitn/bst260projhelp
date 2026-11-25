# Index the table captions in a PDF

Scans every page for lines matching a caption pattern such as
`"TABLE 2.3"` or `"Table 2.3-Continued"`, and reports which PDF page(s)
each table's caption appears on. Useful as the first step when working
with an unfamiliar report: run this, then pass the page number(s) it
reports to
[`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md).

## Usage

``` r
pdf_table_index(
  pdf_file,
  pattern =
    "^\\s*(?:TABLE|Table)\\s+([A-Z]\\.[0-9]+|[0-9]+\\.[0-9]+)(—Continued)?\\s*$"
)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- pattern:

  A Perl-compatible regular expression with one capture group for the
  table identifier (e.g. `"2.3"` or `"A.1"`), matched against each full
  text line. The default expects captions of the form `"TABLE 2.3"`,
  `"Table A.1"`, optionally followed by an em-dash and "Continued".

## Value

A data frame with columns `table`, `pdf_page`, `continued`.
