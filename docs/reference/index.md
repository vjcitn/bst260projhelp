# Package index

## Example data

- [`bst260_example()`](https://vjcitn.github.io/bst260projhelp/reference/bst260_example.md)
  : Path to a bundled example PDF

## Table extraction: word-geometry engine

For tables where pdftools::pdf_text() loses column structure (wrapped
cells, centred headers, rotated pages).

- [`pdf_page_words()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_page_words.md)
  : Per-page word coordinates for a PDF, with convenience columns

- [`pdf_add_lines()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_add_lines.md)
  : Group words on a page into text lines

- [`pdf_line_text()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_line_text.md)
  : Collapse a lined word data frame to one text string per line

- [`pdf_table_index()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_table_index.md)
  : Index the table captions in a PDF

- [`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md)
  : Extract one table from a PDF page by word geometry

- [`pdf_suggest_edges()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_suggest_edges.md)
  :

  Suggest column edges for
  [`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md)

- [`pdf_strip_footnote_letter()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_strip_footnote_letter.md)
  : Drop a trailing single-letter footnote marker from a string

## Table extraction: simple layouts

Line-based readers for tables that don’t need word geometry.

- [`pdf_caption_index()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_caption_index.md)
  : Index simple table captions ("Table N.")
- [`pdf_page_lines()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_page_lines.md)
  : Split a PDF page of plain text into lines
- [`pdf_parse_count_pct_row()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_parse_count_pct_row.md)
  : Parse a "label N (pct) N (pct) ..." table row
- [`pdf_read_count_pct_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_count_pct_table.md)
  : Read a simple "count (percent)" table from a PDF page
- [`pdf_read_wide_wrapped_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_wide_wrapped_table.md)
  : Read a wide table whose cells wrap across several text lines

## HTML scraping: PMC article pages

Generalized rvest-based extraction from PMC-style HTML articles:
citation\_\* meta tags, TabN/FigN elements, and AbsN subsections.

- [`html_article_meta()`](https://vjcitn.github.io/bst260projhelp/reference/html_article_meta.md)
  :

  Extract standard scholarly metadata from an article's `<meta>` tags

- [`html_table_index()`](https://vjcitn.github.io/bst260projhelp/reference/html_table_index.md)
  : Index of an article's tables, by element id

- [`html_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/html_read_table.md)
  : Read one table from an article as a data frame

- [`html_figure_caption()`](https://vjcitn.github.io/bst260projhelp/reference/html_figure_caption.md)
  : Extract a figure's caption text

- [`html_figure_image()`](https://vjcitn.github.io/bst260projhelp/reference/html_figure_image.md)
  : Extract a figure's image URL

- [`html_abstract()`](https://vjcitn.github.io/bst260projhelp/reference/html_abstract.md)
  : Extract an article's structured abstract

## Bibliography: shared helpers

- [`bib_escape()`](https://vjcitn.github.io/bst260projhelp/reference/bib_escape.md)
  : Escape BibTeX special characters in plain-text fields
- [`bib_entry()`](https://vjcitn.github.io/bst260projhelp/reference/bib_entry.md)
  : Render one BibTeX entry from a key, type and named field vector
- [`bib_html_list()`](https://vjcitn.github.io/bst260projhelp/reference/bib_html_list.md)
  : Render a bibliography as an HTML ordered list, with DOI links
- [`bib_cite_link()`](https://vjcitn.github.io/bst260projhelp/reference/bib_cite_link.md)
  : Link in-text to a bibliography entry, with a round-trip backlink
- [`write_bib()`](https://vjcitn.github.io/bst260projhelp/reference/write_bib.md)
  : Write a BibTeX string to file

## Bibliography: RAND-style (per-chapter, author-year)

- [`rand_chapter_ref_pages()`](https://vjcitn.github.io/bst260projhelp/reference/rand_chapter_ref_pages.md)
  : Locate a chapter's reference-list pages
- [`rand_chapter_ref_lines()`](https://vjcitn.github.io/bst260projhelp/reference/rand_chapter_ref_lines.md)
  : Extract a chapter's reference-list lines, with running heads removed
- [`rand_split_entries()`](https://vjcitn.github.io/bst260projhelp/reference/rand_split_entries.md)
  : Split reference-list lines into individual entries
- [`rand_parse_names()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_names.md)
  : Parse a RAND-style author list into one row per author
- [`rand_split_title()`](https://vjcitn.github.io/bst260projhelp/reference/rand_split_title.md)
  : Split the remainder of an unquoted (book/report) entry into title
  parts
- [`rand_parse_entry()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_entry.md)
  : Parse one RAND-style reference entry into structured fields
- [`rand_ref_key()`](https://vjcitn.github.io/bst260projhelp/reference/rand_ref_key.md)
  : Citation key for a parsed RAND reference entry
- [`rand_parse_chapter_refs()`](https://vjcitn.github.io/bst260projhelp/reference/rand_parse_chapter_refs.md)
  : Parse an entire chapter's reference list into keyed entries
- [`rand_refs_table()`](https://vjcitn.github.io/bst260projhelp/reference/rand_refs_table.md)
  : Flatten a list of parsed RAND entries into a data frame
- [`rand_cite_keys()`](https://vjcitn.github.io/bst260projhelp/reference/rand_cite_keys.md)
  : Resolve author-year in-text citations to reference keys
- [`rand_resolve_citations()`](https://vjcitn.github.io/bst260projhelp/reference/rand_resolve_citations.md)
  : Resolve a vector of in-text citation strings to reference entries
- [`rand_link_citations()`](https://vjcitn.github.io/bst260projhelp/reference/rand_link_citations.md)
  : Link one citation column of a table to reference entries
- [`rand_to_bibtex()`](https://vjcitn.github.io/bst260projhelp/reference/rand_to_bibtex.md)
  : Export a list of parsed RAND entries as BibTeX
- [`rand_to_csl_json()`](https://vjcitn.github.io/bst260projhelp/reference/rand_to_csl_json.md)
  : Export a list of parsed RAND entries as CSL-JSON
- [`rand_crossref_doi()`](https://vjcitn.github.io/bst260projhelp/reference/rand_crossref_doi.md)
  : Look up a DOI for a parsed reference entry via Crossref
- [`rand_resolve_dois()`](https://vjcitn.github.io/bst260projhelp/reference/rand_resolve_dois.md)
  : Resolve DOIs for a list of parsed entries, with an on-disk cache
- [`rand_bibliography_html()`](https://vjcitn.github.io/bst260projhelp/reference/rand_bibliography_html.md)
  : Render a list of parsed RAND entries as a rendered bibliography

## Bibliography: Vancouver-style (numbered)

- [`vancouver_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_ref_entries.md)
  : Parse a numbered Vancouver-style reference list
- [`vancouver_authors()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_authors.md)
  : Convert a Vancouver-style author list to BibTeX author form
- [`vancouver_parse_article()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_parse_article.md)
  : Parse a Vancouver-style journal-article reference
- [`vancouver_parse_web()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_parse_web.md)
  : Parse a Vancouver-style web-page reference
- [`vancouver_to_bibtex()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_to_bibtex.md)
  : Export a list of Vancouver-style (plus any hand-curated) entries as
  BibTeX
- [`vancouver_bibliography_html()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_bibliography_html.md)
  : Render a list of Vancouver-style (plus curated) entries as a
  rendered bibliography
- [`vancouver_find_numeric_citations()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_find_numeric_citations.md)
  : Find numbered in-text citations in a PDF, for cross-checking
- [`vancouver_check_urls()`](https://vjcitn.github.io/bst260projhelp/reference/vancouver_check_urls.md)
  : Check that cited URLs are still live

## Bibliography: PMC-style (numbered, pre-structured)

- [`pmc_ref_entries()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_ref_entries.md)
  : Parse a PMC-style reference list
- [`pmc_find_citations()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_find_citations.md)
  : Find in-text citation links in an article's body
- [`pmc_bibliography_html()`](https://vjcitn.github.io/bst260projhelp/reference/pmc_bibliography_html.md)
  : Render a PMC reference list as a rendered bibliography
