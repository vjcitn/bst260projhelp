# Link one citation column of a table to reference entries

The common case of
[`rand_resolve_citations()`](https://vjcitn.github.io/bst260projhelp/reference/rand_resolve_citations.md):
exactly one citation per row, in column `col` of `tab`.

## Usage

``` r
rand_link_citations(tab, col, refs)
```

## Arguments

- tab:

  A data frame with a citation column.

- col:

  Name of the citation column.

- refs:

  A reference table, as from
  [`rand_refs_table()`](https://vjcitn.github.io/bst260projhelp/reference/rand_refs_table.md).

## Value

`tab` with added columns `cite_key`, `bib_key`, `reference`, `doi`,
`url`.
