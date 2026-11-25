# Render a bibliography as an HTML ordered list, with DOI links

The single rendering routine both citation styles in this package build
on: given a bibliography as parallel vectors of citation keys,
already-formatted reference text and DOIs, produce an `<ol>` where each
entry that has a DOI links to `https://doi.org/<doi>`, and every other
entry is marked, in place, as having no DOI – rather than silently
omitting the link. When a plain `url` is also known (often true even
when no DOI is), it's rendered as a second, explicitly labeled link
alongside the "no DOI" marker, rather than dropped.

## Usage

``` r
bib_html_list(keys, text, doi, url = NA_character_, cited_at = NULL)
```

## Arguments

- keys:

  Character vector of citation keys, used as each `<li>`'s `id` (so
  other output, e.g.
  [`rand_link_citations()`](https://vjcitn.github.io/bst260projhelp/reference/rand_link_citations.md)
  results, can link to `#<key>`).

- text:

  Character vector of formatted, HTML-escaped reference text
  (author/title/container/year as appropriate).

- doi:

  Character vector of DOIs, the same length as `keys`; `NA` or `""`
  where no DOI is known.

- url:

  Character vector of plain URLs, the same length as `keys`; `NA` or
  `""` where none is known. Optional.

- cited_at:

  A named list, keys matching (a subset of) `keys`, each value a
  character vector of anchor ids to backlink to. Optional.

## Value

A character vector of HTML lines.

## Details

Each `<li>` gets `id = key`, so in-text citations can link down to their
entry with
[`bib_cite_link()`](https://vjcitn.github.io/bst260projhelp/reference/bib_cite_link.md).
If `cited_at` names one or more anchor ids per key (by convention, the
ids
[`bib_cite_link()`](https://vjcitn.github.io/bst260projhelp/reference/bib_cite_link.md)
sets), each entry also gets an "up" backlink to every one of its citing
locations – so a reader can jump from the bibliography back to where a
source was actually used, not just from the citation down to the source.
