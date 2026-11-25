# Render a list of parsed RAND entries as a rendered bibliography

Each entry is shown as its raw reference-list text, with a live link to
its DOI (field `doi`, e.g. as filled in by
[`rand_resolve_dois()`](https://vjcitn.github.io/bst260projhelp/reference/rand_resolve_dois.md))
when one is known; failing that, its plain `url` (as parsed by
[`rand_parse_entry()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_entry.md)
from the reference text itself) when one is known; and an explicit "no
DOI" marker in either case when no DOI was found.

## Usage

``` r
rand_bibliography_html(refs, cited_at = NULL)
```

## Arguments

- refs:

  A list of parsed entries (see
  [`rand_parse_entry()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_entry.md)),
  such as a subset of
  [`rand_parse_chapter_refs()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_chapter_refs.md)
  output.

- cited_at:

  A named list, keys matching (a subset of) the entries' citation keys,
  each value a character vector of anchor ids – typically from
  [`bib_cite_link()`](https://vjcitn.github.io/bst260projhelp/reference/bib_cite_link.md)
  – to backlink to. Optional.

## Value

A character vector of HTML lines (an `<ol>`).
