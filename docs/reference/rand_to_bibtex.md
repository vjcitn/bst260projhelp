# Export a list of parsed RAND entries as BibTeX

Export a list of parsed RAND entries as BibTeX

## Usage

``` r
rand_to_bibtex(refs)
```

## Arguments

- refs:

  A list of parsed entries, as from
  [`rand_parse_chapter_refs()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_chapter_refs.md)
  (or a subset of one).

## Value

A single character string of BibTeX entries separated by blank lines.
