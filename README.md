# bst260projhelp

Tools for two recurring tasks when working with long PDF reports:

1. **Table extraction** -- recovering structured tables from PDF pages,
   whether they're laid out simply (one row per text line) or awkwardly
   (wrapped cells, centred columns, rotated pages).
2. **Bibliographic integrity** -- parsing a report's own reference list,
   resolving its in-text citations against that list, and exporting the
   result as BibTeX or CSL-JSON, so that a table of cited studies (or a
   curated list of cited systems/datasets) can be checked rather than
   taken on faith.

Table extraction comes in two flavors, matched to how awkward a table's
layout is:

- **Simple layouts** (`pdf_read_count_pct_table()`,
  `pdf_read_wide_wrapped_table()` and friends) work line-by-line off
  `pdftools::pdf_text()`, which is enough when each table row is
  already one clean line of text.
- **Word-geometry extraction** (`pdf_read_table()` and friends) is for
  tables where that breaks down -- wrapped cells, centred rather than
  left-aligned headers, or records with no blank line between them.
  Instead of plain text, it reads `pdftools::pdf_data()`, which gives
  the x/y position of every individual word on the page. From those
  coordinates it reconstructs the table itself: clustering words into
  text lines by vertical position, then into columns by their
  horizontal position (an edge or centre you supply), then grouping
  lines back into records. "Word-geometry" just names this: the table
  structure is recovered from where words sit on the page, not from
  line breaks in the extracted text.

Two worked examples are bundled as package data and vignettes:

- a RAND report on gun policy research (`vignette("gun-legislation")`),
  with a RAND-style, per-chapter, author-year bibliography;
- a CDC waterborne disease surveillance report
  (`vignette("waterborne-disease")`), with a numbered (Vancouver-style)
  bibliography.

## Installation

```r
# install.packages("devtools")
devtools::install_github("vjcitn/bst260projhelp", build_vignettes = TRUE)
```

## Origin

The functions in `R/` were generalized from exploratory scripts written
against these two specific PDFs; those original scripts (and the source
PDFs) are kept in `data-raw/` for reference. See `data-raw/gunleg/README.txt`
and `data-raw/waterborne/README.txt` for the project prompts they were
written to answer.
