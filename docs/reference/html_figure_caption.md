# Extract a figure's caption text

Extract a figure's caption text

## Usage

``` r
html_figure_caption(html_file, id)
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

- id:

  The figure's element id, e.g. `"Fig1"`.

## Value

A single string, or `NA` if the figure has no caption.
