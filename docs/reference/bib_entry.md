# Render one BibTeX entry from a key, type and named field vector

Fields that are `NA` or empty are dropped. Fields named `url`, `doi`,
`urldate`, `title` or `author` are written verbatim (titles and author
lists are expected to already carry any brace-protection they need);
every other field is passed through
[`bib_escape()`](https://vjcitn.github.io/bst260projhelp/reference/bib_escape.md).

## Usage

``` r
bib_entry(key, type, fields)
```

## Arguments

- key:

  BibTeX citation key.

- type:

  BibTeX entry type, e.g. `"article"`, `"book"`, `"misc"`.

- fields:

  A named character vector of field values.

## Value

A single string, the formatted `@type{key, ...}` entry.
