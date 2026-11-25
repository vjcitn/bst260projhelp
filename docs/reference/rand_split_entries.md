# Split reference-list lines into individual entries

An entry is taken to be complete when its last line ends with a period
(that isn't a mid-name initial like `"D."`) or is a bare URL; the next
entry starts where a line beginning with a capital letter follows a
completed one. Hyphenated line-end breaks are rejoined.

## Usage

``` r
rand_split_entries(lines)
```

## Arguments

- lines:

  Character vector as returned by
  [`rand_chapter_ref_lines()`](https://vjcitn.github.io/bst260projhelp/reference/rand_chapter_ref_lines.md).

## Value

Character vector, one re-joined string per reference entry.
