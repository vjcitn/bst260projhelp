# Index of an article's tables, by element id

PMC wraps each table in a `<section id="TabN">` carrying its own number
(`.obj_head`) and caption (`.caption`) – this lists all of them, so a
table's id can be looked up before reading it with
[`html_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/html_read_table.md),
just as
[`pdf_table_index()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_table_index.md)
does for PDF tables.

## Usage

``` r
html_table_index(html_file)
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

## Value

A data frame with columns `id`, `label` (e.g. `"Table 1."`) and
`caption`.
