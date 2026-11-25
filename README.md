# bst260projhelp

## Overview

The final projects for BST260 will consist of pkgdown sites addressing
data science concerns with public datasets.  Objectives include

- demonstrating understanding of how the R package and vignette concepts can be
leveraged via **pkgdown and GitHub pages** to
produce globally accessible web pages with your **scientific goals and findings**
- illustrating methods of **information transformation**, such as extracting
tables and figures from web sites or publications and repurposing them
for communication and data analysis
- consistently clarifying **provenance of materials** used in your
project and future research, including efficient production of
usable **bibliographic references**

Note: This package and pkgdown site were created through prompting claude
code with Sonnet 5, and revising results.

## Details

This repository provides documentation, functions, and
example public documents to help with recurring tasks that
arise when working with PDF reports or journal-article HTML.

1. **Table extraction** -- recovering structured tables from PDF pages,
   whether they're laid out simply (one row per text line) or awkwardly
   (wrapped cells, centred columns, rotated pages), or from an HTML
   article's own `<table>` elements.
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

A third mode works from HTML instead of PDF: `rvest`-based scraping of
a PMC journal-article page, where both the tables and the reference
list are already machine-structured (a real `<table>` element; a
reference list where every in-text citation marker is itself a link
straight to its entry), so the work is reading the right elements
correctly rather than reconstructing structure from plain text or
page geometry.

Three worked examples are bundled as package data and vignettes:

- a RAND report on gun policy research (`vignette("gun-legislation")`),
  with a RAND-style, per-chapter, author-year bibliography;
- a CDC waterborne disease surveillance report
  (`vignette("waterborne-disease")`), with a numbered (Vancouver-style)
  bibliography;
- a PMC journal article on stroke mortality (`vignette("html-scraping")`),
  with its own pre-structured, numbered reference list.

## Installation

```r
# install.packages("devtools") 
devtools::install_github("vjcitn/bst260projhelp", build_vignettes = TRUE)
```

## Origin

The functions in `R/` were generalized from exploratory scripts written
against these specific documents; those original scripts (and the
source PDFs/HTML) are kept in `data-raw/` for reference. See
`data-raw/gunleg/README.txt` and `data-raw/waterborne/README.txt` for
the project prompts the PDF-extraction functions were written to
answer; the HTML-scraping functions were generalized directly from the
PMC article cached at `data-raw/htmlscrape/`.
