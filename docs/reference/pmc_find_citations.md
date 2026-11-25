# Find in-text citation links in an article's body

PMC's own HTML links every in-text numeric citation marker straight to
its reference-list entry (`<a href="#CRN">`), so – unlike
[`vancouver_find_numeric_citations()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_find_numeric_citations.md),
which must guess at a regex over plain PDF text – this is a direct
structural read: every citation link present is found, with no risk of
misreading a table number as a citation or vice versa.

## Usage

``` r
pmc_find_citations(html_file)
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

## Value

A data frame with one row per citation link, columns `para` (the id of
the enclosing paragraph, `NA` if it's not inside one), `key` (e.g.
`"CR1"`) and `label` (the visible marker text, e.g. `"1"`).
