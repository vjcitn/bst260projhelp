# Extract a chapter's reference-list lines, with running heads removed

Extract a chapter's reference-list lines, with running heads removed

## Usage

``` r
rand_chapter_ref_lines(pdf_file, chapter, chapter_title)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- chapter:

  Integer chapter number.

- chapter_title:

  The chapter's running-head title text, e.g. `"Concealed-Carry Laws"`,
  so it can be filtered out.

## Value

Character vector of reference-list lines, in order.
