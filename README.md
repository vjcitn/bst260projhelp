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
