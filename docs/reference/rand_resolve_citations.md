# Resolve a vector of in-text citation strings to reference entries

General form for tables where a cell may hold several citations; one
output row per (input string, resolved key) pair.

## Usage

``` r
rand_resolve_citations(strings, refs)
```

## Arguments

- strings:

  Character vector of in-text citation strings.

- refs:

  A reference table, as from
  [`rand_refs_table()`](https://vjcitn.github.io/bst260projhelp/reference/rand_refs_table.md).

## Value

A data frame with `row` (index into `strings`), `cited_as`, `cite_key`
(as parsed), `bib_key`, `reference` (raw text), `doi`, `url`.
