# Extract a figure's image URL

Reads the `<img>` element's `src` (and `alt`) directly, rather than
downloading the image – PMC serves figures from its own CDN, so the URL
alone is enough to display or re-cite the figure. This package does not
vendor the pixels: reusing a figure, even from an open-access article,
is a licensing decision (see the article's own licence statement) that
belongs to whoever embeds it, not to this extraction step.

## Usage

``` r
html_figure_image(html_file, id)
```

## Arguments

- html_file:

  Path or URL to the article's HTML page.

- id:

  The figure's element id, e.g. `"Fig1"`.

## Value

A list with `src` (the image URL) and `alt` (alt text, `NA` if none was
given).
