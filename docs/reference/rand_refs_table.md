# Flatten a list of parsed RAND entries into a data frame

Flatten a list of parsed RAND entries into a data frame

## Usage

``` r
rand_refs_table(refs)
```

## Arguments

- refs:

  A list of parsed entries as returned by
  [`rand_parse_chapter_refs()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_chapter_refs.md).

## Value

A data frame with one row per entry: `key`, `type`, `year`, `title`,
`container`, `volume`, `number`, `publisher`, `institution`, `url`,
`doi`, `first_author`, `n_authors`, `raw`.
