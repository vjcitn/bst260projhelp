# Link in-text to a bibliography entry, with a round-trip backlink

Produces an HTML anchor pointing down to the entry `key` (rendered by
[`bib_html_list()`](https://vjcitn.github.io/bst260projhelp/reference/bib_html_list.md)
with `id = key`), and carries its own `id` so that entry can link back
up to this exact citing location. Pass the same id(s) via `cited_at` in
[`bib_html_list()`](https://vjcitn.github.io/bst260projhelp/reference/bib_html_list.md)
to get a live "up" link on the entry; use a distinct `id` for a second
citation of the same key (e.g. `paste0("cite-", key, "-2")`) and list
both under that key in `cited_at`.

## Usage

``` r
bib_cite_link(key, label = key, id = paste0("cite-", key))
```

## Arguments

- key:

  Bibliography entry key to link to.

- label:

  Visible link text; defaults to `key`.

- id:

  Anchor id for this citing location; defaults to
  `paste0("cite-", key)`.

## Value

A character vector of HTML strings, the same length as `key`.
