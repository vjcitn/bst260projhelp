# Export a list of Vancouver-style (plus any hand-curated) entries as BibTeX

Export a list of Vancouver-style (plus any hand-curated) entries as
BibTeX

## Usage

``` r
vancouver_to_bibtex(refs, accessed = NA)
```

## Arguments

- refs:

  A named list of entries, each a list with at least `type` and the
  fields
  [`bib_entry()`](https://vjcitn.github.io/bst260projhelp/reference/bib_entry.md)
  expects for that type (`author`, `title`, and for articles
  `journal`/`volume`/`number`/`pages`, for techreports/misc
  `institution`/`address`/`url`/`note`/etc.). Names are used as BibTeX
  citation keys.

- accessed:

  A default access date (e.g. `"2026-11-22"`) used as `urldate` for
  entries with a `url` or `doi` but no `urldate` of their own; pass `NA`
  (the default) to leave `urldate` unset until you have actually checked
  the link.

## Value

A single character string of BibTeX entries separated by blank lines.
