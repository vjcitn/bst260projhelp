# Extract standard scholarly metadata from an article's `<meta>` tags

Reads the `citation_*` meta tags (the Highwire Press/Google Scholar
convention most journal publishing platforms, including PMC, emit in
every article's `<head>`), rather than anything specific to one paper.

## Usage

``` r
html_article_meta(html_file)
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

## Value

A list with `title`, `journal`, `authors` (character vector, one per
`citation_author` tag), `doi`, `pmid`, `date`, `volume`, `firstpage`.
