# Render a PMC reference list as a rendered bibliography

A thin wrapper around
[`bib_html_list()`](https://vjcitn.github.io/bst260projhelp/reference/bib_html_list.md):
PMC's reference entries already come with plain-text, DOI and a fallback
URL, so – unlike
[`rand_bibliography_html()`](https://vjcitn.github.io/bst260projhelp/reference/rand_bibliography_html.md)
and
[`vancouver_bibliography_html()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_bibliography_html.md),
which must first format each entry from parsed fields – there is no
formatting step to do first.

## Usage

``` r
pmc_bibliography_html(refs, cited_at = NULL)
```

## Arguments

- refs:

  A data frame as returned by
  [`pmc_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_ref_entries.md)
  (or a subset of its rows).

- cited_at:

  A named list, keys matching (a subset of) `refs$key`, each value a
  character vector of anchor ids – typically from
  [`bib_cite_link()`](https://vjcitn.github.io/bst260projhelp/reference/bib_cite_link.md)
  – to backlink to. Optional.

## Value

A character vector of HTML lines (an `<ol>`).
