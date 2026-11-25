# Locate a chapter's reference-list pages

Locate a chapter's reference-list pages

## Usage

``` r
rand_chapter_ref_pages(pdf_file, chapter)
```

## Arguments

- pdf_file:

  Path to a PDF file.

- chapter:

  Integer chapter number.

## Value

A named integer vector `c(start, end)`: the PDF page holding
`"Chapter <chapter> References"` and the page where the next chapter's
`"CHAPTER <chapter+1>"` heading begins.
