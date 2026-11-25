# Escape BibTeX special characters in plain-text fields

Backslash-escapes `& % $ # _`. Not applied to fields that are URLs, DOIs
or already-braced titles, which must pass through untouched.

## Usage

``` r
bib_escape(x)
```

## Arguments

- x:

  Character vector.

## Value

Escaped character vector.
