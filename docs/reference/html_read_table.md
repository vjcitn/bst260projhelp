# Read one table from an article as a data frame

Drills down to the actual `<table>` element before calling
[`rvest::html_table()`](https://rvest.tidyverse.org/reference/html_table.html)
– calling it directly on the enclosing wrapper (PMC wraps each table
together with its caption) produces nonsensical single-column
pseudo-tables rather than erroring.

## Usage

``` r
html_read_table(html_file, id)
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

- id:

  The table's element id, e.g. `"Tab1"` (as listed by
  [`html_table_index()`](https://vjcitn.github.io/bst260projhelp/reference/html_table_index.md)).

## Value

A data frame (tibble, if the tibble package is available).
