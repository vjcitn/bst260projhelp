# Render a list of Vancouver-style (plus curated) entries as a rendered bibliography

Formats each entry as author/title plus its container (journal, with
volume/issue/pages, or institution, or a descriptive note) and year,
then renders the list with a live DOI link where `doi` is known; failing
that, its plain `url` when one is known (true of most of the curated
entries – surveillance systems and reporting forms cited by their web
page, not a DOI); and an explicit "no DOI" marker in either case when no
DOI was found, including for entries that were never going to have one.

## Usage

``` r
vancouver_bibliography_html(refs, cited_at = NULL)
```

## Arguments

- refs:

  A named list of entries, as passed to
  [`vancouver_to_bibtex()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_to_bibtex.md).

- cited_at:

  A named list, keys matching (a subset of) `names(refs)`, each value a
  character vector of anchor ids – typically from
  [`bib_cite_link()`](https://vjcitn.github.io/bst260projhelp/reference/bib_cite_link.md)
  – to backlink to. Optional.

## Value

A character vector of HTML lines (an `<ol>`).
