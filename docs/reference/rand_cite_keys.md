# Resolve author-year in-text citations to reference keys

Handles `"A (1999)"`, `"A and B (1999)"`, `"A, B, and C (1999)"`,
`"A et al. (2020)"`, and semicolon-separated lists of these such as
`"Lott (1998a, 1998b, 2000); Lott and Whitley (2003)"`.

## Usage

``` r
rand_cite_keys(s)
```

## Arguments

- s:

  A single in-text citation string.

## Value

A character vector of reference keys, one per semicolon-separated
citation (with multiple years in one citation expanded to multiple
keys).
