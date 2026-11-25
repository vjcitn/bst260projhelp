# Write a BibTeX string to file

Write a BibTeX string to file

## Usage

``` r
write_bib(bib, path)
```

## Arguments

- bib:

  A character string as produced by
  [`bib_entry()`](https://vjcitn.github.io/bst260projhelp/reference/bib_entry.md)
  or one of the
  [`rand_to_bibtex()`](https://vjcitn.github.io/bst260projhelp/reference/rand_to_bibtex.md)
  /
  [`vancouver_to_bibtex()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_to_bibtex.md)
  exporters (entries separated by blank lines).

- path:

  Destination file path.

## Value

`path`, invisibly.
