# Parse a RAND-style author list into one row per author

Handles `"Last, First, and First Last"` style lists: the first author is
`"Family, Given"`, later authors are `"First Last"`.

## Usage

``` r
rand_parse_names(seg)
```

## Arguments

- seg:

  The author segment of a reference entry.

## Value

A data frame with columns `family`, `given`, `suffix`, one row per
author.
