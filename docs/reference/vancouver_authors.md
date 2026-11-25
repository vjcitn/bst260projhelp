# Convert a Vancouver-style author list to BibTeX author form

`"Collier SA, Deng L, Adam EA, et al"` becomes
`"Collier, S. A. and Deng, L. and Adam, E. A. and others"`.

## Usage

``` r
vancouver_authors(s)
```

## Arguments

- s:

  The Vancouver-style author-list string.

## Value

A single BibTeX-ready author string.
