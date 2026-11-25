# Extract an article's structured abstract

Extract an article's structured abstract

## Usage

``` r
html_abstract(html_file, id = "Abs1")
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

- id:

  The abstract section's element id (PMC uses `"Abs1"`).

## Value

A named character vector, names are subsection headings (e.g.
`"Background"`, `"Methods"`), values the subsection text; or, if the
abstract has no subheadings, a single unnamed string.
