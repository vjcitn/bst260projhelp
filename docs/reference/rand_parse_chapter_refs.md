# Parse an entire chapter's reference list into keyed entries

Convenience wrapper chaining
[`rand_chapter_ref_lines()`](https://vjcitn.github.io/bst260projhelp/reference/rand_chapter_ref_lines.md),
[`rand_split_entries()`](https://vjcitn.github.io/bst260projhelp/reference/rand_split_entries.md)
and
[`rand_parse_entry()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_entry.md),
and assigning a unique citation key (via
[`rand_ref_key()`](https://vjcitn.github.io/bst260projhelp/reference/rand_ref_key.md),
de-duplicated with
[`make.unique()`](https://rdrr.io/r/base/make.unique.html)) to each
entry.

## Usage

``` r
rand_parse_chapter_refs(pdf_file, chapter, chapter_title)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- chapter:

  Integer chapter number.

- chapter_title:

  The chapter's running-head title text.

## Value

A list of parsed entries (see
[`rand_parse_entry()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_entry.md)),
each with an added `key` element.
