# bst260projhelp: table extraction and bibliographic integrity for PDF reports

Two families of tools, bundled together because they recur on the same
kind of source document (a long government/NGO report distributed only
as PDF):

## Details

- **Table extraction** (`pdf_*`): recovering structured tables from PDF
  pages, either by simple line-based parsing when a table doesn't wrap
  ([`pdf_read_count_pct_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_count_pct_table.md)),
  or by clustering word coordinates when it does
  ([`pdf_read_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_table.md),
  [`pdf_read_wide_wrapped_table()`](https://vjcitn.github.io/bst260projhelp/reference/pdf_read_wide_wrapped_table.md)).

- **Bibliographic integrity** (`rand_*`, `vancouver_*`): parsing a
  report's own reference list, resolving its in-text citations against
  that list, and exporting the result as BibTeX or CSL-JSON so it can be
  checked, reused or linked. Two citation styles are covered, matching
  the two worked examples: `rand_*` for RAND-style per-chapter,
  author-year reference lists, `vancouver_*` for numbered
  Vancouver-style reference lists.

See
[`vignette("gun-legislation", package = "bst260projhelp")`](https://vjcitn.github.io/bst260projhelp/articles/gun-legislation.md)
and
[`vignette("waterborne-disease", package = "bst260projhelp")`](https://vjcitn.github.io/bst260projhelp/articles/waterborne-disease.md)
for worked examples on the two bundled reports (see
[`bst260_example()`](https://vjcitn.github.io/bst260projhelp/reference/bst260_example.md)).

## See also

Useful links:

- <https://github.com/vjcitn/bst260projhelp>

- Report bugs at <https://github.com/vjcitn/bst260projhelp/issues>

## Author

**Maintainer**: Vincent Carey <stvjc@channing.harvard.edu>

Authors:

- Vincent Carey <stvjc@channing.harvard.edu>
