# Parse a Vancouver-style journal-article reference

Expects the form
`"Authors. Title. Journal. YYYY;vol(issue):pages. doi:..."`.

## Usage

``` r
vancouver_parse_article(e, num)
```

## Arguments

- e:

  The entry text, as from
  [`vancouver_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_ref_entries.md).

- num:

  The reference number (used only in the error message if parsing
  fails).

## Value

A list with `type = "article"`, `num`, `author`, `title`, `journal`,
`year`, `volume`, `number`, `pages`, `doi`.
