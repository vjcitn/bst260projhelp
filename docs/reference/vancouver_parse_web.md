# Parse a Vancouver-style web-page reference

Expects the form
`"Title. YYYY MM/DD/YYYY [cited YYYY MM/DD]; Available from: URL"`.

## Usage

``` r
vancouver_parse_web(e, num)
```

## Arguments

- e:

  The entry text, as from
  [`vancouver_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_ref_entries.md).

- num:

  The reference number (used only in the error message if parsing
  fails).

## Value

A list with `type = "misc"`, `num`, `title`, `year`, `url`, `author`
(inferred from the URL host when recognizable, else `NA`), `note`,
`urldate`, `annote`.
