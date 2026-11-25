# Parse one RAND-style reference entry into structured fields

Distinguishes quoted titles (article / incollection) from unquoted
titles (book / techreport / misc) and extracts authors, title,
container, volume/issue, publisher or institution, year and a same-year
disambiguation suffix (`"1998a"`), plus any URL.

## Usage

``` r
rand_parse_entry(e)
```

## Arguments

- e:

  A single reference-entry string, as produced by
  [`rand_split_entries()`](https://vjcitn.github.io/bst260projhelp/reference/rand_split_entries.md).

## Value

A list of parsed fields: `raw`, `type`, `authors` (data frame), `title`,
`container`, `volume`, `number`, `month`, `publisher`, `institution`,
`edition`, `note`, `url`, `doi`, `year`, `suffix`.
